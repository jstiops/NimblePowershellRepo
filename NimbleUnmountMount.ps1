<#
Dit script is in staat om een snapshot van een productie volume te clonen en deze vervolgens te mounten.
Het script zal eerst de vorige clone ontkoppelen voordat het laatste snapshot gekoppeld wordt.
Dit script kan uitgevoerd worden op de back-up/reporting/OTA/testservert
#>
Import-module "C:\Program Files\Nimble Storage\bin\Nimble.PowershellCmdlets.psd1"
import-module HPENimblePowerShellToolkit

#configureer de servernaam van deze server. kan gebruikt worden als suffix
$servername = "ISCSITEST2"
#configureer de initiatorgroup die gebruikt moet worden voor deze host
$initiatorGroupName = "ISCSITEST2"
#configureer de volumecollection van de productievolumes
$volumeCollectionName = "AXDATABASE-DP"
#configureer een schedule naam waarop gefilterd kan worden indien dit gewenst is
$scheduleFilter = "schedule-axdata"
#configureer de gewenste driveletters die de clones moeten krijgen
$driveletter1 = "E:\"
$driveletter2 = "F:\"

#maak credentials aan en gebruik deze in de scripts. 
$secpasswd = ConvertTo-SecureString "thisisscecret" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("snapusername", $secpasswd)

#set de configuration voor de connectie naar de group
Set-NWTConfiguration -GroupMgmtIP 10.11.12.13 -CredentialObj $mycreds

#verwijder eerst de huidige mounts op de snapshots. Dit verwijderd ook de clones op de Nimble array die hiermee te maken hebben
Remove-NimVolume –NimbleVolumeAccessPath $driveletter1,$driveletter2 -Force

#haal de snapshots op en gebruik de output daarvan voor het maken van clones en het mounten daarvan.
Get-NimSnapshotCollection -VolumeCollectionName $volumeCollectionName -MaxObjects 1 | Where-Object {$_.name-like "*$scheduleFilter*"} | Invoke-CloneNimVolumeCollection –InitiatorGroup $initiatorGroupName –AccessPath $driveletter1,$driveletter2 –Suffix "-$servername"


