{% include '/version.md' %}

# Forge

## クエストの目的

- Puppet Forgeへのアクセス方法とモジュールの検索方法を学ぶ。
- クラスパラメータを使って、Forgeモジュールをニーズに合わせて適応させる。
- ラッパークラスを作成し、Forgeモジュールを各自のモジュールに統合する。

## はじめに

このクエストでは、Forgeを紹介します。Forgeは、Puppetコミュニティにより作成とメンテナンスが行われているモジュールのリポジトリです。

準備ができたら、以下のコマンドを入力してください。

    quest begin the_forge

## Forgeとは？

[Puppet Forge](forge.puppet.com)は、Puppetモジュールの公開されたリポジトリです。Forgeから、モジュールのメンテナンスを行うコミュニティにアクセスできます。Forgeにある既存のモジュールを使えば、時間をかけてカスタムモジュールを開発しなくても、さまざまなアプリケーションやシステムを管理することができます。さらに、多くのForgeモジュールは、Puppetコミュニティによりアクティブに使用され、メンテナンスされているため、そのコードは十分に検証・テストされています。1つのモジュールに関わるユーザの数が増えるほど、あなたやチームが担うメンテナンスやテストの負荷が軽くなります。

十分に検証されたコードやアクティブなメンテナンスを重視するユーザのために、ForgeチームがPuppetの標準セットに照らしてForgeのモジュールのリストをチェックし、メンテナンスしています。[Puppet
Approved](https://forge.puppet.com/approved)カテゴリのモジュールは、十分に検証され、品質、信頼性、アクティブな開発が保証されています。[Puppet
Supported](https://forge.puppet.com/supported)リストのモジュールは、Puppet
Enterprise [サポート](https://puppet.com/support-services/customer-support)契約の対象であり、[Puppet Enterpriseリリースライフサイクル](https://puppet.com/misc/puppet-enterprise-lifecycle)にわたり、複数のプラットフォームおよびバージョンに対応したメンテナンスが行われます。

これまでのクエストで、PastureアプリケーションのAPIを使って、吹き出しにメッセージを入れたASCIIアートの牛のキャラクターを設定してみました。このアプリケーションには、まだ紹介していない別の機能があります。データベースにカスタムメッセージを保存し、IDで検索できる機能です。デフォルトでは、PastureはこれらのメッセージをシンプルなSQLiteデータベースを使って保存しますが、外部データベースに接続するように設定することもできます。

このクエストでは、ForgeのPostgreSQLモジュールを使って、Pastureアプリケーションが牛のメッセージを保存して検索するためのデータベースを設定します。

最初のステップは、使用する適切なモジュールを見つけることです。[Forge](forge.puppet.com)ウェブサイトの検索インターフェースを使って、`PostgreSQL`を検索します。

(現在、インターネットにアクセスできいない場合も、このセクションの続きを読み、Forgeに慣れ親しんでおくことをおすすめします。クエストを完了するのに必要なすべてのリソースは、すでにVM上でキャッシュされているので、モジュールをインストールするために外部接続する必要はありません。)

Forgeに、バージョンやリリースデータ情報、ダウンロード、総合判定スコア、サポートまたは承認されたバナーなどの関連情報を含む検索結果がいくつか表示されます。こうした情報を参考に、モジュールをさらに絞り込むことができます。

このクエストでは、`puppetlabs/postgresql`モジュールを使用します。該当するモジュールタイトルをクリックし、詳細情報とドキュメントを表示します。

Pastureアプリケーション用のデータベースを設定するには、データベースサーバを設定し、適切なユーザと権限のあるデータベースインスタンスを設定する必要があります。以下で具体的に説明していきますが、少し時間をとって、モジュールのドキュメントにざっと目を通し、このモジュールを使ってデータベースサーバのあるべき状態を定義する方法が記載されているかどうかを確認してみてください。どのクラスを使うか、そのパラメータをどのように設定するか、わかりましたか？

## インストール

モジュールとは、Puppetマニフェストと、システム上でそのモジュールを使って管理したい要素を管理するのに必要なその他のコードやデータを含むディレクトリ構造である点を思い出してください。Puppet masterは*モジュールパス*ディレクトリでモジュールを探し、モジュールディレクトリ構造を使って、クラス、ファイル、テンプレートなどモジュールによって提供されるものを見つけます。

モジュールをインストールすると、そのモジュールディレクトリがPuppet masterのモジュールパスに置かれます。モジュールをダウンロードして手動でモジュールパスに移動させることもできますが、Puppetには、モジュールの管理に役立つツールがあります。

`postgresql`モジュールの上のほうに、 Puppetfileと`puppet module` という2種類のインストール方法があること気付いた方もいるかもしれません。このクエストでは、よりシンプルな`puppet module`ツールを使います(ただし、管理するPuppet環境が複雑になり、Puppetコードを管理リポジトリに入れるようになったら、Puppetfileを使うことをおすすめします。Puppetfileとコード管理ワークフローについては、[こちら](https://docs.puppet.com/pe/latest/cmgmt_managing_code.html)を参照してください)。

<div class = "lvm-task-number"><p>タスク1:</p></div>

master上で、`puppet module`ツールを使ってモジュールをインストールします。

    puppet module install puppetlabs-postgresql --version 4.8.0

このコマンドにより、モジュールパスにモジュールが配置されたことを確認するために、モジュールディレクトリのコンテンツを見てみます。

    ls /etc/puppetlabs/code/environments/production/modules

Forge上ではこのモジュールは`puppetlabs/postgresql`と記載されていましたが、インストールすると`puppetlabs-postgresql`という名前になる点に注意してください。ただし、インストールされる実際のディレクトリは`postgresql`です。`puppetlabs`は、このモジュールをForgeにアップロードしたForgeユーザアカウント名です。これにより、Forgeをブラウズしたりインストールしたりする際に、異なるモジュールのバージョンを見分けることができます。モジュールのインストール時には、このアカウント名はモジュールディレクトリ名には含まれません。この点に気付いていないと、ちょっとした混乱が生じることがあります。名前が同じモジュールを同じmaster上に複数インストールしようとすると、競合が生じます。

master上のすべてのモジュールパスにインストールされたモジュールの完全なリストを見るには、`puppet module`ツールの`list`サブコマンドを使用します。

    puppet module list

## ラッパークラスの記述

既存の`postgresql`モジュールを使えば、PostgreSQLサーバとデータベースインスタンスの管理に必要なPuppetコードを再度開発しなくても、Pastureモジュールにデータベースコンポーネントを追加することができます。ここでは、*ラッパークラス*と呼ばれるものを作成し、Pastureアプリケーションに必要なパラメータを用いて、`postgresql`モジュールからクラスを宣言します。

<div class = "lvm-task-number"><p>タスク2:</p></div>

このラッパークラスを`pasture::db`と呼び、`pasture`モジュールの`manifests`ディレクトリにある`db.pp`マニフェスト内で定義します。

    vim pasture/manifests/db.pp

この`pasture::db`クラス内で、`postgresql`モジュールの提供するクラスを用いて、牛の言葉を追跡する`pasture`データベースを設定します。

```puppet
class pasture::db {

  class { 'postgresql::server':
    listen_addresses => '*',
  }

  postgresql::server::db { 'pasture':
    user     => 'pasture',
    password => postgresql_password('pasture', 'm00m00'),
  }

  postgresql::server::pg_hba_rule { 'allow pasture app access':
    type        => 'host',
    database    => 'pasture',
    user        => 'pasture',
    address     => '172.18.0.2/24',
    auth_method => 'password',
  }

}
```

このラッパークラスができたら、このクラスの定義するデータベースサーバを、`site.pp`マニフェストのノード定義に簡単に追加することができます。このクラスでは、できるだけシンプルになるようにパラメータのないクラスを作成しました。必要に応じて、このラッパークラスにパラメータを追加し、ラッパークラスに含まれるpostgresqlクラスに値を渡すこともできます。

<div class = "lvm-task-number"><p>タスク3:</p></div>

次に、`site.pp`マニフェストを開きます。

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

ノード定義を作成し、`pasture::db`クラスにより`pasture-db.puppet.vm`ノードを分類します。

```puppet
node 'pasture-db.puppet.vm' {
  include pasture::db
}
```

`puppet job`ツールを使って、この`pasture-db.puppet.vm`ノードでPuppet agent実行を開始します。

    puppet job run --nodes pasture-db.puppet.vm

このデータベースサーバが設定されたので、メインのPastureクラスにパラメータを追加し、データベースURIを指定し、これを設定ファイルに渡します。

<div class = "lvm-task-number"><p>タスク4:</p></div>

モジュールの`init.pp`マニフェストを開きます。

    vim pasture/manifests/init.pp

デフォルト値を`undef`として、`$db`パラメータを追加します。このテンプレート内で条件とともにこの`undef`を使えば、"何かが設定されている場合のみこのパラメータを管理する"と伝えることができます。次に、この変数を `$pasture_config_hash`に追加し、テンプレートに渡されるようにします。この2つを追加すると、クラスは以下の例のようになるはずです。

```puppet
class pasture (
  $port                = '80',
  $default_character   = 'sheep',
  $default_message     = '',
  $pasture_config_file = '/etc/pasture_config.yaml',
  $sinatra_server      = 'webrick',
  $db                  = undef,
){

  package { 'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }

  $pasture_config_hash = {
    'port'              => $port,
    'default_character' => $default_character,
    'default_message'   => $default_message,
    'sinatra_server'    => $sinatra_server,
    'db'                => $db,
  }

  file { $pasture_config_file:
    content => epp('pasture/pasture_config.yaml.epp', $pasture_config_hash),
    notify  => Service['pasture'],
  }

  $pasture_service_hash = {
    'pasture_config_file' => $pasture_config_file,
  }

  file { '/etc/systemd/system/pasture.service':
    content => epp('pasture/pasture.service.epp', $pasture_service_hash),
    notify  => Service['pasture'],
  }

  service { 'pasture':
    ensure    => running,
  }

  if $sinatra_server == 'thin' or 'mongrel'  {
    package { $sinatra_server:
      provider => 'gem',
      notify   => Service['pasture'],
    }
  }

}
```

<div class = "lvm-task-number"><p>タスク5:</p></div>

次に、`pasture_config.yaml.epp`テンプレートを編集します。条件文を用いて、`$db`変数に値が設定されている場合のみ、`:db:`設定が含まれるようにします。これにより、このオプションを設定しないまま残し、`pasture`クラスの`db`パラメータが明示的に設定されていない場合はPastureアプリケーションのデフォルトを使うようにすることができます。

```puppet
<%- | $port,
      $default_character,
      $default_message,
      $sinatra_server,
      $db,
| -%>
# This file is managed by Puppet. Please do not make manual changes.
---
:default_character: <%= $default_character %>
:default_message: <%= $default_message %>
<%- if $db { -%>
:db: <%= $db %>
<%- } -%>
:sinatra_settings:
  :port:   <%= $port %>
  :server: <%= $sinatra_server %>
```

この`db`パラメータを設定したら、 `pasture-app.puppet.vm`ノード定義を編集します。

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

`pasture`クラスを宣言し、`db`パラメータを、 `pasture-db.puppet.vm`で実行している`pasture`データベースのURIに設定します。

```puppet
node 'pasture-app.puppet.vm' {
  class { 'pasture':
    sinatra_server => 'thin',
    db             => 'postgres://pasture:m00m00@pasture-db.puppet.vm/pasture',
  }
}
```

<div class = "lvm-task-number"><p>タスク6:</p></div>

`puppet job`ツールを使って、このノードでagentを実行します。

    puppet job run --nodes pasture-app.puppet.vm

データベースサーバと、接続するアプリケーションサーバを設定したら、アプリケーションのデータベースにことわざを追加し、IDで検索することができます。試してみましょう。

まず、メッセージ'Hello!'をデータベースに追加します。

    curl -X POST 'pasture-app.puppet.vm/api/v1/cowsay/sayings?message=Hello!'

ここで、使用可能なメッセージのリストを見てみましょう。

    curl 'pasture-app.puppet.vm/api/v1/cowsay/sayings'

最後に、IDでメッセージを検索します。

    curl 'pasture-app.puppet.vm/api/v1/cowsay/sayings/1'

## おさらい

このクエストでは、Forgeのモジュールを自分のモジュールに組み込み、データベースを管理する方法を学びました。まず、Forgeサイトについて知り、自分のプロジェクトに役立つモジュールを見つけるための検索機能を試しました。

適切なモジュールを見つけ、`puppet module`ツールを使って`modules`ディレクトリにインストールしました。モジュールをインストールした後、`pasture::db`クラスを作成し、Pastureアプリケーションに必要とされる具体的なデータベース機能を定義しました。さらに、メインの `pasture`クラスを更新し、データベースへの接続に必要なURIを定義しました。

この新しい`pasture::db`クラスを設定し、`db`パラメータをメインのpastureクラスに追加しておけば、`site.pp`分類に若干の変更を加えるだけで、データベースサーバを作成し、アプリケーションサーバに接続できるようになります。
