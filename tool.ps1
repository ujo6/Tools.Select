# tool-gui.ps1 — Pure GUI popup
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "HuntSint"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 30)
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Title
$title = New-Object System.Windows.Forms.Label
$title.Text = "HUNTSINT"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 48, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(170, 80, 255)
$title.TextAlign = "MiddleCenter"
$title.Size = New-Object System.Drawing.Size(480, 100)
$title.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($title)

# Subtitle
$sub = New-Object System.Windows.Forms.Label
$sub.Text = "OSINT Suite v5.0.0"
$sub.Font = New-Object System.Drawing.Font("Segoe UI", 14)
$sub.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 200)
$sub.TextAlign = "MiddleCenter"
$sub.Size = New-Object System.Drawing.Size(480, 40)
$sub.Location = New-Object System.Drawing.Point(10, 120)
$form.Controls.Add($sub)

# OK button
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "TOOL"
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$btn.Size = New-Object System.Drawing.Size(200, 80)
$btn.Location = New-Object System.Drawing.Point(150, 200)
$btn.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 80)
$btn.ForeColor = [System.Drawing.Color]::Cyan
$btn.FlatStyle = "Flat"
$btn.Add_Click({ $form.Close() })
$form.Controls.Add($btn)

$form.ShowDialog()
