# Cloud-Architektur für eine hochverfügbare Unternehmenswebsite

**Portfolioprojekt DLBSEPCP01_D** — Cloud Programming, IU Internationale Hochschule

## Projektübersicht

Dieses Repository enthält die Infrastructure-as-Code-Implementierung einer hochverfügbaren Unternehmenswebsite auf Microsoft Azure. Die gesamte Cloud-Infrastruktur ist als parametrisiertes ARM Template definiert und über die Azure CLI reproduzierbar bereitstellbar.

## Architektur

Die Lösung integriert vier Azure-Dienste in einer mehrstufigen Architektur:

| Komponente | Azure-Dienst | Funktion |
|---|---|---|
| Webhosting | App Service (F1/S1) | Hosting der statischen Website |
| CDN | Azure CDN (Standard_Microsoft) | Globale Inhaltsverteilung über Edge-Knoten |
| Monitoring | Application Insights + Log Analytics | Serverseitiges Request-Tracking und Telemetrie |
| Skalierung | Auto-Scale (bedingt, S1 Tier) | CPU-basiertes horizontales Scaling (1–3 Instanzen) |

### Strategischer Ansatz: F1 Free → S1 Upgrade-Pfad

Aufgrund des begrenzten Azure-for-Students-Budgets (100 EUR) wurde eine zweistufige Strategie gewählt:
- **Proof of Concept (aktuell):** Free F1 Tier — 0 EUR/Monat
- **Produktionspfad:** Upgrade auf Standard S1 durch Änderung eines einzigen Parameters (`appServicePlanSku` in `parameters.json`)

Alle Auto-Scale-Konfigurationen sind im ARM Template enthalten und werden bei S1 automatisch aktiviert.

## Projektstruktur

```
cloud-website-project/
├── azuredeploy.json     # ARM Template — alle Ressourcen-Definitionen
├── parameters.json      # Deployment-Parameter (SKU, Region, App-Name)
├── index.html           # Test-Website (statisches HTML)
├── deploy.bat           # Deployment-Script (Windows)
├── deploy.sh            # Deployment-Script (Linux/Mac)
├── .gitignore
└── README.md
```

## Deployment-Anleitung

**Voraussetzungen:** Azure for Students Account, Azure CLI installiert

1. Azure CLI Login: `az login`
2. Script ausführen: `deploy.bat` (Windows) oder `bash deploy.sh` (Linux/Mac)
3. Das Script erstellt automatisch die Resource Group, deployt das ARM Template und die Website

## Sicherheitskonzept

- HTTPS-Only Enforcement für App Service und CDN
- TLS 1.2 als Mindestversion
- FTPS deaktiviert (Disabled)
- CDN: ausschließlich HTTPS-Zugriff (`isHttpAllowed: false`)
- Keine sensitiven Credentials im Template — bei Bedarf wäre Azure Key Vault als Referenz in `parameters.json` einsetzbar

## Toolwahl: ARM Templates vs. Alternativen

ARM Templates wurden als IaC-Framework gewählt, da sie nativ in Azure integriert sind und keine zusätzliche Tool-Installation erfordern (im Gegensatz zu Terraform). Die JSON-basierte Struktur ist direkt versionierbar und ermöglicht bedingte Ressourcen-Definitionen (z.B. Auto-Scale nur bei S1). Terraform wäre als cloud-agnostische Alternative portabler, aber für ein reines Azure-Projekt bieten ARM Templates tiefere Integration.

## Alternative Architektur-Ansätze (nicht gewählt)

Folgende Alternativen wurden evaluiert:

| Alternative | Grund für Nicht-Wahl |
|---|---|
| Azure Static Web Apps | Kein App Service Plan, dadurch kein Auto-Scale demonstrierbar |
| Azure Front Door | Ersetzt CDN mit erweiterten Features, aber höhere Kosten und Komplexität für PoC |
| Azure Traffic Manager | DNS-basiertes Routing, relevant bei Multi-Region-Setups — übersteigt PoC-Scope |
| AWS CloudFront + EC2 | Kreditkartenpflicht, kein kostenloses Studentenkonto vergleichbar mit Azure |
