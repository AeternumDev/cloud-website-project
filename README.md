# Cloud-Architektur PoC — Hochverfügbare Unternehmenswebsite

Proof of Concept im Rahmen von **DLBSEPCP01_D** (Cloud Programming Portfolio), IU Internationale Hochschule. Die gesamte Infrastruktur wird über ein parametrisiertes ARM Template als Infrastructure as Code auf Microsoft Azure bereitgestellt.

---

## Architektur-Übersicht

Die Lösung integriert vier Azure-Dienste in einer mehrstufigen Architektur:

- **Azure App Service (F1 / S1):** Hosting der statischen Website. Free F1 dient als PoC-Umgebung; der Upgrade-Pfad auf Standard S1 ist über einen einzigen Parameter in `parameters.json` steuerbar.
- **Azure CDN:** Globale Inhaltsverteilung über Microsoft Edge-Knoten, HTTPS-Only.
- **Application Insights + Log Analytics Workspace:** Serverseitiges Request-Tracking und Telemetrie, konfiguriert über App Service App Settings. Diagnostische Logs (HTTP- und App-Logs) werden an den Log Analytics Workspace weitergeleitet.
- **Auto-Scale:** Bedingtes CPU-basiertes Horizontal-Scaling (1–3 Instanzen), aktiv nur beim S1 Tier.

## Projektstruktur

```
cloud-website-project/
├── index.html           # Website-Content
├── azuredeploy.json     # ARM Template (Infrastructure as Code)
├── parameters.json      # Deployment-Parameter (F1 Free Tier)
├── deploy.bat           # Deployment-Script (Windows)
├── deploy.sh            # Deployment-Script (Linux/Mac)
├── .gitignore
└── README.md
```

## Deployment

**Voraussetzungen:** Azure for Students Account, Azure CLI

```bash
az login
```

**Windows:**
```cmd
deploy.bat
```

**Linux/Mac:**
```bash
bash deploy.sh
```

## Sicherheitsmerkmale

- HTTPS-Only Enforcement für App Service und CDN
- TLS 1.2 Minimum
- FTPS deaktiviert
- CDN ausschließlich HTTPS-Zugriff (`isHttpAllowed: false`)

## Upgrade-Pfad F1 → S1

In `parameters.json` den Wert ändern:

```json
"appServicePlanSku": {
  "value": "S1"
}
```

Dann erneut deployen — Auto-Scale (CPU-Schwellwert 70 %, 1–3 Instanzen) wird automatisch aktiviert.
