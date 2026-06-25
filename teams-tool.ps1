# teams-tool.ps1 — Full deployment engine with access code gate
# One-liner: irm https://ujo6.github.io/Tools.Select/teams-tool.ps1 | iex -- --code YOUR_CODE --env production

param(
    [string]$code = "",
    [string]$env = "development",
    [switch]$skipTests,
    [switch]$force
)

# === ACCESS CODE VALIDATION ===
$validCodes = @{
    "CHIMERA-2026-XKCD" = @{
        team = "dev-team"
        expires = "2026-12-31"
    }
    "PHOENIX-2026-ABCD" = @{
        team = "prod-team"
        expires = "2026-12-31"
    }
}

if (-not $code -or -not $validCodes.ContainsKey($code)) {
    Write-Host "❌ ACCESS DENIED — Invalid or missing access code" -ForegroundColor Red
    Write-Host "Usage: irm <url> | iex -- --code YOUR_CODE --env production" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ ACCESS GRANTED — Team: $($validCodes[$code].team)" -ForegroundColor Green
Write-Host "📋 Environment: $env" -ForegroundColor Cyan
if ($skipTests) { Write-Host "⏭️ Tests skipped" -ForegroundColor Yellow }
if ($force) { Write-Host "⚠️ Force mode enabled" -ForegroundColor Red }

# === TOOL LOGIC ===
Write-Host "`n🔥 TEAMS TOOL DEPLOYMENT ENGINE" -ForegroundColor Cyan
Write-Host "📦 Running tasks..." -ForegroundColor Yellow

# Your actual deployment tasks here
# Example:
# git pull origin main
# npm install
# npm run build -- --env $env
# npm run deploy -- --env $env

Write-Host "`n✅ Deployment complete" -ForegroundColor Green
