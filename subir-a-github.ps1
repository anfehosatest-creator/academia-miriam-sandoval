# ============================================================
#  Sube la landing page de la Academia Miriam Sandoval a GitHub
#  Ejecutar con:
#    powershell -ExecutionPolicy Bypass -File ".\subir-a-github.ps1"
# ============================================================

# Nota: NO se usa ErrorActionPreference='Stop' ni redirecciones tipo *> sobre
# comandos nativos. En Windows PowerShell 5.1 eso convierte la salida normal de
# 'gh' en un error terminante y aborta el script sin motivo real.
$ErrorActionPreference = 'Continue'
Set-Location $PSScriptRoot

$nombreRepo = 'academia-miriam-sandoval'
$rutaSesion = Join-Path $env:APPDATA 'GitHub CLI\hosts.yml'

function Salir-ConError {
    param([string]$Mensaje)
    Write-Host ""
    Write-Host "  X  $Mensaje" -ForegroundColor Red
    Write-Host ""
    Write-Host "Copia todo lo que aparece en esta ventana y enviaselo a Claude." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "=== Academia Miriam Sandoval - subida a GitHub ===" -ForegroundColor Cyan
Write-Host ""

# --- Paso 1: sesion de GitHub ---------------------------------
Write-Host "[1/3] Sesion de GitHub" -ForegroundColor Yellow

if (Test-Path $rutaSesion) {
    Write-Host "      Ya hay una sesion guardada." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "      No hay sesion. Vas a responder 4 preguntas." -ForegroundColor White
    Write-Host "      Muevete con las flechas y confirma con Enter:" -ForegroundColor White
    Write-Host ""
    Write-Host "        Where do you use GitHub?        -> GitHub.com"
    Write-Host "        Preferred protocol?             -> HTTPS"
    Write-Host "        Authenticate Git with...?       -> Yes"
    Write-Host "        How would you like to auth...?  -> Login with a web browser"
    Write-Host ""
    Write-Host "      Luego copia el codigo que salga, presiona Enter," -ForegroundColor White
    Write-Host "      pegalo en el navegador y autoriza." -ForegroundColor White
    Write-Host ""

    gh auth login

    if (-not (Test-Path $rutaSesion)) {
        Salir-ConError "El inicio de sesion no se completo. Vuelve a ejecutar el script."
    }
    Write-Host "      Sesion iniciada." -ForegroundColor Green
}

$usuario = (& gh api user --jq .login | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($usuario)) {
    Salir-ConError "No se pudo leer tu usuario de GitHub."
}
Write-Host "      Conectado como: $usuario" -ForegroundColor Green

# --- Paso 2: crear el repositorio -----------------------------
Write-Host "[2/3] Repositorio '$nombreRepo'" -ForegroundColor Yellow

# si quedo un remoto de un intento anterior, se descarta
$remotos = (& git remote | Out-String)
if ($remotos -match 'origin') { & git remote remove origin | Out-Null }

& gh repo create $nombreRepo --private --description "Landing page del curso de Alta Costura - Academia Miriam Sandoval"

if ($LASTEXITCODE -eq 0) {
    Write-Host "      Repositorio creado." -ForegroundColor Green
} else {
    Write-Host "      Ya existia uno con ese nombre. Se usara ese." -ForegroundColor Green
}

& git remote add origin "https://github.com/$usuario/$nombreRepo.git"

# --- Paso 3: subir los archivos -------------------------------
Write-Host "[3/3] Subiendo los archivos" -ForegroundColor Yellow

& git push -u origin main
if ($LASTEXITCODE -ne 0) {
    Salir-ConError "No se pudieron subir los archivos."
}

Write-Host ""
Write-Host "=== LISTO ===" -ForegroundColor Green
Write-Host ""
Write-Host "  Tu repositorio:" -ForegroundColor White
Write-Host "  https://github.com/$usuario/$nombreRepo" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Para subir cambios mas adelante, desde esta carpeta:" -ForegroundColor White
Write-Host '    git add -A ; git commit -m "que cambiaste" ; git push'
Write-Host ""
