PowerShell
==========

settings to customize the powershell

 1. copy to C:\Users\????\Documents\WindowsPowerShell
 1. execute install.ps1
"""
powershell -NoProfile -ExecutionPolicy unrestricted -command if (!(test-path $profile.CurrentUserAllHosts )) {new-item -type file -path $profile.CurrentUserAllHosts -force} 
powershell -NoProfile -ExecutionPolicy unrestricted -command Copy-Item profile.ps1 $profile.CurrentUserAllHosts
"""

# reference sites
* PowerShell �ŃR�}���h���b�g�̗�����ۑ�����<BR>
http://agpg.seesaa.net/article/387985434.html

* �R�}���h�v�����v�g��փc�[����ckw<BR>
http://ckw-mod.github.io/


* PSReadLine - �R�}���h���C���ҏW�@�\����<BR>
https://github.com/lzybkr/PSReadLine<BR>
http://yanor.net/wiki/?PowerShell%2F%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB%2FPSReadLine%20%20-%20%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%83%A9%E3%82%A4%E3%83%B3%E7%B7%A8%E9%9B%86%E6%A9%9F%E8%83%BD%E5%BC%B7%E5%8C%96


* Windows��Git���g������posh-git�����悤
http://kashewnuts.bitbucket.org/2013/11/17/setupposhgit.html
