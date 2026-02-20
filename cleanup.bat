@echo off
REM ============================================
REM  Aufräumen - ALLE Ressourcen löschen
REM  Erst nach Abgabe/Bewertung ausführen!
REM ============================================

echo.
echo WARNUNG: Dies loescht ALLE Ressourcen in cloud-website-rg!
echo.
set /p confirm="Bist du sicher? (ja/nein): "
if /i not "%confirm%"=="ja" (
    echo Abgebrochen.
    exit /b 0
)

echo Loesche Resource Group...
az group delete --name cloud-website-rg --yes --no-wait
echo Resource Group wird geloescht (kann einige Minuten dauern).
