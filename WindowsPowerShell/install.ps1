
$psversion = $PSVersionTable.PSVersion.Major
if ( $psversion -eq 2)
{
	Write-Output 'PowerShell�̃o�[�W����3���C���X�g�[�����Ă�������'
	return false
}


Write-Output '�Z�b�g�A�b�v�J�n'

# installs listed modules
function ensurePsGetExists {
    if ((Get-Module PsGet) -eq $null) {
       wget("http://psget.net/GetPsGet.ps1")
    }
}

function installModule($moduleName)
{
	# ���W���[���C���X�g�[��
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
