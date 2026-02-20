# Cloud Website Project — Azure Cloud-Architektur PoC

> **DLBSEPCP01_D** — Cloud Programming Portfolio  
> Azure App Service + CDN + Application Insights + Azure Monitor

---

## Projektstruktur

```
cloud-website-project/
├── index.html           # Website-Content (Unternehmenswebsite)
├── azuredeploy.json     # ARM Template (Infrastructure as Code)
├── parameters.json      # Deployment-Parameter (F1 Free Tier)
├── deploy.bat           # Windows Deployment-Script
├── deploy.sh            # Linux/Mac Deployment-Script
├── cleanup.bat          # Aufräum-Script (nach Bewertung)
├── .gitignore           # Git Ignore-Datei
└── README.md            # Diese Datei
```

## Voraussetzungen

1. **Azure for Students Account** aktiv: https://azure.microsoft.com/en-us/free/students
2. **Azure CLI** installiert: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows
3. **Git** installiert

## Schnellstart

### 1. Azure CLI installieren (falls noch nicht geschehen)

```powershell
# Option A: Via winget (empfohlen)
winget install Microsoft.AzureCLI

# Option B: MSI-Installer herunterladen
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows
```

Nach der Installation **Terminal neu starten** und prüfen:
```bash
az --version
```

### 2. Anmelden

```bash
az login
az account show --query "{name:name, id:id, state:state}" -o table
```

### 3. Provider registrieren (einmalig)

```bash
az provider register --namespace Microsoft.Cdn
az provider register --namespace Microsoft.Insights
```

### 4. Deployen

**Windows:**
```cmd
deploy.bat
```

**Oder manuell Schritt für Schritt:**

```bash
# Resource Group erstellen
az group create --name cloud-website-rg --location francecentral

# ARM Template deployen (2-5 Minuten)
az deployment group create --resource-group cloud-website-rg --template-file azuredeploy.json --parameters @parameters.json

# Website deployen
powershell -Command "Compress-Archive -Path index.html -DestinationPath deploy.zip -Force"
az webapp deployment source config-zip --resource-group cloud-website-rg --name azure-cloud-testwebsite --src deploy.zip
```

### 5. Testen

- **Website:** https://azure-cloud-testwebsite.azurewebsites.net
- **CDN:** https://CDN-azure-cloud.azureedge.net (10-30 Min Propagation)

## Screenshots-Checkliste für Deployment-Nachweis

| Nr. | Was | Wo |
|-----|-----|----|
| 1 | Resource Group im Portal | Portal → Resource Groups |
| 2 | ARM Deployment Succeeded | Terminal oder Portal → Deployments |
| 3 | Laufende Website (*.azurewebsites.net) | Browser |
| 4 | Website über CDN (*.azureedge.net) | Browser |
| 5 | Application Insights Metriken | Portal → App Insights |
| 6 | Azure Monitor Dashboard | Portal → Monitor |
| 7 | Resource Group Übersicht alle Ressourcen | Portal → Resource Group |

## Architektur

```
                    ┌─────────────────┐
                    │   Azure CDN     │
                    │ (Global Edge)   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  App Service    │
                    │  (Free F1)     │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼───┐  ┌──────▼──────┐  ┌───▼──────────┐
     │ App Insights│  │Azure Monitor│  │  AutoScale   │
     │ (Telemetrie)│  │ (Metriken) │  │ (nur bei S1) │
     └─────────────┘  └────────────┘  └──────────────┘
```

## Upgrade-Pfad (F1 → S1)

Um von Free auf Standard umzustellen, ändere in `parameters.json`:
```json
"appServicePlanSku": {
  "value": "S1"
}
```
Dann erneut deployen — AutoScaling wird automatisch aktiviert.

## Troubleshooting

| Problem | Lösung |
|---------|--------|
| `Microsoft.Cdn` nicht registriert | `az provider register --namespace Microsoft.Cdn` |
| Website-Name existiert bereits | Anderen `webAppName` in parameters.json wählen |
| CDN zeigt 404 | 15-30 Min warten, dann Cache purgen |
| `az webapp deploy` fehlschlägt | ZIP-Deploy oder Kudu-Portal nutzen |
| Application Insights leer | Website 5-10x aufrufen, 2-3 Min warten |

### CDN Cache purgen
```bash
az cdn endpoint purge --resource-group cloud-website-rg --profile-name cloud-website-cdn --name CDN-azure-cloud --content-paths "/*"
```

## Aufräumen (nach Bewertung)

```bash
az group delete --name cloud-website-rg --yes --no-wait
```
