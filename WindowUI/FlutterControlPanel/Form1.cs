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
        
        // Auto Build 관련
        private FileSystemWatcher fileWatcher;
        private CheckBox chkAutoBuild;
        private System.Windows.Forms.Timer autoBuildDebounceTimer;
        private DateTime lastBuildTime = DateTime.MinValue;
        private bool isBuilding = false;
        
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
            
            // Auto Build Debounce Timer (변경 후 2초 대기)
            autoBuildDebounceTimer = new System.Windows.Forms.Timer();
            autoBuildDebounceTimer.Interval = 2000;
            autoBuildDebounceTimer.Tick += AutoBuildDebounceTimer_Tick;
            
            // File System Watcher 초기화
            SetupFileWatcher();
        }
        
        private void SetupFileWatcher()
        {
            try
            {
                string libPath = Path.Combine(projectRoot, "lib");
                if (Directory.Exists(libPath))
                {
                    fileWatcher = new FileSystemWatcher(libPath);
                    fileWatcher.Filter = "*.dart";
                    fileWatcher.IncludeSubdirectories = true;
                    fileWatcher.NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.FileName;
                    fileWatcher.Changed += FileWatcher_Changed;
                    fileWatcher.Created += FileWatcher_Changed;
                    fileWatcher.EnableRaisingEvents = false; // 기본적으로 비활성화
                }
            }
            catch (Exception ex)
            {
                Log($"FileWatcher 초기화 실패: {ex.Message}");
            }
        }
        
        private void FileWatcher_Changed(object sender, FileSystemEventArgs e)
        {
            // UI 스레드에서 debounce timer 리셋
            this.Invoke((MethodInvoker)delegate {
                autoBuildDebounceTimer.Stop();
                autoBuildDebounceTimer.Start();
                statusLabel.Text = $"변경 감지: {Path.GetFileName(e.FullPath)} - 빌드 대기 중...";
            });
        }
        
        private void AutoBuildDebounceTimer_Tick(object sender, EventArgs e)
        {
            autoBuildDebounceTimer.Stop();
            
            // 이미 빌드 중이면 스킵
            if (isBuilding || (cmdProcess != null && !cmdProcess.HasExited))
            {
                Log("빌드 중이므로 자동 빌드를 건너뜁니다.");
                return;
            }
            
            // 마지막 빌드로부터 5초 이내면 스킵
            if ((DateTime.Now - lastBuildTime).TotalSeconds < 5)
            {
                Log("최근 빌드가 완료되어 자동 빌드를 건너뜁니다.");
                return;
            }
            
            Log("\n=== 자동 빌드 시작 (파일 변경 감지) ===");
            isBuilding = true;
            TriggerAutoBuildAndTest();
        }
        
        private void TriggerAutoBuildAndTest()
        {
            string packageName = GetPackageName();
            string buildAndTestCmd = $"flutter build apk --release && " +
                $"\"{adbPath}\" install -r \"{Path.Combine(projectRoot, "build", "app", "outputs", "flutter-apk", "app-release.apk")}\" && " +
                $"\"{adbPath}\" shell monkey -p {packageName} -c android.intent.category.LAUNCHER 1";
            
            StartProcess("cmd", "/c " + buildAndTestCmd);
            lastBuildTime = DateTime.Now;
            isBuilding = false;
        }

        private void SetupCustomUI()
        {
            this.Text = "Heart Connect - Flutter Controller";
            this.Size = new Size(1024, 800); // 모든 버튼이 보이도록 크기 조정
            this.MinimumSize = new Size(900, 600); // 최소 크기 설정
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
            grpAuto.Text = "Auto Reload / Build";
            grpAuto.Location = new Point(460, 5); // Shifted right
            grpAuto.Size = new Size(180, 60); // Build 버튼과 겹치지 않게 조정
            controlPanel.Controls.Add(grpAuto);

            chkAutoReload = new CheckBox();
            chkAutoReload.Text = "Hot Reload";
            chkAutoReload.Location = new Point(15, 25);
            chkAutoReload.AutoSize = true;
            chkAutoReload.CheckedChanged += ChkAutoReload_CheckedChanged;
            grpAuto.Controls.Add(chkAutoReload);
            toolTip.SetToolTip(chkAutoReload, "Windows 실행 중 주기적으로 Hot Reload");

            numInterval = new NumericUpDown();
            numInterval.Minimum = 1;
            numInterval.Maximum = 600;
            numInterval.Value = 3;
            numInterval.Location = new Point(110, 23);
            numInterval.Width = 50;
            grpAuto.Controls.Add(numInterval);

            Label lblSec = new Label();
            lblSec.Text = "초";
            lblSec.Location = new Point(165, 25);
            lblSec.AutoSize = true;
            grpAuto.Controls.Add(lblSec);
            
            // Auto Build (Android) 체크박스 - 그룹박스 밖에 배치
            chkAutoBuild = new CheckBox();
            chkAutoBuild.Text = "📱 Auto Build";
            chkAutoBuild.Location = new Point(650, 55);
            chkAutoBuild.AutoSize = true;
            chkAutoBuild.ForeColor = Color.FromArgb(0, 150, 136);
            chkAutoBuild.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            chkAutoBuild.CheckedChanged += ChkAutoBuild_CheckedChanged;
            controlPanel.Controls.Add(chkAutoBuild);
            toolTip.SetToolTip(chkAutoBuild, "파일 변경 시 자동으로 Android 빌드 → 설치 → 실행");

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
            btnBuildAndroid.Text = "📱 Build";
            btnBuildAndroid.Size = new Size(80, 40);
            btnBuildAndroid.Location = new Point(650, 10);
            btnBuildAndroid.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            btnBuildAndroid.BackColor = Color.FromArgb(129, 199, 132);
            btnBuildAndroid.FlatStyle = FlatStyle.Flat;
            btnBuildAndroid.Click += BtnBuildAndroid_Click;
            controlPanel.Controls.Add(btnBuildAndroid);
            toolTip.SetToolTip(btnBuildAndroid, "Android APK 빌드 (Release)");

            // Build & Test Button (Build + Install + Run)
            Button btnBuildTest = new Button();
            btnBuildTest.Text = "🚀 Build && Test";
            btnBuildTest.Size = new Size(110, 40);
            btnBuildTest.Location = new Point(740, 10);
            btnBuildTest.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            btnBuildTest.BackColor = Color.FromArgb(79, 195, 247);
            btnBuildTest.ForeColor = Color.White;
            btnBuildTest.FlatStyle = FlatStyle.Flat;
            btnBuildTest.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            btnBuildTest.Click += BtnBuildAndTest_Click;
            controlPanel.Controls.Add(btnBuildTest);
            toolTip.SetToolTip(btnBuildTest, "빌드 → 설치 → 실행 (한번에 테스트)");

            // Settings Button
            Button btnSettings = new Button();
            btnSettings.Text = "⚙";
            btnSettings.Size = new Size(40, 40);
            btnSettings.Location = new Point(860, 10);
            btnSettings.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            btnSettings.BackColor = Color.FromArgb(255, 183, 77);
            btnSettings.FlatStyle = FlatStyle.Flat;
            btnSettings.Font = new Font("Segoe UI", 16);
            btnSettings.Click += BtnSettings_Click;
            controlPanel.Controls.Add(btnSettings);
            toolTip.SetToolTip(btnSettings, "Android 설정 (패키지명, 앱이름, 아이콘 등)");

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

            // Device Monitor Button
            Button btnMonitor = new Button();
            btnMonitor.Text = "🖥 Monitor";
            btnMonitor.Size = new Size(100, 35);
            btnMonitor.Location = new Point(520, row4Y);
            btnMonitor.BackColor = Color.FromArgb(255, 183, 77);
            btnMonitor.FlatStyle = FlatStyle.Flat;
            btnMonitor.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            btnMonitor.Click += (s, ev) => {
                DeviceMonitorForm monitor = new DeviceMonitorForm(adbPath);
                monitor.Show();
            };
            controlPanel.Controls.Add(btnMonitor);
            toolTip.SetToolTip(btnMonitor, "폰 화면과 로그를 실시간으로 모니터링");

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
        
        private void ChkAutoBuild_CheckedChanged(object sender, EventArgs e)
        {
            if (fileWatcher == null)
            {
                Log("FileWatcher가 초기화되지 않았습니다.");
                chkAutoBuild.Checked = false;
                return;
            }
            
            if (chkAutoBuild.Checked)
            {
                fileWatcher.EnableRaisingEvents = true;
                Log("📱 Auto Build 활성화: 파일 변경 시 자동으로 빌드 → 설치 → 실행");
                statusLabel.Text = "Auto Build ON - 파일 변경 대기 중...";
            }
            else
            {
                fileWatcher.EnableRaisingEvents = false;
                autoBuildDebounceTimer.Stop();
                Log("Auto Build 비활성화");
                statusLabel.Text = "Ready";
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
                // Don't clear here - let individual buttons decide
                // Kill any existing instances of flutter run if we are starting a new one? 
                // No, let user manage that or simple stop.
                
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "cmd.exe";
                
                // fileName이 "cmd"인 경우 arguments를 직접 사용 (이중 /c 방지)
                if (fileName.Equals("cmd", StringComparison.OrdinalIgnoreCase))
                {
                    psi.Arguments = arguments;
                    Log($"Working Dir: {projectRoot}");
                    Log($"Executing: {arguments}...");
                }
                else
                {
                    string fullCmd = $"\"{fileName}\" {arguments}";
                    psi.Arguments = $"/c {fullCmd}";
                    Log($"Working Dir: {projectRoot}");
                    Log($"Executing: {fullCmd}...");
                }
                
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

        // ADB 명령을 올바르게 실행하는 헬퍼 함수
        private void StartAdbCommand(string arguments)
        {
            if (!File.Exists(adbPath))
            {
                Log($"ERROR: ADB not found at: {adbPath}");
                Log("Please install Android SDK Platform Tools");
                return;
            }
            
            // adb.exe를 직접 fileName으로 전달 (StartProcess가 cmd /c로 감싸줌)
            StartProcess(adbPath, arguments);
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
            StartAdbCommand("devices -l");
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
            StartAdbCommand($"install -r \"{apkPath}\"");
        }

        private void BtnRunOnDevice_Click(object sender, EventArgs e)
        {
            outputBox.Clear();
            Log("Launching app on device...");
            // Package name from build.gradle.kts
            string packageName = GetPackageName();
            StartAdbCommand($"shell monkey -p {packageName} -c android.intent.category.LAUNCHER 1");
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
            StartAdbCommand("logcat -v time *:S flutter:V FlutterActivity:V");
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

[자동화]
☑ Hot Reload - Windows 실행 중 N초마다 자동 Hot Reload
☑ Auto Build - 파일 변경 시 자동으로 Android 빌드→설치→실행 ⭐NEW

[로그]
🗑 Clear - 로그 지우기
📋 Copy - 로그 클립보드 복사

[Android 빌드 & 테스트]
📱 Build - Android APK 빌드 (Release)
🚀 Build & Test - 빌드 → 설치 → 실행 (한번에!)
⚙ Settings - 패키지명, 앱이름, 버전, 아이콘 설정

[Android 기기 (USB 연결 필요)]
📲 Install - APK를 연결된 폰에 설치
▶ Run - 폰에서 앱 실행
📝 Logcat - Flutter 앱 로그 실시간 확인
⏹ Stop - Logcat 중지
📱 Devices - 연결된 기기 목록 확인

[Auto Build 사용법] ⭐
1. 폰을 USB로 연결하고 [Devices]로 확인
2. 'Auto Build' 체크박스 활성화
3. 코드 수정 후 저장하면 2초 후 자동 빌드 시작
4. 빌드 완료 시 자동으로 설치 및 앱 실행!
";
            MessageBox.Show(helpText, "❓ 사용법", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void BtnBuildAndTest_Click(object sender, EventArgs e)
        {
            if (cmdProcess != null && !cmdProcess.HasExited)
            {
                MessageBox.Show("Please stop the running process first.");
                return;
            }

            outputBox.Clear();
            Log("=== Build & Test 시작 ===");
            Log("1단계: APK 빌드 중...\n");

            // Build -> Install -> Run in sequence
            string packageName = GetPackageName();
            string buildAndTestCmd = $"flutter build apk --release && " +
                $"\"{adbPath}\" install -r \"{Path.Combine(projectRoot, "build", "app", "outputs", "flutter-apk", "app-release.apk")}\" && " +
                $"\"{adbPath}\" shell monkey -p {packageName} -c android.intent.category.LAUNCHER 1";
            
            StartProcess("cmd", "/c " + buildAndTestCmd);
        }

        private void BtnSettings_Click(object sender, EventArgs e)
        {
            using (AndroidSettingsForm settingsForm = new AndroidSettingsForm(projectRoot))
            {
                if (settingsForm.ShowDialog() == DialogResult.OK)
                {
                    Log("설정이 저장되었습니다. 다음 빌드에 적용됩니다.");
                }
            }
        }

        private string GetPackageName()
        {
            try
            {
                string gradlePath = Path.Combine(projectRoot, "android", "app", "build.gradle.kts");
                if (File.Exists(gradlePath))
                {
                    string content = File.ReadAllText(gradlePath);
                    var match = System.Text.RegularExpressions.Regex.Match(content, @"applicationId\s*=\s*""([^""]+)""");
                    if (match.Success)
                    {
                        return match.Groups[1].Value;
                    }
                }
            }
            catch { }
            return "com.example.heart_connect"; // fallback
        }
    }
}
