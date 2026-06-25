# tool.ps1 — The Minimalist Flex
# One-liner: irm https://ujo6.github.io/Tools.Select/tool.ps1 | iex

Clear-Host
Write-Host @"
   ████████╗ ██████╗  ██████╗ ██╗     
   ╚══██╔══╝██╔═══██╗██╔═══██╗██║     
      ██║   ██║   ██║██║   ██║██║     
      ██║   ██║   ██║██║   ██║██║     
      ██║   ╚██████╔╝╚██████╔╝███████╗
      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
"@ -ForegroundColor Cyan
Write-Host "        BY DANNI K — TOOLS.SELECT v1.0" -ForegroundColor Yellow
Write-Host ""

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "TOOL"
$form.Size = New-Object System.Drawing.Size(300, 200)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 30)

$label = New-Object System.Windows.Forms.Label
$label.Text = "TOOL"
$label.Font = New-Object System.Drawing.Font("Segoe UI", 48, [System.Drawing.FontStyle]::Bold)
$label.ForeColor = [System.Drawing.Color]::Cyan
$label.TextAlign = "MiddleCenter"
$label.Size = New-Object System.Drawing.Size(280, 120)
$label.Location = New-Object System.Drawing.Point(10, 10)

$button = New-Object System.Windows.Forms.Button
$button.Text = "OK"
$button.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$button.Size = New-Object System.Drawing.Size(100, 40)
$button.Location = New-Object System.Drawing.Point(100, 130)
$button.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 60)
$button.ForeColor = [System.Drawing.Color]::White
$button.FlatStyle = "Flat"
$button.Add_Click({ $form.Close() })

$form.Controls.Add($label)
$form.Controls.Add($button)
$form.ShowDialog()

Write-Host "TOOL activated." -ForegroundColor Green
