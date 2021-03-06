# √删除无效路径
# ×支持在后面添加 / 打开子目录
# ×如果路径包含 *，支持检索子目录
function open {
	param (
		$argv
	)
	if ($argv.Length -eq 0) {
		Write-Warning "Please provide a path.";
		return;
	}
	$t_args = OptionFilter $argv
	$t = ("*" + ($t_args -join "*") + "*")
	CheckPath
	$raw = Get-Content $HOME/psconfig/quickopen.txt;
	$s = New-Object System.Collections.ArrayList;
	foreach ($item in $raw) {
		if (Test-Path $item) {
			$s.Add($item) | Out-Null;
		}
	}
	$s = Get-Item ($s) -Force
	foreach ($item in $s) {
		if (CheckLike $item $t $argv) {
			OpenOrCode $item $argv $true
		}
	}
}

function pin {
	if ($args.Length -eq 0) {
		Write-Host "pin [action] path [option]";
		Write-Host;
		Write-Host "    actions: add, ls, rm, open";
		Write-Host;
		return;
	}
	
	[Collections.Generic.List[String]]$argv = $args
	$argv.RemoveAt(0)
	if ($args[0] -eq "add") {
		add $argv
	}
	if ($args[0] -eq "ls") {
		pined $argv
	}
	if ($args[0] -eq "rm") {
		unpin $argv
	}
	if ($args[0] -eq "open") {
		open $argv
	}
}

function add {
	param (
		$argv
	)
	if ($argv.Length -eq 0) {
		Write-Warning "Please provide a path.";
		return;
	}
	CheckPath
	$s = (Get-Content $HOME/psconfig/quickopen.txt)
	$t = New-Object System.Collections.ArrayList
    
	$Add = ($argv -join " ")

	if (Test-Path $Add) {
		foreach ($item in $s) {
			$t.Add($item) | Out-Null
		}
    
		$t.Add($Add) | Out-Null
		Set-Content -Path $HOME/psconfig/quickopen.txt -Value $t;
	}
}

function unpin {
	param (
		$argv
	)
	if ($argv.Length -eq 0) {
		Write-Warning "Please provide a path.";
		return;
	}
	CheckPath
	$s = (Get-Content $HOME/psconfig/quickopen.txt)
	$t = New-Object System.Collections.ArrayList
    
	$Remove = ($argv -join " ")

	foreach ($item in $s) {
		$t.Add($item) | Out-Null
	}

	if ($Remove) {
		$t.Remove($Remove) | Out-Null
	}
	Set-Content -Path $HOME/psconfig/quickopen.txt -Value $t;
}

function pined {
	param (
		$argv
	)
	CheckPath
	$raw = Get-Content $HOME/psconfig/quickopen.txt;
	if ($raw.Length -eq 0) {
		return
	}
	$s = New-Object System.Collections.ArrayList;
	foreach ($item in $raw) {
		if (Test-Path $item) {
			$s.Add($item) | Out-Null;
		}
	}
	if (-not ($raw.Length -eq $s.Length)) {
		Set-Content -Path $HOME/psconfig/quickopen.txt -Value $s;
	}
	$t = ("*" + ((OptionFilter $argv) -join "*") + "*")
	if ($t) {
		$s = Get-Item ($s) -Force
		foreach ($item in $s) {
			if (CheckLike $item $t $argv) {
				$item.FullName;
				OpenOrCode $item $argv
			}
		}
	}
	else {
		Write-Host -ForegroundColor 2 (Get-Content $HOME/psconfig/quickopen.txt)
	}
}

function CheckPath {
	if (!((Test-Path $HOME/psconfig/quickopen.txt) -eq $true)) {
		if (!((Test-Path $HOME/psconfig) -eq $true)) {
			mkdir $HOME/psconfig
		}
		New-Item $HOME/psconfig/quickopen.txt -ItemType File
	}
}

function OptionFilter {
	param (
		[parameter(ValueFromPipeLine = $true)]
		$list
	)
	return $list | Where-Object {
		!$_.ToString().StartsWith("-")
	}
}

function CheckLike {
	param (
		$item,
		$test,
		$opt_list
	)
	$target = $item.Name
	if (($opt_list -contains "--full") -or ($opt_list -contains "-f")) {
		$target = $item.FullName
	}
	if (($opt_list -contains "--case") -or ($opt_list -contains "-c")) {
		return $target -clike $test
	}
	else {
		return $target -like $test
	}
}

function OpenOrCode {
	param (
		$item,
		$opt_list,
		$open = $false
	)
	if ($opt_list -contains "--code") {
		if (Get-Command code-insiders -errorAction SilentlyContinue) {
			code-insiders $item.FullName
		}
		elseif (Get-Command code -errorAction SilentlyContinue) {
			code $item.FullName
		}
	}
	elseif ($open -or $opt_list -contains "-o" -or $opt_list -contains "--open") {
		if ($item.PsIsContainer) {
			explorer.exe $item.FullName;
		}
		else {
			explorer.exe $item.Directory.Parent.FullName;
		}
	}
}
# function ParsePath ($str) {
#     $obj = New-Object System.Object;
#     Add-Member -InputObject $obj -Name type -Value 
#     if()
# }
