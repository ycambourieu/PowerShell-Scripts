<#
    Author : Yohan CAMBOURIEU   
    Date : 14/07/2019
    Script : Copy_Selected_Photos_GUI_CR3.ps1
    Version : 1.0
    Utility : Copy a list of CR3 files into a seperated directory for editing purposes
    Compatible Plateform : Windows 10, CANON img CR3 Files
    Usage : 
        - Select the forlder of source RAW CR3 files
        - Select the folder where you want to copy these files
        - Select the ".txt" list of files you want to copy
            .txt list of file must be in this format (one number per line) : 
                5433
                5622
                5625
                
        This will copy files IMG_5433.CR3, IMG_5622.CR3, IMG_5625.CR3 files from source to destination folder
#>
function Find-Folders-Source {
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $browse = New-Object System.Windows.Forms.FolderBrowserDialog
    $browse.SelectedPath = "D:\Photos\"
    $browse.ShowNewFolderButton = $false
    $browse.Description = "Selectionner le repertoire RAW source"

    $loop = $true
    while($loop)
    {
        if ($browse.ShowDialog() -eq "OK")
        {
        $loop = $false
		
		#Insert your script here
		
        } else
        {
            $res = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
            if($res -eq "Cancel")
            {
                #Ends script
                return
                exit 1
            }
        }
    }
    $browse.SelectedPath
    $browse.Dispose()
} 

function Find-Folders-Destination {
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $browse = New-Object System.Windows.Forms.FolderBrowserDialog
    $browse.SelectedPath = "E:\Traitement photos\"
    $browse.ShowNewFolderButton = $true
    $browse.Description = "Selectionner le répertoire de destination"

    $loop = $true
    while($loop)
    {
        if ($browse.ShowDialog() -eq "OK")
        {
        $loop = $false
		
		#Insert your script here
		
        } else
        {
            $res = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
            if($res -eq "Cancel")
            {
                #Ends script
                return
                exit 1
            }
        }
    }
    $browse.SelectedPath
    $browse.Dispose()
} 


$SOURCE = Find-Folders-Source

$DESTINATION = Find-Folders-Destination

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    Multiselect = $false # Multiple files can be chosen
	Filter = 'Fichier texte (*.txt)|*.txt' # Specified file types
}
 
[void]$FileBrowser.ShowDialog()

$file = $FileBrowser.FileName;

If($FileBrowser.FileNames -like "*\*") {

	# Do something 
	$FileBrowser.FileName #Lists selected files (optional)
	
}

else {
    Write-Host "Cancelled by user"
    exit 1
}

foreach($line in Get-Content -Path $file){
    Write-Host "Copie de la photo :  IMG_$line.CR3"
    Copy-Item -Path $SOURCE\IMG_$line.CR3 -Destination "$DESTINATION\"
}