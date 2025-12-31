using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace FlutterControlPanel
{
    public class AndroidSettingsForm : Form
    {
        private TextBox txtPackageName;
        private TextBox txtAppName;
        private TextBox txtVersionName;
        private NumericUpDown numVersionCode;
        private PictureBox picIcon;
        private string projectRoot;
        private string iconPath = "";

        public AndroidSettingsForm(string projectRoot)
        {
            this.projectRoot = projectRoot;
            SetupUI();
            LoadCurrentSettings();
        }

        private void SetupUI()
        {
            this.Text = "⚙ Android 설정";
            this.Size = new Size(500, 500);
            this.StartPosition = FormStartPosition.CenterParent;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.BackColor = Color.White;

            int y = 20;
            int labelWidth = 120;
            int inputX = 140;
            int inputWidth = 320;

            // Package Name
            Label lblPackage = new Label();
            lblPackage.Text = "패키지명:";
            lblPackage.Location = new Point(20, y + 3);
            lblPackage.AutoSize = true;
            lblPackage.Font = new Font("Segoe UI", 10);
            this.Controls.Add(lblPackage);

            txtPackageName = new TextBox();
            txtPackageName.Location = new Point(inputX, y);
            txtPackageName.Width = inputWidth;
            txtPackageName.Font = new Font("Consolas", 10);
            this.Controls.Add(txtPackageName);

            Label lblPackageHint = new Label();
            lblPackageHint.Text = "예: com.yourcompany.appname";
            lblPackageHint.Location = new Point(inputX, y + 25);
            lblPackageHint.AutoSize = true;
            lblPackageHint.ForeColor = Color.Gray;
            lblPackageHint.Font = new Font("Segoe UI", 8);
            this.Controls.Add(lblPackageHint);

            y += 60;

            // App Name
            Label lblAppName = new Label();
            lblAppName.Text = "앱 이름:";
            lblAppName.Location = new Point(20, y + 3);
            lblAppName.AutoSize = true;
            lblAppName.Font = new Font("Segoe UI", 10);
            this.Controls.Add(lblAppName);

            txtAppName = new TextBox();
            txtAppName.Location = new Point(inputX, y);
            txtAppName.Width = inputWidth;
            txtAppName.Font = new Font("Segoe UI", 10);
            this.Controls.Add(txtAppName);

            y += 50;

            // Version Name
            Label lblVersion = new Label();
            lblVersion.Text = "버전 이름:";
            lblVersion.Location = new Point(20, y + 3);
            lblVersion.AutoSize = true;
            lblVersion.Font = new Font("Segoe UI", 10);
            this.Controls.Add(lblVersion);

            txtVersionName = new TextBox();
            txtVersionName.Location = new Point(inputX, y);
            txtVersionName.Width = 150;
            txtVersionName.Font = new Font("Consolas", 10);
            this.Controls.Add(txtVersionName);

            Label lblVersionHint = new Label();
            lblVersionHint.Text = "예: 1.0.0";
            lblVersionHint.Location = new Point(inputX + 160, y + 3);
            lblVersionHint.AutoSize = true;
            lblVersionHint.ForeColor = Color.Gray;
            lblVersionHint.Font = new Font("Segoe UI", 9);
            this.Controls.Add(lblVersionHint);

            y += 50;

            // Version Code
            Label lblVersionCode = new Label();
            lblVersionCode.Text = "버전 코드:";
            lblVersionCode.Location = new Point(20, y + 3);
            lblVersionCode.AutoSize = true;
            lblVersionCode.Font = new Font("Segoe UI", 10);
            this.Controls.Add(lblVersionCode);

            numVersionCode = new NumericUpDown();
            numVersionCode.Location = new Point(inputX, y);
            numVersionCode.Width = 100;
            numVersionCode.Minimum = 1;
            numVersionCode.Maximum = 999999;
            numVersionCode.Font = new Font("Consolas", 10);
            numVersionCode.ValueChanged += NumVersionCode_ValueChanged;
            this.Controls.Add(numVersionCode);

            Label lblCodeHint = new Label();
            lblCodeHint.Text = "(정수, 업데이트시 증가)";
            lblCodeHint.Location = new Point(inputX + 110, y + 3);
            lblCodeHint.AutoSize = true;
            lblCodeHint.ForeColor = Color.Gray;
            lblCodeHint.Font = new Font("Segoe UI", 9);
            this.Controls.Add(lblCodeHint);

            y += 60;

            // App Icon
            Label lblIcon = new Label();
            lblIcon.Text = "앱 아이콘:";
            lblIcon.Location = new Point(20, y);
            lblIcon.AutoSize = true;
            lblIcon.Font = new Font("Segoe UI", 10);
            this.Controls.Add(lblIcon);

            picIcon = new PictureBox();
            picIcon.Location = new Point(inputX, y);
            picIcon.Size = new Size(100, 100);
            picIcon.BorderStyle = BorderStyle.FixedSingle;
            picIcon.SizeMode = PictureBoxSizeMode.Zoom;
            picIcon.BackColor = Color.FromArgb(240, 240, 240);
            this.Controls.Add(picIcon);

            Button btnChangeIcon = new Button();
            btnChangeIcon.Text = "아이콘 변경...";
            btnChangeIcon.Location = new Point(inputX + 120, y + 35);
            btnChangeIcon.Size = new Size(120, 30);
            btnChangeIcon.FlatStyle = FlatStyle.Flat;
            btnChangeIcon.BackColor = Color.FromArgb(224, 224, 224);
            btnChangeIcon.Click += BtnChangeIcon_Click;
            this.Controls.Add(btnChangeIcon);

            Label lblIconHint = new Label();
            lblIconHint.Text = "512x512 PNG 권장";
            lblIconHint.Location = new Point(inputX + 120, y + 70);
            lblIconHint.AutoSize = true;
            lblIconHint.ForeColor = Color.Gray;
            lblIconHint.Font = new Font("Segoe UI", 8);
            this.Controls.Add(lblIconHint);

            y += 130;

            // Buttons
            Button btnSave = new Button();
            btnSave.Text = "💾 저장";
            btnSave.Size = new Size(120, 40);
            btnSave.Location = new Point(this.ClientSize.Width / 2 - 130, y);
            btnSave.BackColor = Color.FromArgb(129, 199, 132);
            btnSave.ForeColor = Color.White;
            btnSave.FlatStyle = FlatStyle.Flat;
            btnSave.Font = new Font("Segoe UI", 11, FontStyle.Bold);
            btnSave.Click += BtnSave_Click;
            this.Controls.Add(btnSave);

            Button btnCancel = new Button();
            btnCancel.Text = "취소";
            btnCancel.Size = new Size(100, 40);
            btnCancel.Location = new Point(this.ClientSize.Width / 2 + 10, y);
            btnCancel.BackColor = Color.FromArgb(224, 224, 224);
            btnCancel.FlatStyle = FlatStyle.Flat;
            btnCancel.Font = new Font("Segoe UI", 11);
            btnCancel.Click += (s, e) => this.Close();
            this.Controls.Add(btnCancel);
        }

        private void LoadCurrentSettings()
        {
            try
            {
                // Load from build.gradle.kts
                string gradlePath = Path.Combine(projectRoot, "android", "app", "build.gradle.kts");
                if (File.Exists(gradlePath))
                {
                    string content = File.ReadAllText(gradlePath);
                    
                    // applicationId
                    var match = Regex.Match(content, @"applicationId\s*=\s*""([^""]+)""");
                    if (match.Success)
                    {
                        txtPackageName.Text = match.Groups[1].Value;
                    }

                    // namespace
                    match = Regex.Match(content, @"namespace\s*=\s*""([^""]+)""");
                    if (match.Success && string.IsNullOrEmpty(txtPackageName.Text))
                    {
                        txtPackageName.Text = match.Groups[1].Value;
                    }
                }

                // Load app name from AndroidManifest.xml
                string manifestPath = Path.Combine(projectRoot, "android", "app", "src", "main", "AndroidManifest.xml");
                if (File.Exists(manifestPath))
                {
                    string content = File.ReadAllText(manifestPath);
                    var match = Regex.Match(content, @"android:label=""([^""]+)""");
                    if (match.Success)
                    {
                        txtAppName.Text = match.Groups[1].Value;
                    }
                }

                // Load version from pubspec.yaml
                string pubspecPath = Path.Combine(projectRoot, "pubspec.yaml");
                if (File.Exists(pubspecPath))
                {
                    string content = File.ReadAllText(pubspecPath);
                    var match = Regex.Match(content, @"version:\s*(\d+\.\d+\.\d+)\+(\d+)");
                    if (match.Success)
                    {
                        txtVersionName.Text = match.Groups[1].Value;
                        numVersionCode.Value = int.Parse(match.Groups[2].Value);
                        previousVersionCode = (int)numVersionCode.Value;
                    }
                    else
                    {
                        match = Regex.Match(content, @"version:\s*(\d+\.\d+\.\d+)");
                        if (match.Success)
                        {
                            txtVersionName.Text = match.Groups[1].Value;
                            numVersionCode.Value = 1;
                            previousVersionCode = 1;
                        }
                    }
                }

                // Load icon
                string[] iconPaths = new string[] {
                    Path.Combine(projectRoot, "assets", "icons", "app_icon.png"),
                    Path.Combine(projectRoot, "android", "app", "src", "main", "res", "mipmap-xxxhdpi", "ic_launcher.png"),
                    Path.Combine(projectRoot, "android", "app", "src", "main", "res", "mipmap-xxhdpi", "ic_launcher.png"),
                };

                foreach (var path in iconPaths)
                {
                    if (File.Exists(path))
                    {
                        iconPath = path;
                        // 파일 잠금 방지를 위해 바이트로 읽어서 메모리 스트림 생성
                        byte[] bytes = File.ReadAllBytes(path);
                        using (var ms = new MemoryStream(bytes))
                        {
                            picIcon.Image = Image.FromStream(ms);
                        }
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("설정 로드 중 오류: " + ex.Message, "오류", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void BtnChangeIcon_Click(object sender, EventArgs e)
        {
            using (OpenFileDialog ofd = new OpenFileDialog())
            {
                ofd.Filter = "PNG 이미지|*.png|모든 이미지|*.png;*.jpg;*.jpeg;*.bmp";
                ofd.Title = "앱 아이콘 선택 (512x512 권장)";

                if (ofd.ShowDialog() == DialogResult.OK)
                {
                    iconPath = ofd.FileName;
                    byte[] bytes = File.ReadAllBytes(iconPath);
                    using (var ms = new MemoryStream(bytes))
                    {
                        picIcon.Image = Image.FromStream(ms);
                    }
                }
            }
        }

        private int previousVersionCode = 0;
        
        private void NumVersionCode_ValueChanged(object sender, EventArgs e)
        {
            // 버전 코드가 증가하면 버전 이름 마지막 자리도 증가
            if (!string.IsNullOrEmpty(txtVersionName.Text))
            {
                int currentCode = (int)numVersionCode.Value;
                if (currentCode > previousVersionCode && previousVersionCode > 0)
                {
                    // 버전 이름 파싱 (예: 1.0.9)
                    var parts = txtVersionName.Text.Split('.');
                    if (parts.Length == 3 && int.TryParse(parts[2], out int patch))
                    {
                        // 마지막 자리 증가
                        patch++;
                        if (patch >= 10)
                        {
                            patch = 0;
                            if (int.TryParse(parts[1], out int minor))
                            {
                                minor++;
                                if (minor >= 10)
                                {
                                    minor = 0;
                                    if (int.TryParse(parts[0], out int major))
                                    {
                                        major++;
                                        parts[0] = major.ToString();
                                    }
                                }
                                parts[1] = minor.ToString();
                            }
                        }
                        parts[2] = patch.ToString();
                        txtVersionName.Text = string.Join(".", parts);
                    }
                }
                previousVersionCode = currentCode;
            }
        }

        private void BtnSave_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate package name
                if (!Regex.IsMatch(txtPackageName.Text, @"^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$"))
                {
                    MessageBox.Show("패키지명이 올바르지 않습니다.\n예: com.yourcompany.appname", "오류", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    txtPackageName.Focus();
                    return;
                }

                // 1. Update build.gradle.kts
                string gradlePath = Path.Combine(projectRoot, "android", "app", "build.gradle.kts");
                if (File.Exists(gradlePath))
                {
                    string content = File.ReadAllText(gradlePath);
                    content = Regex.Replace(content, @"(namespace\s*=\s*"")[^""]+("")", $"$1{txtPackageName.Text}$2");
                    content = Regex.Replace(content, @"(applicationId\s*=\s*"")[^""]+("")", $"$1{txtPackageName.Text}$2");
                    File.WriteAllText(gradlePath, content);
                }

                // 2. Update AndroidManifest.xml (app label)
                string manifestPath = Path.Combine(projectRoot, "android", "app", "src", "main", "AndroidManifest.xml");
                if (File.Exists(manifestPath) && !string.IsNullOrEmpty(txtAppName.Text))
                {
                    string content = File.ReadAllText(manifestPath);
                    content = Regex.Replace(content, @"(android:label="")[^""]+("")", $"$1{txtAppName.Text}$2");
                    File.WriteAllText(manifestPath, content);
                }

                // 3. Update pubspec.yaml version
                string pubspecPath = Path.Combine(projectRoot, "pubspec.yaml");
                if (File.Exists(pubspecPath))
                {
                    string content = File.ReadAllText(pubspecPath);
                    string newVersion = $"{txtVersionName.Text}+{numVersionCode.Value}";
                    content = Regex.Replace(content, @"version:\s*[\d.+]+", $"version: {newVersion}");
                    File.WriteAllText(pubspecPath, content);
                }

                // 4. Copy icon and generate all sizes
                if (!string.IsNullOrEmpty(iconPath) && File.Exists(iconPath))
                {
                    CopyAndResizeIcon(iconPath);
                }

                MessageBox.Show("설정이 저장되었습니다.\n\n다음 빌드에 적용됩니다.", "저장 완료", MessageBoxButtons.OK, MessageBoxIcon.Information);
                this.DialogResult = DialogResult.OK;
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("저장 중 오류: " + ex.Message, "오류", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void CopyAndResizeIcon(string sourceIconPath)
        {
            try
            {
                // 원본 데이터를 메모리에 복사 (파일 핸들 즉시 해제)
                byte[] sourceBytes = File.ReadAllBytes(sourceIconPath);
                
                using (var ms = new MemoryStream(sourceBytes))
                using (Image original = Image.FromStream(ms))
                {
                    // Android icon sizes
                    var sizes = new Dictionary<string, int>
                    {
                        { "mipmap-mdpi", 48 },
                        { "mipmap-hdpi", 72 },
                        { "mipmap-xhdpi", 96 },
                        { "mipmap-xxhdpi", 144 },
                        { "mipmap-xxxhdpi", 192 },
                    };

                    string resPath = Path.Combine(projectRoot, "android", "app", "src", "main", "res");

                    foreach (var size in sizes)
                    {
                        string folderPath = Path.Combine(resPath, size.Key);
                        if (!Directory.Exists(folderPath))
                        {
                            Directory.CreateDirectory(folderPath);
                        }

                        string outputPath = Path.Combine(folderPath, "ic_launcher.png");
                        
                        using (Bitmap resized = new Bitmap(original, new Size(size.Value, size.Value)))
                        {
                            resized.Save(outputPath, System.Drawing.Imaging.ImageFormat.Png);
                        }
                    }
                }
                
                // assets에 원본 저장 (이제 original Image가 dispose되었으므로 안전)
                string assetsIconPath = Path.Combine(projectRoot, "assets", "icons");
                if (!Directory.Exists(assetsIconPath))
                {
                    Directory.CreateDirectory(assetsIconPath);
                }
                
                string destPath = Path.Combine(assetsIconPath, "app_icon.png");
                
                // 원본 경로와 대상 경로가 다를 때만 복사 (같으면 이미 있음)
                // 경로 정규화해서 비교
                string fullSource = Path.GetFullPath(sourceIconPath);
                string fullDest = Path.GetFullPath(destPath);
                
                if (!string.Equals(fullSource, fullDest, StringComparison.OrdinalIgnoreCase))
                {
                   File.WriteAllBytes(destPath, sourceBytes);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("아이콘 생성 중 오류: " + ex.Message, "경고", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}
