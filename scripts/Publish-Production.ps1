# Publikon PTE-ne ne BC Cloud Production permes Automation API.
# Rrit automatikisht versionin ne app.json, rikompilon dhe ngarkon paketen.
# Perdorim: .\Publish-Production.ps1 -ClientId "..." -ClientSecret "..."
# ose vendos me pare $env:BC_CLIENT_ID dhe $env:BC_CLIENT_SECRET.
param(
    [string]$ClientId = $env:BC_CLIENT_ID,
    [string]$ClientSecret = $env:BC_CLIENT_SECRET,
    [string]$TenantId = "55859367-4aad-4e73-8ba9-d1d0be00d1bb",
    [string]$Environment = "Production",
    [string]$CompanyName = "",   # bosh = kompania e pare
    [int]$BuildNumber = 0,       # nese > 0, segmenti i 4-t i versionit behet ky numer (per CI)
    [switch]$NoVersionBump,      # kalo kete nese s'do rritje versioni
    [switch]$NoCompile           # kalo kete per te ngarkuar .app ekzistues pa rikompilim
)

$ErrorActionPreference = "Stop"
$projectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if (-not $ClientId -or -not $ClientSecret) {
    throw "Mungon ClientId/ClientSecret. Jepi si parametra ose vendos BC_CLIENT_ID / BC_CLIENT_SECRET."
}

# 0a. Rrit versionin ne app.json (segmenti i fundit +1)
$appJsonPath = Join-Path $projectDir "app.json"
$appJsonRaw = Get-Content $appJsonPath -Raw
$appJson = $appJsonRaw | ConvertFrom-Json
if (-not $NoVersionBump) {
    $parts = $appJson.version.Split(".")
    if ($BuildNumber -gt 0) { $parts[3] = [string]$BuildNumber }
    else { $parts[3] = [string]([int]$parts[3] + 1) }
    $newVersion = $parts -join "."
    $appJsonRaw = $appJsonRaw -replace ('"version":\s*"' + [regex]::Escape($appJson.version) + '"'), ('"version": "' + $newVersion + '"')
    Set-Content -Path $appJsonPath -Value $appJsonRaw -Encoding utf8 -NoNewline
    Write-Host "Versioni u rrit: $($appJson.version) -> $newVersion"
    $appJson.version = $newVersion
}

$AppFile = Join-Path $projectDir "$($appJson.publisher)_$($appJson.name)_$($appJson.version).app"

# 0b. Kompilo
if (-not $NoCompile) {
    $alc = $env:ALC_PATH
    if (-not $alc) {
        $alc = Get-ChildItem "$env:USERPROFILE\.vscode\extensions\ms-dynamics-smb.al-*\bin\win32\alc.exe" -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
    }
    if (-not $alc) { throw "Nuk u gjet alc.exe - instalo ekstensionin AL ne VS Code ose vendos ALC_PATH." }
    Write-Host "Duke kompiluar me $alc ..."
    & $alc /project:"$projectDir" /packagecachepath:"$projectDir\.alpackages" /out:"$AppFile"
    if ($LASTEXITCODE -ne 0) { throw "Kompilimi deshtoi (exit $LASTEXITCODE). Publikimi u ndalua." }
}
if (-not (Test-Path $AppFile)) { throw "Nuk u gjet file .app: $AppFile" }
Write-Host "Paketa: $AppFile"

# 1. Token
$tokenResp = Invoke-RestMethod -Method Post `
    -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
    -Body @{
        grant_type    = "client_credentials"
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = "https://api.businesscentral.dynamics.com/.default"
    }
$headers = @{ Authorization = "Bearer $($tokenResp.access_token)" }
Write-Host "Token OK."

$autoApi = "https://api.businesscentral.dynamics.com/v2.0/$TenantId/$Environment/api/microsoft/automation/v2.0"

# 2. Kompania
$companies = (Invoke-RestMethod -Uri "$autoApi/companies" -Headers $headers).value
if ($CompanyName) { $company = $companies | Where-Object { $_.name -eq $CompanyName } }
else { $company = $companies | Select-Object -First 1 }
if (-not $company) { throw "Kompania nuk u gjet. Te disponueshme: $($companies.name -join ', ')" }
Write-Host "Kompania: $($company.name)"

# 3. Merr (ose krijo) regjistrin extension upload dhe ngarko permbajtjen (kjo starton deployment-in)
$existing = (Invoke-RestMethod -Uri "$autoApi/companies($($company.id))/extensionUpload" -Headers $headers).value
if ($existing) {
    $upload = $existing[0]
} else {
    $upload = Invoke-RestMethod -Method Post -Uri "$autoApi/companies($($company.id))/extensionUpload" `
        -Headers $headers -ContentType "application/json" -Body '{"schedule": "Current Version"}'
}

$contentHeaders = $headers.Clone()
$contentHeaders["If-Match"] = "*"
# Perdoret media-link-u qe kthen vete API-ja; prona quhet extensionContent
$contentUrl = $upload.'extensionContent@odata.mediaEditLink'
if (-not $contentUrl) { $contentUrl = "$autoApi/companies($($company.id))/extensionUpload($($upload.systemId))/extensionContent" }
Invoke-RestMethod -Method Patch -Uri $contentUrl `
    -Headers $contentHeaders -ContentType "application/octet-stream" -InFile $AppFile | Out-Null
Write-Host "Paketa u ngarkua."

# Aksioni qe NIS deployment-in - pa kete ngarkimi mbetet i papunuar
Invoke-RestMethod -Method Post -Uri "$autoApi/companies($($company.id))/extensionUpload($($upload.systemId))/Microsoft.NAV.upload" `
    -Headers $headers -ContentType "application/json" -Body '{}' | Out-Null
Write-Host "Deployment-i nisi..."

# 4. Prit statusin - vetem regjistrin e versionit qe sapo ngarkuam (jo statuse te vjetra)
for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep -Seconds 10
    $statusList = (Invoke-RestMethod -Uri "$autoApi/companies($($company.id))/extensionDeploymentStatus" -Headers $headers).value
    $status = $statusList | Where-Object { $_.appVersion -eq $appJson.version } |
        Sort-Object startedOn -Descending | Select-Object -First 1
    if (-not $status) { Write-Host "Duke pritur regjistrin e deployment per v$($appJson.version)..."; continue }
    Write-Host ("[{0:HH:mm:ss}] {1} v{2} -> {3}" -f (Get-Date), $status.name, $status.appVersion, $status.status)
    if ($status.status -eq "Completed") { Write-Host "PUBLIKIMI PERFUNDOI ME SUKSES." -ForegroundColor Green; exit 0 }
    if ($status.status -eq "Failed") {
        Write-Host "PUBLIKIMI DESHTOI. Kontrollo detajet ne Admin Center > Environments > $Environment > Extensions > Deployment Status." -ForegroundColor Red
        exit 1
    }
}
Write-Host "Timeout duke pritur statusin - kontrollo Admin Center."
exit 1
