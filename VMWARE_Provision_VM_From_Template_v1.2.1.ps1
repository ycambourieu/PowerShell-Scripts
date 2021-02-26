<#
#######################################################
	Script de création de VM VMware Workstation Player
    Yohan CAMBOURIEU - Créé le 28/02/2020
    VERSION : 1.2.1
	-------------------------
    CHANGELOG :
    06/03/2020 : 1.2.1 :
        - Ajout d'une fonction pour fiabiliser la récupération de l'IP DHCP de la VM
    04/03/2020 : 1.2 :
        - Ajout du choix de sizing de la VM
    04/03/2020 : 1.1 :
        - Ajout de la configuraiton IP statique de la VM
    28/02/2020 : 1.0 :
        - Création du script et de toutes les fonctions de base
#######################################################
#> 

####################################### Variables

# Configuration du chemin des rapport en JSON 
$VMTEMPLATE = "C:\Users\Username\Documents\Virtual Machines\#AUTOTEMPLATE-CENTOS 7"
$VMFOLDER = "C:\Users\Username\Documents\Virtual Machines"
$script:VMNAME = "CARCENTOSDC"
$script:TEMPLATEPASSWORD = "MySecret"
$script:VMPASSWORD = "MyNewSecret"
$script:VMSTATICIP = "192.168.136.16"
$script:VMMASK = "24"
$script:VMGATEWAY = "192.168.136.2"
$script:VMDNS1 = "192.168.136.2"
$script:VMDNS2 = "8.8.8.8"
$script:VMSIZING = "XS"
# Options de sizing - XS par défaut : 
# XS = 1 vCPU / 384 Mo de RAM / 50Go HDD
# S = 1 vCPU / 512 Mo de RAM / 50Go HDD
# M = 2 vCPU / 1024 Mo de RAM / 50Go HDD
# L = 2 vCPU / 2048 Mo de RAM / 50Go HDD
# XL = 4 vCPU / 4096 Mo de RAM / 50Go HDD

####################################### Fonctions d'affichage

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

####################################### Fonctions d'actions

function CheckVMwareInstall {
    AfficherTitre ("Vérificaiton de l'installation de VMware Workstataion Player")
    if ( (Test-Path -Path "C:\Program Files (x86)\VMware\VMware Player") -eq $false){
        AfficherCrit ("VMware Workstation Player n'est pas présent sur la machine")
        exit
    }
    else {
        AfficherOK ("VMware Workstation Player présent sur la machine")
    }
}

function CheckPuttyInstall {
    AfficherTitre ("Vérificaiton de l'installation de Putty")
    if ( (Test-Path -Path "C:\Program Files (x86)\PuTTY\") -eq $false){
        AfficherCrit ("Putty n'est pas présent sur la machine")
        exit
    }
    else {
        AfficherOK ("Putty présent sur la machine")
    }
}

function CheckFolders {
    AfficherTitre ("Vérification des répertoires")
    if ( (Test-Path -Path "$VMTEMPLATE") -eq $false){
        AfficherCrit ("Le répertoire du template $VMTEMPLATE n'existe pas.")
        exit
    }
    elseif ( (Test-Path -Path "$VMFOLDER") -eq $false){
        AfficherCrit ("Le répertoire de destination $VMFOLDER n'existe pas.")
        exit
    }
    else {
        AfficherOK ("Vérification des chemins de template et de stockage de la VM")
    }
}

function CheckVMName {
    AfficherTitre ("Vérification de la disponiblité du nom de VM")
    while( (Test-Path -Path "${VMFOLDER}\${script:VMNAME}") -eq $true){
        $script:VMNAME = "${script:VMNAME}_Copy"
    }
    AfficherOKResultat ("Nom de VM utilisté : "); AfficherRose ("$script:VMNAME")
    AfficherOKResultat ("Chemin de la VM : "); AfficherRose ("${VMFOLDER}\${script:VMNAME}")
}

function CopyVMFolder {
    AfficherTitre ("Lancement de la création de la VM")
    New-Item -Path "${VMFOLDER}\" -Name "${script:VMNAME}" -ItemType "directory" | Out-Null
    Copy-Item -Path "${VMTEMPLATE}\*" -Destination "${VMFOLDER}\${script:VMNAME}\" -Recurse | Out-Null
    AfficherOKResultat ("Machine virtuelle créée dans : "); AfficherRose ("${VMFOLDER}\${script:VMNAME}")
}

function CustomizeVM {
    AfficherTitre ("Configuration de la VM")
    AfficherOK ("Configuration du nom de machine")
    ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "displayName = `"TEMPLATE_CENTOS7`"","displayName = `"$script:VMNAME`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
    AfficherOK ("Création d'un nouvel UUID")
    AfficherOK ("Configuration du réseau en mode NAT")
    AfficherOKResultat ("Configuration du sizing de la VM : "); AfficherRose ("$script:VMSIZING")

    switch($script:VMSIZING){
        "XS" {
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "memsize = .*","memsize = `"384`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "numvcpus = .*","numvcpus = `"1`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            AfficherOKResultat ("Configuration matérielle appliquée : "); AfficherRose ("1 vCPU / 384 Mo de RAM / 50Go HDD")
            break
        }
        "S" {
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "memsize = .*","memsize = `"512`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "numvcpus = .*","numvcpus = `"1`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            AfficherOKResultat ("Configuration matérielle appliquée : "); AfficherRose ("1 vCPU / 512 Mo de RAM / 50Go HDD")
            break
        }
        "M" {
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "memsize = .*","memsize = `"1024`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "numvcpus = .*","numvcpus = `"2`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            AfficherOKResultat ("Configuration matérielle appliquée : "); AfficherRose ("2 vCPU / 1024 Mo de RAM / 50Go HDD")
            break
        }
        "L" {
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "memsize = .*","memsize = `"2048`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "numvcpus = .*","numvcpus = `"2`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            AfficherOKResultat ("Configuration matérielle appliquée : "); AfficherRose ("2 vCPU / 2048 Mo de RAM / 50Go HDD")
            break 
        }
        "XL" {
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "memsize = .*","memsize = `"4096`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "numvcpus = .*","numvcpus = `"4`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            AfficherOKResultat ("Configuration matérielle appliquée : "); AfficherRose ("4 vCPU / 4096 Mo de RAM / 50Go HDD")
            break
        }
        default {
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "memsize = .*","memsize = `"384`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            ((Get-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx" -Raw) -Replace "numvcpus = .*","numvcpus = `"1`"") | Set-Content -Path "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
            AfficherOKResultat ("Configuration matérielle appliquée : "); AfficherRose ("1 vCPU / 384 Mo de RAM / 50Go HDD")
            break
        }
    }
}

function PrepareGetVMIP {
    AfficherTitre ("Mise en surveillance du fichier de baux DHCP VMware")
    $script:DHCPLEASEFILE = "C:\ProgramData\VMware\vmnetdhcp.leases"
    $script:DHCPLEASEFILETMP = "C:\ProgramData\VMware\vmnetdhcp.leases.ori"
    Copy-Item -Path $script:DHCPLEASEFILE -Destination $script:DHCPLEASEFILETMP
    AfficherOK ("Fichier mis en surveillance")
}

function StartVM {
    AfficherTitre ("Démarrage de la VM")
    Invoke-Item "${VMFOLDER}\${script:VMNAME}\TEMPLATE_CENTOS7.vmx"
}

function Waiting {
    AfficherTitre ("Attente du démarrage de la VM (40 sec)")
    Start-Sleep 40 | Out-Null
    AfficherOK ("VM ${script:VMNAME} démarrée")
}

function GetVMIP {
    AfficherTitre ("Récupération de l'adresse IP de la VM")
    $script:IPVM = Compare-Object (Get-Content $script:DHCPLEASEFILETMP) (Get-Content $script:DHCPLEASEFILE) |  Select-String -Pattern "lease" | Out-String  | ForEach-Object{$_.split(' ')[1]}
    Remove-Item -Confirm:$false $script:DHCPLEASEFILETMP
    AfficherOKResultat ("L'adresse IP temporaire de la VM est : "); AfficherRose ("$script:IPVM")
    }

function ConfigureVM {
    AfficherTitre ("Configuration du système d'exploitation")

    $COMMANDFILE = "C:\Users\FX30639\Desktop\Commands_to_VM.txt"
    if ( (Test-Path -Path "$COMMANDFILE") -eq $true){
            Remove-Item -Confirm:$false $COMMANDFILE
    } 
    New-Item -ItemType file $COMMANDFILE | Out-Null
    Clear-Content -Path $COMMANDFILE | Out-Null
    Add-Content -Path $COMMANDFILE -Value "hostnamectl set-hostname $script:VMNAME"
    Add-Content -Path $COMMANDFILE -Value "echo `"$script:VMPASSWORD`" | passwd root --stdin"
    Add-Content -Path $COMMANDFILE -Value "echo `"TYPE=Ethernet`" >> /etc/sysconfig/network-scripts/ifcfg-ens3"
    Add-Content -Path $COMMANDFILE -Value "echo `"PROXY_METHOD=none`" >> /etc/sysconfig/network-scripts/ifcfg-ens3"
    Add-Content -Path $COMMANDFILE -Value "echo `"BROWSER_ONLY=no`" >> /etc/sysconfig/network-scripts/ifcfg-ens3" 
    Add-Content -Path $COMMANDFILE -Value "echo `"BOOTPROTO=none`" >> /etc/sysconfig/network-scripts/ifcfg-ens3" 
    Add-Content -Path $COMMANDFILE -Value "echo `"IPADDR=${script:VMSTATICIP}`" >> /etc/sysconfig/network-scripts/ifcfg-ens3"
    Add-Content -Path $COMMANDFILE -Value "echo `"PREFIX=${script:VMMASK}`" >> /etc/sysconfig/network-scripts/ifcfg-ens3"
    Add-Content -Path $COMMANDFILE -Value "echo `"GATEWAY=${script:VMGATEWAY}`" >> /etc/sysconfig/network-scripts/ifcfg-ens3"
    Add-Content -Path $COMMANDFILE -Value "echo `"DNS1=${script:VMDNS1}`" >> /etc/sysconfig/network-scripts/ifcfg-ens3"
    Add-Content -Path $COMMANDFILE -Value "echo `"DNS2=${script:VMDNS2}`" >> /etc/sysconfig/network-scripts/ifcfg-ens3"
    Add-Content -Path $COMMANDFILE -Value "echo `"DEFROUTE=yes`" >> /etc/sysconfig/network-scripts/ifcfg-ens3" 
    Add-Content -Path $COMMANDFILE -Value "echo `"IPV4_FAILURE_FATAL=no`" >> /etc/sysconfig/network-scripts/ifcfg-ens3" 
    Add-Content -Path $COMMANDFILE -Value "echo `"NAME=ens33`" >> /etc/sysconfig/network-scripts/ifcfg-ens3" 
    Add-Content -Path $COMMANDFILE -Value "echo `"ONBOOT=yes`" >> /etc/sysconfig/network-scripts/ifcfg-ens3" 
    Add-Content -Path $COMMANDFILE -Value "echo `"AUTOCONNECT_PRIORITY=-999`" >> /etc/sysconfig/network-scripts/ifcfg-ens3" 
    Add-Content -Path $COMMANDFILE -Value "reboot"
    AfficherOK ("Connexion SSH")
    if ( (Test-Path -Path "HKCU:\Software\SimonTatham\PuTTY\SshHostKeys\ssh-ed25519@22:${script:IPVM}" ) -eq $true){
        Get-Item -Path HKCU:\Software\SimonTatham\PuTTY\SshHostKeys\ | Remove-ItemProperty -Name ssh-ed25519@22:${script:IPVM} | Out-Null
    }
    $CURRENTPATH = Get-Location
    Set-Location "C:\Program Files (x86)\PuTTY\"
    .\putty.exe -ssh root@${script:IPVM} 22 -pw $script:TEMPLATEPASSWORD -m $COMMANDFILE
    AfficherOK ("Changement du nom d'hôte")
    AfficherOK ("Changement du mdp root")
    AfficherOK ("Application de la configuration réseau")
    AfficherOK ("Redémarrage de la VM")
    AfficherOKResultat ("Après le redémarrage, ${script:VMNAME} sera disponible avec l'IP : "); AfficherRose("$script:VMSTATICIP")
    Set-Location $CURRENTPATH
}

####################################### Programme

AfficherTitreGras ("########## Script de Provisionnement de machine virtuelle VMWare Player ##########")
AfficherTitre ("Lancement du programme")
CheckVMwareInstall
CheckPuttyInstall
CheckFolders
CheckVMName
CopyVMFolder
CustomizeVM
PrepareGetVMIP
StartVM
Waiting
GetVMIP
ConfigureVM
AfficherTitre ("Fin du programme")