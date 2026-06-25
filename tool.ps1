# HuntSint Intelligence Suite - PowerShell GUI Version
# Save as HuntSint.ps1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Color definitions matching the Python version
$Colors = @{
    'Deep' = [System.Drawing.Color]::FromArgb(140, 50, 230)
    'Prim' = [System.Drawing.Color]::FromArgb(170, 80, 255)
    'Bright' = [System.Drawing.Color]::FromArgb(195, 130, 255)
    'Glow' = [System.Drawing.Color]::FromArgb(220, 185, 255)
    'Border' = [System.Drawing.Color]::FromArgb(110, 55, 160)
    'DimTxt' = [System.Drawing.Color]::FromArgb(140, 110, 175)
    'Badge' = [System.Drawing.Color]::FromArgb(170, 95, 240)
    'Text' = [System.Drawing.Color]::FromArgb(228, 222, 240)
    'OK' = [System.Drawing.Color]::FromArgb(120, 230, 160)
    'Warn' = [System.Drawing.Color]::FromArgb(255, 95, 120)
    'Hi' = [System.Drawing.Color]::FromArgb(120, 60, 200)
}

# Language support
$Lang = @{
    'it' = @{
        'suite' = 'SUITE DI INTELLIGENCE'
        'online' = '● ONLINE'
        'categories' = 'CATEGORIE'
        'tools' = 'strumenti'
        'page' = 'Pagina'
        'select' = 'seleziona'
        'exit' = 'esci'
        'reset' = 'reset'
        'next' = 'pag. succ.'
        'prev' = 'pag. prec.'
        'invalid' = 'ID non valido'
        'soon' = 'non ancora disponibile'
    }
    'en' = @{
        'suite' = 'INTELLIGENCE SUITE'
        'online' = '● ONLINE'
        'categories' = 'CATEGORIES'
        'tools' = 'tools'
        'page' = 'Page'
        'select' = 'select'
        'exit' = 'exit'
        'reset' = 'reset'
        'next' = 'next page'
        'prev' = 'prev page'
        'invalid' = 'Invalid ID'
        'soon' = 'not yet available'
    }
    'ru' = @{
        'suite' = 'РАЗВЕДЫВАТЕЛЬНЫЙ НАБОР'
        'online' = '● В СЕТИ'
        'categories' = 'КАТЕГОРИИ'
        'tools' = 'инструм.'
        'page' = 'Страница'
        'select' = 'выбор'
        'exit' = 'выход'
        'reset' = 'сброс'
        'next' = 'след. стр.'
        'prev' = 'пред. стр.'
        'invalid' = 'Неверный ID'
        'soon' = 'пока недоступно'
    }
}

# Page 1 data structure
$PAGE1 = @(
    @{
        name = @{it='OSINT'; en='OSINT'; ru='OSINT'}
        tag = @{it='Identificatori, infrastruttura & esposizione'; en='Identifiers, infrastructure & exposure'; ru='Идентификаторы, инфраструктура и утечки'}
        items = @(
            @('⌖', @{it='Lookup Phone'; en='Lookup Phone Number'; ru='Номер тел.'}, @{it='Validazione e carrier'; en='Validation & carrier'; ru='Проверка и оператор'}, 'number.py'),
            @('@', @{it='Lookup Email'; en='Lookup Email'; ru='Lookup Email'}, @{it='Validità, MX, leak'; en='Validity, MX, leak'; ru='Валидность, MX, утечки'}, 'soon.py'),
            @('#', @{it='Lookup Username'; en='Lookup Username'; ru='Имя польз.'}, @{it='Enumerazione multi-piattaforma'; en='Cross-platform enum'; ru='Поиск по платформам'}, 'username.py'),
            @('+', @{it='Lookup IP'; en='Lookup IP'; ru='Поиск IP'}, @{it='Geo, ASN, reverse DNS'; en='Geo, ASN, reverse DNS'; ru='Гео, ASN, reverse DNS'}, 'ip_lookup.py'),
            @('~', @{it='Lookup Dominio'; en='Lookup Domain'; ru='Домен'}, @{it='Record, registrar, infra'; en='Records, registrar, infra'; ru='Записи, регистратор'}, 'soon.py'),
            @('?', @{it='Lookup DNS'; en='Whois Lookup'; ru='Whois'}, @{it='Dati di registrazione'; en='Registration data'; ru='Данные регистрации'}, 'soon.py'),
            @('=', @{it='Lookup Whois'; en='DNS Lookup'; ru='DNS-запрос'}, @{it='A/AAAA/MX/TXT/NS'; en='A/AAAA/MX/TXT/NS'; ru='A/AAAA/MX/TXT/NS'}, 'soon.py'),
            @('!', @{it='Lookup Database'; en='Lookup Database'; ru='Утечки'}, @{it='Esposizione in leak noti'; en='Exposure in known leaks'; ru='Проверка по утечкам'}, 'database.py')
        )
    },
    @{
        name = @{it='OSINT'; en='OSINT'; ru='OSINT'}
        tag = @{it='Ricognizione di rete e infrastruttura'; en='Network & infrastructure recon'; ru='Разведка сети и инфраструктуры'}
        items = @(
            @('*', @{it='Wayback'; en='Lookup Port Scanner'; ru='Скан портов'}, @{it='Porte e servizi esposti'; en='Open ports & services'; ru='Открытые порты'}, 'soon.py'),
            @('o', @{it='Google Dorks'; en='ASN Lookup'; ru='ASN'}, @{it='Autonomous System'; en='Autonomous System'; ru='Автономная система'}, 'soon.py'),
            @('+', @{it='Robots.txt / Sitemap'; en='Reverse IP'; ru='Reverse IP'}, @{it='Domini sullo stesso IP'; en='Domains on same IP'; ru='Домены на одном IP'}, 'soon.py'),
            @('>', @{it='Tech Stack'; en='Traceroute'; ru='Traceroute'}, @{it='Percorso verso host'; en='Path to host'; ru='Путь до узла'}, 'soon.py'),
            @('.', @{it='Cookie Inspect'; en='Ping Sweep'; ru='Ping Sweep'}, @{it='Host attivi nel range'; en='Live hosts in range'; ru='Активные узлы'}, 'soon.py'),
            @('=', @{it='Redirect Trace'; en='SSL Info'; ru='SSL'}, @{it='Certificato e catena TLS'; en='TLS cert & chain'; ru='Сертификат TLS'}, 'soon.py'),
            @('·', @{it='Prossimamente'; en='Coming Soon'; ru='Скоро'}, @{it='Modulo in arrivo'; en='Module coming soon'; ru='Модуль скоро'}, 'soon.py'),
            @('·', @{it='Prossimamente'; en='Coming Soon'; ru='Скоро'}, @{it='Modulo in arrivo'; en='Module coming soon'; ru='Модуль скоро'}, 'soon.py')
        )
    },
    @{
        name = @{it='WIFI'; en='WIFI'; ru='ВЕБ'}
        tag = @{it='Analisi di siti e superfici pubbliche'; en='Sites & public surface analysis'; ru='Анализ сайтов и поверхности'}
        items = @(
            @('o', @{it='Port Scanner'; en='Wayback'; ru='Wayback'}, @{it='Snapshot storici'; en='Historical snapshots'; ru='История страниц'}, 'soon.py'),
            @('?', @{it='ASN Lookup'; en='Google Dorks'; ru='Google Dorks'}, @{it='Query avanzate mirate'; en='Targeted advanced queries'; ru='Точные запросы'}, 'google_dorks.py'),
            @('&', @{it='Reverse IP'; en='Tech Stack'; ru='Стек технол.'}, @{it='Tecnologie rilevate'; en='Detected technologies'; ru='Технологии сайта'}, 'soon.py'),
            @('=', @{it='Traceroute'; en='Robots/Sitemap'; ru='Robots/Map'}, @{it='robots.txt e sitemap'; en='robots.txt & sitemap'; ru='robots и sitemap'}, 'soon.py'),
            @('~', @{it='Ping Sweep'; en='CMS Detect'; ru='CMS'}, @{it='Riconoscimento CMS'; en='CMS fingerprint'; ru='Определение CMS'}, 'soon.py'),
            @('*', @{it='SSL Info'; en='Favicon Hash'; ru='Favicon Hash'}, @{it='Hash per pivoting'; en='Hash for pivoting'; ru='Хеш favicon'}, 'soon.py'),
            @('>', @{it='HTTP Headers'; en='Redirect Trace'; ru='Редиректы'}, @{it='Catena di redirect'; en='Redirect chain'; ru='Цепочка редиректов'}, 'soon.py'),
            @('o', @{it='Subdomain Enum'; en='Cookie Inspect'; ru='Cookie'}, @{it='Cookie e flag sicurezza'; en='Cookies & security flags'; ru='Cookie и флаги'}, 'soon.py')
        )
    },
    @{
        name = @{it='SOCIAL'; en='SOCIAL'; ru='СОЦСЕТИ'}
        tag = @{it='Profili pubblici per piattaforma'; en='Public profiles per platform'; ru='Публичные профили'}
        items = @(
            @('o', @{it='Roblox'; en='Roblox'; ru='Roblox'}, @{it='Profilo pubblico'; en='Public profile'; ru='Публичный профиль'}, 'soon.py'),
            @('o', @{it='Discord'; en='Discord'; ru='Discord'}, @{it='Info pubbliche da ID'; en='Public info from ID'; ru='Инфо по ID'}, 'soon.py'),
            @('o', @{it='Instagram'; en='Instagram'; ru='Instagram'}, @{it='Dati pubblici profilo'; en='Public profile data'; ru='Данные профиля'}, 'soon.py'),
            @('o', @{it='Telegram'; en='Telegram'; ru='Telegram'}, @{it='Info utente/canale'; en='User/channel info'; ru='Юзер/канал'}, 'soon.py'),
            @('o', @{it='TikTok'; en='TikTok'; ru='TikTok'}, @{it='Profilo pubblico'; en='Public profile'; ru='Публичный профиль'}, 'soon.py'),
            @('o', @{it='Github'; en='Github'; ru='Github'}, @{it='Profilo e attività'; en='Profile & activity'; ru='Профиль и активность'}, 'soon.py'),
            @('o', @{it='X'; en='X (Twitter)'; ru='X (Twitter)'}, @{it='Profilo pubblico'; en='Public profile'; ru='Публичный профиль'}, 'soon.py'),
            @('o', @{it='LinkedIn'; en='LinkedIn'; ru='LinkedIn'}, @{it='Profilo professionale'; en='Professional profile'; ru='Проф. профиль'}, 'soon.py')
        )
    },
    @{
        name = @{it='GEOSINT'; en='GEOSINT'; ru='ИЗОБРАЖ.'}
        tag = @{it='Analisi immagini e geolocalizzazione'; en='Image analysis & geolocation'; ru='Анализ изображений и гео'}
        items = @(
            @('o', @{it='Reverse Img'; en='Reverse Image'; ru='Reverse Image'}, @{it='Ricerca inversa'; en='Reverse search'; ru='Обратный поиск'}, 'soon.py'),
            @('=', @{it='EXIF'; en='EXIF'; ru='EXIF'}, @{it='Metadati immagine'; en='Image metadata'; ru='Метаданные'}, 'soon.py'),
            @('⌖', @{it='Metadata'; en='Metadata'; ru='Метаданные'}, @{it='Metadati foto'; en='Metadata photo'; ru='Метаданные фотографий'}, 'soon.py'),
            @('*', @{it='MetaData Html'; en='MetaData Html'; ru='Метаданные Html.'}, @{it='Metadati foto'; en='Metadata photo'; ru='Метаданные фотографий'}, 'soon.py'),
            @('.', @{it='Strumenti Geosint'; en='Geosint Tools'; ru='Инструменты Geosint'}, @{it='SIti Geosint'; en='Geosint Website'; ru='Сайт Геосинта'}, 'soon.py'),
            @('+', @{it='Map Lookup'; en='Map Lookup'; ru='Карты'}, @{it='Coordinate e mappe'; en='Coordinates & maps'; ru='Координаты и карты'}, 'soon.py'),
            @('o', @{it='Train Geosint'; en='Geosint Test'; ru='Поезд Геосинт'}, @{it='Test di geosint'; en='Geosint test'; ru='Тест Geosint'}, 'soon.py'),
            @('~', @{it='Color Probe'; en='Color Probe'; ru='Цвета'}, @{it='Estrazione palette'; en='Palette extraction'; ru='Извлечение палитры'}, 'soon.py')
        )
    },
    @{
        name = @{it='API'; en='API'; ru='НАБОРЫ'}
        tag = @{it='Framework di ricognizione automatizzata'; en='Automated recon frameworks'; ru='Авто-фреймворки разведки'}
        items = @(
            @('o', @{it='Intelx'; en='Intelx'; ru='Spiderfoot'}, @{it='Automazione modulare'; en='Modular automation'; ru='Модульная автоматизация'}, 'soon.py'),
            @('o', @{it='deadeye.cc'; en='deadeye.cc'; ru='TheHarvester'}, @{it='Email/host/subdomini'; en='Emails/hosts/subdomains'; ru='Email/хосты/поддомены'}, 'soon.py'),
            @('o', @{it='oathnet'; en='oathnet'; ru='Metagoofil'}, @{it='Metadati documenti'; en='Document metadata'; ru='Метаданные документов'}, 'soon.py'),
            @('o', @{it='See-know'; en='See-know'; ru='Exiftool'}, @{it='Analisi metadati'; en='Metadata analysis'; ru='Анализ метаданных'}, 'soon.py'),
            @('o', @{it='Sherlock'; en='Sherlock'; ru='Sherlock'}, @{it='Username multipiattaforma'; en='Username hunting'; ru='Поиск username'}, 'soon.py'),
            @('o', @{it='Maigret'; en='Maigret'; ru='Maigret'}, @{it='Profilazione username'; en='Username profiling'; ru='Профилирование'}, 'soon.py'),
            @('o', @{it='Holehe'; en='Holehe'; ru='Holehe'}, @{it='Email su servizi'; en='Email on services'; ru='Email на сервисах'}, 'soon.py'),
            @('o', @{it='Recon-ng'; en='Recon-ng'; ru='Recon-ng'}, @{it='Framework a moduli'; en='Modular framework'; ru='Модульный фреймворк'}, 'soon.py')
        )
    },
    @{
        name = @{it='OPSEC'; en='OPSEC'; ru='OPSEC'}
        tag = @{it='Operazional Security'; en='Operazional Security'; ru='Проверка и анализ email'}
        items = @(
            @('@', @{it='Opsec Setup'; en='Opsec Setup'; ru='Проверка'}, @{it='Sintassi e dominio'; en='Syntax & domain'; ru='Синтаксис и домен'}, 'soon.py'),
            @('=', @{it='Tutorial Opsec'; en='Tutorial Opsec'; ru='MX'}, @{it='Record di posta'; en='Mail records'; ru='Почтовые записи'}, 'soon.py'),
            @('!', @{it='VPN detection'; en='Vpn'; ru='Утечки'}, @{it='Presenza in leak'; en='Presence in leaks'; ru='Наличие в утечках'}, 'soon.py'),
            @('o', @{it='Proxy check'; en='Gravatar'; ru='Gravatar'}, @{it='Avatar collegato'; en='Linked avatar'; ru='Связанный аватар'}, 'soon.py'),
            @('.', @{it='Disposable Email'; en='Catch-all'; ru='Catch-all'}, @{it='Rilevamento catch-all'; en='Catch-all detection'; ru='Catch-all'}, 'soon.py'),
            @('≡', @{it='Browser Fingerprint Check'; en='Header Parse'; ru='Заголовки'}, @{it='Analisi header email'; en='Email header parse'; ru='Разбор заголовков'}, 'soon.py'),
            @('~', @{it='IP Reputation Check'; en='Disposable'; ru='Одноразов.'}, @{it='Email usa-e-getta'; en='Disposable email'; ru='Одноразовая почта'}, 'soon.py'),
            @('o', @{it='Credential Leak Check'; en='SMTP Probe'; ru='SMTP'}, @{it='Verifica casella (soft)'; en='Mailbox probe (soft)'; ru='Проверка ящика'}, 'soon.py')
        )
    }
)

# Create placeholder section
$soonSection = @{
    name = @{it='Prossimamente'; en='Coming Soon'; ru='Скоро'}
    tag = @{it='Modulo in arrivo'; en='Module coming soon'; ru='Модуль скоро'}
    items = @()
}
for ($i = 0; $i -lt 8; $i++) {
    $soonSection.items += @('·', @{it='Prossimamente'; en='Coming Soon'; ru='Скоро'}, @{it='Modulo in arrivo'; en='Module coming soon'; ru='Модуль скоро'}, 'soon.py')
}

# Add more sections (simplified for space)
$PAGE1 += $soonSection
$PAGE1 += $soonSection
$PAGE1 += @{
    name = @{it='DISCORD'; en='DISCORD'; ru='АРХИВЫ'}
    tag = @{it='Cache, snapshot e archivi pubblici'; en='Cache, snapshots & public archives'; ru='Кэш, снимки и архивы'}
    items = @(
        @('o', @{it='Webhook Tools'; en='Webhook Tools'; ru='Wayback'}, @{it='Snapshot storici'; en='Historical snapshots'; ru='История страниц'}, 'soon.py'),
        @('·', @{it='Prossimamente'; en='Coming Soon'; ru='Скоро'}, @{it='Modulo in arrivo'; en='Module coming soon'; ru='Модуль скоро'}, 'soon.py'),
        @('·', @{it='Prossimamente'; en='Coming Soon'; ru='Скоро'}, @{it='Modulo in arrivo'; en='Module coming soon'; ru='Модуль скоро'}, 'soon.py'),
        @('#', @{it='Server Info'; en='Server Info'; ru='Архив док.'}, @{it='Documenti archiviati'; en='Archived documents'; ru='Архив документов'}, 'soon.py'),
        @('>', @{it='User Info'; en='News Archive'; ru='Архив новост.'}, @{it='Archivio notizie'; en='News archive'; ru='Архив новостей'}, 'soon.py'),
        @('*', @{it='Bot Invite Gen'; en='Bot Invite Gen'; ru='Форумы'}, @{it='Ricerca su forum'; en='Forum search'; ru='Поиск по форумам'}, 'soon.py'),
        @('·', @{it='Prossimamente'; en='Coming Soon'; ru='Скоро'}, @{it='Modulo in arrivo'; en='Module coming soon'; ru='Модуль скоро'}, 'soon.py'),
        @('·', @{it='Prossimamente'; en='Coming Soon'; ru='Скоро'}, @{it='Modulo in arrivo'; en='Module coming soon'; ru='Модуль скоро'}, 'soon.py')
    )
}
$PAGE1 += @{
    name = @{it='SOCIAL TOOL'; en='SOCIAL TOOL'; ru='КОМПАНИИ'}
    tag = @{it='OSINT aziendale e registri pubblici'; en='Corporate OSINT & public registries'; ru='Корпоративный OSINT'}
    items = @(
        @('·', @{it='Prossimamente'; en='Coming Soon'; ru='Скоро'}, @{it='Modulo in arrivo'; en='Module coming soon'; ru='Модуль скоро'}, 'soon.py'),
        @('·', @{it='Prossimamente'; en='Coming Soon'; ru='Скоро'}, @{it='Modulo in arrivo'; en='Module coming soon'; ru='Модуль скоро'}, 'soon.py'),
        @('=', @{it='Boost Tools'; en='Boost Tools'; ru='ИНН/VAT'}, @{it='Partita IVA / codice'; en='Tax ID lookup'; ru='Налоговый номер'}, 'soon.py'),
        @('~', @{it='Join Tools'; en='Join Tools'; ru='Должн. лица'}, @{it='Amministratori e ruoli'; en='Directors & roles'; ru='Руководители'}, 'soon.py'),
        @('?', @{it='Delete Acc'; en='Delete Acc'; ru='Отчёты'}, @{it='Documenti depositati'; en='Filed documents'; ru='Поданные документы'}, 'soon.py'),
        @('*', @{it='Bot Discord'; en='Bot Discord'; ru='Бренд'}, @{it='Marchi registrati'; en='Registered trademarks'; ru='Товарные знаки'}, 'soon.py'),
        @('>', @{it='Auto Quest'; en='Auto Quest'; ru='LEI'}, @{it='Legal Entity ID'; en='Legal Entity ID'; ru='LEI-код'}, 'soon.py'),
        @('+', @{it='Shop'; en='Shop'; ru='История дом.'}, @{it='Storico whois dominio'; en='Whois history'; ru='История whois'}, 'soon.py')
    )
}
$PAGE1 += $soonSection
$PAGE1 += @{
    name = @{it='CODICE'; en='CODE'; ru='КОД'}
    tag = @{it='Ricognizione su repository pubblici'; en='Public repository recon'; ru='Разведка по репозиториям'}
    items = @(
        @('o', @{it='Repo Search'; en='Repo Search'; ru='Поиск репо'}, @{it='Ricerca repository'; en='Repository search'; ru='Поиск репозиториев'}, 'soon.py'),
        @('?', @{it='Code Grep'; en='Code Grep'; ru='Grep кода'}, @{it='Ricerca nel codice'; en='Search in code'; ru='Поиск в коде'}, 'soon.py'),
        @('#', @{it='Gist Search'; en='Gist Search'; ru='Gist'}, @{it='Ricerca gist pubblici'; en='Public gist search'; ru='Поиск gist'}, 'soon.py'),
        @('>', @{it='Commit Hunt'; en='Commit Hunt'; ru='Коммиты'}, @{it='Analisi cronologia commit'; en='Commit history dig'; ru='Анализ коммитов'}, 'soon.py'),
        @('=', @{it='Dependency'; en='Dependency'; ru='Завис.'}, @{it='Albero dipendenze'; en='Dependency tree'; ru='Дерево зависимостей'}, 'soon.py'),
        @('*', @{it='CI Config'; en='CI Config'; ru='CI-конфиг'}, @{it='File di pipeline CI'; en='CI pipeline files'; ru='Файлы CI'}, 'soon.py'),
        @('~', @{it='Secret Scan'; en='Secret Scan'; ru='Скан секрет.'}, @{it='Chiavi esposte nei repo'; en='Exposed keys in repos'; ru='Утёкшие ключи'}, 'soon.py'),
        @('+', @{it='Contributors'; en='Contributors'; ru='Контрибьют.'}, @{it='Mappa contributori'; en='Contributor map'; ru='Карта участников'}, 'soon.py')
    )
}
$PAGE1 += @{
    name = @{it='CERTIFICATI'; en='CERT'; ru='СЕРТИФИК.'}
    tag = @{it='Certificate Transparency & TLS'; en='Certificate Transparency & TLS'; ru='Прозрачность сертификатов'}
    items = @(
        @('o', @{it='crt.sh'; en='crt.sh'; ru='crt.sh'}, @{it='Ricerca CT log'; en='CT log search'; ru='Поиск CT-логов'}, 'soon.py'),
        @('=', @{it='CT Logs'; en='CT Logs'; ru='CT-логи'}, @{it='Certificate Transparency'; en='Certificate Transparency'; ru='Прозрачность серт.'}, 'soon.py'),
        @('*', @{it='SSL Labs'; en='SSL Labs'; ru='SSL Labs'}, @{it='Valutazione TLS'; en='TLS grading'; ru='Оценка TLS'}, 'soon.py'),
        @('#', @{it='Cert Chain'; en='Cert Chain'; ru='Цепочка'}, @{it='Catena di certificati'; en='Certificate chain'; ru='Цепочка серт.'}, 'soon.py'),
        @('?', @{it='OCSP'; en='OCSP'; ru='OCSP'}, @{it='Stato revoca'; en='Revocation status'; ru='Статус отзыва'}, 'soon.py'),
        @('~', @{it='HSTS'; en='HSTS'; ru='HSTS'}, @{it='Policy HSTS'; en='HSTS policy'; ru='Политика HSTS'}, 'soon.py'),
        @('>', @{it='Cipher Scan'; en='Cipher Scan'; ru='Шифры'}, @{it='Suite cifrari supportati'; en='Supported ciphers'; ru='Поддерж. шифры'}, 'soon.py'),
        @('+', @{it='Altri tools'; en='Other Tools'; ru='другие инструменты'}, @{it='Scadenza certificato'; en='Cert expiry'; ru='Срок действия'}, 'other_tools.py')
    )
}
$PAGE1 += @{
    name = @{it='SISTEMA'; en='SYSTEM'; ru='СИСТЕМА'}
    tag = @{it='Configurazione e informazioni'; en='Configuration & info'; ru='Конфигурация и инфо'}
    items = @(
        @('o', @{it='Impostazioni'; en='Settings'; ru='Настройки'}, @{it='Preferenze del tool'; en='Tool preferences'; ru='Параметры'}, 'soon.py'),
        @('~', @{it='Disclaimer'; en='Disclaimer'; ru='Отказ от ответственности'}, @{it='Disclaimer Di HuntSint'; en='Disclaimer Of HuntSint'; ru='Отказ от ответственности HuntSint'}, 'soon.py'),
        @('*', @{it='Tema'; en='Theme'; ru='Тема'}, @{it='Schema colori'; en='Color scheme'; ru='Цветовая схема'}, 'soon.py'),
        @('?', @{it='Info'; en='Info'; ru='Инфо'}, @{it='Informazioni di sistema'; en='System information'; ru='Сведения'}, 'info.py'),
        @('#', @{it='About'; en='About'; ru='О программе'}, @{it='Crediti e versione'; en='Credits & version'; ru='Авторы и версия'}, 'soon.py'),
        @('=', @{it='Update'; en='Update'; ru='Обновление'}, @{it='Verifica aggiornamenti'; en='Check for updates'; ru='Проверка обновлений'}, 'soon.py'),
        @('>', @{it='Logs'; en='Logs'; ru='Логи'}, @{it='Registro attività'; en='Activity log'; ru='Журнал'}, 'soon.py'),
        @('!', @{it='Exit'; en='Exit'; ru='Выход'}, @{it='Chiudi il programma'; en='Quit the program'; ru='Закрыть программу'}, 'soon.py')
    )
}

$PAGES = @($PAGE1)

# ASCII Art Banner
$ASCII_ART = @(
    "   ▄█    █▄    ███    █▄  ███▄▄▄▄       ███        ▄████████  ▄█  ███▄▄▄▄       ███     ",
    "  ███    ███   ███    ███ ███▀▀▀██▄ ▀█████████▄   ███    ███ ███  ███▀▀▀██▄ ▀█████████▄ ",
    "  ███    ███   ███    ███ ███   ███    ▀███▀▀██   ███    █▀  ███▌ ███   ███    ▀███▀▀██ ",
    " ▄███▄▄▄▄███▄▄ ███    ███ ███   ███     ███   ▀   ███        ███▌ ███   ███     ███   ▀ ",
    "▀▀███▀▀▀▀███▀  ███    ███ ███   ███     ███     ▀███████████ ███▌ ███   ███     ███     ",
    "  ███    ███   ███    ███ ███   ███     ███              ███ ███  ███   ███     ███     ",
    "  ███    ███   ███    ███ ███   ███     ███        ▄█    ███ ███  ███   ███     ███     ",
    "  ███    █▀    ████████▀   ▀█   █▀     ▄████▀    ▄████████▀  █▀    ▀█   █▀     ▄████▀    "
)

# LOGO Art for intro
$LOGO_ART = @"
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
"@

# Language selection
$global:currentLang = 'en'
$global:currentPage = 0
$global:username = 'ECH0'

function Get-Text {
    param($key)
    return $Lang[$global:currentLang][$key]
}

function Get-Localized {
    param($dict)
    return $dict[$global:currentLang]
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "HuntSint Intelligence Suite"
$form.Size = New-Object System.Drawing.Size(1400, 900)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 20)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $true
$form.MinimumSize = New-Object System.Drawing.Size(1200, 700)
$form.KeyPreview = $true

# Create main panel
$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Location = New-Object System.Drawing.Point(0, 0)
$mainPanel.Size = $form.ClientSize
$mainPanel.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 20)
$mainPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

# RichTextBox for display
$rtb = New-Object System.Windows.Forms.RichTextBox
$rtb.Location = New-Object System.Drawing.Point(10, 10)
$rtb.Size = New-Object System.Drawing.Size(1360, 800)
$rtb.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 20)
$rtb.ForeColor = [System.Drawing.Color]::FromArgb(228, 222, 240)
$rtb.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Regular)
$rtb.ReadOnly = $true
$rtb.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$rtb.WordWrap = $false
$rtb.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
$rtb.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

# Status bar
$statusBar = New-Object System.Windows.Forms.Label
$statusBar.Location = New-Object System.Drawing.Point(10, 820)
$statusBar.Size = New-Object System.Drawing.Size(1360, 30)
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 30)
$statusBar.ForeColor = [System.Drawing.Color]::Gray
$statusBar.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBar.Text = " ⚡ SYSTEM READY  |  [001-120] select   [N] next page   [P] prev page   [R] reset   [Q] exit"
$statusBar.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

function Build-Display {
    param($pageIndex)
    
    $w = 120
    $output = New-Object System.Text.StringBuilder
    
    # Top bar
    $topLine = "─" * ($w - 2)
    $null = $output.AppendLine("$($Colors.Border.Name)┌$topLine┐$($Colors.Border.Name)")
    
    $left = "● HUNTSINT // $($Colors.Prim.Name)$(Get-Text 'suite')$($Colors.DimTxt.Name)"
    $right = "$($Colors.DimTxt.Name)$global:username@HuntSint$($Colors.DimTxt.Name)"
    $gap = ($w - 4) - $left.Length - $right.Length
    $null = $output.AppendLine("$($Colors.Border.Name)│$($Colors.Text.Name) $left$(' ' * [Math]::Max($gap, 1))$right $($Colors.Border.Name)│$($Colors.Border.Name)")
    
    $null = $output.AppendLine("$($Colors.Border.Name)└$topLine┘$($Colors.Border.Name)")
    $null = $output.AppendLine("")
    
    # Banner
    $grad = @(
        "$($Colors.Deep.Name)", "$($Colors.Prim.Name)", "$($Colors.Bright.Name)", 
        "$($Colors.Glow.Name)", "$($Colors.Prim.Name)", "$($Colors.Deep.Name)",
        "$($Colors.Bright.Name)", "$($Colors.Glow.Name)"
    )
    for ($i = 0; $i -lt $ASCII_ART.Count; $i++) {
        $padding = [Math]::Max(($w - $ASCII_ART[$i].Length) / 2, 0)
        $null = $output.AppendLine("$(' ' * $padding)$($grad[$i % $grad.Count])$($ASCII_ART[$i])$($Colors.Text.Name)")
    }
    
    $null = $output.AppendLine("")
    
    # Status line
    $time = Get-Date -Format "HH:mm:ss"
    $statusLine = "$($Colors.DimTxt.Name)[ $($Colors.Bright.Name)$time$($Colors.DimTxt.Name) ]   cpu $($Colors.Glow.Name) 6%$($Colors.DimTxt.Name) · ram $($Colors.Glow.Name)64%$($Colors.DimTxt.Name) · $($Colors.OK.Name)$(Get-Text 'online')$($Colors.Text.Name)"
    $padding = [Math]::Max(($w - $statusLine.Length) / 2, 0)
    $null = $output.AppendLine("$(' ' * $padding)$statusLine")
    
    $null = $output.AppendLine("")
    
    # Page info
    $pageInfo = "$($Colors.DimTxt.Name)$(Get-Text 'page') $($Colors.Bright.Name)$($pageIndex + 1)$($Colors.DimTxt.Name)/$($PAGES.Count)  ·  $(Get-Text 'categories')  ·  tools  ·  120 tools tot$($Colors.Text.Name)"
    $padding = [Math]::Max(($w - $pageInfo.Length) / 2, 0)
    $null = $output.AppendLine("$(' ' * $padding)$pageInfo")
    
    $null = $output.AppendLine("")
    
    # Draw sections
    $curPage = $PAGES[$pageIndex]
    $cols = 5
    $colWidth = [Math]::Min(38, [Math]::Floor(($w - 20) / $cols))
    $colors = @($Colors.Deep, $Colors.Prim, $Colors.Bright, $Colors.Glow, $Colors.OK)
    
    for ($i = 0; $i -lt $curPage.Count; $i += $cols) {
        $rowSections = @()
        for ($j = 0; $j -lt $cols -and ($i + $j) -lt $curPage.Count; $j++) {
            $rowSections += $curPage[$i + $j]
        }
        
        # Top border
        $rowLines = @()
        foreach ($sec in $rowSections) {
            $color = $colors[([Array]::IndexOf($curPage, $sec) % $colors.Count)]
            $name = Get-Localized $sec.name
            $header = "$($color.Name)╭ $($color.Name)$name"
            $lineLength = $colWidth - 2
            $dashCount = [Math]::Max($lineLength - $header.Length, 1)
            $rowLines += "$header$('─' * $dashCount)╮$($Colors.Text.Name)"
        }
        $null = $output.AppendLine((" " * 10) + ($rowLines -join "   "))
        
        # Separator
        $sepLines = @()
        foreach ($sec in $rowSections) {
            $color = $colors[([Array]::IndexOf($curPage, $sec) % $colors.Count)]
            $sepLines += "$($color.Name)├$('─' * ($colWidth - 2))┤$($Colors.Text.Name)"
        }
        $null = $output.AppendLine((" " * 10) + ($sepLines -join "   "))
        
        # Items
        $maxItems = 8
        $itemLines = @()
        for ($itemIdx = 0; $itemIdx -lt $maxItems; $itemIdx++) {
            $lineParts = @()
            foreach ($sec in $rowSections) {
                $color = $colors[([Array]::IndexOf($curPage, $sec) % $colors.Count)]
                if ($itemIdx -lt $sec.items.Count) {
                    $item = $sec.items[$itemIdx]
                    $id = ($i + $itemIdx + 1).ToString("000")
                    $icon = $item[0]
                    $name = Get-Localized $item[1]
                    $body = "$($color.Name)$id $icon  $($Colors.Text.Name)$($name.Substring(0, [Math]::Min(20, $name.Length)))"
                    $padding = [Math]::Max($colWidth - 2 - $body.Length, 0)
                    $lineParts += "$($color.Name)│$($Colors.Text.Name) $body$(' ' * $padding) $($color.Name)│$($Colors.Text.Name)"
                } else {
                    $lineParts += "$($color.Name)│$(' ' * ($colWidth - 2))$($color.Name)│$($Colors.Text.Name)"
                }
            }
            $null = $output.AppendLine((" " * 10) + ($lineParts -join "   "))
        }
        
        # Bottom border
        $bottomLines = @()
        foreach ($sec in $rowSections) {
            $color = $colors[([Array]::IndexOf($curPage, $sec) % $colors.Count)]
            $bottomLines += "$($color.Name)╰$('─' * ($colWidth - 2))╯$($Colors.Text.Name)"
        }
        $null = $output.AppendLine((" " * 10) + ($bottomLines -join "   "))
        $null = $output.AppendLine("")
    }
    
    # Commands
    $startId = 1
    $endId = 120
    $cmds = "$($Colors.Prim.Name)[$($startId.ToString("000"))-$($endId.ToString("000"))]$($Colors.DimTxt.Name) $(Get-Text 'select')   $($Colors.Prim.Name)[N]$($Colors.DimTxt.Name) $(Get-Text 'next')   $($Colors.Prim.Name)[P]$($Colors.DimTxt.Name) $(Get-Text 'prev')   $($Colors.Prim.Name)[R]$($Colors.DimTxt.Name) $(Get-Text 'reset')   $($Colors.Prim.Name)[Q]$($Colors.DimTxt.Name) $(Get-Text 'exit')$($Colors.Text.Name)"
    $padding = [Math]::Max(($w - $cmds.Length) / 2, 0)
    $null = $output.AppendLine("$(' ' * $padding)$cmds")
    
    $null = $output.AppendLine("")
    
    # Prompt
    $prompt = "$($Colors.Deep.Name)$global:username@HuntSint:~$($Colors.Prim.Name)# $($Colors.Text.Name)"
    $padding = [Math]::Max(($w - $prompt.Length - 10) / 2, 0)
    $null = $output.AppendLine("$(' ' * $padding)$prompt")
    
    return $output.ToString()
}

function Update-Display {
    $rtb.Text = Build-Display -pageIndex $global:currentPage
    $rtb.Select(0, 0)
    $rtb.SelectionLength = 0
    
    $totalItems = 120
    $startId = 1
    $endId = 120
    $statusBar.Text = " ⚡ SYSTEM READY  |  [$($startId.ToString("000"))-$($endId.ToString("000"))] select   [N] next page   [P] prev page   [R] reset   [Q] exit"
}

# Keyboard shortcuts
$form.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Q) {
        $form.Close()
    }
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::N) {
        $global:currentPage = ($global:currentPage + 1) % $PAGES.Count
        Update-Display
        $statusBar.Text = " ⚡ NAVIGATING TO PAGE $($global:currentPage + 1)...  |  PRESS [P] TO RETURN"
    }
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::P) {
        $global:currentPage = ($global:currentPage - 1) % $PAGES.Count
        if ($global:currentPage -lt 0) { $global:currentPage = $PAGES.Count - 1 }
        Update-Display
        $statusBar.Text = " ⚡ RETURNING TO PAGE $($global:currentPage + 1)...  |  PRESS [N] FOR NEXT"
    }
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::R) {
        Update-Display
        $statusBar.Text = " ⚡ RESETTING DISPLAY...  |  SYSTEM READY"
    }
})

# Add controls
$mainPanel.Controls.Add($rtb)
$mainPanel.Controls.Add($statusBar)
$form.Controls.Add($mainPanel)

# Show startup animation
function Show-Startup {
    $rtb.Clear()
    $rtb.ForeColor = $Colors.Prim
    
    $logoLines = $LOGO_ART -split "`n"
    $displayText = ""
    for ($i = 0; $i -lt $logoLines.Count; $i++) {
        if ($logoLines[$i].Trim() -ne "") {
            $displayText += $logoLines[$i] + "`n"
        }
    }
    $rtb.Text = $displayText
    $rtb.ForeColor = [System.Drawing.Color]::FromArgb(170, 80, 255)
    $rtb.SelectAll()
    $rtb.SelectionFont = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Bold)
    $rtb.Select(0, 0)
    $rtb.SelectionLength = 0
}

# Show the form
$form.Add_Shown({
    $form.Activate()
    Show-Startup
    Start-Sleep -Milliseconds 500
    Update-Display
})

$form.ShowDialog() | Out-Null
