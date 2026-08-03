# ============================================================
#  Sube la landing page de la Academia Miriam Sandoval a GitHub
#  Ejecutar con:  .\subir-a-github.ps1
# ============================================================

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$nombreRepo = 'academia-miriam-sandoval'

Write-Host ""
Write-Host "=== Academia Miriam Sandoval - subida a GitHub ===" -ForegroundColor Cyan
Write-Host ""

# --- Paso 1: sesion de GitHub ---------------------------------
Write-Host "[1/3] Revisando la sesion de GitHub..." -ForegroundColor Yellow
gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  No hay sesion iniciada. Se abrira el navegador." -ForegroundColor White
    Write-Host "  Responde asi a las preguntas:" -ForegroundColor White
    Write-Host "    - What account:        GitHub.com"
    Write-Host "    - Preferred protocol:  HTTPS"
    Write-Host "    - Authenticate Git:    Yes"
    Write-Host "    - How to authenticate: Login with a web browser"
    Write-Host ""
    gh auth login
    if ($LASTEXITCODE -ne 0) { throw "No se completo el inicio de sesion." }
}
$usuario = (gh api user --jq .login)
Write-Host "      Sesion activa como: $usuario" -ForegroundColor Green

# --- Paso 2: crear el repositorio -----------------------------
Write-Host "[2/3] Creando el repositorio privado '$nombreRepo'..." -ForegroundColor Yellow

$yaExiste = $false
gh repo view "$usuario/$nombreRepo" *> $null
if ($LASTEXITCODE -eq 0) { $yaExiste = $true }

if ($yaExiste) {
    Write-Host "      Ya existia. Se usara ese mismo." -ForegroundColor Green
    git remote remove origin *> $null
    git remote add origin "https://github.com/$usuario/$nombreRepo.git"
} else {
    gh repo create $nombreRepo --private --source=. --remote=origin `
        --description "Landing page del curso de Alta Costura - Academia Miriam Sandoval"
    if ($LASTEXITCODE -ne 0) { throw "No se pudo crear el repositorio." }
    Write-Host "      Repositorio creado." -ForegroundColor Green
}

# --- Paso 3: subir los archivos -------------------------------
Write-Host "[3/3] Subiendo los archivos..." -ForegroundColor Yellow
git push -u origin main
if ($LASTEXITCODE -ne 0) { throw "Fallo la subida." }

Write-Host ""
Write-Host "=== Listo ===" -ForegroundColor Green
Write-Host "Tu repositorio: https://github.com/$usuario/$nombreRepo" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para subir cambios mas adelante, desde esta carpeta:" -ForegroundColor White
Write-Host '  git add -A ; git commit -m "descripcion del cambio" ; git push'
Write-Host ""
