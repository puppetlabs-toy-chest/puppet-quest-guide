{% include '/version.md' %}

# 条件文

## クエストの目的
 - 柔軟なPuppetコードを記述する場合の条件文の役割を学ぶ。
 - `if`文の構文を学ぶ。
 - `if`文を使って、パッケージ依存関係をインテリジェントに管理する。

## はじめに

このクエストでは、**条件文**について説明します。条件文を使えば、さまざまな文脈でそれぞれ異なる挙動をするPuppetコードを記述することができます。

このクエストを開始するには、以下のコマンドを入力します。

    quest begin conditional_statements

## 柔軟な記述

>風にしなる緑の草は、嵐で折れる立派な樫の木よりも
>強い。

> -孔子

Puppetは、さまざま役割を担う多様なシステムの設定を管理します。そのため、優れたPuppetコードとは、柔軟性が高く移植可能なPuppetコードを意味します。Puppetの*タイプ*と*プロバイダ*は、さまざまなシステム上のPuppetのリソース構文とネイティブツールの間で変換できますが、Puppetモジュールの開発者が答えを出さなければならない疑問も数多くあります。

大原則として、**どのように**という疑問にはリソース抽象化レイヤーで答え、**何を**という疑問にはPuppetコードそのもので答えると覚えておくとよいでしょう。

例として、`puppetlabs-apache`モジュールを見てみましょう。このモジュールの開発者は、Apacheパッケージのインストール方法(`yum`、`apt-get`、または別のパッケージマネージャで処理するかどうか)をPuppetのプロバイダに委ねていますが、Puppetには、インストールが必要なパッケージの名前を自動的に決定する方法はありません。このモジュールを使用してRedHatかDebianシステムのどちらでApacheを管理するかに応じて、`httpd`または`apache2`パッケージのどちらかを管理する必要があります。

多くの場合、このような**何を**という疑問には、条件文とfactまたはパラメータを組み合わせて対応します。 [Forge](forge.puppet.com)の`puppetlabs-apache`モジュールを見れば、[このパッケージの名前やその他の多数の変数](https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/params.pp#L59)が、`osfamily` factを用いて`if`文をもとに設定されていることがわかります(このモジュールでは、下位互換性を確保するために、このfactに非構造化`$::osfamily`フォーマットを用いていることにお気づきかもしれません。このリファレンス形式の詳細については、[ドキュメントページ](https://docs.puppet.com/puppet/latest/lang_facts_and_builtin_vars.html#classic-factname-facts)を参照してください)。

単純化してこのクエストに関係する値のみを示すと、条件文は次のようになります。

```puppet
if $::osfamily == 'RedHat' {
  ...
  $apache_name = 'httpd'
  ...
} elsif $::osfamily == 'Debian' {
  ...
  $apache_name = 'apache2'
  ...
}
```

ここでは、`$apache_name`変数が、`$::osfamily` factの値に応じて`httpd`か`apache2`のいずれかに設定されます。モジュールの別の場所では、この`$apache_name`変数を使って`name`パラメータを設定する[パッケージリソース](https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/package.pp#L32)が見られるはずです。

```puppet
package { 'httpd':
  ensure => $ensure,
  name   => $::apache::apache_name,
  notify => Class['Apache::Service'],
}
```

ここでは`name`パラメータを明示的に設定しているため、リソース*タイトル* (`httpd`)は、リソースの内部識別子としてのみ機能する点に留意してください。インストールされるパッケージの名前を実際に決定するわけではありません。

## 条件

> ちょっと寄っただけ(私の条件がどんな条件だったか確かめるために)

> -ミッキー・ニューベリー

この実際の例を通じて、条件文を使って柔軟性の高いPuppetコードを作成する方法とその理由を確認したところで、少し時間をとって、これらの条件文の機能と記述方法を説明しましょう。

条件文は、指定された変数の値に応じて、さまざまな値を返したり、さまざまなコードブロックを実行したりします。

Puppetでは、条件付きロジックの実装に関して、いくつかの方法をサポートしています。
 
 * `if`文
 * `unless`文
 * ケース文
 * セレクタ

Puppetで利用できるさまざまな条件文の基礎となるコンセプトは、いずれも同じです。そのため、このクエストのタスクでは`if`文のみを扱います。`if`文の使い方を十分に理解した上で、ほかの形式や役に立つケースについても自習してください。

`if`文は、1つの条件とそれに続くPuppetコードブロックを含み、その条件が**true(満たされる)**と評価された場合に**限って**実行されます。オプションとして、`if`文に任意の数の `elsif`節と`else`節を含めることもできます。

- `if`条件が満たされない場合は、Puppetは`elsif`条件(存在する
  場合)に進みます。
- `if`条件と`elsif`条件がどちらも満たされない場合、Puppetは 
  `else`節(存在する場合)のコードを実行します。
- すべての条件が満たされず、かつ`else`ブロックが存在しない場合、Puppetは
  何もせずに先に進みます。

## サーバの選択

Pastureモジュールの例に戻りましょう。このアプリケーションは、[Sinatra](http://www.sinatrarb.com/)フレームワーク上に構築されています。Sinatraはもともと、サービスを実行するサーバについて、WEBrick、Thin、Mongrelといったオプションをサポートしています。プロダクション環境でSinatraを使う場合は[Passenger](https://www.phusionpassenger.com/)や[Unicorn](http://bogomips.org/unicorn/)のようなより堅牢なオプションと併用することが考えられますが、このレッスンではこれらのビルトインオプションで十分です。

Pastureアプリケーションの設定ファイルで使用するサーバは、簡単に選択できます。しかし、デフォルトのWEBrick以外のオプションは、Pastureパッケージのインストール時には必須要件に含まれていません。そうした他のオプションを使うには、モジュールでそれらを個別の`package`リソースとして管理する必要があります。しかし、使う予定がない場合は、そのような余分なパッケージはインストールしたくありません。ここでは、上述の`if`文を使って、必要なThinまたはMongrelパッケージリソースを、これらのサーバが選択された場合に限って管理するように`pasture`クラスを設定します。

Sinatraで使用するサーバをクラスパラメータを使って指定すると、同じ値を設定ファイルテンプレートに渡し、どの追加パッケージをインストールするか決めることができます。パラメータをこのように使うことで、モジュールの管理するシステムコンポーネント全体にわたり、設定を調和させることができます。

<div class = "lvm-task-number"><p>タスク1:</p></div>

モジュールの`init.pp`マニフェストを開きます。

    vim pasture/manifests/init.pp

まず、`$sinatra_server`パラメータをデフォルト値`webrick`で追加します。クラスの冒頭は、以下の例のようになるはずです。

```puppet
class pasture (
  $port              = '80',
  $default_character = 'sheep',
  $default_message   = '',
  $config_file       = '/etc/pasture_config.yaml',
  $sinatra_server    = 'webrick',
){
```

次に、`$sinatra_server`変数を`$pasture_config_hash`に追加し、設定ファイルテンプレートに受け渡せるようにします。

```puppet
  $pasture_config_hash = {
    'port'              => $port,
    'default_character' => $default_character,
    'default_message'   => $default_message,
    'sinatra_server'    => $sinatra_server,
  }
```

<div class = "lvm-task-number"><p>タスク2:</p></div>

ここまで完了したら、`pasture_config.yaml.epp`テンプレートを開きます。

    vim pasture/templates/pasture_config.yaml.epp

`$sinatra_server`変数をテンプレート冒頭のparamsブロックに追加します。Pastureアプリケーションは、`:sinatra_settings:`キーの下にあるすべての設定をSinatraに渡します。

```yaml
<%- | $port,
      $default_character,
      $default_message,
      $sinatra_server,
| -%>
# This file is managed by Puppet. Please do not make manual changes.
---
:default_character: <%= $default_character %>
:default_message:   <%= $default_message %>
:sinatra_settings:
  :port:   <%= $port %>
  :server: <%= $sinatra_server %>
```

これで設定をモジュールで管理できるようになりました。ここで、ThinおよびMongrel Webサーバに必要なパッケージを管理するための条件文を追加します。

<div class = "lvm-task-number"><p>タスク3:</p></div>

`init.pp`マニフェストに戻ります。

    vim pasture/manifests/init.pp

パッケージリソースを`if`文でラッピングし、`$sinatra_server`変数が`thin`または`mongrel`の場合のみリソースを管理するようクラスに指示することができます。

どちらのサーバもgemとして使用できるので、このパッケージには`gem`プロバイダを使用します。

最後に、サービスリソースを示す`notify`パラメータを追加します。このようにすると、サーバパッケージがサービスの前に管理されるため、パッケージがアップデートされた場合にサービスを再起動させることができます。クラスは以下の例のようになります。サーバパッケージを管理するための条件文は、一番下に含まれています。 

```puppet
class pasture (
  $port                = '80',
  $default_character   = 'sheep',
  $default_message     = '',
  $pasture_config_file = '/etc/pasture_config.yaml',
  $sinatra_server      = 'webrick',
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

これらの変更をクラスに加えれば、インフラストラクチャ内の異なるagentノードについて、異なるサーバを簡単に割り当てることができます。例えば、デプロイシステムではデフォルトのWEBrickサーバを使い、プロダクションでは Thinサーバを使うことが可能です。

このクエストでは、`pasture-dev.puppet.vm`と`pasture-prod.puppet,vm`という2つの新しいシステムを作成しました。さらに複雑なインフラストラクチャの場合は、インフラストラクチャの開発、テスト、プロダクションといった各区分について、それぞれ個別の[環境](https://docs.puppet.com/puppet/latest/environments.html)を作成して管理するケースがあるかもしれません。しかし、とりあえずは、`site.pp`マニフェスト内で2種類のノード定義を設定すれば、条件文の実例を簡単に示すことができます。

<div class = "lvm-task-number"><p>タスク4:</p></div>

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

```puppet
node 'pasture-dev.puppet.vm' {
  include pasture
}
node 'pasture-prod.puppet.vm' {
  class { 'pasture':
    sinatra_server => 'thin',
  }
}
```

## Puppetジョブツール

複数のノードを扱っていると、SSHによって手動で接続してPuppetを実行する作業は、やや面倒に思えるかもしれません。`puppet job`ツールを使えば、リモート操作によって複数のノードでPuppetを実行することができます。

<div class = "lvm-task-number"><p>タスク5:</p></div>

このツールを使う前に、PEコンソールでいくつかの手順を行い、PEのロールベースアクセス制御(RBAC)システムを通じて認証を設定します。

コンソールにログインするには、Learning VMで使用中のホストシステムでWebブラウザを開き、`https://<VM's IPADDRESS>`にアクセスします(`https`を使うとコンソールへ、`http`を使うとこのクエストガイドに移動します)。

PEコンソールが自己署名証明書を使用していることを告げる警告が、ブラウザに表示されるかもしれません。この警告を無視し、PEコンソールのログインページに進んでも問題ありません(必要な場合は、**[advanced]**オプションをクリックして先に進んでください)。

以下の認証情報を使ってログインします。

ユーザ名: **admin**
パスワード: **puppetlabs**

接続したら、画面の左下にあるナビゲーションバーの**[access control]**メニューオプションをクリックし、*[Access Control]*ナビゲーションメニューの**[Users]**を選択します。

**[Full name]**に`Learning`、**[Login]**に `learning`と入力して新規ユーザを作成します。

新規ユーザの名前をクリックし、**[Generate password reset]**リンクをクリックします。与えられたリンクを新しいブラウザタブにコピーし、パスワードを**puppet**に設定します。

**[Access Control]**ナビゲーションバーの**[User Roles]**メニューオプションをクリックし、**[Operators]**ロールのリンクをクリックします。ドロップダウンメニューから**[Learning]**ユーザを選択し、**[Add user]**ボタンをクリックしたら、最後にコンソール画面右下の**[Commit 1 change]**ボタンをクリックします。

このユーザ設定で`puppet access`コマンドを使って、`puppet job`ツールの使用を許可するトークンを生成することができます。このトークンの有効期限は1日に設定されているので、作業中に再認証が発生する心配はありません。

    puppet access login --lifetime 1d

ダイアログが表示されたら、ユーザ名**learning**とパスワード**puppet**を入力します。

これで、`puppet job`ツールを使って`pasture-dev.puppet.vm`と`pasture-prod.puppet.vm`でPuppet実行を開始できるようになりました。この2つのノードの名前は、`--nodes`フラグのあとのカンマ区切りリストで提供されています(ノードネームの間にスペースがない点に注意してください。このため、ノード名を区切るカンマとノード名そのものに含まれるドットが見分けにくいかもしれません)。

    puppet job run --nodes pasture-dev.puppet.vm,pasture-prod.puppet.vm

ジョブが完了したら、`curl`コマンドでそれぞれのジョブをチェックします。

    curl 'pasture-dev.puppet.vm/api/v1/cowsay?message=Hello!'

および

    curl 'pasture-prod.puppet.vm/api/v1/cowsay?message=Hello!'

各システムで指定したサーバが使用されていることを確認するには、ログイン後に`journalctl`コマンドを使ってサービスのスタートアップログをチェックします。

    ssh learning@pasture-dev.puppet.vm

実行します。

    journalctl -u pasture

`pasture-dev`との接続を終えます。

    exit

次のシステムに接続します。

    ssh learning@pasture-prod.puppet.vm

ここでもログをチェックします。

    journalctl -u pasture

各ノードでサーバが意図したとおり使用されていることを確認したら、接続を終了してLearning VMに戻ります。

    exit

## おさらい

このクエストでは、条件文を使って、Puppetモジュールのコードをさまざまな条件に対応させることを学びました。`puppetlabs-apache`モジュールで条件文を使って、ノードのオペレーティングシステムに応じて異なるパッケージをインストールする実例を見てきました。また、`if`文の構文について学んだ後で、条件文を`pasture`モジュールに組み込み、Sinatraフレームワークで利用可能な各種のサーバオプションについて、パッケージ依存関係を管理するのに利用しました。

これまでに使用した、`pasture`および`motd`モジュールはすべて一から記述しました。学習のためにはとてもよいことですが、PuppetにはPuppetコミュニティとPuppet Forgeという強みがあります。これは、あらかじめ記述されたモジュールのリポジトリで、ユーザがPuppetコードベースに簡単に組み込めるように用意されています。次のクエストでは、既存のモジュールを活用して、Pastureアプリケーションのデータベースバックエンドを設定する方法を見ていきます。
