[CmdletBinding()]
param()

#Start the Transcript
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

#Load OSDCloud Functions
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)

# Check if Secure Boot is enabled
$secureBoot = Confirm-SecureBootUEFI

if (!$secureBoot) {
    Write-Host -ForegroundColor Red  "Secure Boot is disabled on this system. Go to the System BIOS to enable Secure Boot before installing."
    Write-Host -ForegroundColor Red  "If Secure Boot is already enabled in BIOS, try restoring factory keys, and try again"
        
    Start-Sleep -Seconds 300
    Exit
}

$disks = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType =3"
If (-not $Disks){
    Write-Host -ForegroundColor Red  "No disk detected, either the boot image is missing neccesary drivers, or the harddrive needs to be replaced."
    Start-Sleep -Seconds 300
    #ToDo - Send warning with model and serial number to teams.
    Exit       
}

# GaX OSDCloud start script

$BrandName = 'GaX'
$BrandColor = '#059297ff'
$OSActivation = 'Retail'

$Global:MyOSDCloud = [ordered]@{
    Restart = [bool]$True
    RecoveryPartition = [bool]$true
    OEMActivation = [bool]$true
	WindowsUpdate = [bool]$false
    WindowsUpdateDrivers = [bool]$false
    WindowsDefenderUpdate = [bool]$false
	SetTimeZone = [bool]$true
    ClearDiskConfirm = [bool]$true
    ShutdownSetupComplete = [bool]$false
    SyncMSUpCatDriverUSB = [bool]$true
    CheckSHA1 = [bool]$true
}

$menuOptions = [ordered]@{
	"1" = "Windows 11 Pro 24H2 English ";
    "2" = "Chose between Windows 10,11 and language";

}

# Display the menu
Show-Menu -Options $menuOptions

# Funktion til automatisk at formatere brugerens valg
function Format-Selection {
    param (
        [string]$selection
    )
    return $selection.PadLeft(3, '0')
}
do {
    Show-Menu
    $selection = Read-Host "Please select option you need"
    
    switch ($selection) {

"1" {
            Write-Host "You selected: $($menuOptions[$selection])"
			$OSLanguage = 'en-us'
			$OSName = 'Windows 11 24H2 x64'
			$OSEdition = 'Pro'
			$OSActivation = 'Retail'
			$arch = $env:PROCESSOR_ARCHITECTURE

if ($arch -eq "ARM64") {
    Write-Output "ARM64"
	    Start-OSDCloudGUIDEV -BrandColor $Brandcolor -BrandName $BrandName
		#Start-OSDCloudGUIDEV -OSLanguage $OSLanguage -OSActivation $OSActivation -OSName $OSName -OSEdition $OSEdition
} else {
    Write-Output "(x86/x64)"
	    Start-OSDCloud -OSLanguage $OSLanguage -OSActivation $OSActivation -OSName $OSName -OSEdition $OSEdition
}

        }

"2" {
            Write-Host "You selected: $($menuOptions[$selection])"
$arch = $env:PROCESSOR_ARCHITECTURE

if ($arch -eq "ARM64") {
    Write-Output "ARM64"
	    Start-OSDCloudGUIDEV -BrandColor $Brandcolor -BrandName $BrandName
} else {
    Write-Output "(x86/x64)"
	    Start-OSDCloudGUI -BrandColor $Brandcolor -BrandName $BrandName
}

        }
		
        #Default option
        default {
            Write-Host "You selected: $($menuOptions[$selection])"

        }
    }
} while (-not $selection)

    Write-Host -ForegroundColor Green "Starting OSDCloud "
    If ($selection -eq '1') {
        # Do nothing

    }
    Else{
		# Hent processorarkitekturen fra miljøvariablen
$arch = $env:PROCESSOR_ARCHITECTURE

if ($arch -eq "ARM64") {
    Write-Output "ARM64"
	    Start-OSDCloudGUIDEV -BrandColor $Brandcolor -BrandName $BrandName

} else {
    Write-Output "(x86/x64)"
	    Start-OSDCloudGUI -BrandColor $Brandcolor -BrandName $BrandName
}

    }