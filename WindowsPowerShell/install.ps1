
$psversion = $PSVersionTable.PSVersion
if ( $psversion -eq 2)
{
	Write-Output 'PowerShellのバージョン3をインストールしてください'
	return false
}


Write-Output 'セットアップ開始'

# installs listed modules
function ensurePsGetExists {
    if ((Get-Module PsGet) -eq $null) {
        # install psget
        $wc = new-object System.Net.WebClient
		$proxy = [System.Net.WebRequest]::GetSystemWebProxy()
		$proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
		$wc.Proxy = $proxy

		try {
		  $wc.DownloadString("http://psget.net/GetPsGet.ps1") | iex
		} catch [System.Net.WebException] {
			if ($_.Exception -match ".*\(407\).*") {
				# ダイアログを表示してログイン情報を取得
				$cred = get-credential
				$wc.Proxy.Credentials = $cred.GetNetworkCredential()
				# 再度ダウンロード
				$wc.DownloadString("http://psget.net/GetPsGet.ps1") | iex
			} else {
				throw
			}
		} 
        
    }
}

function installModule($moduleName)
{
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
