# HuntSint Intelligence Suite - Terminal Interface
# Save as HuntSint.ps1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "HuntSint Intelligence Suite"
$form.Size = New-Object System.Drawing.Size(1300, 800)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 20)
$form.ForeColor = [System.Drawing.Color]::Cyan
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.KeyPreview = $true

# Create a rich textbox for the display
$rtb = New-Object System.Windows.Forms.RichTextBox
$rtb.Location = New-Object System.Drawing.Point(10, 10)
$rtb.Size = New-Object System.Drawing.Size(1260, 730)
$rtb.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 20)
$rtb.ForeColor = [System.Drawing.Color]::Cyan
$rtb.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Regular)
$rtb.ReadOnly = $true
$rtb.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$rtb.WordWrap = $false
$rtb.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical

# Build the ASCII art display
$display = @"
┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ● HUNTSINT // INTELLIGENCE SUITE                                                                                                         ECH0@HuntSint │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

                                    ▄█    █▄    ███    █▄  ███▄▄▄▄       ███        ▄████████  ▄█  ███▄▄▄▄       ███     
                                   ███    ███   ███    ███ ███▀▀▀██▄ ▀█████████▄   ███    ███ ███  ███▀▀▀██▄ ▀█████████▄ 
                                   ███    ███   ███    ███ ███   ███    ▀███▀▀██   ███    █▀  ███▌ ███   ███    ▀███▀▀██ 
                                  ▄███▄▄▄▄███▄▄ ███    ███ ███   ███     ███   ▀   ███        ███▌ ███   ███     ███   ▀ 
                                 ▀▀███▀▀▀▀███▀  ███    ███ ███   ███     ███     ▀███████████ ███▌ ███   ███     ███     
                                   ███    ███   ███    ███ ███   ███     ███              ███ ███  ███   ███     ███     
                                   ███    ███   ███    ███ ███   ███     ███        ▄█    ███ ███  ███   ███     ███     
                                  ███    █▀    ████████▀   ▀█   █▀     ▄████▀    ▄████████▀  █▀    ▀█   █▀     ▄████▀    

                                                       [ 20:39:00 ]   cpu  6% · ram 64% · ● ONLINE

                                                Page 1/2  ·  15 categories  ·  120 tools  ·  240 tools tot

   ╭ 01 OSINT ───────────────╮   ╭ 02 OSINT ───────────────╮   ╭ 03 WIFI ────────────────╮   ╭ 04 SOCIAL ──────────────╮   ╭ 05 GEOSINT ─────────────╮
   ├─────────────────────────┤   ├─────────────────────────┤   ├─────────────────────────┤   ├─────────────────────────┤   ├─────────────────────────┤
   │ 001 ⌖  Lookup Phone Number │   │ 009 *  Lookup Port Scanner │   │ 017 o  Wayback          │   │ 025 o  Roblox           │   │ 033 o  Reverse Image    │
   │ 002 @  Lookup Email     │   │ 010 o  ASN Lookup       │   │ 018 ?  Google Dorks     │   │ 026 o  Discord          │   │ 034 =  EXIF             │
   │ 003 #  Lookup Username  │   │ 011 +  Reverse IP       │   │ 019 &  Tech Stack       │   │ 027 o  Instagram        │   │ 035 ⌖  Metadata         │
   │ 004 +  Lookup IP        │   │ 012 >  Traceroute       │   │ 020 =  Robots/Sitemap   │   │ 028 o  Telegram         │   │ 036 *  MetaData Html    │
   │ 005 ~  Lookup Domain    │   │ 013 .  Ping Sweep       │   │ 021 ~  CMS Detect       │   │ 029 o  TikTok           │   │ 037 .  Geosint Tools    │
   │ 006 ?  Whois Lookup     │   │ 014 =  SSL Info         │   │ 022 *  Favicon Hash     │   │ 030 o  Github           │   │ 038 +  Map Lookup       │
   │ 007 =  DNS Lookup       │   │ 015 ·  Coming Soon      │   │ 023 >  Redirect Trace   │   │ 031 o  X (Twitter)      │   │ 039 o  Geosint Test     │
   │ 008 !  Lookup Database  │   │ 016 ·  Coming Soon      │   │ 024 o  Cookie Inspect   │   │ 032 o  LinkedIn         │   │ 040 ~  Color Probe      │
   ╰─────────────────────────╯   ╰─────────────────────────╯   ╰─────────────────────────╯   ╰─────────────────────────╯   ╰─────────────────────────╯

   ╭ 06 API ─────────────────╮   ╭ 07 OPSEC ───────────────╮   ╭ 08 Coming Soon ─────────╮   ╭ 09 Coming Soon ─────────╮   ╭ 10 DISCORD ─────────────╮
   ├─────────────────────────┤   ├─────────────────────────┤   ├─────────────────────────┤   ├─────────────────────────┤   ├─────────────────────────┤
   │ 041 o  Intelx           │   │ 049 @  Opsec Setup      │   │ 057 ·  Coming Soon      │   │ 065 ·  Coming Soon      │   │ 073 o  Webhook Tools    │
   │ 042 o  deadeye.cc       │   │ 050 =  Tutorial Opsec   │   │ 058 ·  Coming Soon      │   │ 066 ·  Coming Soon      │   │ 074 ·  Coming Soon      │
   │ 043 o  oathnet          │   │ 051 !  Vpn              │   │ 059 ·  Coming Soon      │   │ 067 ·  Coming Soon      │   │ 075 ·  Coming Soon      │
   │ 044 o  See-know         │   │ 052 o  Gravatar         │   │ 060 ·  Coming Soon      │   │ 068 ·  Coming Soon      │   │ 076 #  Server Info      │
   │ 045 o  Sherlock         │   │ 053 .  Catch-all        │   │ 061 ·  Coming Soon      │   │ 069 ·  Coming Soon      │   │ 077 >  News Archive     │
   │ 046 o  Maigret          │   │ 054 ≡  Header Parse     │   │ 062 ·  Coming Soon      │   │ 070 ·  Coming Soon      │   │ 078 *  Bot Invite Gen   │
   │ 047 o  Holehe           │   │ 055 ~  Disposable       │   │ 063 ·  Coming Soon      │   │ 071 ·  Coming Soon      │   │ 079 ·  Coming Soon      │
   │ 048 o  Recon-ng         │   │ 056 o  SMTP Probe       │   │ 064 ·  Coming Soon      │   │ 072 ·  Coming Soon      │   │ 080 ·  Coming Soon      │
   ╰─────────────────────────╯   ╰─────────────────────────╯   ╰─────────────────────────╯   ╰─────────────────────────╯   ╰─────────────────────────╯

   ╭ 11 SOCIAL TOOL ─────────╮   ╭ 12 Coming Soon ─────────╮   ╭ 13 CODE ────────────────╮   ╭ 14 CERT ────────────────╮   ╭ 15 SYSTEM ──────────────╮
   ├─────────────────────────┤   ├─────────────────────────┤   ├─────────────────────────┤   ├─────────────────────────┤   ├─────────────────────────┤
   │ 081 ·  Coming Soon      │   │ 089 ·  Coming Soon      │   │ 097 o  Repo Search      │   │ 105 o  crt.sh           │   │ 113 o  Settings         │
   │ 082 ·  Coming Soon      │   │ 090 ·  Coming Soon      │   │ 098 ?  Code Grep        │   │ 106 =  CT Logs          │   │ 114 ~  Disclaimer       │
   │ 083 =  Boost Tools      │   │ 091 ·  Coming Soon      │   │ 099 #  Gist Search      │   │ 107 *  SSL Labs         │   │ 115 *  Theme            │
   │ 084 ~  Join Tools       │   │ 092 ·  Coming Soon      │   │ 100 >  Commit Hunt      │   │ 108 #  Cert Chain       │   │ 116 ?  Info             │
   │ 085 ?  Delete Acc       │   │ 093 ·  Coming Soon      │   │ 101 =  Dependency       │   │ 109 ?  OCSP             │   │ 117 #  About            │
   │ 086 *  Bot Discord      │   │ 094 ·  Coming Soon      │   │ 102 *  CI Config        │   │ 110 ~  HSTS             │   │ 118 =  Update           │
   │ 087 >  Auto Quest       │   │ 095 ·  Coming Soon      │   │ 103 ~  Secret Scan      │   │ 111 >  Cipher Scan      │   │ 119 >  Logs             │
   │ 088 +  Shop             │   │ 096 ·  Coming Soon      │   │ 104 +  Contributors     │   │ 112 +  Other Tools      │   │ 120 !  Exit             │
   ╰─────────────────────────╯   ╰─────────────────────────╯   ╰─────────────────────────╯   ╰─────────────────────────╯   ╰─────────────────────────╯

                                         [001-120] select   [N] next page   [P] prev page   [R] reset   [Q] exit

                                                              ECH0@HuntSint:~# 
"@

# Add the text to the rich textbox with color formatting
$rtb.Text = $display

# Colorize the display
$rtb.Select(0, $rtb.Text.Length)
$rtb.SelectionColor = [System.Drawing.Color]::Cyan

# Color the header
$headerStart = $display.IndexOf("┌────")
$headerEnd = $display.IndexOf("└────") + 80
$rtb.Select($headerStart, 120)
$rtb.SelectionColor = [System.Drawing.Color]::Yellow

# Color the category headers (01 OSINT, 02 OSINT, etc.)
$categories = @("01 OSINT", "02 OSINT", "03 WIFI", "04 SOCIAL", "05 GEOSINT", 
                "06 API", "07 OPSEC", "08 Coming Soon", "09 Coming Soon", "10 DISCORD",
                "11 SOCIAL TOOL", "12 Coming Soon", "13 CODE", "14 CERT", "15 SYSTEM")
foreach ($cat in $categories) {
    $pos = $display.IndexOf("╭ $cat")
    if ($pos -gt 0) {
        $rtb.Select($pos, 30)
        $rtb.SelectionColor = [System.Drawing.Color]::Green
    }
}

# Color tool numbers
$toolNums = @("001", "002", "003", "004", "005", "006", "007", "008", "009", "010",
              "011", "012", "013", "014", "015", "016", "017", "018", "019", "020",
              "021", "022", "023", "024", "025", "026", "027", "028", "029", "030",
              "031", "032", "033", "034", "035", "036", "037", "038", "039", "040")
foreach ($num in $toolNums) {
    $pos = $display.IndexOf("│ $num")
    if ($pos -gt 0) {
        $rtb.Select($pos, 7)
        $rtb.SelectionColor = [System.Drawing.Color]::Yellow
    }
}

# Color status indicators
$rtb.Select($display.IndexOf("● ONLINE"), 10)
$rtb.SelectionColor = [System.Drawing.Color]::Lime

# Color the prompt at the bottom
$promptPos = $display.LastIndexOf("ECH0@HuntSint:~#")
if ($promptPos -gt 0) {
    $rtb.Select($promptPos, 20)
    $rtb.SelectionColor = [System.Drawing.Color]::Yellow
}

# Color the exit command
$exitPos = $display.IndexOf("!  Exit")
if ($exitPos -gt 0) {
    $rtb.Select($exitPos, 8)
    $rtb.SelectionColor = [System.Drawing.Color]::Red
}

$rtb.Select(0, 0)
$rtb.SelectionLength = 0

# Add the rich textbox to the form
$form.Controls.Add($rtb)

# Add status bar
$statusBar = New-Object System.Windows.Forms.Label
$statusBar.Location = New-Object System.Drawing.Point(10, 745)
$statusBar.Size = New-Object System.Drawing.Size(1260, 25)
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 30)
$statusBar.ForeColor = [System.Drawing.Color]::Gray
$statusBar.Font = New-Object System.Drawing.Font("Consolas", 8)
$statusBar.Text = " ⚡ SYSTEM READY  |  PRESS [Q] TO EXIT  |  [N] NEXT PAGE  |  [P] PREV PAGE  |  [R] RESET"
$form.Controls.Add($statusBar)

# Keyboard shortcuts
$form.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Q) {
        $form.Close()
    }
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::N) {
        $statusBar.Text = " ⚡ NAVIGATING TO PAGE 2...  |  PRESS [P] TO RETURN"
    }
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::P) {
        $statusBar.Text = " ⚡ RETURNING TO PAGE 1...  |  PRESS [N] FOR NEXT"
    }
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::R) {
        $statusBar.Text = " ⚡ RESETTING DISPLAY...  |  SYSTEM READY"
        $rtb.Select(0, 0)
        $rtb.SelectionLength = 0
    }
})

# Show the form
$form.Add_Shown({$form.Activate()})
$form.ShowDialog() | Out-Null
