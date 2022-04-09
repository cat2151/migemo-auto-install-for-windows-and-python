# migemo-auto-install-for-windows-and-python

[C/Migemo](https://www.kaoriya.net/software/cmigemo/) と [python-cmigemo](https://github.com/mooz/python-cmigemo) を、Windows + Pythonですぐ使えるよう自動インストールします。

# Features
- 以下を自動化します :
  - migemoがインストール済みかをチェックする（インストール済みなら処理を終了する）
    - インストール済みとは :
      - C/Migemo の64bit Windows 用DLLが、PATHの通った場所に存在すること
      - PATHの通ったPythonに、python-cmigemo がインストール済みであること
      - カレントディレクトリ配下に dict/migemo-dict 等がインストール済みであること
      - つまり、test_cmigemo.py （当batが生成します）が正常終了すること
  - うっかりpipを破壊してしまった状態であればpipを応急で修復する（get-pipする）
  - python-cmigemo をインストールする
  - C/Migemo をダウンロードする
  - C/Migemo の64bit Windows 用DLLを、Pythonのexeのあるディレクトリ（PATHで最初に見つけたもの）にコピーする
    - 書き込み権限がなくコピー失敗した場合、自動で権限昇格してコピーする
  - テスト用Pythonスクリプトを生成する
  - テスト用Pythonスクリプトを実行し、結果を出力する
    - （`migemo install SUCCESS`と出力されれば成功）
  - 上記すべてのログを出力する

- コマンドプロンプトからこのコマンドを実行するだけで自動ですべてが完了します。面倒な操作は不要です。
```
curl.exe -L https://raw.githubusercontent.com/cat2151/migemo-auto-install-for-windows-and-python/main/install_python_cmigemo.bat --output install_python_cmigemo.bat && install_python_cmigemo.bat
```

# Requirement
- Windows + Python （いずれも64bitであること）
- 17MB程度の空き容量
- （場合により）権限昇格のダイアログ操作
- batを実行する場所のフルパス名に半角スペースや日本語を含まないこと

# Usage
- 前述のコマンドを実行します。
- ログを確認します。
  - `migemo install SUCCESS` または `already installed` と出力されれば成功です
- （migemoをPythonから使うプログラムを配布したい。migemoもインストールしてもらいたい。何かいい手はないかなあ…）と思ったら、どうぞご利用ください。
