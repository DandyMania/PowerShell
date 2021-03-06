
#-----------------------------------------
# command history
#-----------------------------------------
$MaximumHistoryCount = 32
$historyFilePath = "~/_pscmd_history"
if ( Test-Path $historyFilePath ){
	Import-Csv $historyFilePath | Add-History
}


#-----------------------------------------
# prompt setting
#-----------------------------------------
<# origin
function Prompt
{
	$promptString = "PS " + $(Get-Location) + ">"

	# Custom color for Windows console
	if ( $Host.Name -eq "ConsoleHost" )
	{
	    Write-Host $promptString -NoNewline -ForegroundColor Yellow
	}
	# Default color for the rest
	else
	{
	    Write-Host $promptString -NoNewline
	}

	return " "
}
#>


function prompt {
	# our theme
	$cdelim = [ConsoleColor]::DarkCyan
	$chost = [ConsoleColor]::DarkGreen
	$cloc = [ConsoleColor]::DarkYellow

	#bg
	#$host.ui.rawui.backgroundcolor = "DarkGray"

	# command history
	$latestHistory = Get-History -Count 1
	if($script:lastHistory -ne $latestHistory) {
		$csv = ConvertTo-Csv $latestHistory

		if( -not(Test-Path $historyFilePath)) {
			Out-File $historyFilePath -InputObject $csv[0] -Encoding UTF8
			Out-File $historyFilePath -InputObject $csv[1] -Encoding UTF8 -Append
		}
		Out-File $historyFilePath -InputObject $csv[-1] -Encoding UTF8 -Append

		$script:lastHistory = $latestHistory
	}

	
	#write-host '[' ([net.dns]::GetHostName()) -n -f $chost
	#write-host ' @ ' -n -f $cdelim
	write-host '[' -n -f $cdelim
	write-host (shorten-path (pwd).Path) -n -f $cloc
	write-host ' ~]' -n -f $cdelim
	write-host "$([char]0x0A7)" -n -f $chost
	return ' '
}
function shorten-path([string] $path) {
	$loc = $path.Replace($HOME, '~')
	# remove prefix for UNC paths
	$loc = $loc -replace '^[^:]+::', ''
	# make path shorter like tabs in Vim,
	# handle paths starting with \\ and . correctly
	return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')
}


if ((Get-Module Pscx -ListAvailable) -ne $null) {
	Import-Module Pscx -DisableNameChecking #-arg "$(Split-Path $profile -parent)\Pscx.UserPreferences.ps1"
}
if ((Get-Module PSWindowsUpdate -ListAvailable) -ne $null) {
	Import-Module PSWindowsUpdate -DisableNameChecking
}
#-----------------------------------------------------------------------------
# PSReadLine
#-----------------------------------------------------------------------------
if ((Get-Module PSReadLine -ListAvailable) -ne $null) {
	if ($host.Name -eq 'ConsoleHost')
	{
		Import-Module PSReadline

		#Set-PSReadlineOption -EditMode Emacs
		Set-PSReadlineOption -BellStyle None

		Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
		Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
		Set-PSReadlineKeyHandler -Key Tab -Function Complete
	}
}

# Load posh-git example profile
#. 'C:\Users\DM\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'



# ウィンドウの設定とか
$a = (Get-Host).UI.RawUI 
$a.WindowTitle =  "Console@" + [net.dns]::GetHostName() + " - " + (Get-Location)

$pshost = get-host  
$pswindow = $pshost.ui.rawui  
  
$newsize = $pswindow.buffersize  
$newsize.height = 3000  
$newsize.width = 100
$pswindow.buffersize = $newsize  
  
$newsize = $pswindow.windowsize  
$newsize.height = 20  
$newsize.width = 100 
$pswindow.windowsize = $newsize 


#-----------------------------------------------------------------------------
# Alias
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
function wget([string]$URL,[string]$dir=$Env:temp+"/",[switch]$exec){
<#
.SYNOPSIS
    シェルのwgetの簡易版
.Description
.Link
.Example
#>

	Write-Host $URL
	
	$uri = new-object Uri($URL)
    $filename = $uri.Segments[$uri.Segments.Length-1]
    
	$file_path = $dir + $filename

	[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $wc = new-object System.Net.WebClient
	$proxy = [System.Net.WebRequest]::GetSystemWebProxy()
	$proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
	$wc.Proxy = $proxy

	try {
		$wc.DownloadFile($URL,(Join-Path $dir $filename)) #| iex
	} catch [System.Net.WebException] {
		if ($_.Exception -match ".*\(407\).*") {
			# ダイアログを表示してログイン情報を取得
			$cred = get-credential
			$wc.Proxy.Credentials = $cred.GetNetworkCredential()
			# 再度ダウンロード
			$wc.DownloadFile($URL,(Join-Path $dir $filename)) #| iex
		} else {
			throw
		}
	}
	if( $exec ){
		# 実行
		if( $(Get-ChildItem $file_path).get_Extension() -eq ".ps1"){
				$wc.DownloadString($URL) | iex
		}else{
				cmd /c "$dir$filename"
		}
	}

	
	
}

#-----------------------------------------------------------------------------
# unzip
function psunzip([string]$zipfilename,[string]$dir=$Env:temp+"/") {
<#
.SYNOPSIS
    unzip
.Description
.Link
.Example
#>
	
	
	# ブロック解除
	#$File = Get-Item $zipfilename
	#$File.DeleteAlternateDataStream
	cmd /c copy $zipfilename "$dir"
	$path = $dir + "\" + $(Get-ChildItem $zipfilename).Name
	
	Write-Host $path
	pushd $dir
	cmd /c 7z.exe x -y $path
	popd
}

# パス一覧見やすく表示
function path(){echo ($Env:path).split(';')}

# OS名取得
function os(){
	$os_name = (Get-WmiObject -Class win32_operatingsystem).caption
	if( $os_name.Contains("XP") ){
		return "XP"
	}elseif( $os_name.Contains("7") ){
		return "7"
	}
	return "Windows"	
}


#Powershellのホームフォルダ
function profiledir(){return "$env:userProfile\My Documents\WindowsPowerShell\"}


#------------------------------------------------------------------------------
function setup(){

<#
.SYNOPSIS
    必要なソフトやPoweShellのモジュールなどを自動的にインストールする
.Description
	インストールされるもの
    chocolatey … コンソールからソフトをインストールするツール
    ・以下Windows7の場合
      PowerShell3.0
      PowerShellのモジュール(コマンド履歴保存など)
.Link
.Example
#>


	# チョコレーティ入れる。
	$path = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
	if( !$path.Contains("chocolatey") ){
		Write-Output "□ chocolateyをインストール"
		wget 'https://chocolatey.org/install.ps1' -exec
		
		#$path = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
		#$path += ';' + $choco_path + ";"
		#[Environment]::SetEnvironmentVariable('PATH', $path, 'Machine')
		# 再起動
		cmd /c resetenv.bat
		return
	}
	
	# 7z
	cinst 7Zip

	$os_name = os
	if( $os_name -eq "7" ){
		Write-Host "□ PowerShell 3.0 インストール"
		cinst PowerShell
	}

	# PSのモジュール
	InstallModule


	# DirectXインストール
	if( $Env:DXSDK_DIR -eq $null ){
		#選択肢の作成
		$typename = "System.Management.Automation.Host.ChoiceDescription"
		$yes = new-object $typename("&Yes","実行する")
		$no  = new-object $typename("&No","実行しない")

		#選択肢コレクションの作成
		$choice = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)

		#選択プロンプトの表示
		$answer = $host.ui.PromptForChoice("<実行確認>","DirectX SDK(Fev2010)が入ってないけどインストールします？",$choice,0)
		if($answer -eq 0){
			wget http://download.microsoft.com/download/A/E/7/AE743F1F-632B-4809-87A9-AA1BB3458E31/DXSDK_Jun10.exe -exec
		}
	}else{
		$a = Get-ItemProperty "hklm:\Software\Microsoft\DirectX" 
		$strValue = $a.Version
		Write-Host "DirectX Ver." $strValue
	}
}



#------------------------------------------------------------------------------
function InstallModule(){
<#
.SYNOPSIS
    PSモジュールのインストール
.Description
.Link
.Example
#>


	Write-Host '□ モジュールインストール開始'

	# installs listed modules
	function ensurePsGetExists {
	    if ((Get-Module PsGet) -eq $null) {
	       wget "http://psget.net/GetPsGet.ps1" -exec
	    }
	}

	function installModule($moduleName)
	{
		# モジュールインストール
		if ((Get-Module $moduleName) -eq $null) {
			Install-Module $moduleName
		}
	}

	Write-Host 'InstallModule Start.'

	# PsGet
	ensurePsGetExists

	# Other module
	installModule pscx
	installModule Find-String
	installModule psake

	#installModule posh-git
	
	# WindowsUpdateモジュール	
	if ((Get-Module PSWindowsUpdate) -eq $null) {
		
		#InstallModule PSWindowsUpdate # リストになかった。。。
		#$psupdate_path = "http://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/"
		#$psupdate_path = $psupdate_path + "file/41459/28/PSWindowsUpdate.zip"
		#wget($psupdate_path)
		#$filename = Split-Path $psupdate_path -Leaf
		#psunzip ($Env:temp+"$filename") $profilePath"Modules"

		# zipダウンロード
		cinst PSWindowsUpdate
		$profilepath = profiledir
		psunzip ($Env:temp+"\chocolatey\PSWindowsUpdate\PSWindowsUpdateInstall.zip") $profilepath"Modules"
		
		# ブロック解除は不要なのでスクリプトから取り除く
		$PSWindowsUpdatePsmFile = "PSWindowsUpdate.psm1"
		$PSWindowsUpdatePath = $profilepath+"\Modules\PSWindowsUpdate\"
		Rename-Item $PSWindowsUpdatePath$PSWindowsUpdatePsmFile -newName "temp"
		(Get-Content $PSWindowsUpdatePath"temp") -replace "Unblock-File",'Foreach-Object{}' > $PSWindowsUpdatePath$PSWindowsUpdatePsmFile	
		
		# モジュールインポート
		Import-Module PSWindowsUpdate
	}

	# PS3.0でしか動かない。。。
	$os_name = os
	if( !($os_name -eq "XP") ){
		installModule PSReadline
	}
	
	
	Write-Output '...終了'
}

