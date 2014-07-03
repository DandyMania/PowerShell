
$psversion = $PSVersionTable.PSVersion.Major
if ( $psversion -eq 2)
{
	Write-Output 'PowerShellのバージョン3をインストールしてください'
	return false
}


Write-Output 'セットアップ開始'

# installs listed modules
function ensurePsGetExists {
    if ((Get-Module PsGet) -eq $null) {
       wget("http://psget.net/GetPsGet.ps1")
    }
}

function installModule($moduleName)
{
	# モジュールインストール
	if ((Get-Module $moduleName) -eq $null) {
		Install-Module $moduleName
	}
}

Write-Output 'InstallModule Start.'

# PsGet
ensurePsGetExists

# Other module
installModule pscx
installModule Find-String
installModule psake
#installModule posh-git
installModule PSReadline

Write-Output 'Finish'
