@echo off
REM ============================================
REM  Azure Cloud Website - Deployment Script
REM  Führe dieses Script nach "az login" aus
REM ============================================
REM Prüfe ob Azure CLI im PATH ist
where az >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo FEHLER: Azure CLI nicht im PATH gefunden!
    echo Installiere Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
    exit /b 1
)

set WEBAPP_NAME=azure-cloud-testwebsite
set RG_NAME=cloud-website-rg
set CDN_PROFILE=cloud-website-cdn
set CDN_ENDPOINT=cdn-azure-cloud

echo.
echo === Phase A: Azure Login pruefen ===
az account show --query "{name:name, id:id, state:state}" -o table
if %ERRORLEVEL% neq 0 (
    echo FEHLER: Bitte erst "az login" ausfuehren!
    exit /b 1
)

echo.
echo === Phase B1: Resource Group erstellen ===
az group create --name %RG_NAME% --location westeurope
if %ERRORLEVEL% neq 0 (
    echo FEHLER beim Erstellen der Resource Group!
    exit /b 1
)
REM Deployment-Schritt: Resource Group erstellt

echo.
echo === Phase B2: ARM Template deployen ===
echo Dies kann 2-5 Minuten dauern...
az deployment group create --resource-group %RG_NAME% --template-file azuredeploy.json --parameters @parameters.json
if %ERRORLEVEL% neq 0 (
    echo FEHLER beim Deployment! Siehe Troubleshooting in README.md
    exit /b 1
)
REM Deployment-Schritt: ARM Template erfolgreich deployed

echo.
echo === Phase B3: Website Content deployen ===
echo Versuche ZIP-Deploy...
powershell -Command "Compress-Archive -Path index.html -DestinationPath deploy.zip -Force"
az webapp deployment source config-zip --resource-group %RG_NAME% --name %WEBAPP_NAME% --src deploy.zip
if %ERRORLEVEL% neq 0 (
    echo ZIP-Deploy fehlgeschlagen. Versuche direkten Deploy...
    az webapp deploy --resource-group %RG_NAME% --name %WEBAPP_NAME% --src-path index.html --type static
)

echo.
echo === Phase B4: Website testen ===
echo Website URL: https://%WEBAPP_NAME%.azurewebsites.net

echo.
echo === Phase C: CDN pruefen ===
az cdn endpoint show --resource-group %RG_NAME% --profile-name %CDN_PROFILE% --name %CDN_ENDPOINT% --query "{hostname:hostName, resourceState:resourceState}" -o table
echo CDN URL: https://%CDN_ENDPOINT%.azureedge.net
echo HINWEIS: CDN-Propagation kann 10-30 Minuten dauern!

echo.
echo === Deployment abgeschlossen! ===
echo.
echo Naechste Schritte:
echo  1. Oeffne https://%WEBAPP_NAME%.azurewebsites.net im Browser
echo  2. Warte 10-30 Min, dann oeffne https://%CDN_ENDPOINT%.azureedge.net
echo  3. Oeffne Azure Portal fuer Application Insights und Monitor
echo.
