using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using System.Threading;

namespace FlutterControlPanel
{
    public partial class Form1 : Form
    {
        private Process cmdProcess;
        private System.Windows.Forms.Timer autoReloadTimer;
        private RichTextBox outputBox;
        private Button btnRunWindows;
        private Button btnHotReload;
        private Button btnHotRestart;
        private CheckBox chkAutoReload;
        private NumericUpDown numInterval;
        private Button btnBuildAndroid;
        private ToolStripStatusLabel statusLabel;
        
        // Path to the Flutter project root
        // Assuming we build to WindowUI/FlutterControlPanel/bin/Release, the root is up 4 levels?
        // Let's just hardcode the path provided in user info or search for pubspec.yaml
        private string projectRoot = @"e:\work2025\App\ConnectHeart";

        public Form1()
        {
            InitializeComponent(); // Call the empty one to set basic properties
            SetupCustomUI();
            
            autoReloadTimer = new System.Windows.Forms.Timer();
            autoReloadTimer.Tick += AutoReloadTimer_Tick;
        }

        private void SetupCustomUI()
        {
            this.Text = "Heart Connect - Flutter Controller";
            this.Size = new Size(768, 1024); // Default size as requested
            this.BackColor = Color.FromArgb(245, 245, 245);

            try {
                string iconPath = Path.Combine(projectRoot, "assets", "icons", "app_icon.png");
                if (File.Exists(iconPath)) {
                    using (Bitmap bmp = new Bitmap(iconPath)) {
                        this.Icon = Icon.FromHandle(bmp.GetHicon());
                    }
                }
            } catch { /* Ignore icon errors */ }

            // 1. Controls Panel
            Panel controlPanel = new Panel();
            controlPanel.Dock = DockStyle.Top;
            controlPanel.Height = 180; // Increased height for two rows
            controlPanel.Padding = new Padding(10);
            controlPanel.BackColor = Color.White;
            this.Controls.Add(controlPanel);

            // Row 1: Execution Control
            // Run Windows Button
            btnRunWindows = new Button();
            btnRunWindows.Text = "▶ Run Windows";
            btnRunWindows.Size = new Size(140, 50);
            btnRunWindows.Location = new Point(10, 10);
            btnRunWindows.BackColor = Color.FromArgb(255, 138, 101); // Accent Coral
            btnRunWindows.ForeColor = Color.White;
            btnRunWindows.FlatStyle = FlatStyle.Flat;
            btnRunWindows.Font = new Font("Segoe UI", 10, FontStyle.Bold);
            btnRunWindows.Click += (s, e) => {
                 // Fast Run: Reuse existing packages/build
                 RunProcessChain("flutter run -d windows");
            };
            controlPanel.Controls.Add(btnRunWindows);

            // Hot Reload Button
            btnHotReload = new Button();
            btnHotReload.Text = "⚡ Hot Reload";
            btnHotReload.Size = new Size(140, 50);
            btnHotReload.Location = new Point(160, 10);
            btnHotReload.BackColor = Color.FromArgb(255, 204, 128); 
            btnHotReload.FlatStyle = FlatStyle.Flat;
            btnHotReload.Font = new Font("Segoe UI", 10, FontStyle.Bold);
            btnHotReload.Click += BtnHotReload_Click;
            btnHotReload.Enabled = false;
            controlPanel.Controls.Add(btnHotReload);

            // Hot Restart Button
            btnHotRestart = new Button();
            btnHotRestart.Text = "🔄 Hot Restart";
            btnHotRestart.Size = new Size(140, 50);
            btnHotRestart.Location = new Point(310, 10);
            btnHotRestart.BackColor = Color.FromArgb(144, 202, 249); 
            btnHotRestart.FlatStyle = FlatStyle.Flat;
            btnHotRestart.Font = new Font("Segoe UI", 10, FontStyle.Bold);
            btnHotRestart.Click += BtnHotRestart_Click;
            btnHotRestart.Enabled = false;
            controlPanel.Controls.Add(btnHotRestart);

            // Auto Reload Group (Wider)
            GroupBox grpAuto = new GroupBox();
            grpAuto.Text = "Auto Reload";
            grpAuto.Location = new Point(460, 5); // Shifted right
            grpAuto.Size = new Size(280, 60); // Compact height
            controlPanel.Controls.Add(grpAuto);

            chkAutoReload = new CheckBox();
            chkAutoReload.Text = "Enable";
            chkAutoReload.Location = new Point(15, 25);
            chkAutoReload.AutoSize = true;
            chkAutoReload.CheckedChanged += ChkAutoReload_CheckedChanged;
            grpAuto.Controls.Add(chkAutoReload);

            numInterval = new NumericUpDown();
            numInterval.Minimum = 1;
            numInterval.Maximum = 600;
            numInterval.Value = 3;
            numInterval.Location = new Point(100, 23);
            numInterval.Width = 60;
            grpAuto.Controls.Add(numInterval);

            Label lblSec = new Label();
            lblSec.Text = "sec";
            lblSec.Location = new Point(170, 25);
            grpAuto.Controls.Add(lblSec);

            // Row 2: Reinstall & Gen buttons
            int row2Y = 75;

            // Reinstall Packages Button (Clean, Pub Get, Run)
            Button btnReinstall = new Button();
            btnReinstall.Text = "📥 Reinstall Packages";
            btnReinstall.Size = new Size(180, 50);
            btnReinstall.Location = new Point(10, row2Y);
            btnReinstall.BackColor = Color.FromArgb(176, 190, 197);
            btnReinstall.FlatStyle = FlatStyle.Flat;
            btnReinstall.Font = new Font("Segoe UI", 10, FontStyle.Bold);
            btnReinstall.Click += (s, ev) => {
                // Full Clean & Reinstall
                RunProcessChain("flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter run -d windows");
            };
            controlPanel.Controls.Add(btnReinstall);

            // Gen & Run button
            Button btnGenRun = new Button();
            btnGenRun.Text = "🏗 Gen && Run";
            btnGenRun.Size = new Size(150, 50); 
            btnGenRun.Location = new Point(200, row2Y); 
            btnGenRun.BackColor = Color.FromArgb(207, 216, 220);
            btnGenRun.FlatStyle = FlatStyle.Flat;
            btnGenRun.Font = new Font("Segoe UI", 10, FontStyle.Bold);
            btnGenRun.Click += (s, ev) => {
                 RunProcessChain("dart run build_runner build --delete-conflicting-outputs && flutter run -d windows");
            };
            controlPanel.Controls.Add(btnGenRun);

            // Row 3: Log & Build Controls
            int row3Y = 135;

            // Clear Log Button
            Button btnClearLog = new Button();
            btnClearLog.Text = "🗑 Clear Log";
            btnClearLog.Size = new Size(120, 35);
            btnClearLog.Location = new Point(10, row3Y);
            btnClearLog.BackColor = Color.FromArgb(238, 238, 238);
            btnClearLog.FlatStyle = FlatStyle.Flat;
            btnClearLog.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            btnClearLog.Click += (s, e) => outputBox.Clear();
            controlPanel.Controls.Add(btnClearLog);

            // Copy Log Button
            Button btnCopyLog = new Button();
            btnCopyLog.Text = "📋 Copy Log";
            btnCopyLog.Size = new Size(120, 35);
            btnCopyLog.Location = new Point(140, row3Y);
            btnCopyLog.BackColor = Color.FromArgb(238, 238, 238);
            btnCopyLog.FlatStyle = FlatStyle.Flat;
            btnCopyLog.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            btnCopyLog.Click += (s, e) => {
                if (!string.IsNullOrEmpty(outputBox.Text)) {
                    Clipboard.SetText(outputBox.Text);
                    MessageBox.Show("Log copied to clipboard!");
                }
            };
            controlPanel.Controls.Add(btnCopyLog);

            // Build Android Button
            btnBuildAndroid = new Button();
            btnBuildAndroid.Text = "📱 Build Android";
            btnBuildAndroid.Size = new Size(120, 40);
            btnBuildAndroid.RightToLeft = RightToLeft.No; // Just alignment
            btnBuildAndroid.Location = new Point(controlPanel.Width - 140, 10);
            btnBuildAndroid.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            btnBuildAndroid.BackColor = Color.FromArgb(129, 199, 132);
            btnBuildAndroid.FlatStyle = FlatStyle.Flat;
            btnBuildAndroid.Click += BtnBuildAndroid_Click;
            controlPanel.Controls.Add(btnBuildAndroid);

            // 2. Output Box (Enable Copy)
            outputBox = new RichTextBox();
            outputBox.Dock = DockStyle.Fill;
            outputBox.Font = new Font("Consolas", 10);
            outputBox.BackColor = Color.FromArgb(30, 30, 30);
            outputBox.ForeColor = Color.FromArgb(200, 200, 200);
            outputBox.ReadOnly = true; 
            // ShortcutsEnabled allows Ctrl+C even if ReadOnly
            outputBox.ShortcutsEnabled = true; 
            this.Controls.Add(outputBox);
            
            // Status Strip
            StatusStrip statusStrip = new StatusStrip();
            statusLabel = new ToolStripStatusLabel();
            statusLabel.Text = "Ready";
            statusStrip.Items.Add(statusLabel);
            this.Controls.Add(statusStrip);
        }

        private void RunProcessChain(string commandChain)
        {
            if (cmdProcess != null && !cmdProcess.HasExited)
            {
                DialogResult dialogResult = MessageBox.Show("Stop current process?", "Process Running", MessageBoxButtons.YesNo);
                if(dialogResult == DialogResult.Yes)
                {
                    StopProcess();
                }
                else
                {
                    return;
                }
            }

            StartProcess("cmd", "/c " + commandChain);
            btnRunWindows.Text = "⏹ Stop";
            btnHotReload.Enabled = true;
            btnHotRestart.Enabled = true;
        }

        private void BtnRunWindows_Click(object sender, EventArgs e)
        {
             // Fallback or explicit handler if needed, now replaced by lambda above
             RunProcessChain("flutter run -d windows");
        }

        private void BtnHotReload_Click(object sender, EventArgs e)
        {
            TriggerHotReload();
        }

        private void BtnHotRestart_Click(object sender, EventArgs e)
        {
            if (cmdProcess != null && !cmdProcess.HasExited)
            {
                // Flutter expects 'R' for hot restart
                cmdProcess.StandardInput.WriteLine("R");
                Log("Sent Hot Restart command (R)");
            }
            else
            {
                Log("Process is not running.");
            }
        }

        private void TriggerHotReload()
        {
            if (cmdProcess != null && !cmdProcess.HasExited)
            {
                // Flutter expects 'r' or 'R' in stdin
                cmdProcess.StandardInput.WriteLine("r");
                Log("Sent Hot Reload command (r)");
            }
            else
            {
                Log("Process is not running.");
            }
        }

        private void ChkAutoReload_CheckedChanged(object sender, EventArgs e)
        {
            if (chkAutoReload.Checked)
            {
                autoReloadTimer.Interval = (int)numInterval.Value * 1000;
                autoReloadTimer.Start();
                Log($"Auto reload started. Interval: {numInterval.Value}s");
            }
            else
            {
                autoReloadTimer.Stop();
                Log("Auto reload stopped.");
            }
        }

        private void AutoReloadTimer_Tick(object sender, EventArgs e)
        {
             // Update interval if changed
             if (autoReloadTimer.Interval != (int)numInterval.Value * 1000)
             {
                 autoReloadTimer.Interval = (int)numInterval.Value * 1000;
             }
             TriggerHotReload();
        }

        private void BtnBuildAndroid_Click(object sender, EventArgs e)
        {
             if (cmdProcess != null && !cmdProcess.HasExited)
            {
                MessageBox.Show("Please stop the running process first.");
                return;
            }
            StartProcess("flutter", "build apk --release");
        }

        private void StartProcess(string fileName, string arguments)
        {
            if (!Directory.Exists(projectRoot))
            {
                Log($"ERROR: Project path not found: {projectRoot}");
                return;
            }

            try 
            {
                outputBox.Clear();
                // Kill any existing instances of flutter run if we are starting a new one? 
                // No, let user manage that or simple stop.
                
                string fullCmd = $"{fileName} {arguments}";
                Log($"Working Dir: {projectRoot}");
                Log($"Executing: {fullCmd}...");

                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "cmd.exe";
                psi.Arguments = $"/c {fullCmd}";
                psi.WorkingDirectory = projectRoot;
                psi.UseShellExecute = false;
                psi.RedirectStandardOutput = true;
                psi.RedirectStandardError = true;
                psi.RedirectStandardInput = true;
                psi.CreateNoWindow = true;
                
                // Important: encoding fix for some systems
                psi.StandardOutputEncoding = System.Text.Encoding.UTF8;
                psi.StandardErrorEncoding = System.Text.Encoding.UTF8;

                cmdProcess = new Process();
                cmdProcess.StartInfo = psi;
                
                cmdProcess.OutputDataReceived += (s, ev) => { 
                    if(ev.Data != null) InvokeLog(ev.Data); 
                };
                cmdProcess.ErrorDataReceived += (s, ev) => { 
                    if(ev.Data != null) InvokeLog("ERR: " + ev.Data); 
                };
                
                cmdProcess.EnableRaisingEvents = true;
                cmdProcess.Exited += (s, ev) => {
                    this.Invoke((MethodInvoker)delegate {
                        btnRunWindows.Text = "▶ Run Windows";
                        btnHotReload.Enabled = false;
                        statusLabel.Text = "Stopped";
                        Log("Process exited with code: " + cmdProcess.ExitCode);
                    });
                };

                cmdProcess.Start();
                cmdProcess.BeginOutputReadLine();
                cmdProcess.BeginErrorReadLine();
                
                statusLabel.Text = "Running...";
            }
            catch (Exception ex)
            {
                Log("CRITICAL ERROR: " + ex.Message);
            }
        }

        private void StopProcess()
        {
            if (cmdProcess != null && !cmdProcess.HasExited)
            {
                try {
                    // Try polite quit first
                    cmdProcess.StandardInput.WriteLine("q");
                    if (!cmdProcess.WaitForExit(2000))
                    {
                        cmdProcess.Kill();
                    }
                } catch {
                     try { cmdProcess.Kill(); } catch {}
                }
            }
        }

        private void InvokeLog(string message)
        {
            if (this.IsDisposed) return;
            try {
                this.Invoke((MethodInvoker)delegate {
                    Log(message);
                });
            } catch {}
        }

        private void Log(string message)
        {
            outputBox.AppendText(message + Environment.NewLine);
            outputBox.ScrollToCaret();
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            StopProcess();
            base.OnFormClosing(e);
        }
    }
}
