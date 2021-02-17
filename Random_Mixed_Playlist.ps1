<#
    Author : Yohan CAMBOURIEU   
    Date : 10/02/2020
    Script : Random_Mixed_PLaylist.ps1
    Version : 1.0
    Utility : Create a random playlist of audio or video files with a targeted duration. Works with MP3, FLAC, MP4, AVI..
            Playlist files are randomized and renamed, a VLC shortcut is created to autoplay the playlist
    Compatible Plateform : Windows 10, VLC Merdia Player installed
#>

# VARIABLES
$script:FOLDER_PATH = "C:\Users\User\Music" # Contain all Music files ordered by Folder : Rock, Metal, Rap
$script:OUTPUT_PATH = "C:\Users\User\Mix" # Destination of the output playlist
$script:MAX_TIME = 60 # Max time in minutes

$FOLDERS = @(
    [pscustomobject]@{Name='Rock';Ponderation=2}
    [pscustomobject]@{Name='Metal'; Ponderation=2}
    [pscustomobject]@{Name='Rap';Ponderation=1}
) # Use this to add weight to certain folders, more files will be copied from these folders

# FONCTIONS
function InitVariables(){
    #Clear-Host
    $script:MAX_TIME_SEC = $script:MAX_TIME * 60
    $script:OUTPUT_TOTAL_TIME = "0"
    $script:NB_FOLDERS = $FOLDERS.count
    Write-Host "Source : $script:FOLDER_PATH "
    Write-Host "Output: $script:OUTPUT_PATH"
    Write-Host "Target Time : $script:MAX_TIME min ($script:MAX_TIME_SEC sec)"
}
function CheckTotalOutputTime(){
    $TOTAL_TIME = 0
    $Shell = New-Object -ComObject Shell.Application
    Get-ChildItem -Path $script:OUTPUT_PATH -Recurse -Force | ForEach-Object {
        $Folder = $Shell.Namespace($_.DirectoryName)
        $File = $Folder.ParseName($_.Name)
        $Duration = $Folder.GetDetailsOf($File, 27)
        $textReformat = $Duration -replace ",","."
        $seconds = ([TimeSpan]::Parse($textReformat)).TotalSeconds
        $TOTAL_TIME = $TOTAL_TIME + $seconds
    }
    $script:OUTPUT_TOTAL_TIME = $TOTAL_TIME
}
function CutRandomFileToOutput(){
    Move-Item "$FILE" -Destination $script:OUTPUT_PATH
}
function CopytRandomFileToOutput($FILE){
    Copy-Item "$FILE" -Destination $script:OUTPUT_PATH
}
function GetStatsOutputFolder(){
    $Shell = New-Object -ComObject Shell.Application
    Get-ChildItem -Path $script:OUTPUT_PATH -Recurse -Force | ForEach-Object {
        $Folder = $Shell.Namespace($_.DirectoryName)
        $File = $Folder.ParseName($_.Name)
        $Duration = $Folder.GetDetailsOf($File, 27)
        $textReformat = $Duration -replace ",","."
        $seconds = ([TimeSpan]::Parse($textReformat)).TotalSeconds
        $TOTAL_TIME = $TOTAL_TIME + $seconds
    }
    $TOTAL_TIME_MIN = [math]::Round($TOTAL_TIME / 60,2)
    Write-Host "-----------------"
    Write-Host "Total time $TOTAL_TIME_MIN min (Goal $script:MAX_TIME min) "
    Write-Host "Number of files : "( Get-ChildItem $script:OUTPUT_PATH | Measure-Object ).Count;
}

function RandomizeOutputNames (){
    Get-ChildItem -Path $script:OUTPUT_PATH |ForEach-Object {Move-Item "$script:OUTPUT_PATH\$_" -Destination "$script:OUTPUT_PATH\$([guid]::NewGuid().ToString()+$_.extension)"}
}

function CreateShortCut (){
    if (Test-Path -path "C:\Program Files\VideoLAN\VLC\vlc.exe"){
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$script:OUTPUT_PATH\PlayMe.lnk")
        $Shortcut.TargetPath = "C:\Program Files\VideoLAN\VLC\vlc.exe"
        $Shortcut.Arguments = "--playlist-autostart --no-video-title -f --qt-pause-minimized --one-instance $script:OUTPUT_PATH\"
        $Shortcut.IconLocation = "%systemroot%\system32\imageres.dll,81"
        $Shortcut.Save()
    }
}

# PROGRAM
InitVariables
while ($script:OUTPUT_TOTAL_TIME -lt $script:MAX_TIME_SEC) {
    for ( $cpt = 0; $cpt -lt $script:NB_FOLDERS; $cpt++)
    {  
        $FOLDER_NAME = $FOLDERS[$cpt].Name
        $FOLDER_POND = $FOLDERS[$cpt].Ponderation
        $CPT_POND = 0
        while ($CPT_POND -lt $FOLDER_POND){
            $FILE_NAME = Get-ChildItem -Path "$script:FOLDER_PATH\$FOLDER_NAME" -Name | Select-Object -index $(Get-Random $((Get-ChildItem).Count))
            $FILE = "$script:FOLDER_PATH\$FOLDER_NAME\$FILE_NAME"
            if ((Get-Item $FILE) -is [System.IO.DirectoryInfo] -eq $False){
                #CutRandomFileToOutput "$FILE"
                CopytRandomFileToOutput "$FILE"
            }
            $CPT_POND++ 
        }
    }
    CheckTotalOutputTime
}
RandomizeOutputNames
CreateShortCut
GetStatsOutputFolder