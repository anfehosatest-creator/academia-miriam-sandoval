# ============================================================
#  Sube el proyecto a un repositorio YA CREADO en github.com
#  (no usa gh, solo git)
#
#  Ejecutar con:
#    powershell -ExecutionPolicy Bypass -File ".\subir-sin-gh.ps1"
# ============================================================

$ErrorActionPreference = 'Continue'
Set-Location $PSScriptRoot

$nombreRepo = 'academia-miriam-sandoval'

Write-Host ""
Write-Host "=== Subida a GitHub (sin gh) ===" -ForegroundColor Cyan
Write-Host ""

# --- Usuario de GitHub ----------------------------------------
Write-Host "Escribe tu nombre de usuario de GitHub y presiona Enter." -ForegroundColor Yellow
Write-Host "(es el que aparece arriba a la derecha en github.com)" -ForegroundColor DarkGray
$usuario = (Read-Host "Usuario").Trim()

if ([string]::IsNullOrWhiteSpace($usuario)) {
    Write-Host ""
    Write-Host "  X  No escribiste ningun usuario." -ForegroundColor Red
    Write-Host ""
    exit 1
}

$url = "https://github.com/$usuario/$nombreRepo.git"
Write-Host ""
Write-Host "Se subira a: $url" -ForegroundColor Cyan
Write-Host ""

# --- Configurar el destino ------------------------------------
$remotos = (& git remote | Out-String)
if ($remotos -match 'origin') { & git remote remove origin | Out-Null }
& git remote add origin $url

# --- Subir ----------------------------------------------------
Write-Host "Subiendo... Puede abrirse una ventana pidiendo autorizacion." -ForegroundColor Yellow
Write-Host "Si aparece, elige 'Sign in with your browser' y autoriza." -ForegroundColor Yellow
Write-Host ""

& git push -u origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  X  No se pudo subir." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Revisa que:" -ForegroundColor Yellow
    Write-Host "   - el usuario '$usuario' este bien escrito"
    Write-Host "   - el repositorio '$nombreRepo' exista en github.com"
    Write-Host "   - lo hayas creado VACIO (sin marcar 'Add a README file')"
    Write-Host ""
    Write-Host "  Copia esta ventana completa y enviasela a Claude." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "=== LISTO ===" -ForegroundColor Green
Write-Host ""
Write-Host "  Tu repositorio:" -ForegroundColor White
Write-Host "  https://github.com/$usuario/$nombreRepo" -ForegroundColor Cyan
Write-Host ""
