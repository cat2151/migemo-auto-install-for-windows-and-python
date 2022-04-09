@powershell -NoProfile -ExecutionPolicy Unrestricted "$s=[scriptblock]::create((gc \"%~f0\"|?{$_.readcount -gt 1})-join\"`n\");&$s" %*&goto:eof

# スクリプトの動作ディレクトリを得る
function getScriptDir() {
  if ("$PSScriptRoot" -eq "") {
    $Pwd.Path # bat化した場合、$PSScriptRoot や $MyInvocation.MyCommand.Path や $PSCommandPath は空なので、bat起動時のカレントディレクトリで代用する
  } else {
    $PSScriptRoot
  }
}

function startLog($filename) {
    $null = Start-Transcript $filename
    Get-Date
}

function endLog() {
    "かかった時間 : " + ((Get-Date) - $startTime).ToString("m'分's'秒'")
    Stop-Transcript
}

function recover_pip() { # もしpipが破壊されていてもこれで修復できる用
    pip --version
    if (! $?) {
        curl.exe https://bootstrap.pypa.io/get-pip.py --output get-pip.py
        python get-pip.py # インストールしたpythonに対して書き込み権限のないユーザで実行するたび、交互に破壊されたり復活したりするので、破壊されているときのみ実施する（根本的には管理者権限でpythonをインストールしたディレクトリに プロパティ/セキュリティ/Users/アクセス許可/フルコントロール を付与したほうが安全そう）
        del get-pip.py
    }
}

function install_python_module_cmigemo() {
    pip install cmigemo
}

function install_dll_cmigemo_win64() {
    curl.exe -L http://files.kaoriya.net/goto/cmigemo_w64 --output cmigemo-default-win64-20110227.zip
    Expand-Archive -Path cmigemo-default-win64-20110227.zip -DestinationPath . -Force

    $copy_src  = "$(getScriptDir)\\cmigemo-default-win64\migemo.dll" # Q:なぜフルパスなの？ A:もし権限昇格した場合はカレントディレクトリが変化しフルパスが必要になるため
    $copy_dest = "$(getPythonDir)migemo.dll"
    copy_with_uac $copy_src $copy_dest
}

# コピーし、失敗したら権限昇格してコピーする
function copy_with_uac($copy_src, $copy_dest) {
    $copyCmd = "copy $copy_src $copy_dest"
    $copyCmd_powerShell = $copyCmd + ";`$?"
    $result = Invoke-Expression $copyCmd_powerShell
    if (! $result) {
        "コピー失敗しました。権限昇格してコピーします"
        Start-Process -FilePath "cmd" -ArgumentList "/c ${copyCmd}" -Verb Runas
    }
}

function getPythonDir() {
    $str = $Env:PATH
    $array = $str.Split(";")
    foreach ($i in $array) {
        if ($i -match ".*[Pp]ython.*") {
            $f = $i + "python.exe"
            if (Test-Path $f) {
                $i
                return
            }
        }
    }
}

function install_dict() {
    xcopy /E /I "cmigemo-default-win64\dict\utf-8" "dict"
}

function test_python_cmigemo() {
    Set-Content -Path "test_cmigemo.py" -Force -Value @'
import cmigemo
migemo = cmigemo.Migemo("dict/migemo-dict")
result = migemo.query("hoge")
print(result)
if result == "hoge":
    print("ERROR")
    exit(1)
else:
    print("migemo install SUCCESS")
'@

    python test_cmigemo.py
    $?
}

function check_if_installed() {
    $result = test_python_cmigemo
    if (! $result) {
        $result
    } else {
        "already installed"
        exit
    }
}

function main() {
    if (! $(check_if_installed)) {
        recover_pip
        install_python_module_cmigemo
        install_dll_cmigemo_win64
        install_dict
        test_python_cmigemo
    }
}


###
$startTime = startLog "install_python_cmigemo.log"
main
endLog
