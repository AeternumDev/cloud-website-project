#!/bin/bash
# ============================================
#  Azure Cloud Website - Deployment Script
#  Führe dieses Script nach "az login" aus
# ============================================

set -e

WEBAPP_NAME="azure-cloud-testwebsite"
RG_NAME="cloud-website-rg"
CDN_PROFILE="cloud-website-cdn"
CDN_ENDPOINT="CDN-azure-cloud"

echo ""
echo "=== Phase A: Azure Login prüfen ==="
az account show --query "{name:name, id:id, state:state}" -o table || {
    echo "FEHLER: Bitte erst 'az login' ausführen!"
    exit 1
}

echo ""
echo "=== Phase B1: Resource Group erstellen ==="
az group create \
  --name $RG_NAME \
  --location francecentral
echo "--- Screenshot 1: Resource Group erstellt ---"

echo ""
echo "=== Phase B2: ARM Template deployen ==="
echo "Dies kann 2-5 Minuten dauern..."
az deployment group create \
  --resource-group $RG_NAME \
  --template-file azuredeploy.json \
  --parameters @parameters.json
echo "--- Screenshot 2: Deployment Succeeded ---"

echo ""
echo "=== Phase B3: Website Content deployen ==="
echo "Versuche ZIP-Deploy..."
zip -j deploy.zip index.html
az webapp deployment source config-zip \
  --resource-group $RG_NAME \
  --name $WEBAPP_NAME \
  --src deploy.zip || {
    echo "ZIP-Deploy fehlgeschlagen. Versuche direkten Deploy..."
    az webapp deploy \
      --resource-group $RG_NAME \
      --name $WEBAPP_NAME \
      --src-path index.html \
      --type static
}

echo ""
echo "=== Phase B4: Website testen ==="
echo "Website URL: https://$WEBAPP_NAME.azurewebsites.net"
echo "--- Screenshot 3: Website im Browser öffnen ---"

echo ""
echo "=== Phase C: CDN prüfen ==="
az cdn endpoint show \
  --resource-group $RG_NAME \
  --profile-name $CDN_PROFILE \
  --name $CDN_ENDPOINT \
  --query "{hostname:hostName, resourceState:resourceState}" \
  -o table
echo "CDN URL: https://$CDN_ENDPOINT.azureedge.net"
echo "HINWEIS: CDN-Propagation kann 10-30 Minuten dauern!"
echo "--- Screenshot 4: CDN URL im Browser öffnen (später) ---"

echo ""
echo "=== Deployment abgeschlossen! ==="
echo ""
echo "Nächste Schritte:"
echo "  1. Öffne https://$WEBAPP_NAME.azurewebsites.net im Browser"
echo "  2. Warte 10-30 Min, dann öffne https://$CDN_ENDPOINT.azureedge.net"
echo "  3. Öffne Azure Portal für Application Insights Screenshots"
echo "  4. Mache alle 7 Screenshots (siehe README.md)"
echo ""
