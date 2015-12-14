Param(
	[Parameter(Mandatory=$true)]
	[bool]$Enable,
	
	[Parameter(Mandatory=$true)]
	[string]$TestAgentOrController,
	
	[Parameter(Mandatory=$true)]
	[string]$Version
)

function GetInstallDir([string]$vsTestVersion){
	$wowNode=""
	if($ENV:PROCESSOR_ARCHITECTURE -eq "amd64")
	{
		$wowNode="\Wow6432Node"
	}
	$regkey = Get-ItemProperty -Path ("HKLM:\SOFTWARE" + $wowNode + "\Microsoft\VisualStudio\" + $vsTestVersion)
	return $regKey.InstallDir
}

function TracingInConfigFile([string]$file, [string]$traceLevel, [string]$traceListener){
	$xml = [System.Xml.XmlDocument](Get-Content $file)
	
	$diagnosticsElements = $xml.SelectNodes("//configuration/system.diagnostics/switches")
	$diagnosticsElements.add | foreach { if ($_.name -eq 'EqtTraceLevel') { $_.value = $traceLevel } }
	
	$appSettingsElements = $xml.SelectNodes("//configuration/appSettings")
	$appSettingsElements.add | foreach { if ($_.key -eq 'CreateTraceListener') { $_.value = $traceListener } }
	
	$xml.Save($file)
}




Write-Host "Starting up..."

$installDir = GetInstallDir $Version
Write-Host "found installdir - $installDir"

if($TestAgentOrController -eq "testagent"){
	$taConfigFileNames = Get-ChildItem -path $installDir -filter "qtagent*.exe.config"
	foreach ($taConfigFileName in $taConfigFileNames){
		$taConfigFile = $installDir + ([system.io.path]::DirectorySeparatorChar) + $taConfigFileName
		Write-Host "test agent config file $taConfigFile"
		
		if($Enable){
			Write-Host "Enabling traces in $taConfigFile..."
			TracingInConfigFile $taConfigFile "4" "yes"
			Write-Host "Enabled!"
		}
		else{
			Write-Host "Disabling traces for test agent..."
			TracingInConfigFile $taConfigFile "0" "no"
			Write-Host "Disabled!"	
		}
	}
}
else{
	$tcConfigFileNames = Get-ChildItem -path $installDir -filter "qtcontroller*.exe.config"
	foreach ($tcConfigFileName in $tcConfigFileNames){
		$tcConfigFile = $installDir + ([system.io.path]::DirectorySeparatorChar) + $tcConfigFileName
		Write-Host "test controller config file $tcConfigFile"
		
		if($Enable){
			Write-Host "Enabling traces in $tcConfigFile..."
			TracingInConfigFile $tcConfigFile "4" "yes"
			Write-Host "Enabled!"
		}
		else{
			Write-Host "Disabling traces for test controller..."
			TracingInConfigFile $tcConfigFile "0" "no"		
			Write-Host "Disabled!"
		}
	}
}


Write-Host "..Done"
