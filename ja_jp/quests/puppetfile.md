{% include '/version.md' %}

# Puppetfile

## クエストの目的

- Puppetfileを作成し、外部モジュールの依存関係を管理する。
- `puppet module`ツールを使用して依存関係を計算し、
  どのモジュールをPuppetfileに含める必要があるかの判断に役立てる。

## はじめに

このクエストでは、Puppetfileを使って、コントロールリポジトリに外部モジュールの依存関係を追加します。

準備ができたら、以下のコマンドを入力してください。

    quest begin puppetfile

## Puppetfile

コントロールリポジトリのクエストでは、Puppetモジュールを`control-repo` Gitリポジトリに移動しました。しかし、これまでのところ、このリポジトリに含まれているのは、このガイドの過去のクエストであなたが自分で記述したPuppetコードだけです。Puppetモジュールツールを使ってインストールしたForgeモジュールは含まれていません。

こうした外部モジュールをコントロールリポジトリから除外しているのには、それなりの理由があります。直接追加すると、大量の重複コードが生じることになります。その後、各モジュールについて、手動でバージョン管理と更新を行う必要が生じます。コントロールリポジトリの核心であるサイト固有のコードは、すぐにこの大量の外部ソースのコードに圧倒されてしまいます。

Puppetfileは、外部モジュールの依存関係を効率的に管理するための方法を提供します。1つのファイルを使って、各外部モジュールの任意のバージョンとソースを指定することができます。Puppetのコードマネージャは、コードデプロイプロセスの際に、Puppetfileで指定されたモジュールを環境のモジュールディレクトリにインストールします。

この方法を使えば、Puppetfile内のコードを1行か2行変更するだけで、外部モジュールの追加、削除、更新に対応できます。

<div class = "lvm-task-number"><p>タスク1:</p></div>

Pastureアプリケーションのデータベース支援バージョンは`puppetlabs-postgresql`モジュールに依存しているため、Puppetでこのアプリケーションを管理できるようにするためには、Puppetfileにこのモジュールを含める必要があります。

まず、`~/control-repo`ディレクトリで作業していることを確認します。

    cd ~/control-repo

作業を開始する前に、現在のリポジトリステータスを確認します。

    git status

まだ前クエストのfeatureブランチにいる場合は、`production`ブランチに戻ります。

    git checkout production

`production`ブランチのアップストリームバージョンに、featureブランチで導入した変更を組み込んだことを思い出してください。その変更をフェッチし、`git pull`でローカルの`production`ブランチにマージします。

    git pull upstream production

ローカルのproductionブランチが、アップストリームリモートの productionと同じになりました。これで、新たな作業に使う新しいfeatureブランチを作成できるようになりました。

    git checkout -b puppetfile

<div class = "lvm-task-number"><p>タスク2:</p></div>

エディタで`Puppetfile`という名前の新しいファイルを開きます。

    vim Puppetfile

以下の行を追加し、`puppetlabs-postgresql`モジュールのバージョン4.9.0を含めます。

```ruby
mod "puppetlabs/postgresql", '4.9.0'
```

残念ながら、まだ終わりではありません。`puppet module`ツールとは違い、コードマネージャは、モジュールの依存関係ツリーを自動的に管理してくれません。依存関係を解決したいモジュールが多数ある場合は、[puppet-generate-puppetfile](https://github.com/rnelson0/puppet-generate-puppetfile)や[librarian-puppet](https://github.com/voxpupuli/librarian-puppet)などのいくつかのサードパーティ製ツールが役に立ちます。

<div class = "lvm-task-number"><p>タスク3:</p></div>

しかし、このケースでは、扱う外部モジュールは1つだけなので、一般的な次善策で対応可能です。`puppet module`ツールを使って任意のバージョンの`puppetlabs/postgresql`モジュールを一時ディレクトリにインストールし、このツールのアウトプットを使って必要な依存関係を決定します。

    mkdir temp  
    puppet module install puppetlabs/postgresql --version 4.9.0 --modulepath=temp  

ツールは以下のような結果を返します。

```
Notice: Preparing to install into /root/control-repo/tmp ...
Notice: Downloading from https://forge.puppet.com ...
Notice: Installing -- do not interrupt ...
/root/control-repo/tmp
└─┬ puppetlabs-postgresql (v4.9.0)
  ├── puppetlabs-apt (v2.4.0)
  ├── puppetlabs-concat (v2.2.1)
  └── puppetlabs-stdlib (v4.20.0)
```

一時ディレクトリを削除し、クリーンアップします。

    rm -rf temp

Puppetfileに戻り、リストに記載されたバージョンを用いて、`puppetlabs-apt`、`puppetlabs-concat`、および`puppetlabs-stdlib`モジュールのエントリを追加します。

完成したPuppetfileは、以下のようになります。

```ruby
mod "puppetlabs/postgresql", '4.9.0'
mod "puppetlabs/apt", '2.4.0'
mod "puppetlabs/concat", '2.2.1'
mod "puppetlabs/stdlib", '4.20.0'
```

<div class = "lvm-task-number"><p>タスク4:</p></div>

新しいPuppetfileがコミットされるように設定します。

    git add Puppetfile

変更をコミットします。

    git commit

以下のようなコミットメッセージを入力します。

```
Puppetfileをpuppetlabs-postgresqlモジュールとともに追加

Pastureモジュールは、アプリケーションのデータベース支援バージョンを
`puppetlabs-postgresql`モジュールに依存しています。このモジュールと
依存関係を含めるためにPuppetfileを追加します。
```

ブランチをアップストリームリモートにプッシュします。

    git push upstream puppetfile

<div class = "lvm-task-number"><p>タスク5:</p></div>

Gitea UI (`<IP ADDRESS>:3000`)から、新しいプルリクエストを作成します。

プルリクエストをレビューしてマージします(実際の本稼働環境では、このレビューおよびマージ手順に関するチームプロセスを構築する必要がある点に留意してください。このプロセスは、コードベースに加えられたすべての変更をレビューおよび承認してから、本稼働環境にマージおよびデプロイするためのものです)。

<div class = "lvm-task-number"><p>タスク6:</p></div>

これで、この変更がコントロールリポジトリに統合されました。次に、`puppet code`ツールを使って、本稼働環境にデプロイします(前回に認証されたトークンの期限が切れている場合は、`puppet access login --lifetime 1d`を使って認証情報`deployer`:`puppet`で新規トークンを生成してください)。

    puppet code deploy production --wait

デプロイが完了したら、インストールされたモジュールのリストをチェックし、適切なモジュールがインストールされていることを確認します。

    puppet module list

Puppetfileに追加したモジュールが、本稼働環境のモジュールパスに含まれているはずです。

```
/etc/puppetlabs/code/environments/production/modules
├── puppetlabs-apt (v2.4.0)
├── puppetlabs-concat (v2.2.1)
├── puppetlabs-postgresql (v4.9.0)
└── puppetlabs-stdlib (v4.20.0)
```

<div class = "lvm-task-number"><p>タスク7:</p></div>

これで、外部のForgeモジュールがPuppetfileに含まれたので、コントロールリポジトリでPastureアプリケーションのデータベースサーバーをサポートできるようになりました。

`puppet job`ツールを使って、`pasture-db.auroch.vm`および`pasture-app.auroch.vm`ノードでPuppet agentを実行します。

    puppet job run --nodes pasture-app.auroch.vm,pasture-db.auroch.vm

ノードを設定したら、少し時間を取って、アプリケーションが接続されたデータベース内の値を保存し、取得できるかどうかをテストします。

    curl -X POST 'pasture-app.auroch.vm/api/v1/cowsay/sayings?message=Hello!'
    curl pasture-app.auroch.vm/api/v1/cowsay/sayings/1

## おさらい

このクエストでは、Puppetfileを使って外部モジュールの依存関係を管理する方法を説明しました。

Puppetfileの基本的な構文規則を学習し、`puppet module tool`を使って`puppetlabs-postgresql`を一時ディレクトリにインストールし、モジュールの依存関係とバージョンのセットを解決しました。

Puppetfileで外部リソースを指定し、プルリクエストを使って、この変更をアップストリームのコントロールリポジトリに追加し、`puppet code deploy`コマンドを使って、このリポジトリをmasterの本稼働環境にデプロイしました。デプロイプロセスの一環として、PuppetのコードマネージャがPuppetfileの構文を解析し、記載された各モジュールを`/etc/puppetlabs/code/environments/production/modules`ディレクトリにインストールしました。

これらのモジュールをインストールしたことで、それに接続するデータベースサーバーとアプリケーションサーバーを設定できるようになりました。

## その他のリソース

Puppetfileの使い方の詳細については、Puppetの[ドキュメントページ](https://puppet.com/docs/pe/latest/code_management/puppetfile.html)で見ることができます。

Puppetfileについては、複数の[インストラクターによるトレーニング](https://learn.puppet.com/course-catalog)で扱っています。

[コントロールリポジトリ](https://github.com/puppetlabs/control-repo)例に含まれるPuppetfileも、自身で作成する際の参考になるかもしれません。
