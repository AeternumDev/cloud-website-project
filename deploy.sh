#!/bin/bash
# ============================================
#  Azure Cloud Website - Deployment Script
#  Führe dieses Script nach "az login" aus
# ============================================

set -e

echo ""
echo "=== Phase A: Azure Login prüfen ==="
az account show --query "{name:name, id:id, state:state}" -o table || {
    echo "FEHLER: Bitte erst 'az login' ausführen!"
    exit 1
}

echo ""
echo "=== Phase B1: Resource Group erstellen ==="
az group create \
  --name cloud-website-rg \
  --location westeurope
echo "--- Screenshot 1: Resource Group erstellt ---"

echo ""
echo "=== Phase B2: ARM Template deployen ==="
echo "Dies kann 2-5 Minuten dauern..."
az deployment group create \
  --resource-group cloud-website-rg \
  --template-file azuredeploy.json \
  --parameters @parameters.json
echo "--- Screenshot 2: Deployment Succeeded ---"

echo ""
echo "=== Phase B3: Website Content deployen ==="
echo "Versuche ZIP-Deploy..."
zip -j deploy.zip index.html
az webapp deployment source config-zip \
  --resource-group cloud-website-rg \
  --name azure-cloud-testwebsite \
  --src deploy.zip || {
    echo "ZIP-Deploy fehlgeschlagen. Versuche direkten Deploy..."
    az webapp deploy \
      --resource-group cloud-website-rg \
      --name azure-cloud-testwebsite \
      --src-path index.html \
      --type static
}

echo ""
echo "=== Phase B4: Website testen ==="
echo "Website URL: https://azure-cloud-testwebsite.azurewebsites.net"
echo "--- Screenshot 3: Website im Browser öffnen ---"

echo ""
echo "=== Phase C: CDN prüfen ==="
az cdn endpoint show \
  --resource-group cloud-website-rg \
  --profile-name cloud-website-cdn \
  --name CDN-azure-cloud \
  --query "{hostname:hostName, resourceState:resourceState}" \
  -o table
echo "CDN URL: https://CDN-azure-cloud.azureedge.net"
echo "HINWEIS: CDN-Propagation kann 10-30 Minuten dauern!"
echo "--- Screenshot 4: CDN URL im Browser öffnen (später) ---"

echo ""
echo "=== Deployment abgeschlossen! ==="
echo ""
echo "Nächste Schritte:"
echo "  1. Öffne https://azure-cloud-testwebsite.azurewebsites.net im Browser"
echo "  2. Warte 10-30 Min, dann öffne https://CDN-azure-cloud.azureedge.net"
echo "  3. Öffne Azure Portal für Application Insights Screenshots"
echo "  4. Mache alle 7 Screenshots (siehe README.md)"
echo ""
