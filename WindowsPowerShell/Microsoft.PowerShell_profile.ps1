
if ($host.Name -eq 'ConsoleHost')
{
   Import-Module PSReadline
}


$historyFilePath = "~/_pscmd_history"

if ( Test-path $historyFilePath ){
	Import-Csv $historyFilePath | Add-History
}

function prompt {
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

	$chost = [ConsoleColor]::Green
	$cdelim = [ConsoleColor]::DarkCyan
	$cloc = [ConsoleColor]::Cyan

	Write-Host '[' ([Environment]::MachineName) -nonewline -foregroundcolor $chost
	Write-Host -nonewline -foregroundcolor $cdelim
	Write-Host '@' (Shorten-Path (pwd).Path) -nonewline -foregroundcolor $cloc
	Write-Host '] ' -nonewline -foregroundcolor $cdelim

	$promptCalls | foreach { $_.Invoke() }

	Write-Host "»" -nonewline -foregroundcolor $cloc
	' '

	$host.UI.RawUI.ForegroundColor = [ConsoleColor]::White
	
	return ' '
}

function Shorten-Path([string] $path = $pwd) {
	$loc = $path.Replace($HOME, '~')
	# remove prefix for UNC paths
	$loc = $loc -replace '^[^:]+::', ''
	# make path shorter like tabs in Vim,
	# handle paths starting with \\ and . correctly
	return ($loc -replace "\\(\.?)([^\\]{$shortenPathLength})[^\\]*(?=\\)",'\$1$2')
}


if ((Get-Module PSReadLine -ListAvailable) -ne $null) {
    Import-Module PSReadLine

    Set-PSReadlineOption -EditMode Emacs
    Set-PSReadlineOption -BellStyle None

    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadlineKeyHandler -Key Tab -Function Complete
}