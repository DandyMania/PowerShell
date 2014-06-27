
$psversion = $PSVersionTable.PSVersion
if ( $psversion -eq 2)
{
	Write-Output 'PowerShell�̃o�[�W����3���C���X�g�[�����Ă�������'
	return false
}


Write-Output '�Z�b�g�A�b�v�J�n'

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
				# �_�C�A���O��\�����ă��O�C�������擾
				$cred = get-credential
				$wc.Proxy.Credentials = $cred.GetNetworkCredential()
				# �ēx�_�E�����[�h
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
