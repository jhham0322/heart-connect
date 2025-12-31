using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Win32;

namespace FlutterControlPanel
{
    public class DeviceMonitorForm : Form
    {
        private PictureBox screenBox;
        private RichTextBox logBox;
        private Button btnCopyScreen;
        private Button btnSaveScreen;
        private Button btnCopyLog;
        private Button btnRefresh;
        private Button btnStartLog;
        private Button btnStopLog;
        private ToolStripStatusLabel lblStatus;
        private System.Windows.Forms.Timer refreshTimer;
        private Process logcatProcess;
        private string adbPath;
        private string deviceId;
        private StringBuilder logBuffer = new StringBuilder();
        private bool isCapturing = false;

        public DeviceMonitorForm(string adbPath) : this(adbPath, "") { }
        
        public DeviceMonitorForm(string adbPath, string deviceId)
        {
            this.adbPath = adbPath;
            this.deviceId = deviceId ?? "";
            InitializeUI();
            StartScreenCapture();
        }
        
        // ADB 명령에 디바이스 ID 추가
        private string GetAdbArgs(string baseArgs)
        {
            if (!string.IsNullOrEmpty(deviceId))
            {
                return $"-s {deviceId} {baseArgs}";
            }
            return baseArgs;
        }

        private void InitializeUI()
        {
            this.Text = "📱 Device Monitor - Screen & Log";
            this.Size = new Size(1000, 700);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.BackColor = Color.FromArgb(45, 45, 45);

            // Split panel
            SplitContainer splitContainer = new SplitContainer();
            splitContainer.Dock = DockStyle.Fill;
            splitContainer.SplitterDistance = 400;
            splitContainer.BackColor = Color.FromArgb(60, 60, 60);
            this.Controls.Add(splitContainer);

            // Left Panel - Screen
            Panel leftPanel = new Panel();
            leftPanel.Dock = DockStyle.Fill;
            leftPanel.BackColor = Color.FromArgb(30, 30, 30);
            splitContainer.Panel1.Controls.Add(leftPanel);

            Label lblScreen = new Label();
            lblScreen.Text = "📱 Phone Screen";
            lblScreen.ForeColor = Color.White;
            lblScreen.Font = new Font("Segoe UI", 12, FontStyle.Bold);
            lblScreen.Dock = DockStyle.Top;
            lblScreen.Height = 30;
            lblScreen.TextAlign = ContentAlignment.MiddleCenter;
            leftPanel.Controls.Add(lblScreen);

            screenBox = new PictureBox();
            screenBox.Dock = DockStyle.Fill;
            screenBox.SizeMode = PictureBoxSizeMode.Zoom;
            screenBox.BackColor = Color.Black;
            leftPanel.Controls.Add(screenBox);
            screenBox.BringToFront();

            // Left Bottom - Controls
            Panel leftBottom = new Panel();
            leftBottom.Dock = DockStyle.Bottom;
            leftBottom.Height = 50;
            leftBottom.BackColor = Color.FromArgb(50, 50, 50);
            leftPanel.Controls.Add(leftBottom);

            btnRefresh = new Button();
            btnRefresh.Text = "🔄 Refresh";
            btnRefresh.Size = new Size(100, 35);
            btnRefresh.Location = new Point(10, 8);
            btnRefresh.BackColor = Color.FromArgb(129, 212, 250);
            btnRefresh.FlatStyle = FlatStyle.Flat;
            btnRefresh.Click += (s, e) => CaptureScreen();
            leftBottom.Controls.Add(btnRefresh);

            btnCopyScreen = new Button();
            btnCopyScreen.Text = "📋 Copy Screen";
            btnCopyScreen.Size = new Size(120, 35);
            btnCopyScreen.Location = new Point(120, 8);
            btnCopyScreen.BackColor = Color.FromArgb(165, 214, 167);
            btnCopyScreen.FlatStyle = FlatStyle.Flat;
            btnCopyScreen.Click += BtnCopyScreen_Click;
            leftBottom.Controls.Add(btnCopyScreen);

            btnSaveScreen = new Button();
            btnSaveScreen.Text = "💾 Save";
            btnSaveScreen.Size = new Size(100, 35);
            btnSaveScreen.Location = new Point(250, 8);
            btnSaveScreen.BackColor = Color.FromArgb(255, 183, 77);
            btnSaveScreen.FlatStyle = FlatStyle.Flat;
            btnSaveScreen.Click += BtnSaveScreen_Click;
            leftBottom.Controls.Add(btnSaveScreen);

            // Right Panel - Log
            Panel rightPanel = new Panel();
            rightPanel.Dock = DockStyle.Fill;
            rightPanel.BackColor = Color.FromArgb(30, 30, 30);
            splitContainer.Panel2.Controls.Add(rightPanel);

            Label lblLog = new Label();
            lblLog.Text = "📝 Logcat (Flutter)";
            lblLog.ForeColor = Color.White;
            lblLog.Font = new Font("Segoe UI", 12, FontStyle.Bold);
            lblLog.Dock = DockStyle.Top;
            lblLog.Height = 30;
            lblLog.TextAlign = ContentAlignment.MiddleCenter;
            rightPanel.Controls.Add(lblLog);

            logBox = new RichTextBox();
            logBox.Dock = DockStyle.Fill;
            logBox.BackColor = Color.FromArgb(20, 20, 20);
            logBox.ForeColor = Color.LightGreen;
            logBox.Font = new Font("Consolas", 9);
            logBox.ReadOnly = true;
            rightPanel.Controls.Add(logBox);
            logBox.BringToFront();

            // Right Bottom - Controls
            Panel rightBottom = new Panel();
            rightBottom.Dock = DockStyle.Bottom;
            rightBottom.Height = 50;
            rightBottom.BackColor = Color.FromArgb(50, 50, 50);
            rightPanel.Controls.Add(rightBottom);

            btnStartLog = new Button();
            btnStartLog.Text = "▶ Start Log";
            btnStartLog.Size = new Size(100, 35);
            btnStartLog.Location = new Point(10, 8);
            btnStartLog.BackColor = Color.FromArgb(129, 199, 132);
            btnStartLog.FlatStyle = FlatStyle.Flat;
            btnStartLog.Click += BtnStartLog_Click;
            rightBottom.Controls.Add(btnStartLog);

            btnStopLog = new Button();
            btnStopLog.Text = "⏹ Stop Log";
            btnStopLog.Size = new Size(100, 35);
            btnStopLog.Location = new Point(120, 8);
            btnStopLog.BackColor = Color.FromArgb(255, 138, 101);
            btnStopLog.FlatStyle = FlatStyle.Flat;
            btnStopLog.Click += BtnStopLog_Click;
            rightBottom.Controls.Add(btnStopLog);

            btnCopyLog = new Button();
            btnCopyLog.Text = "📋 Copy Log";
            btnCopyLog.Size = new Size(100, 35);
            btnCopyLog.Location = new Point(230, 8);
            btnCopyLog.BackColor = Color.FromArgb(165, 214, 167);
            btnCopyLog.FlatStyle = FlatStyle.Flat;
            btnCopyLog.Click += BtnCopyLog_Click;
            rightBottom.Controls.Add(btnCopyLog);

            // Status bar
            StatusStrip statusStrip = new StatusStrip();
            statusStrip.BackColor = Color.FromArgb(40, 40, 40);
            lblStatus = new ToolStripStatusLabel("Ready");
            lblStatus.ForeColor = Color.White;
            statusStrip.Items.Add(lblStatus);
            this.Controls.Add(statusStrip);

            // Screen refresh timer (2 seconds)
            refreshTimer = new System.Windows.Forms.Timer();
            refreshTimer.Interval = 2000;
            refreshTimer.Tick += (s, e) => CaptureScreen();
        }

        private void StartScreenCapture()
        {
            CaptureScreen();
            refreshTimer.Start();
        }

        private async void CaptureScreen()
        {
            if (isCapturing) return;
            isCapturing = true;

            try
            {
                lblStatus.Text = "Capturing screen...";
                
                await Task.Run(() =>
                {
                    try
                    {
                        // Check if adb exists
                        if (!File.Exists(adbPath))
                        {
                            this.Invoke(new Action(() =>
                            {
                                lblStatus.Text = $"ADB not found at: {adbPath}";
                            }));
                            return;
                        }

                        string tempPath = Path.Combine(Path.GetTempPath(), "screen_capture.png");
                        string phonePath = "/sdcard/screen_capture.png";

                        // Step 1: Capture screen on phone
                        var psiCapture = new ProcessStartInfo
                        {
                            FileName = adbPath,
                            Arguments = GetAdbArgs($"shell screencap -p {phonePath}"),
                            UseShellExecute = false,
                            CreateNoWindow = true,
                            RedirectStandardError = true
                        };
                        
                        using (var proc = Process.Start(psiCapture))
                        {
                            proc.WaitForExit(10000);
                            if (proc.ExitCode != 0)
                            {
                                string error = proc.StandardError.ReadToEnd();
                                this.Invoke(new Action(() =>
                                {
                                    lblStatus.Text = $"Capture failed: {error}";
                                }));
                                return;
                            }
                        }

                        // Step 2: Pull file from phone
                        var psiPull = new ProcessStartInfo
                        {
                            FileName = adbPath,
                            Arguments = GetAdbArgs($"pull {phonePath} \"{tempPath}\""),
                            UseShellExecute = false,
                            CreateNoWindow = true,
                            RedirectStandardError = true
                        };
                        
                        using (var proc = Process.Start(psiPull))
                        {
                            proc.WaitForExit(10000);
                            if (proc.ExitCode != 0)
                            {
                                string error = proc.StandardError.ReadToEnd();
                                this.Invoke(new Action(() =>
                                {
                                    lblStatus.Text = $"Pull failed: {error}";
                                }));
                                return;
                            }
                        }

                        // Step 3: Load image
                        if (File.Exists(tempPath))
                        {
                            try
                            {
                                using (var stream = new FileStream(tempPath, FileMode.Open, FileAccess.Read))
                                {
                                    Image img = Image.FromStream(stream);
                                    this.Invoke(new Action(() =>
                                    {
                                        screenBox.Image?.Dispose();
                                        screenBox.Image = (Image)img.Clone();
                                        lblStatus.Text = $"Screen captured at {DateTime.Now:HH:mm:ss}";
                                    }));
                                }
                                File.Delete(tempPath);
                            }
                            catch (Exception imgEx)
                            {
                                this.Invoke(new Action(() =>
                                {
                                    lblStatus.Text = $"Image load error: {imgEx.Message}";
                                }));
                            }
                        }
                        else
                        {
                            this.Invoke(new Action(() =>
                            {
                                lblStatus.Text = "Screenshot file not found. Is device connected?";
                            }));
                        }

                        // Cleanup phone file
                        var psiClean = new ProcessStartInfo
                        {
                            FileName = adbPath,
                            Arguments = GetAdbArgs($"shell rm {phonePath}"),
                            UseShellExecute = false,
                            CreateNoWindow = true
                        };
                        Process.Start(psiClean)?.WaitForExit(2000);
                    }
                    catch (Exception ex)
                    {
                        this.Invoke(new Action(() =>
                        {
                            lblStatus.Text = $"Error: {ex.Message}";
                        }));
                    }
                });
            }
            finally
            {
                isCapturing = false;
            }
        }

        private void BtnStartLog_Click(object sender, EventArgs e)
        {
            if (logcatProcess != null && !logcatProcess.HasExited)
            {
                MessageBox.Show("Logcat is already running.");
                return;
            }

            logBox.Clear();
            logBuffer.Clear();
            lblStatus.Text = "Starting logcat...";

            try
            {
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = adbPath;
                psi.Arguments = GetAdbArgs("logcat -v time flutter:V *:S");
                psi.UseShellExecute = false;
                psi.RedirectStandardOutput = true;
                psi.RedirectStandardError = true;
                psi.CreateNoWindow = true;
                psi.StandardOutputEncoding = Encoding.UTF8;

                logcatProcess = new Process();
                logcatProcess.StartInfo = psi;
                logcatProcess.OutputDataReceived += (s, ev) =>
                {
                    if (ev.Data != null)
                    {
                        logBuffer.AppendLine(ev.Data);
                        try
                        {
                            this.Invoke(new Action(() =>
                            {
                                logBox.AppendText(ev.Data + Environment.NewLine);
                                logBox.ScrollToCaret();
                            }));
                        }
                        catch { }
                    }
                };
                logcatProcess.ErrorDataReceived += (s, ev) =>
                {
                    if (ev.Data != null)
                    {
                        try
                        {
                            this.Invoke(new Action(() =>
                            {
                                logBox.AppendText("ERR: " + ev.Data + Environment.NewLine);
                            }));
                        }
                        catch { }
                    }
                };

                logcatProcess.Start();
                logcatProcess.BeginOutputReadLine();
                logcatProcess.BeginErrorReadLine();

                lblStatus.Text = "Logcat running...";
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error starting logcat: {ex.Message}");
            }
        }

        private void BtnStopLog_Click(object sender, EventArgs e)
        {
            if (logcatProcess != null && !logcatProcess.HasExited)
            {
                logcatProcess.Kill();
                logcatProcess = null;
                lblStatus.Text = "Logcat stopped.";
            }
        }

        private void BtnCopyScreen_Click(object sender, EventArgs e)
        {
            if (screenBox.Image != null)
            {
                Clipboard.SetImage(screenBox.Image);
                MessageBox.Show("Screen copied to clipboard!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            else
            {
                MessageBox.Show("No screen captured yet.", "Info", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }

        private void BtnSaveScreen_Click(object sender, EventArgs e)
        {
            if (screenBox.Image != null)
            {
                try
                {
                    string downloadsPath = GetDownloadsFolderPath();
                    string timestamp = DateTime.Now.ToString("yyyyMMdd_HH_mm_ss");
                    string fileName = $"ConnectHeart_{timestamp}.png";
                    string fullPath = Path.Combine(downloadsPath, fileName);

                    screenBox.Image.Save(fullPath, System.Drawing.Imaging.ImageFormat.Png);
                    MessageBox.Show($"Screen saved to:\n{fullPath}", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Failed to save: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            else
            {
                MessageBox.Show("No screen captured yet.", "Info", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }

        private void BtnCopyLog_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(logBox.Text))
            {
                Clipboard.SetText(logBox.Text);
                MessageBox.Show("Log copied to clipboard!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            else
            {
                MessageBox.Show("No log to copy.", "Info", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            refreshTimer?.Stop();
            if (logcatProcess != null && !logcatProcess.HasExited)
            {
                logcatProcess.Kill();
            }
            base.OnFormClosing(e);
        }

        private string GetDownloadsFolderPath()
        {
            try
            {
                // Check registry for user's download folder
                string keyName = @"Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders";
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(keyName))
                {
                    if (key != null)
                    {
                        // Look for the Downloads GUID
                        object val = key.GetValue("{374DE290-123F-4565-9164-39C4925E467B}");
                        if (val != null)
                        {
                            string path = val.ToString();
                            // Expand checks for %USERPROFILE% etc.
                            return Environment.ExpandEnvironmentVariables(path);
                        }
                    }
                }
            }
            catch { }

            // Fallback to default
            return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Downloads");
        }
    }
}
