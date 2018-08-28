Param(
   [string]$keypass
)
#gci d:\a\ -Recurse 
$tempDirectory = $env:AGENT_WORKFOLDER + "\_temp\" 
$keypath = "$tempDirectory\pshellSigning.pfx"

$Copyright = "(C) $((get-date).year) Microsoft Corporation All rights reserved."
$ModuleName = "Microsoft.Xrm.Data.PowerShell" 
$moduleFileName = "$ModuleName.psd1"

cd $ModuleName

$modulePath = Convert-Path "."

#get, parse, and update Module attributes 
$datafile = Import-PowerShellDataFile "$modulepath\$moduleFileName" -Verbose
$vNum = $datafile.ModuleVersion
$manifestVersion = [System.Version]::Parse($vNum)
$newBuildNumber = "$($manifestVersion.Major).$($manifestVersion.Minor)"
$datafile.Copyright = $Copyright
$datafile.ModuleVersion = $newBuildNumber
$datafile.CmdletsToExport = "*"
$datafile.FunctionsToExport = "*-*"
$datafile.VariablesToExport = "*"

"Updating module manifest" 
Update-ModuleManifest "$modulepath\$moduleFileName" -Copyright $Copyright -ModuleVersion $vNum

"Clean out *.psproj and *.pshproj from $modulepath..."
try{
	$Files = Get-ChildItem $modulepath -Include *.pssproj,*.pshproj -Recurse -verbose
	foreach ($File in $Files){ 
		"Deleting File $File"
		Remove-Item $File | out-null 
	}
}
Catch{
	"Failed to cleanup specific file extensions"
}

#$Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($keypath,$keypass)
#Set-AuthenticodeSignature -Certificate $Cert -TimeStampServer http://timestamp.verisign.com/scripts/timstamp.dll -FilePath "$ModuleName.psd1"
#Set-AuthenticodeSignature -Certificate $Cert -TimeStampServer http://timestamp.verisign.com/scripts/timstamp.dll -FilePath "$ModuleName.psm1"