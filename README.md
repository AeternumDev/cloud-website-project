# Cloud-Architektur für eine hochverfügbare Unternehmenswebsite

**Portfolioprojekt DLBSEPCP01_D** — Cloud Programming, IU Internationale Hochschule

🔗 [Live-Demo](https://azure-cloud-testwebsite.azurewebsites.net/)

---

## Projektübersicht

Infrastructure-as-Code-Implementierung einer hochverfügbaren Unternehmenswebsite auf Microsoft Azure. Die gesamte Cloud-Infrastruktur ist als parametrisiertes ARM Template definiert und über die Azure CLI reproduzierbar bereitstellbar.

---

## Architektur

| Komponente | Azure-Dienst | Funktion |
|---|---|---|
| Webhosting | App Service (F1/S1) | Hosting der statischen Website |
| CDN | Azure Front Door Standard *(bedingt)* | Globale Inhaltsverteilung über Edge-Knoten |
| Monitoring | Application Insights + Log Analytics | Request-Tracking und Telemetrie |
| Skalierung | Auto-Scale *(bedingt, S1 Tier)* | CPU-basiertes horizontales Scaling (1–3 Instanzen) |

### F1 Free → S1 Upgrade-Pfad

Aufgrund des begrenzten Azure-for-Students-Budgets (100 EUR) wurde eine zweistufige Strategie gewählt:

- **Aktuell (PoC):** Free F1 Tier — 0 EUR/Monat
- **Produktion:** Upgrade auf S1 via `appServicePlanSku`-Parameter — Auto-Scale und CDN werden automatisch aktiviert

> CDN (Azure Front Door) ist per `enableCdn: false` standardmäßig deaktiviert, da Azure for Students keine Front Door-Ressourcen unterstützt.

---

## Projektstruktur

```
cloud-website-project/
├── azuredeploy.json     # ARM Template — alle Ressourcen-Definitionen
├── parameters.json      # Deployment-Parameter (SKU, Region, App-Name)
├── index.html           # Statische Website
├── deploy.bat           # Deployment-Script (Windows)
├── deploy.sh            # Deployment-Script (Linux/Mac)
└── README.md
```

---

## Deployment

**Voraussetzungen:** Azure for Students Account, Azure CLI

```bash
az login
# Windows:
deploy.bat
# Linux/Mac:
bash deploy.sh
```

Das Script erstellt die Resource Group, deployt das ARM Template und die Website automatisch.

### Wichtige Parameter

| Parameter | Default | Beschreibung |
|---|---|---|
| `webAppName` | *(Pflicht)* | Eindeutiger Name der Web App |
| `appServicePlanSku` | `F1` | `F1` (Free) oder `S1` (Standard mit Auto-Scale) |
| `enableCdn` | `false` | CDN aktivieren (nur bei bezahltem Abo) |
| `logRetentionInDays` | `30` | Log-Aufbewahrung in Tagen (7–365) |

Alle Parameter haben sinnvolle Defaults und sind in `parameters.json` konfigurierbar.

---

## Sicherheitskonzept

- HTTPS-Only für App Service und CDN; TLS 1.2 Mindestversion
- FTPS deaktiviert
- Keine Credentials im Template (Azure Key Vault als Erweiterungsoption)

---

## Governance

Alle Ressourcen werden mit einheitlichen Tags versehen (Kostenkontrolle, Compliance, Ressourcen-Management):

```json
{
  "project": "cloud-website-portfolio",
  "environment": "proof-of-concept",
  "owner": "Antonio Prinz"
}
```

---

## Technologieentscheidungen

**ARM Templates** wurden gegenüber Terraform gewählt: native Azure-Integration, keine zusätzliche Tool-Installation, bedingte Ressourcen-Definitionen direkt unterstützt.

**Evaluierte Alternativen (nicht gewählt):**

| Alternative | Grund |
|---|---|
| Azure Static Web Apps | Kein App Service Plan → kein Auto-Scale demonstrierbar |
| Azure Traffic Manager | Nur bei Multi-Region relevant — übersteigt PoC-Scope |
| AWS CloudFront + EC2 | Kein vergleichbares kostenloses Studentenkonto |
