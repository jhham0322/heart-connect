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
        private ToolTip toolTip;
        
        // Path to the Flutter project root
        // Assuming we build to WindowUI/FlutterControlPanel/bin/Release, the root is up 4 levels?
        // Let's just hardcode the path provided in user info or search for pubspec.yaml
        private string projectRoot = @"e:\work2025\App\ConnectHeart";
        
        // ADB path - Android SDK platform-tools
        private string adbPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "Android", "Sdk", "platform-tools", "adb.exe"
        );

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
                // 1. 실행 파일과 같은 폴더에서 icon.ico 찾기
                string exeDir = Path.GetDirectoryName(Application.ExecutablePath) ?? "";
                string iconPath = Path.Combine(exeDir, "icon.ico");
                
                // 2. 없으면 프로젝트 소스 폴더에서 찾기
                if (!File.Exists(iconPath)) {
                    iconPath = Path.Combine(projectRoot, "WindowUI", "FlutterControlPanel", "icon.ico");
                }
                
                // 3. 없으면 assets에서 PNG로 찾기
                if (!File.Exists(iconPath)) {
                    string pngPath = Path.Combine(projectRoot, "assets", "icons", "app_icon.png");
                    if (File.Exists(pngPath)) {
                        using (Bitmap bmp = new Bitmap(pngPath)) {
                            this.Icon = Icon.FromHandle(bmp.GetHicon());
                        }
                    }
                } else {
                    // ICO 파일로 직접 로드
                    this.Icon = new Icon(iconPath);
                }
            } catch { /* Ignore icon errors */ }

            // 1. Controls Panel
            Panel controlPanel = new Panel();
            controlPanel.Dock = DockStyle.Top;
            controlPanel.Height = 230; // Increased height for Android controls
            controlPanel.Padding = new Padding(10);
            controlPanel.BackColor = Color.White;
            this.Controls.Add(controlPanel);

            // Initialize ToolTip
            toolTip = new ToolTip();
            toolTip.AutoPopDelay = 5000;
            toolTip.InitialDelay = 500;
            toolTip.ReshowDelay = 200;
            toolTip.ShowAlways = true;

            // Help Button (사용법)
            Button btnHelp = new Button();
            btnHelp.Text = "❓";
            btnHelp.Size = new Size(40, 40);
            btnHelp.Location = new Point(controlPanel.Width - 50, controlPanel.Height - 50);
            btnHelp.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            btnHelp.BackColor = Color.FromArgb(187, 222, 251);
            btnHelp.FlatStyle = FlatStyle.Flat;
            btnHelp.Font = new Font("Segoe UI", 14, FontStyle.Bold);
            btnHelp.Click += BtnHelp_Click;
            toolTip.SetToolTip(btnHelp, "사용법 보기");
            controlPanel.Controls.Add(btnHelp);

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
            toolTip.SetToolTip(btnRunWindows, "Flutter Windows 앱 실행");

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
            toolTip.SetToolTip(btnHotReload, "코드 변경사항 빠르게 반영 (상태 유지)");

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
            toolTip.SetToolTip(btnHotRestart, "앱 재시작 (상태 초기화)");

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
            toolTip.SetToolTip(btnReinstall, "전체 재설치: clean → pub get → build_runner → run");

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
            toolTip.SetToolTip(btnGenRun, "코드 생성 후 실행 (build_runner → run)");

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
            toolTip.SetToolTip(btnClearLog, "로그 지우기");

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
            toolTip.SetToolTip(btnCopyLog, "로그 클립보드 복사");

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
            toolTip.SetToolTip(btnBuildAndroid, "Android APK 빌드 (Release)");

            // Row 4: Android Device Controls
            int row4Y = 180;

            // Install to Device Button
            Button btnInstall = new Button();
            btnInstall.Text = "📲 Install";
            btnInstall.Size = new Size(100, 35);
            btnInstall.Location = new Point(10, row4Y);
            btnInstall.BackColor = Color.FromArgb(129, 212, 250);
            btnInstall.FlatStyle = FlatStyle.Flat;
            btnInstall.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            btnInstall.Click += BtnInstallToDevice_Click;
            controlPanel.Controls.Add(btnInstall);
            toolTip.SetToolTip(btnInstall, "APK를 연결된 폰에 설치");

            // Run on Device Button
            Button btnRunDevice = new Button();
            btnRunDevice.Text = "▶ Run";
            btnRunDevice.Size = new Size(80, 35);
            btnRunDevice.Location = new Point(120, row4Y);
            btnRunDevice.BackColor = Color.FromArgb(165, 214, 167);
            btnRunDevice.FlatStyle = FlatStyle.Flat;
            btnRunDevice.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            btnRunDevice.Click += BtnRunOnDevice_Click;
            controlPanel.Controls.Add(btnRunDevice);
            toolTip.SetToolTip(btnRunDevice, "폰에서 앱 실행");

            // Logcat Button
            Button btnLogcat = new Button();
            btnLogcat.Text = "📝 Logcat";
            btnLogcat.Size = new Size(100, 35);
            btnLogcat.Location = new Point(210, row4Y);
            btnLogcat.BackColor = Color.FromArgb(255, 224, 178);
            btnLogcat.FlatStyle = FlatStyle.Flat;
            btnLogcat.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            btnLogcat.Click += BtnLogcat_Click;
            controlPanel.Controls.Add(btnLogcat);
            toolTip.SetToolTip(btnLogcat, "Flutter 앱 로그 실시간 확인");

            // Stop Logcat Button
            Button btnStopLogcat = new Button();
            btnStopLogcat.Text = "⏹ Stop";
            btnStopLogcat.Size = new Size(80, 35);
            btnStopLogcat.Location = new Point(320, row4Y);
            btnStopLogcat.BackColor = Color.FromArgb(255, 183, 178);
            btnStopLogcat.FlatStyle = FlatStyle.Flat;
            btnStopLogcat.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            btnStopLogcat.Click += (s, ev) => StopProcess();
            controlPanel.Controls.Add(btnStopLogcat);
            toolTip.SetToolTip(btnStopLogcat, "Logcat 중지");

            // Check Devices Button
            Button btnDevices = new Button();
            btnDevices.Text = "📱 Devices";
            btnDevices.Size = new Size(100, 35);
            btnDevices.Location = new Point(410, row4Y);
            btnDevices.BackColor = Color.FromArgb(206, 147, 216);
            btnDevices.FlatStyle = FlatStyle.Flat;
            btnDevices.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            btnDevices.Click += BtnCheckDevices_Click;
            controlPanel.Controls.Add(btnDevices);
            toolTip.SetToolTip(btnDevices, "연결된 Android 기기 목록 확인");

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
            // Gradle 캐시 정리 후 빌드 (core library desugaring 설정 적용을 위해)
            StartProcess("cmd", "/c flutter clean && flutter build apk --release");
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

        // Android Device Functions
        private void BtnCheckDevices_Click(object sender, EventArgs e)
        {
            outputBox.Clear();
            Log("Checking connected devices...");
            StartProcess(adbPath, "devices -l");
        }

        private void BtnInstallToDevice_Click(object sender, EventArgs e)
        {
            string apkPath = Path.Combine(projectRoot, "build", "app", "outputs", "flutter-apk", "app-release.apk");
            
            if (!File.Exists(apkPath))
            {
                // Try debug apk
                apkPath = Path.Combine(projectRoot, "build", "app", "outputs", "flutter-apk", "app-debug.apk");
            }
            
            if (!File.Exists(apkPath))
            {
                MessageBox.Show("APK not found. Please build first.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            outputBox.Clear();
            Log($"Installing APK: {apkPath}");
            StartProcess(adbPath, $"install -r \"{apkPath}\"");
        }

        private void BtnRunOnDevice_Click(object sender, EventArgs e)
        {
            outputBox.Clear();
            Log("Launching app on device...");
            // Package name from build.gradle.kts
            StartProcess(adbPath, "shell am start -n com.example.heart_connect/.MainActivity");
        }

        private void BtnLogcat_Click(object sender, EventArgs e)
        {
            if (cmdProcess != null && !cmdProcess.HasExited)
            {
                MessageBox.Show("Please stop the running process first.");
                return;
            }

            outputBox.Clear();
            Log("Starting Logcat (filtering Flutter)...");
            Log("Press 'Stop' to stop logging.\n");
            
            // Filter logs for Flutter app
            StartProcess(adbPath, "logcat -v time *:S flutter:V FlutterActivity:V");
        }

        private void BtnHelp_Click(object sender, EventArgs e)
        {
            string helpText = @"=== Heart Connect Controller 사용법 ===

[Windows 개발]
▶ Run - Flutter Windows 앱 실행
⚡ Hot Reload - 코드 변경사항 빠르게 반영 (상태 유지)
🔄 Hot Restart - 앱 재시작 (상태 초기화)
🔧 Reinstall - 전체 재설치 (clean → pub get → build_runner → run)
🏗 Gen && Run - 코드 생성 후 실행

[로그]
🗑 Clear - 로그 지우기
📋 Copy - 로그 클립보드 복사

[Android 빌드]
📱 Build - Android APK 빌드 (Release)

[Android 기기 (USB 연결 필요)]
📲 Install - APK를 연결된 폰에 설치
▶ Run - 폰에서 앱 실행
📝 Logcat - Flutter 앱 로그 실시간 확인
⏹ Stop - Logcat 중지
📱 Devices - 연결된 기기 목록 확인

[Android 폰 사용법]
1. 폰에서 [설정] → [개발자 옵션] → [USB 디버깅] 활성화
2. USB로 PC와 폰 연결
3. [Devices] 클릭하여 연결 확인
4. [Build] 클릭하여 APK 빌드
5. [Install] 클릭하여 폰에 설치
6. [Run] 클릭하여 앱 실행
7. [Logcat] 클릭하여 로그 확인 (디버깅)
";
            MessageBox.Show(helpText, "❓ 사용법", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
    }
}
