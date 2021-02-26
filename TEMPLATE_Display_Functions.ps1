####################################### Display Functions

function ClearAffichage {
    Clear-Host
}

function AfficherOK ($texte) {
    Write-host -NoNewLine "	["; Write-host -NoNewLine "OK" -ForegroundColor Green; Write-host -NoNewLine "] - "; Write-host "$texte"
}

function AfficherOKResultat ($texte) {
    Write-host -NoNewLine "	["; Write-host -NoNewLine "OK" -ForegroundColor Green; Write-host -NoNewLine "] - "; Write-host -NoNewLine "$texte"
}

function AfficherWarn ($texte) {
    Write-host -NoNewLine "	["; Write-host -NoNewLine "WARN" -ForegroundColor Yellow; Write-host -NoNewLine "] - "; Write-host "$texte"
}

function AfficherCrit ($texte) {
    Write-host -NoNewLine "	["; Write-host -NoNewLine "CRIT" -ForegroundColor Red; Write-host -NoNewLine "] - "; Write-host "$texte"
}

function AfficherCritResultat ($texte) {
    Write-host -NoNewLine "	["; Write-host -NoNewLine "CRIT" -ForegroundColor Red; Write-host -NoNewLine "] - "; Write-host -NoNewLine "$texte"
}

function AfficherTitreGras ($texte) {
    Write-host ""
    Write-host "$texte" -ForegroundColor Black -BackgroundColor White
}

function AfficherTitre ($texte) {
    Write-host ""
    Write-host "[+] - $texte"
}
function AfficherTitreResultat ($texte) {
    Write-host ""
    Write-host -NoNewline "[+] - $texte"
}

function AfficherListe ($texte) {
    Write-host "     - $texte" -ForegroundColor Gray
}

function AfficherRose ($texte) {
    Write-host "$texte" -ForegroundColor Magenta
}

function AfficherJaune ($texte) {
    Write-host "$texte" -ForegroundColor Yellow
}

function AfficherJauneListe ($texte) {
    Write-host -NoNewLine "$texte" -ForegroundColor Yellow
}

function AfficherVert ($texte) {
    Write-host "$texte" -ForegroundColor Green
}

function AfficherVertListe ($texte) {
    Write-host -NoNewLine "$texte" -ForegroundColor Green
}

function AfficherRouge ($texte) {
    Write-host "$texte" -ForegroundColor Red
}

function AfficherRougeListe ($texte) {
    Write-host -NoNewLine "$texte" -ForegroundColor Red
}

function Debug ($texte) {
    Write-host "----------- $texte --------------" -ForegroundColor Cyan
}

function SautLigne ($texte) {
    Write-Host "$texte"
}

function AfficherLigne ($texte) {
    Write-Host  -NoNewLine "$texte "
}

function AfficherResultat ($texte) {
    Write-host -NoNewLine "	$texte"
}

function AfficherTabListe ($texte) {
    Write-host -NoNewLine "	"
}

function Separator {
    Write-host ""
    Write-host "..."
    Write-host ""
}