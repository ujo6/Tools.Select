# tool.ps1 — TOOL.SELECT OSINT Hub
# One-liner: irm https://ujo6.github.io/Tools.Select/tool.ps1 | iex

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "TOOL.SELECT v1.0"

# ─── THEME ENGINE ───────────────────────────────────────────────────────────────

$Themes = @{
    purple  = @{ Primary = "Magenta";  Accent = "Cyan";    Glow = "DarkMagenta" }
    red     = @{ Primary = "Red";      Accent = "DarkRed"; Glow = "DarkRed"     }
    blue    = @{ Primary = "Cyan";     Accent = "Blue";    Glow = "DarkCyan"    }
    green   = @{ Primary = "Green";    Accent = "DarkGreen"; Glow = "DarkGreen" }
    cyan    = @{ Primary = "Cyan";     Accent = "DarkCyan"; Glow = "DarkCyan"   }
    orange  = @{ Primary = "Yellow";   Accent = "DarkYellow"; Glow = "DarkYellow" }
    pink    = @{ Primary = "Magenta";  Accent = "DarkMagenta"; Glow = "DarkMagenta" }
    white   = @{ Primary = "White";    Accent = "Gray";    Glow = "DarkGray"    }
}

$ThemeNames    = @("purple","red","blue","green","cyan","orange","pink","white")
$SettingsFile  = Join-Path $env:APPDATA "ToolSelect\settings.json"

function Load-Settings {
    if (Test-Path $SettingsFile) {
        try { return Get-Content $SettingsFile -Raw | ConvertFrom-Json } catch {}
    }
    return [PSCustomObject]@{ theme = "purple"; operator = "OPERATOR"; lang = "en" }
}

function Save-Settings($cfg) {
    $dir = Split-Path $SettingsFile
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $cfg | ConvertTo-Json | Set-Content $SettingsFile -Encoding UTF8
}

$CFG = Load-Settings
$Theme = $Themes[$CFG.theme]

function C($text, $color = $Theme.Primary, $nl = $true) {
    if ($nl) { Write-Host $text -ForegroundColor $color }
    else      { Write-Host $text -ForegroundColor $color -NoNewline }
}

function Dim($text) { Write-Host $text -ForegroundColor DarkGray }

# ─── BANNER ─────────────────────────────────────────────────────────────────────

function Show-Banner {
    Clear-Host
    C @"

  ████████╗ ██████╗  ██████╗ ██╗      ███████╗███████╗██╗     ███████╗ ██████╗████████╗
  ╚══██╔══╝██╔═══██╗██╔═══██╗██║      ██╔════╝██╔════╝██║     ██╔════╝██╔════╝╚══██╔══╝
     ██║   ██║   ██║██║   ██║██║      ███████╗█████╗  ██║     █████╗  ██║        ██║
     ██║   ██║   ██║██║   ██║██║      ╚════██║██╔══╝  ██║     ██╔══╝  ██║        ██║
     ██║   ╚██████╔╝╚██████╔╝███████╗ ███████║███████╗███████╗███████╗╚██████╗   ██║
     ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝ ╚══════╝╚══════╝╚══════╝╚══════╝ ╚═════╝   ╚═╝
"@ $Theme.Primary

    C "                      BY ujo6  —  TOOL.SELECT v1.0  —  OSINT INTELLIGENCE SUITE" DarkGray
    C ""
    C "  ● ONLINE" Green -nl $false
    C "   OPERATOR: " DarkGray -nl $false
    C $CFG.operator.ToUpper() $Theme.Accent -nl $false
    C "   THEME: " DarkGray -nl $false
    C $CFG.theme.ToUpper() $Theme.Primary
    C ""
    C ("  " + ("─" * 88)) DarkGray
    C ""
}

# ─── TOOL DATA ──────────────────────────────────────────────────────────────────

$ToolPages = @(
    @{
        PageLabel = "PAGE 1 — CORE"
        Categories = @(
            @{
                Name = "OSINT — IDENTIFIERS"
                Tag  = "Identifiers, infrastructure & exposure"
                Tools = @(
                    @{ Icon="⌖"; Name="Phone Lookup";    Desc="Validation & carrier lookup";       Status="AVAILABLE"; Action="phone"    }
                    @{ Icon="@"; Name="Email Lookup";     Desc="Validity, MX, breach exposure";     Status="SOON";      Action="soon"     }
                    @{ Icon="#"; Name="Username Lookup";  Desc="Cross-platform enumeration";        Status="AVAILABLE"; Action="username" }
                    @{ Icon="+"; Name="IP Lookup";        Desc="Geo, ASN, reverse DNS";             Status="AVAILABLE"; Action="ip"       }
                    @{ Icon="~"; Name="Domain Lookup";    Desc="Records, registrar, infra";         Status="SOON";      Action="soon"     }
                    @{ Icon="?"; Name="Whois Lookup";     Desc="Domain registration data";          Status="SOON";      Action="soon"     }
                    @{ Icon="="; Name="DNS Lookup";       Desc="A/AAAA/MX/TXT/NS records";         Status="SOON";      Action="soon"     }
                    @{ Icon="!"; Name="Database Lookup";  Desc="Exposure in known leaks";           Status="AVAILABLE"; Action="breach"   }
                )
            }
            @{
                Name = "OSINT — NETWORK"
                Tag  = "Network & infrastructure recon"
                Tools = @(
                    @{ Icon="*"; Name="Port Scanner";   Desc="Open ports & services";      Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="ASN Lookup";     Desc="Autonomous System info";     Status="SOON"; Action="soon" }
                    @{ Icon="+"; Name="Reverse IP";     Desc="Domains on same IP";         Status="SOON"; Action="soon" }
                    @{ Icon=">"; Name="Traceroute";     Desc="Path to host";               Status="SOON"; Action="soon" }
                    @{ Icon="."; Name="Ping Sweep";     Desc="Live hosts in range";        Status="SOON"; Action="soon" }
                    @{ Icon="="; Name="SSL Info";       Desc="TLS certificate & chain";    Status="SOON"; Action="soon" }
                    @{ Icon="~"; Name="Banner Grab";    Desc="Service banner grabbing";    Status="SOON"; Action="soon" }
                    @{ Icon="&"; Name="Shodan Query";   Desc="Exposed hosts via Shodan";   Status="SOON"; Action="soon" }
                )
            }
            @{
                Name = "WEB"
                Tag  = "Sites & public surface analysis"
                Tools = @(
                    @{ Icon="o"; Name="Wayback";        Desc="Historical snapshots";         Status="SOON"; Action="soon" }
                    @{ Icon="?"; Name="Google Dorks";   Desc="Targeted advanced queries";    Status="AVAILABLE"; Action="dorks" }
                    @{ Icon="&"; Name="Tech Stack";     Desc="Detected technologies";        Status="SOON"; Action="soon" }
                    @{ Icon="="; Name="Robots/Sitemap"; Desc="robots.txt & sitemap";         Status="SOON"; Action="soon" }
                    @{ Icon="~"; Name="CMS Detect";     Desc="CMS fingerprint";              Status="SOON"; Action="soon" }
                    @{ Icon="*"; Name="Favicon Hash";   Desc="Hash for pivoting";            Status="SOON"; Action="soon" }
                    @{ Icon=">"; Name="Redirect Trace"; Desc="Redirect chain analysis";      Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Cookie Inspect";  Desc="Cookies & security flags";    Status="SOON"; Action="soon" }
                )
            }
            @{
                Name = "SOCIAL"
                Tag  = "Public profiles per platform"
                Tools = @(
                    @{ Icon="o"; Name="Roblox";    Desc="Public profile lookup";      Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Discord";   Desc="Public info from user ID";   Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Instagram"; Desc="Public profile data";        Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Telegram";  Desc="User/channel info";          Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="TikTok";    Desc="Public profile lookup";      Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Github";    Desc="Profile & activity";         Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="X/Twitter"; Desc="Public profile lookup";      Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="LinkedIn";  Desc="Professional profile";       Status="SOON"; Action="soon" }
                )
            }
            @{
                Name = "GEOSINT"
                Tag  = "Image analysis & geolocation"
                Tools = @(
                    @{ Icon="o"; Name="Reverse Image";   Desc="Reverse image search";      Status="SOON"; Action="soon" }
                    @{ Icon="="; Name="EXIF";            Desc="Image metadata extraction"; Status="SOON"; Action="soon" }
                    @{ Icon="⌖"; Name="Metadata";        Desc="Metadata from photo";       Status="SOON"; Action="soon" }
                    @{ Icon="*"; Name="Metadata HTML";   Desc="HTML metadata analysis";    Status="SOON"; Action="soon" }
                    @{ Icon="."; Name="Geosint Tools";   Desc="Geosint websites";          Status="SOON"; Action="soon" }
                    @{ Icon="+"; Name="Map Lookup";      Desc="Coordinates & maps";        Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Geosint Test";    Desc="Practice geosint test";     Status="SOON"; Action="soon" }
                    @{ Icon="~"; Name="Color Probe";     Desc="Palette extraction";        Status="SOON"; Action="soon" }
                )
            }
            @{
                Name = "API TOOLS"
                Tag  = "Automated recon frameworks"
                Tools = @(
                    @{ Icon="o"; Name="Intelx";     Desc="Intelligence X search";      Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="deadeye.cc"; Desc="Emails/hosts/subdomains";    Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Sherlock";   Desc="Username hunting";           Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Maigret";    Desc="Username profiling";         Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Holehe";     Desc="Email on services check";    Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Recon-ng";   Desc="Modular recon framework";    Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="theHarvester";Desc="Email/host/subdomain enum"; Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Maltego";    Desc="Visual link analysis";       Status="SOON"; Action="soon" }
                )
            }
            @{
                Name = "OPSEC"
                Tag  = "Operational Security"
                Tools = @(
                    @{ Icon="@"; Name="Opsec Setup";          Desc="OPSEC setup guide";            Status="SOON"; Action="soon" }
                    @{ Icon="="; Name="Tutorial Opsec";       Desc="Full OPSEC tutorial";          Status="SOON"; Action="soon" }
                    @{ Icon="!"; Name="VPN Detection";        Desc="VPN/proxy detection";          Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Proxy Check";          Desc="Proxy verification";           Status="SOON"; Action="soon" }
                    @{ Icon="."; Name="Disposable Email";     Desc="Disposable email detect";      Status="SOON"; Action="soon" }
                    @{ Icon="≡"; Name="Browser Fingerprint";  Desc="Browser fingerprint check";   Status="SOON"; Action="soon" }
                    @{ Icon="~"; Name="IP Reputation";        Desc="IP reputation lookup";         Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="Credential Leak";      Desc="Credential exposure check";    Status="SOON"; Action="soon" }
                )
            }
            @{
                Name = "DISCORD"
                Tag  = "Discord intelligence"
                Tools = @(
                    @{ Icon="o"; Name="Webhook Tools";   Desc="Webhook utilities";          Status="SOON"; Action="soon" }
                    @{ Icon="#"; Name="Server Info";     Desc="Server information lookup";  Status="SOON"; Action="soon" }
                    @{ Icon=">"; Name="User Info";       Desc="User information lookup";    Status="SOON"; Action="soon" }
                    @{ Icon="*"; Name="Bot Invite Gen";  Desc="Bot invite link generator";  Status="SOON"; Action="soon" }
                    @{ Icon="."; Name="Message Lookup";  Desc="Message/channel lookup";     Status="SOON"; Action="soon" }
                    @{ Icon="="; Name="Token Checker";   Desc="Token validation check";     Status="SOON"; Action="soon" }
                    @{ Icon="~"; Name="Invite Resolver"; Desc="Resolve invite links";       Status="SOON"; Action="soon" }
                    @{ Icon="+"; Name="Role Lookup";     Desc="Role information";           Status="SOON"; Action="soon" }
                )
            }
        )
    }
    @{
        PageLabel = "PAGE 2 — ADVANCED"
        Categories = @(
            @{
                Name = "EMAIL"
                Tag  = "Email analysis & verification"
                Tools = @(
                    @{ Icon="@"; Name="Email Validate";  Desc="Syntax & domain check";       Status="AVAILABLE"; Action="emailval"  }
                    @{ Icon="="; Name="MX Records";      Desc="Mail exchange records";       Status="AVAILABLE"; Action="mx"        }
                    @{ Icon="#"; Name="SPF / DKIM";      Desc="Anti-spoofing policy check";  Status="SOON";      Action="soon"      }
                    @{ Icon="!"; Name="Email Breach";    Desc="Email in known leaks";        Status="AVAILABLE"; Action="emailbreach"}
                    @{ Icon="o"; Name="Gravatar";        Desc="Linked Gravatar avatar";      Status="SOON";      Action="soon"      }
                    @{ Icon="."; Name="Catch-all";       Desc="Catch-all domain detection";  Status="SOON";      Action="soon"      }
                    @{ Icon="~"; Name="Disposable";      Desc="Disposable email detection";  Status="SOON";      Action="soon"      }
                    @{ Icon="≡"; Name="Header Parse";    Desc="Email header analysis";       Status="SOON";      Action="soon"      }
                )
            }
            @{
                Name = "DOMAIN"
                Tag  = "Domain & DNS intelligence"
                Tools = @(
                    @{ Icon="~"; Name="Whois";          Desc="Domain registration data";      Status="AVAILABLE"; Action="whois"    }
                    @{ Icon="="; Name="DNS Records";    Desc="A/AAAA/MX/TXT/NS records";      Status="AVAILABLE"; Action="dns"      }
                    @{ Icon="o"; Name="Subdomain Enum"; Desc="Subdomain enumeration";         Status="SOON";      Action="soon"     }
                    @{ Icon="?"; Name="Reverse Whois";  Desc="Domains by registrant";         Status="SOON";      Action="soon"     }
                    @{ Icon=">"; Name="DNS History";    Desc="Historical DNS records";        Status="SOON";      Action="soon"     }
                    @{ Icon="*"; Name="Zone Transfer";  Desc="AXFR zone transfer test";       Status="SOON";      Action="soon"     }
                    @{ Icon="+"; Name="Domain Age";     Desc="Domain age & expiry";           Status="SOON";      Action="soon"     }
                    @{ Icon="#"; Name="Typosquat";      Desc="Look-alike domain detection";   Status="SOON";      Action="soon"     }
                )
            }
            @{
                Name = "NETWORK"
                Tag  = "Network & host recon"
                Tools = @(
                    @{ Icon="o"; Name="Port Scan";      Desc="Open ports & services";          Status="AVAILABLE"; Action="portscan" }
                    @{ Icon="="; Name="Banner Grab";    Desc="Service banner grabbing";        Status="SOON";      Action="soon"     }
                    @{ Icon=">"; Name="Traceroute";     Desc="Path to host";                   Status="SOON";      Action="soon"     }
                    @{ Icon="."; Name="Ping Sweep";     Desc="Live hosts in subnet range";     Status="SOON";      Action="soon"     }
                    @{ Icon="?"; Name="ASN Lookup";     Desc="Autonomous System lookup";       Status="SOON";      Action="soon"     }
                    @{ Icon="&"; Name="Reverse IP";     Desc="Domains on same IP";             Status="SOON";      Action="soon"     }
                    @{ Icon="+"; Name="GeoIP";          Desc="IP geolocation data";            Status="AVAILABLE"; Action="geoip"    }
                    @{ Icon="*"; Name="Shodan Query";   Desc="Exposed hosts via Shodan";       Status="SOON";      Action="soon"     }
                )
            }
            @{
                Name = "BREACH"
                Tag  = "Exposure in known leaks & breaches"
                Tools = @(
                    @{ Icon="!"; Name="HIBP Check";        Desc="Have I Been Pwned check";      Status="AVAILABLE"; Action="hibp"    }
                    @{ Icon="?"; Name="Leak DB Query";     Desc="Search in leak databases";     Status="SOON";      Action="soon"    }
                    @{ Icon="o"; Name="Paste Monitor";     Desc="Pastebin search";              Status="SOON";      Action="soon"    }
                    @{ Icon="~"; Name="Domain Breach";     Desc="Leaks by domain";              Status="SOON";      Action="soon"    }
                    @{ Icon=">"; Name="Breach Timeline";   Desc="Exposure timeline";            Status="SOON";      Action="soon"    }
                    @{ Icon="#"; Name="Breach Stats";      Desc="Leak statistics";              Status="SOON";      Action="soon"    }
                    @{ Icon="="; Name="Hash Identify";     Desc="Hash type identification";     Status="SOON";      Action="soon"    }
                    @{ Icon="+"; Name="Exposure Score";    Desc="Digital exposure risk score";  Status="SOON";      Action="soon"    }
                )
            }
            @{
                Name = "METADATA"
                Tag  = "File metadata extraction"
                Tools = @(
                    @{ Icon="="; Name="EXIF Reader";     Desc="Image EXIF metadata";          Status="SOON"; Action="soon" }
                    @{ Icon="#"; Name="Doc Metadata";    Desc="Document metadata";            Status="SOON"; Action="soon" }
                    @{ Icon="o"; Name="PDF Metadata";    Desc="PDF info extraction";          Status="SOON"; Action="soon" }
                    @{ Icon="+"; Name="Image GPS";       Desc="GPS coords from photo";        Status="SOON"; Action="soon" }
                    @{ Icon="~"; Name="Strip Metadata";  Desc="Remove metadata from file";    Status="SOON"; Action="soon" }
                    @{ Icon="*"; Name="Office Meta";     Desc="Office document metadata";     Status="SOON"; Action="soon" }
                    @{ Icon=">"; Name="Media Info";      Desc="Audio/video info";             Status="SOON"; Action="soon" }
                    @{ Icon="?"; Name="File Hash";       Desc="File hash (MD5/SHA)";          Status="SOON"; Action="soon" }
                )
            }
            @{
                Name = "THREAT INTEL"
                Tag  = "Reputation & indicators of compromise"
                Tools = @(
                    @{ Icon="!"; Name="IP Reputation";    Desc="IP threat reputation";         Status="AVAILABLE"; Action="iprep"  }
                    @{ Icon="o"; Name="URL Scan";         Desc="URL safety analysis";          Status="SOON";      Action="soon"   }
                    @{ Icon="~"; Name="Hash Lookup";      Desc="File hash reputation";         Status="SOON";      Action="soon"   }
                    @{ Icon="="; Name="CVE Search";       Desc="Vulnerability search";         Status="SOON";      Action="soon"   }
                    @{ Icon=">"; Name="Malware Sandbox";  Desc="Online sandbox analysis";      Status="SOON";      Action="soon"   }
                    @{ Icon="*"; Name="Threat Feed";      Desc="Live threat feeds";            Status="SOON";      Action="soon"   }
                    @{ Icon="#"; Name="IOC Search";       Desc="Indicator of compromise";      Status="SOON";      Action="soon"   }
                    @{ Icon="+"; Name="MITRE ATT&CK";     Desc="Tactic/technique lookup";      Status="SOON";      Action="soon"   }
                )
            }
            @{
                Name = "CERT"
                Tag  = "Certificate Transparency & TLS"
                Tools = @(
                    @{ Icon="o"; Name="crt.sh";        Desc="CT log search";                  Status="AVAILABLE"; Action="crtsh"  }
                    @{ Icon="="; Name="CT Logs";       Desc="Certificate transparency logs";  Status="SOON";      Action="soon"   }
                    @{ Icon="*"; Name="SSL Labs";      Desc="TLS grade & config";             Status="AVAILABLE"; Action="ssllabs"}
                    @{ Icon="#"; Name="Cert Chain";    Desc="Certificate chain viewer";       Status="SOON";      Action="soon"   }
                    @{ Icon="?"; Name="OCSP";          Desc="Revocation status check";        Status="SOON";      Action="soon"   }
                    @{ Icon="~"; Name="HSTS";          Desc="HSTS policy check";              Status="SOON";      Action="soon"   }
                    @{ Icon=">"; Name="Cipher Scan";   Desc="Supported ciphers list";         Status="SOON";      Action="soon"   }
                    @{ Icon="+"; Name="Cert Expiry";   Desc="Certificate expiry check";       Status="SOON";      Action="soon"   }
                )
            }
            @{
                Name = "CODE"
                Tag  = "Public repository recon"
                Tools = @(
                    @{ Icon="o"; Name="Repo Search";    Desc="Repository search";           Status="SOON"; Action="soon" }
                    @{ Icon="?"; Name="Code Grep";      Desc="Search in code";              Status="SOON"; Action="soon" }
                    @{ Icon="#"; Name="Gist Search";    Desc="Public gist search";          Status="SOON"; Action="soon" }
                    @{ Icon=">"; Name="Commit Hunt";    Desc="Commit history analysis";     Status="SOON"; Action="soon" }
                    @{ Icon="="; Name="Dependency";     Desc="Dependency tree analysis";    Status="SOON"; Action="soon" }
                    @{ Icon="*"; Name="CI Config";      Desc="CI pipeline file search";     Status="SOON"; Action="soon" }
                    @{ Icon="~"; Name="Secret Scan";    Desc="Exposed keys in repos";       Status="SOON"; Action="soon" }
                    @{ Icon="+"; Name="Contributors";   Desc="Contributor map";             Status="SOON"; Action="soon" }
                )
            }
        )
    }
)

# ─── TOOL ACTIONS ───────────────────────────────────────────────────────────────

function Run-PhoneLookup {
    C "  Enter phone number (e.g. +1 555 000 0000): " $Theme.Accent -nl $false
    $num = Read-Host
    if (!$num) { return }
    C ""
    C "  [*] Launching: https://www.truecaller.com/search/us/$($num -replace '\s','')" DarkGray
    C "  [*] Launching: https://www.whitepages.com/phone/$($num -replace '[\s\+\-\(\)]','')" DarkGray
    try { Start-Process "https://www.truecaller.com/search/us/$($num -replace '\s','')" } catch {}
}

function Run-UsernameLookup {
    C "  Enter username: " $Theme.Accent -nl $false
    $u = Read-Host
    if (!$u) { return }
    C ""
    C "  Launching Sherlock-compatible sites for: $u" DarkGray
    $urls = @(
        "https://www.google.com/search?q=%22$u%22+site:twitter.com+OR+site:instagram.com+OR+site:reddit.com",
        "https://github.com/$u",
        "https://www.reddit.com/user/$u",
        "https://twitter.com/$u",
        "https://instagram.com/$u",
        "https://www.tiktok.com/@$u"
    )
    foreach ($url in $urls) {
        C "  [>] $url" DarkGray
        try { Start-Process $url } catch {}
        Start-Sleep -Milliseconds 300
    }
}

function Run-IPLookup {
    C "  Enter IP address: " $Theme.Accent -nl $false
    $ip = Read-Host
    if (!$ip) { return }
    C ""
    C "  [*] Querying ip-api.com ..." DarkGray
    try {
        $r = Invoke-RestMethod "http://ip-api.com/json/$ip" -TimeoutSec 10
        C ""
        C "  ┌─ IP LOOKUP RESULT ─────────────────────────────" $Theme.Primary
        C "  │  IP:        $($r.query)" White
        C "  │  Status:    $($r.status)" White
        C "  │  Country:   $($r.country) ($($r.countryCode))" White
        C "  │  Region:    $($r.regionName) ($($r.region))" White
        C "  │  City:      $($r.city)" White
        C "  │  ZIP:       $($r.zip)" White
        C "  │  Lat/Lon:   $($r.lat), $($r.lon)" White
        C "  │  Timezone:  $($r.timezone)" White
        C "  │  ISP:       $($r.isp)" White
        C "  │  Org:       $($r.org)" White
        C "  │  AS:        $($r.as)" White
        C "  └────────────────────────────────────────────────" $Theme.Primary
    } catch {
        C "  [!] Failed to query ip-api.com: $_" Red
    }
}

function Run-GeoIP {
    C "  Enter IP address: " $Theme.Accent -nl $false
    $ip = Read-Host
    if (!$ip) { return }
    Run-IPLookup-ForIP $ip
}

function Run-IPLookup-ForIP($ip) {
    C ""
    C "  [*] Querying ip-api.com ..." DarkGray
    try {
        $r = Invoke-RestMethod "http://ip-api.com/json/$ip" -TimeoutSec 10
        C ""
        C "  ┌─ GEOIP RESULT ─────────────────────────────────" $Theme.Primary
        C "  │  IP:        $($r.query)" White
        C "  │  Country:   $($r.country) ($($r.countryCode))" White
        C "  │  Region:    $($r.regionName)" White
        C "  │  City:      $($r.city)" White
        C "  │  Lat/Lon:   $($r.lat), $($r.lon)" White
        C "  │  ISP:       $($r.isp)" White
        C "  │  AS:        $($r.as)" White
        C "  └────────────────────────────────────────────────" $Theme.Primary
    } catch {
        C "  [!] Error: $_" Red
    }
}

function Run-BreachCheck {
    C "  Enter email or identifier: " $Theme.Accent -nl $false
    $q = Read-Host
    if (!$q) { return }
    C ""
    C "  [*] Opening breach lookup for: $q" DarkGray
    try { Start-Process "https://haveibeenpwned.com/account/$q" } catch {}
    try { Start-Process "https://www.google.com/search?q=site:pastebin.com+%22$q%22" } catch {}
    C "  [>] Opened: haveibeenpwned.com" DarkGray
    C "  [>] Opened: Google Pastebin search" DarkGray
}

function Run-HIBP {
    C "  Enter email address: " $Theme.Accent -nl $false
    $email = Read-Host
    if (!$email) { return }
    C ""
    C "  [*] Checking Have I Been Pwned ..." DarkGray
    try { Start-Process "https://haveibeenpwned.com/account/$email" } catch {}
    C "  [>] Opened: haveibeenpwned.com/account/$email" DarkGray
}

function Run-EmailValidate {
    C "  Enter email address: " $Theme.Accent -nl $false
    $email = Read-Host
    if (!$email) { return }
    C ""
    $valid = $email -match '^[^@\s]+@[^@\s]+\.[^@\s]+$'
    if ($valid) {
        $domain = $email.Split('@')[1]
        C "  ┌─ EMAIL VALIDATION ──────────────────────────────" $Theme.Primary
        C "  │  Address:   $email" White
        C "  │  Format:    VALID" Green
        C "  │  Domain:    $domain" White
        C "  └────────────────────────────────────────────────" $Theme.Primary
        C ""
        C "  [*] Checking MX records ..." DarkGray
        try {
            $mx = Resolve-DnsName -Name $domain -Type MX -ErrorAction Stop
            foreach ($r in $mx) { C "  [+] MX: $($r.NameExchange) (priority $($r.Preference))" Green }
        } catch {
            C "  [!] No MX records found or DNS error" Yellow
        }
    } else {
        C "  [!] INVALID email format" Red
    }
}

function Run-EmailBreach {
    C "  Enter email address: " $Theme.Accent -nl $false
    $email = Read-Host
    if (!$email) { return }
    C ""
    C "  [*] Opening breach sources for: $email" DarkGray
    try { Start-Process "https://haveibeenpwned.com/account/$email" } catch {}
    try { Start-Process "https://www.dehashed.com/?query=$email" } catch {}
    C "  [>] Opened: haveibeenpwned.com" DarkGray
    C "  [>] Opened: dehashed.com" DarkGray
}

function Run-MXRecords {
    C "  Enter domain: " $Theme.Accent -nl $false
    $domain = Read-Host
    if (!$domain) { return }
    C ""
    C "  [*] Querying MX records for: $domain" DarkGray
    try {
        $mx = Resolve-DnsName -Name $domain -Type MX -ErrorAction Stop
        C ""
        C "  ┌─ MX RECORDS ───────────────────────────────────" $Theme.Primary
        foreach ($r in $mx) {
            C "  │  Priority $($r.Preference)   $($r.NameExchange)" White
        }
        C "  └────────────────────────────────────────────────" $Theme.Primary
    } catch {
        C "  [!] No MX records found for $domain" Red
    }
}

function Run-Whois {
    C "  Enter domain: " $Theme.Accent -nl $false
    $domain = Read-Host
    if (!$domain) { return }
    C ""
    C "  [*] Opening Whois lookup for: $domain" DarkGray
    try { Start-Process "https://www.whois.com/whois/$domain" } catch {}
    try { Start-Process "https://who.is/whois/$domain" } catch {}
    C "  [>] Opened: whois.com/whois/$domain" DarkGray
    C "  [>] Opened: who.is/whois/$domain" DarkGray
}

function Run-DNS {
    C "  Enter domain: " $Theme.Accent -nl $false
    $domain = Read-Host
    if (!$domain) { return }
    C ""
    C "  [*] Querying DNS records for: $domain" DarkGray
    $types = @("A","AAAA","MX","TXT","NS","CNAME")
    C ""
    C "  ┌─ DNS RECORDS ──────────────────────────────────" $Theme.Primary
    foreach ($t in $types) {
        try {
            $recs = Resolve-DnsName -Name $domain -Type $t -ErrorAction Stop
            foreach ($r in $recs) {
                $val = if ($r.IPAddress) { $r.IPAddress }
                       elseif ($r.NameExchange) { $r.NameExchange }
                       elseif ($r.NameHost) { $r.NameHost }
                       elseif ($r.Strings) { $r.Strings -join " " }
                       elseif ($r.PrimaryServer) { $r.PrimaryServer }
                       else { $r.Name }
                C "  │  $($t.PadRight(6))  $val" White
            }
        } catch {}
    }
    C "  └────────────────────────────────────────────────" $Theme.Primary
}

function Run-PortScan {
    C "  Enter host (IP or domain): " $Theme.Accent -nl $false
    $host_ = Read-Host
    if (!$host_) { return }
    C ""
    C "  Enter ports (e.g. 22,80,443,8080) or press ENTER for common: " $Theme.Accent -nl $false
    $portInput = Read-Host
    $ports = if ($portInput) { $portInput.Split(',') | ForEach-Object { [int]$_.Trim() } }
             else { @(21,22,23,25,53,80,110,143,443,445,3306,3389,5900,8080,8443) }
    C ""
    C "  ┌─ PORT SCAN: $host_ ────────────────────────────" $Theme.Primary
    foreach ($p in $ports) {
        $status = "CLOSED"
        $color  = DarkGray
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $ar  = $tcp.BeginConnect($host_, $p, $null, $null)
            $ok  = $ar.AsyncWaitHandle.WaitOne(500, $false)
            if ($ok -and $tcp.Connected) { $status = "OPEN  "; $color = "Green" }
            $tcp.Close()
        } catch {}
        Write-Host "  │  $($p.ToString().PadLeft(5))   " -NoNewline -ForegroundColor DarkGray
        Write-Host $status -ForegroundColor $color
    }
    C "  └────────────────────────────────────────────────" $Theme.Primary
}

function Run-GoogleDorks {
    C "  Enter target domain or keyword: " $Theme.Accent -nl $false
    $q = Read-Host
    if (!$q) { return }
    C ""
    C "  Common Google Dork queries for: $q" DarkGray
    C ""
    $dorks = @(
        "site:$q",
        "site:$q filetype:pdf",
        "site:$q filetype:xls OR filetype:xlsx",
        "site:$q inurl:admin",
        "site:$q inurl:login",
        "site:$q intitle:index.of",
        "`"$q`" site:pastebin.com",
        "`"@$q`" email",
        "site:linkedin.com `"$q`""
    )
    foreach ($d in $dorks) {
        C "  [>] " DarkGray -nl $false
        C $d $Theme.Accent -nl $false
        C "" White
    }
    C ""
    C "  Open all in browser? [Y/N]: " $Theme.Accent -nl $false
    $yn = Read-Host
    if ($yn -eq "Y" -or $yn -eq "y") {
        foreach ($d in $dorks) {
            try { Start-Process "https://www.google.com/search?q=$([System.Uri]::EscapeUriString($d))" } catch {}
            Start-Sleep -Milliseconds 400
        }
    }
}

function Run-CrtSh {
    C "  Enter domain: " $Theme.Accent -nl $false
    $domain = Read-Host
    if (!$domain) { return }
    C ""
    C "  [*] Opening crt.sh for: $domain" DarkGray
    try { Start-Process "https://crt.sh/?q=$domain" } catch {}
    try { Start-Process "https://crt.sh/?q=%25.$domain" } catch {}
    C "  [>] Opened crt.sh (exact + wildcard)" DarkGray
}

function Run-SSLLabs {
    C "  Enter domain: " $Theme.Accent -nl $false
    $domain = Read-Host
    if (!$domain) { return }
    C ""
    C "  [*] Opening SSL Labs for: $domain" DarkGray
    try { Start-Process "https://www.ssllabs.com/ssltest/analyze.html?d=$domain&hideResults=on" } catch {}
    C "  [>] Opened: ssllabs.com" DarkGray
}

function Run-IPRep {
    C "  Enter IP address: " $Theme.Accent -nl $false
    $ip = Read-Host
    if (!$ip) { return }
    C ""
    C "  [*] Opening reputation checks for: $ip" DarkGray
    try { Start-Process "https://www.abuseipdb.com/check/$ip" } catch {}
    try { Start-Process "https://www.virustotal.com/gui/ip-address/$ip" } catch {}
    C "  [>] Opened: abuseipdb.com" DarkGray
    C "  [>] Opened: virustotal.com" DarkGray
}

function Run-Soon {
    C ""
    C "  MODULE NOT YET AVAILABLE" Yellow
    C "  This module is under development. Check back soon." DarkGray
}

$ActionMap = @{
    phone      = { Run-PhoneLookup }
    username   = { Run-UsernameLookup }
    ip         = { Run-IPLookup }
    geoip      = { Run-GeoIP }
    breach     = { Run-BreachCheck }
    hibp       = { Run-HIBP }
    emailval   = { Run-EmailValidate }
    emailbreach= { Run-EmailBreach }
    mx         = { Run-MXRecords }
    whois      = { Run-Whois }
    dns        = { Run-DNS }
    portscan   = { Run-PortScan }
    dorks      = { Run-GoogleDorks }
    crtsh      = { Run-CrtSh }
    ssllabs    = { Run-SSLLabs }
    iprep      = { Run-IPRep }
    soon       = { Run-Soon }
}

# ─── DISPLAY HELPERS ────────────────────────────────────────────────────────────

function Show-CategoryMenu($cat) {
    C "  ┌─ $($cat.Name) " $Theme.Primary -nl $false
    C "─ $($cat.Tag)" DarkGray
    C "  │" DarkGray
    $i = 1
    foreach ($t in $cat.Tools) {
        $statusColor = if ($t.Status -eq "AVAILABLE") { "Green" } else { "DarkGray" }
        $nameColor   = if ($t.Status -eq "AVAILABLE") { "White"  } else { "DarkGray" }
        $badge       = if ($t.Status -eq "AVAILABLE") { "[LIVE]" } else { "[SOON]" }

        Write-Host "  │  " -NoNewline -ForegroundColor DarkGray
        Write-Host " $i " -NoNewline -BackgroundColor DarkGray -ForegroundColor White
        Write-Host " " -NoNewline
        Write-Host "$($t.Icon)  " -NoNewline -ForegroundColor $Theme.Primary
        Write-Host "$($t.Name.PadRight(20))" -NoNewline -ForegroundColor $nameColor
        Write-Host "  $($t.Desc.PadRight(38))" -NoNewline -ForegroundColor DarkGray
        Write-Host $badge -ForegroundColor $statusColor
        $i++
    }
    C "  │" DarkGray
    C "  └─ [1-8] SELECT   [B] BACK   [Q] QUIT ─────────────" $Theme.Primary
    C ""
}

function Show-PageMenu($page) {
    C "  ┌─ $($page.PageLabel) ─────────────────────────────────────────" $Theme.Primary
    C "  │" DarkGray
    $i = 1
    foreach ($cat in $page.Categories) {
        $available = ($cat.Tools | Where-Object { $_.Status -eq "AVAILABLE" }).Count
        Write-Host "  │  " -NoNewline -ForegroundColor DarkGray
        Write-Host " $i " -NoNewline -BackgroundColor DarkGray -ForegroundColor White
        Write-Host "  " -NoNewline
        Write-Host "$($cat.Name.PadRight(22))" -NoNewline -ForegroundColor $Theme.Accent
        Write-Host "  $($cat.Tag.PadRight(42))" -NoNewline -ForegroundColor DarkGray
        Write-Host "$available live" -ForegroundColor Green
        $i++
    }
    C "  │" DarkGray
    C "  └─ [1-$($page.Categories.Count)] SELECT   [P] PAGES   [S] SETTINGS   [Q] QUIT ──" $Theme.Primary
    C ""
}

function Show-PageSelect {
    C "  ┌─ SELECT PAGE ───────────────────────────────────────" $Theme.Primary
    C "  │" DarkGray
    $i = 1
    foreach ($p in $ToolPages) {
        Write-Host "  │  " -NoNewline -ForegroundColor DarkGray
        Write-Host " $i " -NoNewline -BackgroundColor DarkGray -ForegroundColor White
        Write-Host "  $($p.PageLabel)" -ForegroundColor $Theme.Accent
        $i++
    }
    C "  │" DarkGray
    C "  └─ [1-$($ToolPages.Count)] SELECT   [Q] QUIT ──────────────────────────" $Theme.Primary
    C ""
}

function Show-Settings {
    Show-Banner
    C "  ┌─ SETTINGS ─────────────────────────────────────────" $Theme.Primary
    C "  │" DarkGray
    C "  │  OPERATOR NAME: $($CFG.operator)" White
    C "  │  THEME:         $($CFG.theme)" White
    C "  │" DarkGray
    C "  │  [1] Change operator name" White
    C "  │  [2] Change theme" White
    C "  │  [B] Back" White
    C "  │" DarkGray
    C "  └────────────────────────────────────────────────────" $Theme.Primary
    C ""
    C "  Choice: " $Theme.Accent -nl $false
    $ch = Read-Host
    switch ($ch) {
        "1" {
            C "  New operator name: " $Theme.Accent -nl $false
            $n = Read-Host
            if ($n) { $CFG.operator = $n.ToUpper(); Save-Settings $CFG }
        }
        "2" {
            C ""
            C "  Available themes:" DarkGray
            for ($i = 0; $i -lt $ThemeNames.Count; $i++) {
                C "  [$($i+1)] $($ThemeNames[$i])" White
            }
            C "  Choice: " $Theme.Accent -nl $false
            $tc = Read-Host
            $ti = [int]$tc - 1
            if ($ti -ge 0 -and $ti -lt $ThemeNames.Count) {
                $CFG.theme = $ThemeNames[$ti]
                Save-Settings $CFG
                $script:Theme = $Themes[$CFG.theme]
                C "  Theme set to: $($CFG.theme)" Green
            }
        }
    }
}

function Show-Disclaimer {
    C ""
    C "  ┌─ DISCLAIMER ───────────────────────────────────────" $Theme.Primary
    C "  │" DarkGray
    C "  │  TOOL.SELECT is intended for educational and" White
    C "  │  ethical security research purposes only." White
    C "  │" DarkGray
    C "  │  Use of these tools against systems or persons" White
    C "  │  without explicit permission is illegal." White
    C "  │" DarkGray
    C "  │  The author assumes no liability for misuse." White
    C "  │" DarkGray
    C "  └────────────────────────────────────────────────────" $Theme.Primary
    C ""
}

# ─── MAIN LOOP ──────────────────────────────────────────────────────────────────

$currentPageIdx = 0

while ($true) {
    Show-Banner
    Show-PageMenu $ToolPages[$currentPageIdx]

    C "  > " $Theme.Primary -nl $false
    $input = Read-Host

    switch -Regex ($input.Trim().ToLower()) {
        "^q$" { C "  Goodbye, $($CFG.operator)." $Theme.Primary; Start-Sleep 1; exit }
        "^p$" {
            Show-Banner
            Show-PageSelect
            C "  > " $Theme.Primary -nl $false
            $pi = Read-Host
            $pidx = [int]$pi - 1
            if ($pidx -ge 0 -and $pidx -lt $ToolPages.Count) { $currentPageIdx = $pidx }
        }
        "^s$" { Show-Settings }
        "^d$" { Show-Banner; Show-Disclaimer; C "  Press ENTER to continue..." DarkGray; Read-Host | Out-Null }
        default {
            $catIdx = [int]$input - 1
            if ($catIdx -ge 0 -and $catIdx -lt $ToolPages[$currentPageIdx].Categories.Count) {
                $cat = $ToolPages[$currentPageIdx].Categories[$catIdx]

                while ($true) {
                    Show-Banner
                    Show-CategoryMenu $cat

                    C "  > " $Theme.Primary -nl $false
                    $sel = Read-Host

                    if ($sel -eq "b" -or $sel -eq "B") { break }
                    if ($sel -eq "q" -or $sel -eq "Q") { C "  Goodbye, $($CFG.operator)." $Theme.Primary; Start-Sleep 1; exit }

                    $toolIdx = [int]$sel - 1
                    if ($toolIdx -ge 0 -and $toolIdx -lt $cat.Tools.Count) {
                        $tool = $cat.Tools[$toolIdx]
                        Show-Banner
                        C "  ┌─ $($tool.Icon)  $($tool.Name.ToUpper()) ──────────────────────────────" $Theme.Primary
                        C "  │  $($tool.Desc)" DarkGray
                        C "  └────────────────────────────────────────────────" $Theme.Primary
                        C ""

                        $action = $ActionMap[$tool.Action]
                        if ($action) { & $action } else { Run-Soon }

                        C ""
                        C "  Press ENTER to continue..." DarkGray
                        Read-Host | Out-Null
                    }
                }
            }
        }
    }
}
