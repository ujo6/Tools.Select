# =====================================================================
# HUNTSINT.ps1 — PowerShell Port v5.0.0
# Full OSINT suite with 240+ tools, 2 pages, 30 categories
# One-liner: irm https://ujo6.github.io/Tools.Select/huntsint.ps1 | iex
# =====================================================================

# === SETUP ===
$Host.UI.RawUI.WindowTitle = "HuntSint v5.0.0"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$global:RESET = "`e[0m"
$global:BOLD = "`e[1m"
$global:CLEAR = "`e[H`e[2J"
$global:HIDE = "`e[?25l"
$global:SHOW = "`e[?25h"

# === COLOR FUNCTIONS ===
function rgb($r,$g,$b) { return "`e[38;2;${r};${g};${b}m" }
function bg($r,$g,$b) { return "`e[48;2;${r};${g};${b}m" }

# === THEMES ===
$global:THEMES = @{
    "red" = @{
        deep=(200,30,30); prim=(255,55,55); bright=(255,110,110); glow=(255,180,175)
        border=(150,40,40); dim=(180,100,100); badge=(235,60,60); hi=(190,45,45)
        grad=((255,45,45),(255,140,110))
    }
    "purple" = @{
        deep=(140,50,230); prim=(170,80,255); bright=(195,130,255); glow=(220,185,255)
        border=(110,55,160); dim=(140,110,175); badge=(170,95,240); hi=(130,65,210)
        grad=((165,55,255),(90,150,255))
    }
    "blue" = @{
        deep=(35,95,235); prim=(70,140,255); bright=(120,185,255); glow=(180,215,255)
        border=(45,85,165); dim=(105,130,185); badge=(65,130,245); hi=(45,95,215)
        grad=((40,100,255),(70,215,255))
    }
    "green" = @{
        deep=(25,185,90); prim=(45,220,110); bright=(120,255,160); glow=(185,255,200)
        border=(30,120,65); dim=(95,165,120); badge=(45,210,105); hi=(30,150,80)
        grad=((35,205,95),(150,255,130))
    }
    "cyan" = @{
        deep=(0,190,185); prim=(20,220,210); bright=(120,250,235); glow=(190,255,245)
        border=(20,120,120); dim=(95,170,165); badge=(25,215,205); hi=(20,150,145)
        grad=((0,210,200),(130,255,235))
    }
    "orange" = @{
        deep=(230,120,15); prim=(255,150,35); bright=(255,185,90); glow=(255,215,160)
        border=(160,95,25); dim=(190,140,90); badge=(245,150,40); hi=(200,115,25)
        grad=((255,130,20),(255,205,95))
    }
    "pink" = @{
        deep=(230,40,140); prim=(255,60,160); bright=(255,120,195); glow=(255,185,225)
        border=(155,40,110); dim=(195,100,155); badge=(245,60,165); hi=(200,45,135)
        grad=((255,55,150),(180,75,255))
    }
    "white" = @{
        deep=(150,150,165); prim=(205,205,220); bright=(230,230,245); glow=(248,248,255)
        border=(110,110,125); dim=(150,150,165); badge=(215,215,230); hi=(120,120,140)
        grad=((150,150,165),(248,248,255))
    }
    "rainbow" = @{
        deep=(190,90,255); prim=(210,120,255); bright=(225,160,255); glow=(240,205,255)
        border=(120,90,150); dim=(155,140,175); badge=(215,120,255); hi=(150,80,220)
        grad=((255,70,70),(70,160,255)); rainbow=$true
    }
}

# === GLOBAL COLOR VARS ===
$global:C_DEEP = ""; $global:C_PRIM = ""; $global:C_BRIGHT = ""; $global:C_GLOW = ""
$global:C_BORDER = ""; $global:C_DIMTXT = ""; $global:C_BADGE = ""
$global:THEME_HI = (120,60,200); $global:THEME_RAINBOW = $false
$global:GRAD_S = (110,30,175); $global:GRAD_E = (210,140,255); $global:THEME_NAME = "purple"
$global:C_TEXT = rgb 228 222 240; $global:C_OK = rgb 120 230 160; $global:C_WARN = rgb 255 95 120

function Set-Theme {
    param($name)
    $th = $global:THEMES[$name]
    if (-not $th) { $th = $global:THEMES["purple"] }
    $global:THEME_NAME = $name
    $global:C_DEEP = rgb $th.deep[0] $th.deep[1] $th.deep[2]
    $global:C_PRIM = rgb $th.prim[0] $th.prim[1] $th.prim[2]
    $global:C_BRIGHT = rgb $th.bright[0] $th.bright[1] $th.bright[2]
    $global:C_GLOW = rgb $th.glow[0] $th.glow[1] $th.glow[2]
    $global:C_BORDER = rgb $th.border[0] $th.border[1] $th.border[2]
    $global:C_DIMTXT = rgb $th.dim[0] $th.dim[1] $th.dim[2]
    $global:C_BADGE = rgb $th.badge[0] $th.badge[1] $th.badge[2]
    $global:THEME_HI = $th.hi
    $global:THEME_RAINBOW = $th.rainbow
    $global:GRAD_S = $th.grad[0]; $global:GRAD_E = $th.grad[1]
}

Set-Theme "purple"

# === UTILITY FUNCTIONS ===
function vis_len { param($s) ($s -replace "`e\[[0-9;]*[a-zA-Z]","").Length }
function term_w { try { (Get-Host).UI.RawUI.WindowSize.Width } catch { 140 } }
function term_h { try { (Get-Host).UI.RawUI.WindowSize.Height } catch { 40 } }

function center {
    param($s, $color="", $width=$null)
    $w = if ($width) { $width } else { term_w }
    $pad = [Math]::Max(($w - (vis_len $s)) / 2, 0)
    Write-Host (" " * [Math]::Floor($pad) + $color + $s + $global:RESET)
}

function gradient_banner {
    param($n)
    if ($global:THEME_RAINBOW) {
        $out = @()
        for ($i=0; $i -lt $n; $i++) {
            $h = ($i / [Math]::Max($n-1,1)) * 0.85
            $r,$g,$b = [System.Drawing.Color]::FromArgb(255, [int]([Math]::Sin($h*6.283)*127+128), [int]([Math]::Sin(($h+0.333)*6.283)*127+128), [int]([Math]::Sin(($h+0.667)*6.283)*127+128)).R, [System.Drawing.Color]::FromArgb(255, [int]([Math]::Sin($h*6.283)*127+128), [int]([Math]::Sin(($h+0.333)*6.283)*127+128), [int]([Math]::Sin(($h+0.667)*6.283)*127+128)).G, [System.Drawing.Color]::FromArgb(255, [int]([Math]::Sin($h*6.283)*127+128), [int]([Math]::Sin(($h+0.333)*6.283)*127+128), [int]([Math]::Sin(($h+0.667)*6.283)*127+128)).B
            $out += rgb $r $g $b
        }
        return $out
    }
    $s=$global:GRAD_S; $e=$global:GRAD_E; $out=@()
    for ($i=0; $i -lt $n; $i++) {
        $t = $i / [Math]::Max($n-1,1)
        $out += rgb ([int]($s[0]+($e[0]-$s[0])*$t)) ([int]($s[1]+($e[1]-$s[1])*$t)) ([int]($s[2]+($e[2]-$s[2])*$t))
    }
    return $out
}

# === ASCII ART ===
$global:ASCII_ART = @(
    "   ▄█    █▄    ███    █▄  ███▄▄▄▄       ███        ▄████████  ▄█  ███▄▄▄▄       ███     ",
    "  ███    ███   ███    ███ ███▀▀▀██▄ ▀█████████▄   ███    ███ ███  ███▀▀▀██▄ ▀█████████▄ ",
    "  ███    ███   ███    ███ ███   ███    ▀███▀▀██   ███    █▀  ███▌ ███   ███    ▀███▀▀██ ",
    " ▄███▄▄▄▄███▄▄ ███    ███ ███   ███     ███   ▀   ███        ███▌ ███   ███     ███   ▀ ",
    "▀▀███▀▀▀▀███▀  ███    ███ ███   ███     ███     ▀███████████ ███▌ ███   ███     ███     ",
    "  ███    ███   ███    ███ ███   ███     ███              ███ ███  ███   ███     ███     ",
    "  ███    ███   ███    ███ ███   ███     ███        ▄█    ███ ███  ███   ███     ███     ",
    "  ███    █▀    ████████▀   ▀█   █▀     ▄████▀    ▄████████▀  █▀    ▀█   █▀     ▄████▀    "
)

$global:LOGO_ART = @"
                                                   >@@|
                                                   >@@|
                                                   >@@|
                                                   >@@|
                                          >|a@@@@@@@@@|
                                     }@@@@@@@@@@@@@@@@| 000M|
                                 ;@@@@@@O  @@@@@@@@@@@|  j000000_
                              }@@@@@v   |@@@@@@@@@@@@@| 00J  |00000j
                            @@@@@_     @@@@@@@@@@@@@@@| 0000    ;00000^
                         ;@@@@v       _@@@@@@@     >@@| 0000v      }0000_
                       ^@@@@_         @@@@@@@      ^O@| 00000        ;0000_
                        @@@@;         @@@@@@@      ;p@| 00000         0000^
                          @@@@p       >@@@@@@@^    >@@| 0000v      J0000;
                            O@@@@|     M@@@@@@@@@@@@@@| 0000    >00000
                              ;@@@@@J^  }@@@@@@@@@@@@@| 00v  j00000}
                                 >@@@@@@@_;@@@@@@@@@@@| ;M000000_
                                     >@@@@@@@@@@@@@@@@| 00000}
                                          ^jpM@@@@@@@@|
                                                   >@@|
                                                   >@@|
                                                   >@@|
                                                   >@@|
                                                   >@@|
"@ -split "`n"

# === LOCALIZATION ===
$global:TR = @{
    "suite" = @{"it"="SUITE DI INTELLIGENCE"; "en"="INTELLIGENCE SUITE"; "ru"="РАЗВЕДЫВАТЕЛЬНЫЙ НАБОР"}
    "present" = @{"it"="~ Giorno Presente, Tempo Presente ~"; "en"="~ Present Day, Present Time ~"; "ru"="~ Настоящий день, настоящее время ~"}
    "categories" = @{"it"="CATEGORIE"; "en"="CATEGORIES"; "ru"="КАТЕГОРИИ"}
    "monitor" = @{"it"="MONITOR"; "en"="MONITOR"; "ru"="МОНИТОР"}
    "online" = @{"it"="● ONLINE"; "en"="● ONLINE"; "ru"="● В СЕТИ"}
    "ready" = @{"it"="PRONTO"; "en"="READY"; "ru"="ГОТОВ"}
    "tools" = @{"it"="strumenti"; "en"="tools"; "ru"="инструм."}
    "section" = @{"it"="sezione"; "en"="section"; "ru"="раздел"}
    "f_section" = @{"it"="sezione"; "en"="section"; "ru"="раздел"}
    "f_select" = @{"it"="seleziona"; "en"="select"; "ru"="выбор"}
    "f_exit" = @{"it"="esci"; "en"="exit"; "ru"="выход"}
    "f_reset" = @{"it"="reset"; "en"="reset"; "ru"="сброс"}
    "f_next" = @{"it"="pag. succ."; "en"="next page"; "ru"="след. стр."}
    "f_prev" = @{"it"="pag. prec."; "en"="prev page"; "ru"="пред. стр."}
    "page" = @{"it"="Pagina"; "en"="Page"; "ru"="Страница"}
    "selected" = @{"it"="Selezionato"; "en"="Selected"; "ru"="Выбрано"}
    "invalid" = @{"it"="ID non valido"; "en"="Invalid ID"; "ru"="Неверный ID"}
    "soon" = @{"it"="non ancora disponibile"; "en"="not yet available"; "ru"="пока недоступно"}
    "nofile" = @{"it"="file non trovato"; "en"="file not found"; "ru"="файл не найден"}
    "access" = @{"it"="» PREMI INVIO PER ACCEDERE «"; "en"="» PRESS ENTER TO ACCESS «"; "ru"="» НАЖМИТЕ ВВОД ДЛЯ ВХОДА «"}
    "setup" = @{"it"="CONFIGURAZIONE INIZIALE"; "en"="FIRST RUN SETUP"; "ru"="ПЕРВЫЙ ЗАПУСК"}
    "ask_user" = @{"it"="Inserisci il tuo username operatore:"; "en"="Enter your operator username:"; "ru"="Введите имя оператора:"}
    "lang_sel" = @{"it"="Lingua selezionata"; "en"="Selected language"; "ru"="Выбранный язык"}
    "init" = @{"it"="Inizializzazione interfaccia..."; "en"="Initializing interface..."; "ru"="Инициализация интерфейса..."}
    "ask_color" = @{"it"="Seleziona il tema colore:"; "en"="Select the color theme:"; "ru"="Выберите цветовую тему:"}
    "color_sel" = @{"it"="Tema selezionato"; "en"="Selected theme"; "ru"="Выбранная тема"}
    "operator" = @{"it"="Operatore"; "en"="Operator"; "ru"="Оператор"}
}

function t { param($key) return $global:TR[$key][$script:lang] }
function loc { param($d) return $d[$script:lang] }

# === PLACEHOLDER ===
$global:PLACEHOLDER_NAME = @{"it"="Prossimamente"; "en"="Coming Soon"; "ru"="Скоро"}
$global:PLACEHOLDER_DESC = @{"it"="Modulo in arrivo"; "en"="Module coming soon"; "ru"="Модуль скоро"}

function SoonSection {
    $items = @()
    for ($i=0; $i -lt 8; $i++) {
        $items += @(("·", $global:PLACEHOLDER_NAME, $global:PLACEHOLDER_DESC, "soon.ps1"))
    }
    return @{"name"=$global:PLACEHOLDER_NAME; "tag"=$global:PLACEHOLDER_NAME; "items"=$items}
}

# =====================================================================
# PAGE 1 — 15 Categories · 120 Tools (IDs 001-120)
# =====================================================================
$global:PAGE1 = @(
    @{
        "name"=@{"it"="OSINT"; "en"="OSINT"; "ru"="OSINT"}
        "tag"=@{"it"="Identificatori, infrastruttura & esposizione"; "en"="Identifiers, infrastructure & exposure"; "ru"="Идентификаторы, инфраструктура и утечки"}
        "items"=@(
            @("⌖", @{"it"="Lookup Phone"; "en"="Lookup Phone Number"; "ru"="Номер тел."}, @{"it"="Validazione e carrier"; "en"="Validation & carrier"; "ru"="Проверка и оператор"}, "phone.ps1"),
            @("@", @{"it"="Lookup Email"; "en"="Lookup Email"; "ru"="Lookup Email"}, @{"it"="Validità, MX, leak"; "en"="Validity, MX, leak"; "ru"="Валидность, MX, утечки"}, "email.ps1"),
            @("#", @{"it"="Lookup Username"; "en"="Lookup Username"; "ru"="Имя польз."}, @{"it"="Enumerazione multi-piattaforma"; "en"="Cross-platform enum"; "ru"="Поиск по платформам"}, "username.ps1"),
            @("+", @{"it"="Lookup IP"; "en"="Lookup IP"; "ru"="Поиск IP"}, @{"it"="Geo, ASN, reverse DNS"; "en"="Geo, ASN, reverse DNS"; "ru"="Гео, ASN, reverse DNS"}, "ip.ps1"),
            @("~", @{"it"="Lookup Dominio"; "en"="Lookup Domain"; "ru"="Домен"}, @{"it"="Record, registrar, infra"; "en"="Records, registrar, infra"; "ru"="Записи, регистратор"}, "domain.ps1"),
            @("?", @{"it"="Lookup DNS"; "en"="Whois Lookup"; "ru"="Whois"}, @{"it"="Dati di registrazione"; "en"="Registration data"; "ru"="Данные регистрации"}, "whois.ps1"),
            @("=", @{"it"="Lookup Whois"; "en"="DNS Lookup"; "ru"="DNS-запрос"}, @{"it"="A/AAAA/MX/TXT/NS"; "en"="A/AAAA/MX/TXT/NS"; "ru"="A/AAAA/MX/TXT/NS"}, "dns.ps1"),
            @("!", @{"it"="Lookup Database"; "en"="Lookup Database"; "ru"="Утечки"}, @{"it"="Esposizione in leak noti"; "en"="Exposure in known leaks"; "ru"="Проверка по утечкам"}, "breach.ps1")
        )
    },
    @{
        "name"=@{"it"="OSINT"; "en"="OSINT"; "ru"="OSINT"}
        "tag"=@{"it"="Ricognizione di rete e infrastruttura"; "en"="Network & infrastructure recon"; "ru"="Разведка сети и инфраструктуры"}
        "items"=@(
            @("*", @{"it"="Wayback"; "en"="Lookup Port Scanner"; "ru"="Скан портов"}, @{"it"="Porte e servizi esposti"; "en"="Open ports & services"; "ru"="Открытые порты"}, "port.ps1"),
            @("o", @{"it"="Google Dorks"; "en"="ASN Lookup"; "ru"="ASN"}, @{"it"="Autonomous System"; "en"="Autonomous System"; "ru"="Автономная система"}, "asn.ps1"),
            @("+", @{"it"="Robots.txt / Sitemap"; "en"="Reverse IP"; "ru"="Reverse IP"}, @{"it"="Domini sullo stesso IP"; "en"="Domains on same IP"; "ru"="Домены на одном IP"}, "revip.ps1"),
            @(">", @{"it"="Tech Stack"; "en"="Traceroute"; "ru"="Traceroute"}, @{"it"="Percorso verso host"; "en"="Path to host"; "ru"="Путь до узла"}, "traceroute.ps1"),
            @(".", @{"it"="Cookie Inspect"; "en"="Ping Sweep"; "ru"="Ping Sweep"}, @{"it"="Host attivi nel range"; "en"="Live hosts in range"; "ru"="Активные узлы"}, "ping.ps1"),
            @("=", @{"it"="Redirect Trace"; "en"="SSL Info"; "ru"="SSL"}, @{"it"="Certificato e catena TLS"; "en"="TLS cert & chain"; "ru"="Сертификат TLS"}, "ssl.ps1"),
            @("·", $global:PLACEHOLDER_NAME, $global:PLACEHOLDER_DESC, "soon.ps1"),
            @("·", $global:PLACEHOLDER_NAME, $global:PLACEHOLDER_DESC, "soon.ps1")
        )
    },
    @{
        "name"=@{"it"="WIFI"; "en"="WIFI"; "ru"="ВЕБ"}
        "tag"=@{"it"="Analisi di siti e superfici pubbliche"; "en"="Sites & public surface analysis"; "ru"="Анализ сайтов и поверхности"}
        "items"=@(
            @("o", @{"it"="Port Scanner"; "en"="Wayback"; "ru"="Wayback"}, @{"it"="Snapshot storici"; "en"="Historical snapshots"; "ru"="История страниц"}, "wayback.ps1"),
            @("?", @{"it"="ASN Lookup"; "en"="Google Dorks"; "ru"="Google Dorks"}, @{"it"="Query avanzate mirate"; "en"="Targeted advanced queries"; "ru"="Точные запросы"}, "dorks.ps1"),
            @("&", @{"it"="Reverse IP"; "en"="Tech Stack"; "ru"="Стек технол."}, @{"it"="Tecnologie rilevate"; "en"="Detected technologies"; "ru"="Технологии сайта"}, "tech.ps1"),
            @("=", @{"it"="Traceroute"; "en"="Robots/Sitemap"; "ru"="Robots/Map"}, @{"it"="robots.txt e sitemap"; "en"="robots.txt & sitemap"; "ru"="robots и sitemap"}, "robots.ps1"),
            @("~", @{"it"="Ping Sweep"; "en"="CMS Detect"; "ru"="CMS"}, @{"it"="Riconoscimento CMS"; "en"="CMS fingerprint"; "ru"="Определение CMS"}, "cms.ps1"),
            @("*", @{"it"="SSL Info"; "en"="Favicon Hash"; "ru"="Favicon Hash"}, @{"it"="Hash per pivoting"; "en"="Hash for pivoting"; "ru"="Хеш favicon"}, "favicon.ps1"),
            @(">", @{"it"="HTTP Headers"; "en"="Redirect Trace"; "ru"="Редиректы"}, @{"it"="Catena di redirect"; "en"="Redirect chain"; "ru"="Цепочка редиректов"}, "redirect.ps1"),
            @("o", @{"it"="Subdomain Enum"; "en"="Cookie Inspect"; "ru"="Cookie"}, @{"it"="Cookie e flag sicurezza"; "en"="Cookies & security flags"; "ru"="Cookie и флаги"}, "cookie.ps1")
        )
    },
    @{
        "name"=@{"it"="SOCIAL"; "en"="SOCIAL"; "ru"="СОЦСЕТИ"}
        "tag"=@{"it"="Profili pubblici per piattaforma"; "en"="Public profiles per platform"; "ru"="Публичные профили"}
        "items"=@(
            @("o", @{"it"="Roblox"; "en"="Roblox"; "ru"="Roblox"}, @{"it"="Profilo pubblico"; "en"="Public profile"; "ru"="Публичный профиль"}, "roblox.ps1"),
            @("o", @{"it"="Discord"; "en"="Discord"; "ru"="Discord"}, @{"it"="Info pubbliche da ID"; "en"="Public info from ID"; "ru"="Инфо по ID"}, "discord.ps1"),
            @("o", @{"it"="Instagram"; "en"="Instagram"; "ru"="Instagram"}, @{"it"="Dati pubblici profilo"; "en"="Public profile data"; "ru"="Данные профиля"}, "instagram.ps1"),
            @("o", @{"it"="Telegram"; "en"="Telegram"; "ru"="Telegram"}, @{"it"="Info utente/canale"; "en"="User/channel info"; "ru"="Юзер/канал"}, "telegram.ps1"),
            @("o", @{"it"="TikTok"; "en"="TikTok"; "ru"="TikTok"}, @{"it"="Profilo pubblico"; "en"="Public profile"; "ru"="Публичный профиль"}, "tiktok.ps1"),
            @("o", @{"it"="Github"; "en"="Github"; "ru"="Github"}, @{"it"="Profilo e attività"; "en"="Profile & activity"; "ru"="Профиль и активность"}, "github.ps1"),
            @("o", @{"it"="X"; "en"="X (Twitter)"; "ru"="X (Twitter)"}, @{"it"="Profilo pubblico"; "en"="Public profile"; "ru"="Публичный профиль"}, "twitter.ps1"),
            @("o", @{"it"="LinkedIn"; "en"="LinkedIn"; "ru"="LinkedIn"}, @{"it"="Profilo professionale"; "en"="Professional profile"; "ru"="Проф. профиль"}, "linkedin.ps1")
        )
    },
    @{
        "name"=@{"it"="GEOSINT"; "en"="GEOSINT"; "ru"="ИЗОБРАЖ."}
        "tag"=@{"it"="Analisi immagini e geolocalizzazione"; "en"="Image analysis & geolocation"; "ru"="Анализ изображений и гео"}
        "items"=@(
            @("o", @{"it"="Reverse Img"; "en"="Reverse Image"; "ru"="Reverse Image"}, @{"it"="Ricerca inversa"; "en"="Reverse search"; "ru"="Обратный поиск"}, "revimg.ps1"),
            @("=", @{"it"="EXIF"; "en"="EXIF"; "ru"="EXIF"}, @{"it"="Metadati immagine"; "en"="Image metadata"; "ru"="Метаданные"}, "exif.ps1"),
            @("⌖", @{"it"="Metadata"; "en"="Metadata"; "ru"="Метаданные"}, @{"it"="Metadati foto"; "en"="Metadata photo"; "ru"="Метаданные фотографий"}, "metadata.ps1"),
            @("*", @{"it"="MetaData Html"; "en"="MetaData Html"; "ru"="Метаданные Html."}, @{"it"="Metadati foto"; "en"="Metadata photo"; "ru"="Метаданные фотографий"}, "metahtml.ps1"),
            @(".", @{"it"="Strumenti Geosint"; "en"="Geosint Tools"; "ru"="Инструменты Geosint"}, @{"it"="SIti Geosint"; "en"="Geosint Website"; "ru"="Сайт Геосинта"}, "geosint.ps1"),
            @("+", @{"it"="Map Lookup"; "en"="Map Lookup"; "ru"="Карты"}, @{"it"="Coordinate e mappe"; "en"="Coordinates & maps"; "ru"="Координаты и карты"}, "map.ps1"),
            @("o", @{"it"="Train Geosint"; "en"="Geosint Test"; "ru"="Поезд Геосинт"}, @{"it"="Test di geosint"; "en"="Geosint test"; "ru"="Тест Geosint"}, "geotest.ps1"),
            @("~", @{"it"="Color Probe"; "en"="Color Probe"; "ru"="Цвета"}, @{"it"="Estrazione palette"; "en"="Palette extraction"; "ru"="Извлечение палитры"}, "color.ps1")
        )
    },
    @{
        "name"=@{"it"="API"; "en"="API"; "ru"="НАБОРЫ"}
        "tag"=@{"it"="Framework di ricognizione automatizzata"; "en"="Automated recon frameworks"; "ru"="Авто-фреймворки разведки"}
        "items"=@(
            @("o", @{"it"="Intelx"; "en"="Intelx"; "ru"="Spiderfoot"}, @{"it"="Automazione modulare"; "en"="Modular automation"; "ru"="Модульная автоматизация"}, "spiderfoot.ps1"),
            @("o", @{"it"="deadeye.cc"; "en"="deadeye.cc"; "ru"="TheHarvester"}, @{"it"="Email/host/subdomini"; "en"="Emails/hosts/subdomains"; "ru"="Email/хосты/поддомены"}, "harvester.ps1"),
            @("o", @{"it"="oathnet"; "en"="oathnet"; "ru"="Metagoofil"}, @{"it"="Metadati documenti"; "en"="Document metadata"; "ru"="Метаданные документов"}, "metagoofil.ps1"),
            @("o", @{"it"="See-know"; "en"="See-know"; "ru"="Exiftool"}, @{"it"="Analisi metadati"; "en"="Metadata analysis"; "ru"="Анализ метаданных"}, "exiftool.ps1"),
            @("o", @{"it"="Sherlock"; "en"="Sherlock"; "ru"="Sherlock"}, @{"it"="Username multipiattaforma"; "en"="Username hunting"; "ru"="Поиск username"}, "sherlock.ps1"),
            @("o", @{"it"="Maigret"; "en"="Maigret"; "ru"="Maigret"}, @{"it"="Profilazione username"; "en"="Username profiling"; "ru"="Профилирование"}, "maigret.ps1"),
            @("o", @{"it"="Holehe"; "en"="Holehe"; "ru"="Holehe"}, @{"it"="Email su servizi"; "en"="Email on services"; "ru"="Email на сервисах"}, "holehe.ps1"),
            @("o", @{"it"="Recon-ng"; "en"="Recon-ng"; "ru"="Recon-ng"}, @{"it"="Framework a moduli"; "en"="Modular framework"; "ru"="Модульный фреймворк"}, "recon.ps1")
        )
    },
    @{
        "name"=@{"it"="OPSEC"; "en"="OPSEC"; "ru"="OPSEC"}
        "tag"=@{"it"="Operazional Security"; "en"="Operazional Security"; "ru"="Проверка и анализ email"}
        "items"=@(
            @("@", @{"it"="Opsec Setup"; "en"="Opsec Setup"; "ru"="Проверка"}, @{"it"="Sintassi e dominio"; "en"="Syntax & domain"; "ru"="Синтаксис и домен"}, "opsec.ps1"),
            @("=", @{"it"="Tutorial Opsec"; "en"="Tutorial Opsec"; "ru"="MX"}, @{"it"="Record di posta"; "en"="Mail records"; "ru"="Почтовые записи"}, "mx.ps1"),
            @("!", @{"it"="VPN detection"; "en"="Vpn"; "ru"="Утечки"}, @{"it"="Presenza in leak"; "en"="Presence in leaks"; "ru"="Наличие в утечках"}, "vpn.ps1"),
            @("o", @{"it"="Proxy check"; "en"="Gravatar"; "ru"="Gravatar"}, @{"it"="Avatar collegato"; "en"="Linked avatar"; "ru"="Связанный аватар"}, "gravatar.ps1"),
            @(".", @{"it"="Disposable Email"; "en"="Catch-all"; "ru"="Catch-all"}, @{"it"="Rilevamento catch-all"; "en"="Catch-all detection"; "ru"="Catch-all"}, "catchall.ps1"),
            @("≡", @{"it"="Browser Fingerprint Check"; "en"="Header Parse"; "ru"="Заголовки"}, @{"it"="Analisi header email"; "en"="Email header parse"; "ru"="Разбор заголовков"}, "header.ps1"),
            @("~", @{"it"="IP Reputation Check"; "en"="Disposable"; "ru"="Одноразов."}, @{"it"="Email usa-e-getta"; "en"="Disposable email"; "ru"="Одноразовая почта"}, "disposable.ps1"),
            @("o", @{"it"="Credential Leak Check"; "en"="SMTP Probe"; "ru"="SMTP"}, @{"it"="Verifica casella (soft)"; "en"="Mailbox probe (soft)"; "ru"="Проверка ящика"}, "smtp.ps1")
        )
    },
    (SoonSection),
    (SoonSection),
    @{
        "name"=@{"it"="DISCORD"; "en"="DISCORD"; "ru"="АРХИВЫ"}
        "tag"=@{"it"="Cache, snapshot e archivi pubblici"; "en"="Cache, snapshots & public archives"; "ru"="Кэш, снимки и архивы"}
        "items"=@(
            @("o", @{"it"="Webhook Tools"; "en"="Webhook Tools"; "ru"="Wayback"}, @{"it"="Snapshot storici"; "en"="Historical snapshots"; "ru"="История страниц"}, "webhook.ps1"),
            @("·", $global:PLACEHOLDER_NAME, $global:PLACEHOLDER_DESC, "soon.ps1"),
            @("·", $global:PLACEHOLDER_NAME, $global:PLACEHOLDER_DESC, "soon.ps1"),
            @("#", @{"it"="Server Info"; "en"="Server Info"; "ru"="Архив док."}, @{"it"="Documenti archiviati"; "en"="Archived documents"; "ru"="Архив документов"}, "serverinfo.ps1"),
            @(">", @{"it"="User Info"; "en"="News Archive"; "ru"="Архив новост."}, @{"it"="Archivio notizie"; "en"="News archive"; "ru"="Архив новостей"}, "userinfo.ps1"),
            @("*", @{"it"="Bot Invite Gen"; "en"="Bot Invite Gen"; "ru"="Форумы"}, @{"it"="Ricerca su forum"; "en"="Forum search"; "ru"="Поиск по форумам"}, "botinvite.ps1"),
            @("·", $global:PLACEHOLDER_NAME, $global:PLACEHOLDER_DESC, "soon.ps1"),
            @("·", $global:PLACEHOLDER_NAME, $global:PLACEHOLDER_DESC, "soon.ps1")
        )
    },
    @{
        "name"=@{"it"="SOCIAL TOOL"; "en"="SOCIAL TOOL"; "ru"="КОМПАНИИ"}
        "tag"=@{"it"="OSINT aziendale e registri pubblici"; "en"="Corporate OSINT & public registries"; "ru"="Корпоративный OSINT"}
        "items"=@(
            @("·", $global:PLACEHOLDER_NAME, $global:PLACEHOLDER_DESC, "soon.ps1"),
            @("·", $global:PLACEHOLDER_NAME, $global:PLACEHOLDER_DESC, "soon.ps1"),
            @("=", @{"it"="Boost Tools"; "en"="Boost Tools"; "ru"="ИНН/VAT"}, @{"it"="Partita IVA / codice"; "en"="Tax ID lookup"; "ru"="Налоговый номер"}, "boost.ps1"),
            @("~", @{"it"="Join Tools"; "en"="Join Tools"; "ru"="Должн. лица"}, @{"it"="Amministratori e ruoli"; "en"="Directors & roles"; "ru"="Руководители"}, "join.ps1"),
            @("?", @{"it"="Delete Acc"; "en"="Delete Acc"; "ru"="Отчёты"}, @{"it"="Documenti depositati"; "en"="Filed documents"; "ru"="Поданные документы"}, "delete.ps1"),
            @("*", @{"it"="Bot Discord"; "en"="Bot Discord"; "ru"="Бренд"}, @{"it"="Marchi registrati"; "en"="Registered trademarks"; "ru"="Товарные знаки"}, "botdiscord.ps1"),
            @(">", @{"it"="Auto Quest"; "en"="Auto Quest"; "ru"="LEI"}, @{"it"="Legal Entity ID"; "en"="Legal Entity ID"; "ru"="LEI-код"}, "autoquest.ps1"),
            @("+", @{"it"="Shop"; "en"="Shop"; "ru"="История дом."}, @{"it"="Storico whois dominio"; "en"="Whois history"; "ru"="История whois"}, "shop.ps1")
        )
    },
    (SoonSection),
    @{
        "name"=@{"it"="CODICE"; "en"="CODE"; "ru"="КОД"}
        "tag"=@{"it"="Ricognizione su repository pubblici"; "en"="Public repository recon"; "ru"="Разведка по репозиториям"}
        "items"=@(
            @("o", @{"it"="Repo Search"; "en"="Repo Search"; "ru"="Поиск репо"}, @{"it"="Ricerca repository"; "en"="Repository search"; "ru"="Поиск репозиториев"}, "repo.ps1"),
            @("?", @{"it"="Code Grep"; "en"="Code Grep"; "ru"="Grep кода"}, @{"it"="Ricerca nel codice"; "en"="Search in code"; "ru"="Поиск в коде"}, "grep.ps1"),
            @("#", @{"it"="Gist Search"; "en"="Gist Search"; "ru"="Gist"}, @{"it"="Ricerca gist pubblici"; "en"="Public gist search"; "ru"="Поиск gist"}, "gist.ps1"),
            @(">", @{"it"="Commit Hunt"; "en"="Commit Hunt"; "ru"="Коммиты"}, @{"it"="Analisi cronologia commit"; "en"="Commit history dig"; "ru"="Анализ коммитов"}, "commit.ps1"),
            @("=", @{"it"="Dependency"; "en"="Dependency"; "ru"="Завис."}, @{"it"="Albero dipendenze"; "en"="Dependency tree"; "ru"="Дерево зависимостей"}, "dep.ps1"),
            @("*", @{"it"="CI Config"; "en"="CI Config"; "ru"="CI-конфиг"}, @{"it"="File di pipeline CI"; "en"="CI pipeline files"; "ru"="Файлы CI"}, "ci.ps1"),
            @("~", @{"it"="Secret Scan"; "en"="Secret Scan"; "ru"="Скан секрет."}, @{"it"="Chiavi esposte nei repo"; "en"="Exposed keys in repos"; "ru"="Утёкшие ключи"}, "secret.ps1"),
            @("+", @{"it"="Contributors"; "en"="Contributors"; "ru"="Контрибьют."}, @{"it"="Mappa contributori"; "en"="Contributor map"; "ru"="Карта участников"}, "contrib.ps1")
        )
    },
    @{
        "name"=@{"it"="CERTIFICATI"; "en"="CERT"; "ru"="СЕРТИФИК."}
        "tag"=@{"it"="Certificate Transparency & TLS"; "en"="Certificate Transparency & TLS"; "ru"="Прозрачность сертификатов"}
        "items"=@(
            @("o", @{"it"="crt.sh"; "en"="crt.sh"; "ru"="crt.sh"}, @{"it"="Ricerca CT log"; "en"="CT log search"; "ru"="Поиск CT-логов"}, "crtsh.ps1"),
            @("=", @{"it"="CT Logs"; "en"="CT Logs"; "ru"="CT-логи"}, @{"it"="Certificate Transparency"; "en"="Certificate Transparency"; "ru"="Прозрачность серт."}, "ctlogs.ps1"),
            @("*", @{"it"="SSL Labs"; "en"="SSL Labs"; "ru"="SSL Labs"}, @{"it"="Valutazione TLS"; "en"="TLS grading"; "ru"="Оценка TLS"}, "ssllabs.ps1"),
            @("#", @{"it"="Cert Chain"; "en"="Cert Chain"; "ru"="Цепочка"}, @{"it"="Catena di certificati"; "en"="Certificate chain"; "ru"="Цепочка серт."}, "certchain.ps1"),
            @("?", @{"it"="OCSP"; "en"="OCSP"; "ru"="OCSP"}, @{"it"="Stato revoca"; "en"="Revocation status"; "ru"="Статус отзыва"}, "ocsp.ps1"),
            @("~", @{"it"="HSTS"; "en"="HSTS"; "ru"="HSTS"}, @{"it"="Policy HSTS"; "en"="HSTS policy"; "ru"="Политика HSTS"}, "hsts.ps1"),
            @(">", @{"it"="Cipher Scan"; "en"="Cipher Scan"; "ru"="Шифры"}, @{"it"="Suite cifrari supportati"; "en"="Supported ciphers"; "ru"="Поддерж. шифры"}, "cipher.ps1"),
            @("+", @{"it"="Altri tools"; "en"="Other Tools"; "ru"="другие инструменты"}, @{"it"="Scadenza certificato"; "en"="Cert expiry"; "ru"="Срок действия"}, "other.ps1")
        )
    },
    @{
        "name"=@{"it"="SISTEMA"; "en"="SYSTEM"; "ru"="СИСТЕМА"}
        "tag"=@{"it"="Configurazione e informazioni"; "en"="Configuration & info"; "ru"="Конфигурация и инфо"}
        "items"=@(
            @("o", @{"it"="Impostazioni"; "en"="Settings"; "ru"="Настройки"}, @{"it"="Preferenze del tool"; "en"="Tool preferences"; "ru"="Параметры"}, "settings.ps1"),
            @("~", @{"it"="Disclaimer"; "en"="Disclaimer"; "ru"="Отказ от ответственности"}, @{"it"="Disclaimer Di HuntSint"; "en"="Disclaimer Of HuntSint"; "ru"="Отказ от ответственности HuntSint"}, "disclaimer.ps1"),
            @("*", @{"it"="Tema"; "en"="Theme"; "ru"="Тема"}, @{"it"="Schema colori"; "en"="Color scheme"; "ru"="Цветовая схема"}, "theme.ps1"),
            @("?", @{"it"="Info"; "en"="Info"; "ru"="Инфо"}, @{"it"="Informazioni di sistema"; "en"="System information"; "ru"="Сведения"}, "info.ps1"),
            @("#", @{"it"="About"; "en"="About"; "ru"="О программе"}, @{"it"="Crediti e versione"; "en"="Credits & version"; "ru"="Авторы и версия"}, "about.ps1"),
            @("=", @{"it"="Update"; "en"="Update"; "ru"="Обновление"}, @{"it"="Verifica aggiornamenti"; "en"="Check for updates"; "ru"="Проверка обновлений"}, "update.ps1"),
            @(">", @{"it"="Logs"; "en"="Logs"; "ru"="Логи"}, @{"it"="Registro attività"; "en"="Activity log"; "ru"="Журнал"}, "logs.ps1"),
            @("!", @{"it"="Exit"; "en"="Exit"; "ru"="Выход"}, @{"it"="Chiudi il programma"; "en"="Quit the program"; "ru"="Закрыть программу"}, "exit.ps1")
        )
    }
)

# =====================================================================
# PAGE 2 — 15 Categories · 120 Tools (IDs 121-240)
# =====================================================================
$global:PAGE2 = @(
    @{
        "name"=@{"it"="EMAIL"; "en"="EMAIL"; "ru"="EMAIL"}
        "tag"=@{"it"="Analisi e verifica indirizzi email"; "en"="Email analysis & verification"; "ru"="Анализ и проверка email"}
        "items"=@(
            @("@", @{"it"="Email Validate"; "en"="Email Validate"; "ru"="Проверка email"}, @{"it"="Sintassi e dominio"; "en"="Syntax & domain"; "ru"="Синтаксис и домен"}, "emailval.ps1"),
            @("=", @{"it"="MX Records"; "en"="MX Records"; "ru"="MX-записи"}, @{"it"="Record di posta"; "en"="Mail records"; "ru"="Почтовые записи"}, "mxrec.ps1"),
            @("#", @{"it"="SPF / DKIM"; "en"="SPF / DKIM"; "ru"="SPF / DKIM"}, @{"it"="Policy anti-spoof"; "en"="Anti-spoof policy"; "ru"="Антиспуф-политика"}, "spf.ps1"),
            @("!", @{"it"="Email Breach"; "en"="Email Breach"; "ru"="Утечки email"}, @{"it"="Presenza in leak"; "en"="Presence in leaks"; "ru"="Наличие в утечках"}, "emailbreach.ps1"),
            @("o", @{"it"="Gravatar"; "en"="Gravatar"; "ru"="Gravatar"}, @{"it"="Avatar collegato"; "en"="Linked avatar"; "ru"="Связанный аватар"}, "gravatar2.ps1"),
            @(".", @{"it"="Catch-all"; "en"="Catch-all"; "ru"="Catch-all"}, @{"it"="Rilevamento catch-all"; "en"="Catch-all detection"; "ru"="Catch-all"}, "catchall2.ps1"),
            @("~", @{"it"="Disposable"; "en"="Disposable"; "ru"="Одноразов."}, @{"it"="Email usa-e-getta"; "en"="Disposable email"; "ru"="Одноразовая почта"}, "disposable2.ps1"),
            @("≡", @{"it"="Header Parse"; "en"="Header Parse"; "ru"="Заголовки"}, @{"it"="Analisi header email"; "en"="Email header parse"; "ru"="Разбор заголовков"}, "header2.ps1")
        )
    },
    @{
        "name"=@{"it"="DOMINIO"; "en"="DOMAIN"; "ru"="ДОМЕН"}
        "tag"=@{"it"="Intelligence su domini e DNS"; "en"="Domain & DNS intelligence"; "ru"="Разведка по доменам и DNS"}
        "items"=@(
            @("~", @{"it"="Whois"; "en"="Whois"; "ru"="Whois"}, @{"it"="Dati di registrazione"; "en"="Registration data"; "ru"="Данные регистрации"}, "whois2.ps1"),
            @("=", @{"it"="DNS Records"; "en"="DNS Records"; "ru"="DNS-записи"}, @{"it"="A/AAAA/MX/TXT/NS"; "en"="A/AAAA/MX/TXT/NS"; "ru"="A/AAAA/MX/TXT/NS"}, "dns2.ps1"),
            @("o", @{"it"="Subdomain Enum"; "en"="Subdomain Enum"; "ru"="Поддомены"}, @{"it"="Enumerazione sottodomini"; "en"="Subdomain enumeration"; "ru"="Поиск поддоменов"}, "subdomain.ps1"),
            @("?", @{"it"="Reverse Whois"; "en"="Reverse Whois"; "ru"="Обр. Whois"}, @{"it"="Domini per registrante"; "en"="Domains by registrant"; "ru"="Домены владельца"}, "revwhois.ps1"),
            @(">", @{"it"="DNS History"; "en"="DNS History"; "ru"="История DNS"}, @{"it"="Storico record DNS"; "en"="Historical DNS records"; "ru"="История DNS"}, "dnshist.ps1"),
            @("*", @{"it"="Zone Transfer"; "en"="Zone Transfer"; "ru"="Перенос зоны"}, @{"it"="Test AXFR"; "en"="AXFR test"; "ru"="Проверка AXFR"}, "zone.ps1"),
            @("+", @{"it"="Domain Age"; "en"="Domain Age"; "ru"="Возраст домена"}, @{"it"="Età e scadenza"; "en"="Age & expiry"; "ru"="Возраст и срок"}, "domainage.ps1"),
            @("#", @{"it"="Typosquat"; "en"="Typosquat"; "ru"="Тайпсквоттинг"}, @{"it"="Domini simili"; "en"="Look-alike domains"; "ru"="Похожие домены"}, "typosquat.ps1")
        )
    },
    @{
        "name"=@{"it"="RETE"; "en"="NETWORK"; "ru"="СЕТЬ"}
        "tag"=@{"it"="Ricognizione di rete e host"; "en"="Network & host recon"; "ru"="Разведка сети и узлов"}
        "items"=@(
            @("o", @{"it"="Port Scan"; "en"="Port Scan"; "ru"="Скан портов"}, @{"it"="Porte e servizi"; "en"="Ports & services"; "ru"="Порты и сервисы"}, "portscan.ps1"),
            @("=", @{"it"="Banner Grab"; "en"="Banner Grab"; "ru"="Баннеры"}, @{"it"="Banner dei servizi"; "en"="Service banners"; "ru"="Баннеры сервисов"}, "banner.ps1"),
            @(">", @{"it"="Traceroute"; "en"="Traceroute"; "ru"="Traceroute"}, @{"it"="Percorso verso host"; "en"="Path to host"; "ru"="Путь до узла"}, "traceroute2.ps1"),
            @(".", @{"it"="Ping Sweep"; "en"="Ping Sweep"; "ru"="Ping Sweep"}, @{"it"="Host attivi nel range"; "en"="Live hosts in range"; "ru"="Активные узлы"}, "pingsweep.ps1"),
            @("?", @{"it"="ASN Lookup"; "en"="ASN Lookup"; "ru"="ASN"}, @{"it"="Autonomous System"; "en"="Autonomous System"; "ru"="Автономная система"}, "asn2.ps1"),
            @("&", @{"it"="Reverse IP"; "en"="Reverse IP"; "ru"="Reverse IP"}, @{"it"="Domini sullo stesso IP"; "en"="Domains on same IP"; "ru"="Домены на одном IP"}, "revip2.ps1"),
            @("+", @{"it"="GeoIP"; "en"="GeoIP"; "ru"="GeoIP"}, @{"it"="Geolocalizzazione IP"; "en"="IP geolocation"; "ru"="Геолокация IP"}, "geoip.ps1"),
            @("*", @{"it"="Shodan Query"; "en"="Shodan Query"; "ru"="Shodan"}, @{"it"="Host esposti (Shodan)"; "en"="Exposed hosts (Shodan)"; "ru"="Хосты в Shodan"}, "shodan.ps1")
        )
    },
    @{
        "name"=@{"it"="BREACH"; "en"="BREACH"; "ru"="УТЕЧКИ"}
        "tag"=@{"it"="Esposizione in leak e breach noti"; "en"="Exposure in known leaks & breaches"; "ru"="Проверка по известным утечкам"}
        "items"=@(
            @("!", @{"it"="HIBP Check"; "en"="HIBP Check"; "ru"="HIBP"}, @{"it"="Have I Been Pwned"; "en"="Have I Been Pwned"; "ru"="Have I Been Pwned"}, "hibp.ps1"),
            @("?", @{"it"="Leak DB Query"; "en"="Leak DB Query"; "ru"="База утечек"}, @{"it"="Ricerca in DB di leak"; "en"="Search in leak DB"; "ru"="Поиск в базе утечек"}, "leakdb.ps1"),
            @("o", @{"it"="Paste Monitor"; "en"="Paste Monitor"; "ru"="Paste-мониторинг"}, @{"it"="Ricerca su pastebin"; "en"="Pastebin search"; "ru"="Поиск по pastebin"}, "paste.ps1"),
            @("~", @{"it"="Domain Breach"; "en"="Domain Breach"; "ru"="Утечки домена"}, @{"it"="Leak per dominio"; "en"="Leaks by domain"; "ru"="Утечки по домену"}, "domainbreach.ps1"),
            @(">", @{"it"="Breach Timeline"; "en"="Breach Timeline"; "ru"="Хронология"}, @{"it"="Cronologia esposizioni"; "en"="Exposure timeline"; "ru"="Хронология утечек"}, "timeline.ps1"),
            @("#", @{"it"="Breach Stats"; "en"="Breach Stats"; "ru"="Статистика"}, @{"it"="Statistiche dei leak"; "en"="Leak statistics"; "ru"="Статистика утечек"}, "stats.ps1"),
            @("=", @{"it"="Hash Identify"; "en"="Hash Identify"; "ru"="Тип хеша"}, @{"it"="Riconoscimento hash"; "en"="Hash identification"; "ru"="Определение хеша"}, "hashid.ps1"),
            @("+", @{"it"="Exposure Score"; "en"="Exposure Score"; "ru"="Оценка риска"}, @{"it"="Punteggio di rischio"; "en"="Risk score"; "ru"="Балл риска"}, "exposure.ps1")
        )
    },
    @{
        "name"=@{"it"="METADATA"; "en"="METADATA"; "ru"="МЕТАДАННЫЕ"}
        "tag"=@{"it"="Estrazione metadati da file"; "en"="File metadata extraction"; "ru"="Извлечение метаданных"}
        "items"=@(
            @("=", @{"it"="EXIF Reader"; "en"="EXIF Reader"; "ru"="EXIF"}, @{"it"="Metadati immagine"; "en"="Image metadata"; "ru"="Метаданные фото"}, "exif2.ps1"),
            @("#", @{"it"="Doc Metadata"; "en"="Doc Metadata"; "ru"="Метаданные док."}, @{"it"="Metadati documenti"; "en"="Document metadata"; "ru"="Метаданные документов"}, "docmeta.ps1"),
            @("o", @{"it"="PDF Metadata"; "en"="PDF Metadata"; "ru"="Метаданные PDF"}, @{"it"="Info da PDF"; "en"="PDF info"; "ru"="Данные PDF"}, "pdfmeta.ps1"),
            @("+", @{"it"="Image GPS"; "en"="Image GPS"; "ru"="GPS фото"}, @{"it"="Coordinate da foto"; "en"="Coordinates from photo"; "ru"="Координаты из фото"}, "gps.ps1"),
            @("~", @{"it"="Strip Metadata"; "en"="Strip Metadata"; "ru"="Очистка мета"}, @{"it"="Rimuovi metadati"; "en"="Remove metadata"; "ru"="Удалить метаданные"}, "strip.ps1"),
            @("*", @{"it"="Office Meta"; "en"="Office Meta"; "ru"="Office-мета"}, @{"it"="Metadati Office"; "en"="Office metadata"; "ru"="Метаданные Office"}, "officemeta.ps1"),
            @(">", @{"it"="Media Info"; "en"="Media Info"; "ru"="Медиа-инфо"}, @{"it"="Info audio/video"; "en"="Audio/video info"; "ru"="Аудио/видео инфо"}, "media.ps1"),
            @("?", @{"it"="File Hash"; "en"="File Hash"; "ru"="Хеш файла"}, @{"it"="Hash del file"; "en"="File hashes"; "ru"="Хеши файла"}, "filehash.ps1")
        )
    },
    @{
        "name"=@{"it"="THREAT INTEL"; "en"="THREAT INTEL"; "ru"="ТРЕЙТ-ИНТЕЛ"}
        "tag"=@{"it"="Reputazione e indicatori di compromissione"; "en"="Reputation & indicators of compromise"; "ru"="Репутация и индикаторы"}
        "items"=@(
            @("!", @{"it"="IP Reputation"; "en"="IP Reputation"; "ru"="Репутация IP"}, @{"it"="Reputazione di un IP"; "en"="IP reputation"; "ru"="Репутация IP"}, "iprep.ps1"),
            @("o", @{"it"="URL Scan"; "en"="URL Scan"; "ru"="Скан URL"}, @{"it"="Analisi di un URL"; "en"="URL analysis"; "ru"="Анализ URL"}, "urlscan.ps1"),
            @("#", @{"it"="File Reputation"; "en"="File Reputation"; "ru"="Репутация файла"}, @{"it"="Reputazione file (hash)"; "en"="File reputation (hash)"; "ru"="Репутация файла"}, "filerep.ps1"),
            @("~", @{"it"="Domain Reputation"; "en"="Domain Reputation"; "ru"="Репут. дом."}, @{"it"="Reputazione dominio"; "en"="Domain reputation"; "ru"="Репутация домена"}, "domainrep.ps1"),
            @("?", @{"it"="IOC Lookup"; "en"="IOC Lookup"; "ru"="IOC"}, @{"it"="Indicatori noti"; "en"="Known indicators"; "ru"="Известные индикаторы"}, "ioc.ps1"),
            @(".", @{"it"="Blocklist Check"; "en"="Blocklist Check"; "ru"="Блок-листы"}, @{"it"="Presenza in blocklist"; "en"="Presence in blocklists"; "ru"="Наличие в блок-листах"}, "blocklist.ps1"),
            @("=", @{"it"="Hash Reputation"; "en"="Hash Reputation"; "ru"="Репут. хеша"}, @{"it"="Reputazione hash"; "en"="Hash reputation"; "ru"="Репутация хеша"}, "hashrep.ps1"),
            @(">", @{"it"="Abuse Report"; "en"="Abuse Report"; "ru"="Жалобы"}, @{"it"="Segnalazioni abuse"; "en"="Abuse reports"; "ru"="Сообщения об abuse"}, "abuse.ps1")
        )
    },
    @{
        "name"=@{"it"="CRYPTO"; "en"="CRYPTO"; "ru"="КРИПТО"}
        "tag"=@{"it"="OSINT su blockchain e wallet"; "en"="Blockchain & wallet OSINT"; "ru"="Разведка по блокчейну"}
        "items"=@(
            @("+", @{"it"="BTC Address"; "en"="BTC Address"; "ru"="BTC-адрес"}, @{"it"="Info indirizzo Bitcoin"; "en"="Bitcoin address info"; "ru"="Данные BTC-адреса"}, "btc.ps1"),
            @("+", @{"it"="ETH Address"; "en"="ETH Address"; "ru"="ETH-адрес"}, @{"it"="Info indirizzo Ethereum"; "en"="Ethereum address info"; "ru"="Данные ETH-адреса"}, "eth.ps1"),
            @(">", @{"it"="TX Lookup"; "en"="TX Lookup"; "ru"="Транзакция"}, @{"it"="Dettaglio transazione"; "en"="Transaction detail"; "ru"="Детали транзакции"}, "tx.ps1"),
            @("#", @{"it"="Wallet Cluster"; "en"="Wallet Cluster"; "ru"="Кластер"}, @{"it"="Cluster di indirizzi"; "en"="Address clustering"; "ru"="Кластеризация адресов"}, "wallet.ps1"),
            @("o", @{"it"="Exchange Tag"; "en"="Exchange Tag"; "ru"="Биржа"}, @{"it"="Etichetta exchange"; "en"="Exchange labeling"; "ru"="Метка биржи"}, "exchange.ps1"),
            @("=", @{"it"="ENS Lookup"; "en"="ENS Lookup"; "ru"="ENS"}, @{"it"="Nomi ENS"; "en"="ENS names"; "ru"="ENS-имена"}, "ens.ps1"),
            @("*", @{"it"="NFT Lookup"; "en"="NFT Lookup"; "ru"="NFT"}, @{"it"="Info NFT"; "en"="NFT info"; "ru"="Данные NFT"}, "nft.ps1"),
            @("~", @{"it"="Chain Stats"; "en"="Chain Stats"; "ru"="Статистика"}, @{"it"="Statistiche on-chain"; "en"="On-chain stats"; "ru"="Он-чейн статистика"}, "chain.ps1")
        )
    },
    @{
        "name"=@{"it"="ARCHIVI"; "en"="ARCHIVES"; "ru"="АРХИВЫ"}
        "tag"=@{"it"="Snapshot storici e cache pubbliche"; "en"="Historical snapshots & public cache"; "ru"="История страниц и кэш"}
        "items"=@(
            @("*", @{"it"="Wayback"; "en"="Wayback"; "ru"="Wayback"}, @{"it"="Snapshot storici"; "en"="Historical snapshots"; "ru"="История страниц"}, "wayback2.ps1"),
            @("o", @{"it"="Cache View"; "en"="Cache View"; "ru"="Кэш"}, @{"it"="Versione in cache"; "en"="Cached version"; "ru"="Кэш-версия"}, "cache.ps1"),
            @(">", @{"it"="URL History"; "en"="URL History"; "ru"="История URL"}, @{"it"="Storico di un URL"; "en"="URL history"; "ru"="История URL"}, "urlhist.ps1"),
            @("=", @{"it"="Snapshot Diff"; "en"="Snapshot Diff"; "ru"="Сравнение"}, @{"it"="Differenze tra snapshot"; "en"="Snapshot differences"; "ru"="Разница снимков"}, "snapshot.ps1"),
            @("#", @{"it"="Archive.today"; "en"="Archive.today"; "ru"="Archive.today"}, @{"it"="Archivio alternativo"; "en"="Alternative archive"; "ru"="Альтернативный архив"}, "archivetoday.ps1"),
            @("?", @{"it"="Robots History"; "en"="Robots History"; "ru"="История robots"}, @{"it"="Storico robots.txt"; "en"="robots.txt history"; "ru"="История robots"}, "robothist.ps1"),
            @("~", @{"it"="Sitemap Fetch"; "en"="Sitemap Fetch"; "ru"="Sitemap"}, @{"it"="Recupero sitemap"; "en"="Sitemap fetch"; "ru"="Загрузка sitemap"}, "sitemap.ps1"),
            @(".", @{"it"="Dead Link Check"; "en"="Dead Link Check"; "ru"="Битые ссылки"}, @{"it"="Link non funzionanti"; "en"="Broken links"; "ru"="Битые ссылки"}, "deadlink.ps1")
        )
    },
    @{
        "name"=@{"it"="PROFILI"; "en"="PROFILES"; "ru"="ПРОФИЛИ"}
        "tag"=@{"it"="Aggregazione profili pubblici"; "en"="Public profile aggregation"; "ru"="Агрегация публичных профилей"}
        "items"=@(
            @("#", @{"it"="Username Search"; "en"="Username Search"; "ru"="Поиск юзера"}, @{"it"="Username multipiattaforma"; "en"="Cross-platform username"; "ru"="Поиск по платформам"}, "usersearch.ps1"),
            @("o", @{"it"="Profile Aggregate"; "en"="Profile Aggregate"; "ru"="Агрегатор"}, @{"it"="Unione profili pubblici"; "en"="Public profile merge"; "ru"="Объединение профилей"}, "profileagg.ps1"),
            @("~", @{"it"="Avatar Search"; "en"="Avatar Search"; "ru"="Поиск аватара"}, @{"it"="Ricerca per avatar"; "en"="Avatar reverse search"; "ru"="Поиск по аватару"}, "avatar.ps1"),
            @("?", @{"it"="Bio Search"; "en"="Bio Search"; "ru"="Поиск по био"}, @{"it"="Ricerca nelle bio"; "en"="Bio text search"; "ru"="Поиск по описаниям"}, "bio.ps1"),
            @("=", @{"it"="Public Records"; "en"="Public Records"; "ru"="Реестры"}, @{"it"="Registri pubblici"; "en"="Public records"; "ru"="Публичные реестры"}, "records.ps1"),
            @(">", @{"it"="Forum Search"; "en"="Forum Search"; "ru"="Форумы"}, @{"it"="Ricerca su forum"; "en"="Forum search"; "ru"="Поиск по форумам"}, "forum.ps1"),
            @("*", @{"it"="Pastebin User"; "en"="Pastebin User"; "ru"="Pastebin юзер"}, @{"it"="Paste per utente"; "en"="Pastes by user"; "ru"="Paste пользователя"}, "pasteuser.ps1"),
            @("+", @{"it"="Cross Reference"; "en"="Cross Reference"; "ru"="Сопоставление"}, @{"it"="Incrocio dei dati"; "en"="Data cross-reference"; "ru"="Перекрёстная сверка"}, "crossref.ps1")
        )
    },
    @{
        "name"=@{"it"="IMMAGINI"; "en"="IMAGES"; "ru"="ИЗОБРАЖЕНИЯ"}
        "tag"=@{"it"="Analisi forense di immagini"; "en"="Image forensics & analysis"; "ru"="Анализ изображений"}
        "items"=@(
            @("o", @{"it"="Reverse Image"; "en"="Reverse Image"; "ru"="Обр. поиск"}, @{"it"="Ricerca inversa"; "en"="Reverse search"; "ru"="Обратный поиск"}, "revimg2.ps1"),
            @("=", @{"it"="Image Hash"; "en"="Image Hash"; "ru"="Хеш фото"}, @{"it"="Hash percettivo"; "en"="Perceptual hash"; "ru"="Перцептивный хеш"}, "imghash.ps1"),
            @("#", @{"it"="OCR Text"; "en"="OCR Text"; "ru"="OCR"}, @{"it"="Estrazione testo"; "en"="Text extraction"; "ru"="Извлечение текста"}, "ocr.ps1"),
            @("~", @{"it"="Color Palette"; "en"="Color Palette"; "ru"="Палитра"}, @{"it"="Estrazione palette"; "en"="Palette extraction"; "ru"="Извлечение палитры"}, "palette.ps1"),
            @("?", @{"it"="Image Forensics"; "en"="Image Forensics"; "ru"="Форензика"}, @{"it"="Analisi manipolazioni"; "en"="Tamper analysis"; "ru"="Анализ подделок"}, "forensics.ps1"),
            @(">", @{"it"="Screenshot"; "en"="Screenshot"; "ru"="Скриншот"}, @{"it"="Cattura pagina web"; "en"="Web page capture"; "ru"="Снимок страницы"}, "screenshot.ps1"),
            @("*", @{"it"="QR Decode"; "en"="QR Decode"; "ru"="QR-код"}, @{"it"="Decodifica QR/barcode"; "en"="QR/barcode decode"; "ru"="Декод QR"}, "qr.ps1"),
            @(".", @{"it"="Stego Check"; "en"="Stego Check"; "ru"="Стеганография"}, @{"it"="Verifica steganografia"; "en"="Steganography check"; "ru"="Проверка стего"}, "stego.ps1")
        )
    },
    @{
        "name"=@{"it"="MOBILE"; "en"="MOBILE"; "ru"="МОБИЛЬН."}
        "tag"=@{"it"="OSINT su numeri e applicazioni"; "en"="Phone & app OSINT"; "ru"="Разведка номеров и приложений"}
        "items"=@(
            @("⌖", @{"it"="Phone Validate"; "en"="Phone Validate"; "ru"="Проверка номера"}, @{"it"="Validazione numero"; "en"="Number validation"; "ru"="Проверка номера"}, "phoneval.ps1"),
            @("=", @{"it"="Carrier Lookup"; "en"="Carrier Lookup"; "ru"="Оператор"}, @{"it"="Operatore e tipo"; "en"="Carrier & type"; "ru"="Оператор и тип"}, "carrier.ps1"),
            @("?", @{"it"="HLR Lookup"; "en"="HLR Lookup"; "ru"="HLR"}, @{"it"="Stato della SIM"; "en"="SIM status"; "ru"="Статус SIM"}, "hlr.ps1"),
            @("o", @{"it"="App Search"; "en"="App Search"; "ru"="Поиск приложений"}, @{"it"="Ricerca app store"; "en"="App store search"; "ru"="Поиск в сторах"}, "appsearch.ps1"),
            @("#", @{"it"="APK Info"; "en"="APK Info"; "ru"="APK-инфо"}, @{"it"="Analisi pacchetto APK"; "en"="APK package analysis"; "ru"="Анализ APK"}, "apk.ps1"),
            @("!", @{"it"="App Permissions"; "en"="App Permissions"; "ru"="Разрешения"}, @{"it"="Permessi richiesti"; "en"="Requested permissions"; "ru"="Запрошенные разрешения"}, "appperm.ps1"),
            @(">", @{"it"="Store Listing"; "en"="Store Listing"; "ru"="Карточка стора"}, @{"it"="Scheda dello store"; "en"="Store listing data"; "ru"="Данные карточки"}, "store.ps1"),
            @("~", @{"it"="Number Format"; "en"="Number Format"; "ru"="Формат номера"}, @{"it"="Formattazione E.164"; "en"="E.164 formatting"; "ru"="Формат E.164"}, "numformat.ps1")
        )
    },
    @{
        "name"=@{"it"="CLOUD"; "en"="CLOUD"; "ru"="ОБЛАКО"}
        "tag"=@{"it"="Esposizione di risorse cloud"; "en"="Exposed cloud resources"; "ru"="Открытые облачные ресурсы"}
        "items"=@(
            @("o", @{"it"="Bucket Finder"; "en"="Bucket Finder"; "ru"="Поиск бакетов"}, @{"it"="Bucket S3 aperti"; "en"="Open S3 buckets"; "ru"="Открытые S3-бакеты"}, "bucket.ps1"),
            @("=", @{"it"="Storage Scan"; "en"="Storage Scan"; "ru"="Скан хранилищ"}, @{"it"="Storage esposti"; "en"="Exposed storage"; "ru"="Открытые хранилища"}, "storage.ps1"),
            @("#", @{"it"="Cloud Metadata"; "en"="Cloud Metadata"; "ru"="Облач. мета"}, @{"it"="Endpoint metadata"; "en"="Metadata endpoints"; "ru"="Метаданные облака"}, "cloudmeta.ps1"),
            @("?", @{"it"="CDN Detect"; "en"="CDN Detect"; "ru"="CDN"}, @{"it"="Riconoscimento CDN"; "en"="CDN fingerprint"; "ru"="Определение CDN"}, "cdn.ps1"),
            @("!", @{"it"="Subdomain Takeover"; "en"="Subdomain Takeover"; "ru"="Захват поддомена"}, @{"it"="Verifica takeover"; "en"="Takeover check"; "ru"="Проверка захвата"}, "takeover.ps1"),
            @("+", @{"it"="Cloud Range"; "en"="Cloud Range"; "ru"="Диапазоны"}, @{"it"="Range IP del provider"; "en"="Provider IP ranges"; "ru"="Диапазоны провайдера"}, "cloudrange.ps1"),
            @(">", @{"it"="Open Index"; "en"="Open Index"; "ru"="Открытый индекс"}, @{"it"="Directory listing aperte"; "en"="Open directory listings"; "ru"="Открытые листинги"}, "openindex.ps1"),
            @("~", @{"it"="Misconfig Scan"; "en"="Misconfig Scan"; "ru"="Скан конфиг."}, @{"it"="Configurazioni errate"; "en"="Misconfigurations"; "ru"="Ошибки конфигурации"}, "misconfig.ps1")
        )
    },
    @{
        "name"=@{"it"="MONITORAGGIO"; "en"="MONITORING"; "ru"="МОНИТОРИНГ"}
        "tag"=@{"it"="Sorveglianza e allerta continua"; "en"="Continuous watch & alerting"; "ru"="Слежение и оповещения"}
        "items"=@(
            @("o", @{"it"="Domain Watch"; "en"="Domain Watch"; "ru"="Слежка домена"}, @{"it"="Monitor su dominio"; "en"="Domain monitor"; "ru"="Мониторинг домена"}, "domwatch.ps1"),
            @("=", @{"it"="Cert Watch"; "en"="Cert Watch"; "ru"="Слежка серт."}, @{"it"="Nuovi certificati"; "en"="New certificates"; "ru"="Новые сертификаты"}, "certwatch.ps1"),
            @("?", @{"it"="Keyword Alert"; "en"="Keyword Alert"; "ru"="Ключ. слова"}, @{"it"="Allerta su parole chiave"; "en"="Keyword alerting"; "ru"="Оповещение по словам"}, "keyword.ps1"),
            @(".", @{"it"="Paste Watch"; "en"="Paste Watch"; "ru"="Слежка paste"}, @{"it"="Monitor su pastebin"; "en"="Pastebin monitor"; "ru"="Мониторинг paste"}, "pastewatch.ps1"),
            @(">", @{"it"="Change Detect"; "en"="Change Detect"; "ru"="Изменения"}, @{"it"="Rileva cambiamenti"; "en"="Change detection"; "ru"="Обнаружение изменений"}, "change.ps1"),
            @("#", @{"it"="Feed Monitor"; "en"="Feed Monitor"; "ru"="Лента"}, @{"it"="Monitor di feed"; "en"="Feed monitor"; "ru"="Мониторинг лент"}, "feed.ps1"),
            @("*", @{"it"="Uptime Check"; "en"="Uptime Check"; "ru"="Аптайм"}, @{"it"="Disponibilità host"; "en"="Host availability"; "ru"="Доступность узла"}, "uptime.ps1"),
            @("~", @{"it"="RSS Track"; "en"="RSS Track"; "ru"="RSS"}, @{"it"="Tracciamento RSS"; "en"="RSS tracking"; "ru"="Отслеживание RSS"}, "rss.ps1")
        )
    },
    @{
        "name"=@{"it"="REPORT"; "en"="REPORT"; "ru"="ОТЧЁТЫ"}
        "tag"=@{"it"="Generazione ed esportazione report"; "en"="Report generation & export"; "ru"="Создание и экспорт отчётов"}
        "items"=@(
            @("#", @{"it"="Build Report"; "en"="Build Report"; "ru"="Создать отчёт"}, @{"it"="Genera report del caso"; "en"="Build case report"; "ru"="Сформировать отчёт"}, "buildreport.ps1"),
            @("o", @{"it"="Export JSON"; "en"="Export JSON"; "ru"="Экспорт JSON"}, @{"it"="Esporta in JSON"; "en"="Export to JSON"; "ru"="Экспорт в JSON"}, "exportjson.ps1"),
            @("=", @{"it"="Export PDF"; "en"="Export PDF"; "ru"="Экспорт PDF"}, @{"it"="Esporta in PDF"; "en"="Export to PDF"; "ru"="Экспорт в PDF"}, "exportpdf.ps1"),
            @(">", @{"it"="Export HTML"; "en"="Export HTML"; "ru"="Экспорт HTML"}, @{"it"="Esporta in HTML"; "en"="Export to HTML"; "ru"="Экспорт в HTML"}, "exporthtml.ps1"),
            @("+", @{"it"="Export CSV"; "en"="Export CSV"; "ru"="Экспорт CSV"}, @{"it"="Esporta in CSV"; "en"="Export to CSV"; "ru"="Экспорт в CSV"}, "exportcsv.ps1"),
            @("~", @{"it"="Timeline"; "en"="Timeline"; "ru"="Хронология"}, @{"it"="Linea temporale eventi"; "en"="Event timeline"; "ru"="Лента событий"}, "timeline2.ps1"),
            @("*", @{"it"="Graph View"; "en"="Graph View"; "ru"="Граф"}, @{"it"="Grafo delle relazioni"; "en"="Relationship graph"; "ru"="Граф связей"}, "graph.ps1"),
            @("?", @{"it"="Case Notes"; "en"="Case Notes"; "ru"="Заметки"}, @{"it"="Note del caso"; "en"="Case notes"; "ru"="Заметки по делу"}, "cases.ps1")
        )
    },
    @{
        "name"=@{"it"="SISTEMA 2"; "en"="SYSTEM 2"; "ru"="СИСТЕМА 2"}
        "tag"=@{"it"="Configurazione avanzata e manutenzione"; "en"="Advanced config & maintenance"; "ru"="Расширенная настройка"}
        "items"=@(
            @("#", @{"it"="API Keys"; "en"="API Keys"; "ru"="API-ключи"}, @{"it"="Gestione chiavi API"; "en"="API key management"; "ru"="Управление ключами"}, "apikeys.ps1"),
            @("=", @{"it"="Proxy Config"; "en"="Proxy Config"; "ru"="Прокси"}, @{"it"="Configurazione proxy"; "en"="Proxy configuration"; "ru"="Настройка прокси"}, "proxy.ps1"),
            @("o", @{"it"="Lingua"; "en"="Language"; "ru"="Язык"}, @{"it"="Cambia lingua"; "en"="Change language"; "ru"="Сменить язык"}, "language.ps1"),
            @("*", @{"it"="Tema"; "en"="Theme"; "ru"="Тема"}, @{"it"="Schema colori"; "en"="Color scheme"; "ru"="Цветовая схема"}, "theme2.ps1"),
            @("~", @{"it"="Cache Clear"; "en"="Cache Clear"; "ru"="Очистка кэша"}, @{"it"="Svuota la cache"; "en"="Clear the cache"; "ru"="Очистить кэш"}, "cacheclear.ps1"),
            @(">", @{"it"="Backup"; "en"="Backup"; "ru"="Бэкап"}, @{"it"="Backup impostazioni"; "en"="Settings backup"; "ru"="Резервная копия"}, "backup.ps1"),
            @("?", @{"it"="Plugins"; "en"="Plugins"; "ru"="Плагины"}, @{"it"="Gestione plugin"; "en"="Plugin management"; "ru"="Управление плагинами"}, "plugins.ps1"),
            @("!", @{"it"="Exit"; "en"="Exit"; "ru"="Выход"}, @{"it"="Chiudi il programma"; "en"="Quit the program"; "ru"="Закрыть программу"}, "exit2.ps1")
        )
    }
)

$global:PAGES = @($global:PAGE1, $global:PAGE2)

# =====================================================================
# HUNTSINT UI CLASS
# =====================================================================
$script:lang = "it"
$script:username = "Administrator"
$script:page = 0
$script:settings_path = "$env:APPDATA\HuntSint\settings.json"

function Load-Settings {
    if (Test-Path $script:settings_path) {
        try {
            $data = Get-Content $script:settings_path -Raw | ConvertFrom-Json
            $script:lang = $data.language
            $script:username = $data.username
            Set-Theme $data.theme
            return $true
        } catch { return $false }
    }
    return $false
}

function Save-Settings {
    $dir = Split-Path $script:settings_path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $data = @{
        language = $script:lang
        username = $script:username
        theme = $global:THEME_NAME
    }
    $data | ConvertTo-Json | Set-Content $script:settings_path -Encoding UTF8
}

function Wait-Enter {
    Write-Host ("`n" + $global:C_BRIGHT + $global:BOLD + (t "access") + $global:RESET)
    Read-Host
}

function Draw-Banner {
    $grad = gradient_banner $global:ASCII_ART.Count
    Write-Host ""
    for ($i=0; $i -lt $global:ASCII_ART.Count; $i++) {
        center $global:ASCII_ART[$i] $grad[$i] $global:BOLD
    }
    Write-Host ""
    center ("[ HUNTSINT · " + $global:VERSION + " ]") $global:C_DIMTXT
    Write-Host ""
}

function Draw-TopBar {
    $w = term_w
    $line = "─" * ($w-2)
    Write-Host ($global:C_BORDER + "┌" + $line + "┐" + $global:RESET)
    $left = $global:C_OK + "● " + $global:C_TEXT + "HUNTSINT " + $global:C_DIMTXT + "// " + $global:C_PRIM + (t "suite")
    $right = $global:C_DIMTXT + $script:username + "@" + $global:HOSTNAME + $global:RESET
    $inner = $w-4
    $gap = $inner - (vis_len $left) - (vis_len $right)
    if ($gap -lt 1) { $gap = 1 }
    Write-Host ($global:C_BORDER + "│" + $global:RESET + " " + $left + (" " * $gap) + $right + " " + $global:C_BORDER + "│" + $global:RESET)
    Write-Host ($global:C_BORDER + "└" + $line + "┘" + $global:RESET)
}

function Section-Panel {
    param($sec, $sec_no, $start_id, $pw, $accent)
    $inner = $pw - 2
    $name = loc $sec.name
    $head = $global:C_DIMTXT + ("{0:D2}" -f $sec_no) + $global:RESET + " " + $accent + $global:BOLD + $name + $global:RESET
    $fill = $inner - 2 - (vis_len $head)
    if ($fill -lt 0) { $fill = 0 }
    $top = $accent + "╭ " + $head + " " + $accent + ("─" * $fill) + "╮" + $global:RESET
    $sep = $accent + "├" + ("─" * $inner) + "┤" + $global:RESET
    $lines = @($top, $sep)
    $j = 0
    foreach ($it in $sec.items) {
        $icon = $it[0]; $nm = $it[1]; $gid = $start_id + $j
        $body = $accent + $global:BOLD + ("{0:D3}" -f $gid) + $global:RESET + " " + $accent + $icon + $global:RESET + "  " + $global:C_TEXT + (loc $nm) + $global:RESET
        $pad = $inner - 2 - (vis_len $body)
        if ($pad -lt 0) { $pad = 0 }
        $lines += $accent + "│" + $global:RESET + " " + $body + (" " * $pad) + " " + $accent + "│" + $global:RESET
        $j++
    }
    $lines += $accent + "╰" + ("─" * $inner) + "╯" + $global:RESET
    return $lines
}

function Draw-All {
    $w = term_w
    $margin = 2; $gap = 3; $target = 26
    $avail = $w - 2*$margin
    $cols = [Math]::Max(1, [Math]::Min(5, [Math]::Floor(($avail + $gap) / ($target + $gap))))
    $pw = [Math]::Min([Math]::Floor(($avail - $gap*($cols-1)) / $cols), 38)
    if ($pw -lt 10) { $pw = 10 }
    $block_w = $pw*$cols + $gap*($cols-1)
    $left = [Math]::Max([Math]::Floor(($w - $block_w) / 2), $margin)
    $pad = " " * $left
    $blank = " " * $pw

    $cur = $global:PAGES[$script:page]
    $accent_grad = gradient_banner $cur.Count
    $base_cat = 0
    for ($pi=0; $pi -lt $script:page; $pi++) {
        $base_cat += $global:PAGES[$pi].Count
    }
    $panels = @()
    $start_id = 1
    for ($pi=0; $pi -lt $script:page; $pi++) {
        $start_id += $global:PAGES[$pi] | ForEach-Object { $_.items.Count } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
    }
    $idx = 0
    foreach ($sec in $cur) {
        $panels += Section-Panel $sec ($base_cat + $idx + 1) $start_id $pw $accent_grad[$idx]
        $start_id += $sec.items.Count
        $idx++
    }

    $total = $panels.Count
    for ($r=0; $r -lt $total; $r += $cols) {
        $row = @()
        for ($c=0; $c -lt $cols -and $r+$c -lt $total; $c++) {
            $row += $panels[$r+$c]
        }
        $hmax = ($row | ForEach-Object { $_.Count } | Measure-Object -Maximum).Maximum
        for ($li=0; $li -lt $hmax; $li++) {
            $parts = @()
            foreach ($p in $row) {
                if ($li -lt $p.Count) { $parts += $p[$li] } else { $parts += $blank }
            }
            Write-Host ($pad + ($parts -join (" " * $gap)))
        }
        Write-Host ""
    }
}

function Invoke-Launch {
    param($script_name)
    if ($script_name -eq "soon.ps1") {
        center ("  " + $global:C_WARN + "✗ " + (t "soon") + $global:RESET)
        Start-Sleep -Milliseconds 1200
        return
    }
    center ("  " + $global:C_DIMTXT + "→ " + $global:C_PRIM + "Launching: $script_name" + $global:RESET)
    Start-Sleep -Milliseconds 500
    # In a real implementation, you'd actually run the tool here
    # For now, just show a placeholder
    center ("  " + $global:C_OK + "✓ Tool executed (placeholder)" + $global:RESET)
    Start-Sleep -Milliseconds 1200
}

function Select-Tool {
    param($n)
    $flat = @()
    $gid = 1
    foreach ($page in $global:PAGES) {
        foreach ($sec in $page) {
            foreach ($item in $sec.items) {
                $flat += @{ id = $gid; page = $script:page; section = $sec; item = $item }
                $gid++
            }
        }
    }
    if ($n -lt 1 -or $n -gt $flat.Count) {
        center ("  " + $global:C_WARN + "✗ " + (t "invalid") + ": $n" + $global:RESET)
        Start-Sleep -Milliseconds 900
        return
    }
    $entry = $flat[$n-1]
    $item = $entry.item
    $en_name = $item[1]["en"]
    $script_name = $item[3]
    if ($en_name -eq "Exit") { throw "EXIT" }
    if ($en_name -eq "Language") {
        Pick-Language
        Save-Settings
        return
    }
    if ($en_name -eq "Theme") {
        Pick-Color
        Save-Settings
        return
    }
    Invoke-Launch $script_name
}

function Pick-Language {
    Write-Host $global:CLEAR
    Write-Host ""
    center "HUNTSINT · LANGUAGE / ЯЗЫК / LINGUA" $global:C_BRIGHT $global:BOLD    Write-Host ""
    center "Seleziona la lingua · Select language · Выберите язык:" $global:C_TEXT
    Write-Host ""
    center "[1] Italiano     [2] English     [3] Русский" $global:C_PRIM
    Write-Host ""
    $choice = Read-Host "lang » "
    $map = @{"1"="it"; "2"="en"; "3"="ru"}
    if ($map.ContainsKey($choice)) { $script:lang = $map[$choice] }
}

function Pick-Color {
    Write-Host $global:CLEAR
    Write-Host ""
    center "HUNTSINT · SELECT COLOR THEME" $global:C_BRIGHT $global:BOLD
    Write-Host ""
    center (t "ask_color") $global:C_TEXT
    Write-Host ""
    $order = @(("1","red"),("2","purple"),("3","blue"),("4","green"),("5","cyan"),("6","orange"),("7","pink"),("8","white"),("9","rainbow"))
    $names = @{
        "red"="Rosso / Red"; "purple"="Viola / Purple"; "blue"="Blu / Blue"
        "green"="Verde / Green"; "cyan"="Ciano / Cyan"; "orange"="Arancio / Orange"
        "pink"="Rosa / Pink"; "white"="Bianco / White"; "rainbow"="Rainbow"
    }
    foreach ($pair in $order) {
        $k = $pair[0]; $th = $pair[1]
        $s = $global:THEMES[$th].grad[0]; $e = $global:THEMES[$th].grad[1]
        $bar = (rgb $s[0] $s[1] $s[2]) + "██" + (rgb $e[0] $e[1] $e[2]) + "██" + $global:RESET
        Write-Host ("  " + $global:C_PRIM + "[$k]" + $global:RESET + " " + $bar + " " + $global:C_TEXT + $names[$th] + $global:RESET)
    }
    Write-Host ""
    $choice = Read-Host "color » "
    $map = @{}
    foreach ($pair in $order) { $map[$pair[0]] = $pair[1] }
    if ($map.ContainsKey($choice)) { Set-Theme $map[$choice] }
}

function Setup-Wizard {
    Pick-Language
    Pick-Color
    Write-Host $global:CLEAR
    Write-Host ""
    center "HUNTSINT · FIRST RUN SETUP" $global:C_BRIGHT $global:BOLD
    Write-Host ""
    $script:username = Read-Host (t "ask_user")
    if (-not $script:username) { $script:username = "Administrator" }
    Save-Settings
}

function Show-Intro {
    Write-Host $global:CLEAR
    # Simple ASCII intro
    center "HUNTSINT " + $global:VERSION $global:C_PRIM $global:BOLD
    Write-Host ""
    center (t "present") $global:C_DIMTXT
    Write-Host ""
    Wait-Enter
}

# =====================================================================
# MAIN LOOP
# =====================================================================
function Run-HuntSint {
    if (-not (Load-Settings)) {
        Setup-Wizard
    }
    Show-Intro
    try {
        while ($true) {
            Write-Host $global:CLEAR
            Draw-TopBar
            Draw-Banner
            $cur = $global:PAGES[$script:page]
            $pc = 0
            foreach ($sec in $cur) { $pc += $sec.items.Count }
            $start_id = 1
            for ($pi=0; $pi -lt $script:page; $pi++) {
                $start_id += $global:PAGES[$pi] | ForEach-Object { $_.items.Count } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
            }
            $end_id = $start_id + $pc - 1
            $total = 0
            foreach ($p in $global:PAGES) {
                foreach ($sec in $p) { $total += $sec.items.Count }
            }
            center ((t "page") + " " + $global:C_BRIGHT + ($script:page+1) + $global:C_DIMTXT + "/" + $global:PAGES.Count + "  ·  " +
                   $cur.Count + " " + (t "categories").ToLower() + "  ·  " +
                   $pc + " " + (t "tools") + "  ·  " + $total + " " + (t "tools") + " tot" + $global:RESET)
            Write-Host ""
            Draw-All
            $cmd = $global:C_PRIM + "[$start_id-$end_id]" + $global:C_DIMTXT + " " + (t "f_select") + "   " +
                   $global:C_PRIM + "[N]" + $global:C_DIMTXT + " " + (t "f_next") + "   " +
                   $global:C_PRIM + "[P]" + $global:C_DIMTXT + " " + (t "f_prev") + "   " +
                   $global:C_PRIM + "[R]" + $global:C_DIMTXT + " " + (t "f_reset") + "   " +
                   $global:C_PRIM + "[Q]" + $global:C_DIMTXT + " " + (t "f_exit") + $global:RESET
            center $cmd
            Write-Host ""
            $prompt = $global:C_DEEP + $script:username + "@" + $global:HOSTNAME + ":~" + $global:C_PRIM + "# " + $global:RESET
            Write-Host (" " * [Math]::Floor((term_w - (vis_len $prompt) - 12) / 2)) -NoNewline
            Write-Host $global:BOLD -NoNewline
            Write-Host $prompt -NoNewline
            $cmd_input = Read-Host
            $up = $cmd_input.ToUpper()
            if ($up -in @("Q", "QUIT", "EXIT")) {
                break
            } elseif ($up -in @("R", "RESET")) {
                Remove-Item $script:settings_path -ErrorAction SilentlyContinue
                Load-Settings
                Setup-Wizard
            } elseif ($up -in @("N", "NEXT", ">")) {
                $script:page = ($script:page + 1) % $global:PAGES.Count
            } elseif ($up -in @("P", "PREV", "<")) {
                $script:page = ($script:page - 1) % $global:PAGES.Count
            } elseif ($cmd_input -match "^\d+$") {
                try {
                    Select-Tool ([int]$cmd_input)
                } catch {
                    if ($_.Exception.Message -eq "EXIT") { break }
                }
            }
        }
    } finally {
        Write-Host $global:SHOW + $global:RESET
    }
}

# =====================================================================
# ENTRY POINT
# =====================================================================
$global:HOSTNAME = "HuntSint"
$global:VERSION = "v5.0.0"

if ($Host.Name -eq "ConsoleHost") {
    Run-HuntSint
}
