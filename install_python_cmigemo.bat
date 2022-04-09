@powershell -NoProfile -ExecutionPolicy Unrestricted "$s=[scriptblock]::create((gc \"%~f0\"|?{$_.readcount -gt 1})-join\"`n\");&$s" %*&goto:eof

# �X�N���v�g�̓���f�B���N�g���𓾂�
function getScriptDir() {
  if ("$PSScriptRoot" -eq "") {
    $Pwd.Path # bat�������ꍇ�A$PSScriptRoot �� $MyInvocation.MyCommand.Path �� $PSCommandPath �͋�Ȃ̂ŁAbat�N�����̃J�����g�f�B���N�g���ő�p����
  } else {
    $PSScriptRoot
  }
}

function startLog($filename) {
    $null = Start-Transcript $filename
    Get-Date
}

function endLog() {
    "������������ : " + ((Get-Date) - $startTime).ToString("m'��'s'�b'")
    Stop-Transcript
}

function recover_pip() { # ����pip���j�󂳂�Ă��Ă�����ŏC���ł���p
    pip --version
    if (! $?) {
        curl.exe https://bootstrap.pypa.io/get-pip.py --output get-pip.py
        python get-pip.py # �C���X�g�[������python�ɑ΂��ď������݌����̂Ȃ����[�U�Ŏ��s���邽�сA���݂ɔj�󂳂ꂽ�蕜�������肷��̂ŁA�j�󂳂�Ă���Ƃ��̂ݎ��{����i���{�I�ɂ͊Ǘ��Ҍ�����python���C���X�g�[�������f�B���N�g���� �v���p�e�B/�Z�L�����e�B/Users/�A�N�Z�X����/�t���R���g���[�� ��t�^�����ق������S�����j
        del get-pip.py
    }
}

function install_python_module_cmigemo() {
    pip install cmigemo
}

function install_dll_cmigemo_win64() {
    curl.exe -L http://files.kaoriya.net/goto/cmigemo_w64 --output cmigemo-default-win64-20110227.zip
    Expand-Archive -Path cmigemo-default-win64-20110227.zip -DestinationPath . -Force

    $copy_src  = "$(getScriptDir)\\cmigemo-default-win64\migemo.dll" # Q:�Ȃ��t���p�X�Ȃ́H A:�����������i�����ꍇ�̓J�����g�f�B���N�g�����ω����t���p�X���K�v�ɂȂ邽��
    $copy_dest = "$(getPythonDir)migemo.dll"
    copy_with_uac $copy_src $copy_dest
}

# �R�s�[���A���s�����猠�����i���ăR�s�[����
function copy_with_uac($copy_src, $copy_dest) {
    $copyCmd = "copy $copy_src $copy_dest"
    $copyCmd_powerShell = $copyCmd + ";`$?"
    $result = Invoke-Expression $copyCmd_powerShell
    if (! $result) {
        "�R�s�[���s���܂����B�������i���ăR�s�[���܂�"
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
