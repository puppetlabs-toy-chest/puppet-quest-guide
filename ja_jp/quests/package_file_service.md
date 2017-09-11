{% include '/version.md' %}

# パッケージファイルサービス

## クエストの目的

- `package`、`file`、`service`リソースを一緒に使って、 
  アプリケーションを管理する方法を学ぶ。
- リソース順序付けメタパラメータを用いて、リソース間の依存関係を定義する。

## はじめに

準備ができたら、以下のコマンドを入力してください。

    quest begin package_file_service

## パッケージ、ファイル、サービスパターン

前回のクエストでは、`cowsay`および`fortune-mod`パッケージを管理するシンプルなモジュールを作成しました。しかし、Puppetでは多くの場合、管理対象のシステムをあるべき状態にするために、複数の関連するリソースタイプの管理が必要になります。ここでは、連携して使用されることの多い`package`、`file`、`service`というリソースタイプを、"パッケージ、ファイル、サービス"パターンとして、まとめて説明します。パッケージリソースは、ソフトウェアパッケージそのものを管理します。ファイルリソースは、関連する設定ファイルのカスタマイズを可能にします。サービスリソースは、インストールおよび設定したソフトウェアの提供するサービスを開始します。

このクエストや以後のクエストでは、例としてPastureと呼ばれるシンプルなRubyアプリケーションを使用します。PastureはRESTful APIでcowsayの機能を提供し、HTTPで牛を使用できるようにするものです。これは、cowsay as a service (CaaS)と呼べるかもしれません(ソースコードは[こちら](https://github.com/puppetlabs/pltraining-pasture)で見つかります)。Pastureアプリケーションは変わっていますがとてもシンプルなので、遠回りをして複雑なアプリケーションの機能や注意点を説明することなく、Puppetそのものに焦点を絞ることができます。

cowsayコマンドラインツールと同様に、`package`リソースと`gem`プロバイダを使ってPastureをインストールします。

次に、Pastureは設定ファイルを読みとるため、`file`リソースを使って設定を管理します。

最後に、cowsayコマンドラインツールのように一度だけの実行ではなく、Pastureを持続的なバックグラウンドプロセスとして実行したいと思います。 そのためには届いたリクエストを受理し、必要に応じて牛を提供する必要があります。これを設定するため、まずサービスを定義する`file`リソースを作成してから、`service`リソースを使って確実に実行できるようにする必要があります。

## パッケージ

<div class = "lvm-task-number"><p>タスク1:</p></div>

始める前に、現在Puppet masterの`modules`ディレクトリにいることを確認します。

    cd /etc/puppetlabs/code/environments/production/modules

`pasture`モジュールのための新規ディレクトリ構造を作成します。今回は、モジュールに`manifests`と`files`という2つのサブディレクトリを含めます。

    mkdir -p pasture/{manifests,files}

<div class = "lvm-task-number"><p>タスク2:</p></div>

新しい`init.pp`マニフェストを開き、メインの`pasture`クラスの定義を始めます。

    vim pasture/manifests/init.pp

ここまでは、`cowsay`クラスのときとあまり変わりません。ただし、今回はパッケージリソースで `cowsay`ではなく`pasture`パッケージを管理します。

```puppet
class pasture {
  package { 'pasture':
    ensure   => present,
    provider => gem,
  }
}
```

`puppet parser`ツールを使って構文を検証し、必要に応じて修正します。

    puppet parser validate pasture/manifests/init.pp

<div class = "lvm-task-number"><p>タスク3:</p></div>

続ける前に、このクラスを割り当て、ファイルリソースがどのようになったか見てみましょう。

`site.pp`マニフェストを開きます。

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

このクエストのために設定した`pasture.puppet.vm`ノードの新規ノード定義を作成します。記述したばかりの`pasture`クラスを含めます。

```puppet
node 'pasture.puppet.vm' {
  include pasture
}
```
<div class = "lvm-task-number"><p>タスク4:</p></div>

`pasture.puppet.vm`ノードに接続します。

    ssh learning@pasture.puppet.vm 

Puppet agent実行を開始します。

    sudo puppet agent -t

<div class = "lvm-task-number"><p>タスク5:</p></div>

`pasture` gemがインストールされていれば、`pasture start`コマンドを使うことができます。まだこのプロセスを管理するようにサービスを設定していませんが、コマンドの後に引数(`&`)を追加すれば、バックグラウンドで開始できます。

    pasture start &

<div class = "lvm-task-number"><p>タスク6:</p></div>

`curl`コマンドを使ってPasture APIをテストします。このリクエストには2つのパラメータがあります。`string`は返されるメッセージを定義し、`character`にはメッセージを言わせるキャラクターを設定します。デフォルトでは、このプロセスはポート4567でリッスンします。以下のコマンドを試してみてください。

    curl 'localhost:4567/api/v1/cowsay?message=Hello!'

デフォルトでは、牛のキャラクターがメッセージを話します。パラメータを変えてみましょう。

    curl 'localhost:4567/api/v1/cowsay?message=Hello!&character=elephant'

<div class = "lvm-task-number"><p>タスク7:</p></div>

ほかのパラメータでも自由に試してみてください。終わったらプロセスをフォアグラウンドにします。

    fg

`CTRL-C`を使ってプロセスを終了し、agentノードとの接続を解除します。

    exit

## ファイル

多くの場合、Puppetでインストールするパッケージにはその挙動をカスタマイズするための設定ファイルが含まれています。Pasture gemは、シンプルな設定ファイルを使用するように記述されています。基本的なコンセプトを理解すれば、より複雑な設定にも簡単に拡張することができるはずです。

すでに、`pasture`モジュールディレクトリ内に`files`ディレクトリを作成しています。モジュールの`manifests`ディレクトリ内にマニフェストを配置すると、マニフェストの定義するクラスをPuppetが見つけられるようになりますが、同様にモジュールの`files`ディレクトリ内にファイルを配置すると、Puppetがファイルを利用できるようになります。

<div class = "lvm-task-number"><p>タスク8:</p></div>

モジュールの`files`ディレクトリに`pasture_config.yaml`ファイルを作成します。

    vim pasture/files/pasture_config.yaml

以下の行を追加して、デフォルトのキャラクターを`elephant`に設定します。

```yaml
---
:default_character: elephant
```

このソースファイルをモジュールの`files`ディレクトリに保存すれば、これを使って `file`リソースの内容を定義することができます。

`file`リソースは`source`パラメータをとります。このパラメータにより、管理対象のファイルの内容を定義するソースファイルを指定できます。 このパラメータは、値としてURIをとります。他のロケーションを指定することも可能ですが、通常はこれを使ってモジュールの`files`ディレクトリを指定します。Puppetでは、`puppet:`という接頭辞で始まる短縮化されたURIフォーマットを用いて、Puppet masterのモジュールファイルを指定します。このフォーマットは、`puppet:///modules/<MODULE NAME>/<FILE PATH>`というパターンに従います。`puppet:`のすぐ後に続く3つのスラッシュに注目してください。これは、Puppet master上のモジュールの暗黙パスの代わりです。

このURI構文は複雑に見えるかもしれませんが、心配ありません。モジュール内のファイルを指定するとき以外に、この構文を使用することはめったにありません。ですから上述のパターンさえ覚えておけば大丈夫でしょう。忘れてしまったら、いつでも[ドキュメント](https://docs.puppet.com/puppet/latest/reference/types/file.html#file-attribute-source)を参照すれば思い出すことができます。

<div class = "lvm-task-number"><p>タスク9:</p></div>

`init.pp`マニフェストに戻ります。

    vim pasture/manifests/init.pp

ファイルリソース宣言を追加します。

```puppet
class pasture {

  package {'pasture':
    ensure   => present,
    provider => 'gem',
  }

  file { '/etc/pasture_config.yaml':
    source => 'puppet:///modules/pasture/pasture_config.yaml',
  }
}
```

`puppet parser`ツールで構文をチェックします。

    puppet parser validate pasture/manifests/init.pp

## サービス

前回のクエストでインストールしたcowsayコマンドは、1回だけの実行で終了するものですが、Pastureはサービスとして実行されることを意図しています。Pastureプロセスはバックグラウンドで実行され、指定されたポートに来るリクエストに対応します。 ここでは、agentノードはCentOS 7を使用しているため、[systemd](https://www.freedesktop.org/wiki/Software/systemd/)サービスマネージャを使ってPastureプロセスを処理します。一部のパッケージでは、それぞれのサービスユニットファイルが設定されることもありますが、Pastureはそうではありません。`file`リソースを使えば、簡単に独自のファイルを設定できます。このサービスユニットファイルにより、いつ、どのようにしてPastureアプリケーションを起動するかをsystemdに伝えます。

<div class = "lvm-task-number"><p>タスク10:</p></div>

まず、`pasture.service`という名前のファイルを作成します。

    vim pasture/files/pasture.service

以下の内容を含めます。

```
[Unit]
Description=Run the pasture service

[Service]
Environment=RACK_ENV=production
ExecStart=/usr/local/bin/pasture start

[Install]
WantedBy=multi-user.target
```

systemdユニットファイルのフォーマットに慣れていない方も、ここでは細かい点を気にする必要はありません。Puppetの利点は、この例で学ぶ基本原理を、今後扱うどのようなシステムにも簡単に移植できる点にあります。 

<div class = "lvm-task-number"><p>タスク11:</p></div>

もう一度`init.pp`マニフェストを開きます。

    vim pasture/manifests/init.pp

まず、サービスユニットファイルを管理するファイルリソースを追加します。

```puppet
class pasture {

  package {'pasture':
    ensure   => present,
    provider => 'gem',
  }

  file { '/etc/pasture_config.yaml':
    source => 'puppet:///modules/pasture/pasture_config.yaml',
  }

  file { '/etc/systemd/system/pasture.service':
    source => 'puppet:///modules/pasture/pasture.service',
  }

}
```

次に、`service`リソースそのものを追加します。このリソースには、`pasture`というタイトルと、サービス状態を `running`に設定する単一パラメータがあります。

```puppet
class pasture {

  package {'pasture':
    ensure   => present,
    provider => 'gem',
  }

  file { '/etc/pasture_config.yaml':
    source => 'puppet:///modules/pasture/pasture_config.yaml',
  }

  file { '/etc/systemd/system/pasture.service':
    source => 'puppet:///modules/pasture/pasture.service',
  }

  service { 'pasture':
    ensure => running,
  }

}
```

## リソースの順序付け

クラスを完成させるには、あと1つ手順があります。このクラスで定義したリソースを、適切な順序で管理する必要があります。"パッケージ、ファイル、サービス"パターンは、これらのリソースに共通する依存関係を記述するものです。 ここで意図しているのは、パッケージをインストールし、設定ファイルを記述し、サービスを開始することですが、この順序で行う必要があります。さらに、後から設定ファイルに変更を加えた場合には、Puppetがサービスを再起動し、この変更が適用されるようにしておく必要もあります。

Puppetコードは、デフォルトではマニフェストで記述した順序に従ってリソースを管理しますが、[関係性メタパラメータ](https://docs.puppet.com/puppet/latest/lang_relationships.html#syntax-relationship-metaparameters)を通じて、リソースの依存関係を明示することを強く推奨します。メタパラメータは、リソースのあるべき状態を直接定義するのではなく、Puppetが*どのように*リソースを処理するかに影響を与えるパラメータです。関係性メタパラメータは、リソースの順序関係をPuppetに伝えます。

この例のクラスでは、`before`と`notify`という2つの関係性メタパラメータを使います。`before`は、現在のリソースがターゲットリソースの前に来なければならないことをPuppetに伝えます。`notify`メタパラメータは、`before`と同様のものですが、ターゲットリソースがサービスの場合、メタパラメータセットによりPuppetがそのリソースに修正を加えた際に必ずサービスを再起動するという追加の機能があります。これは、Puppetにサービスを再起動させ、設定ファイルの変更を適用する必要がある場合に役立ちます。

関係性メタパラメータは、値として[リソースリファレンス](https://docs.puppet.com/puppet/latest/lang_data_resource_reference.html)をとります。このリソースリファレンスは、Puppetコード内の別のリソースを指定するものです。 リソースリファレンスの構文は、`Type['title']`のように、先頭が大文字のリソースタイプの後に、大括弧で囲まれたリソースタイトルが続く形式になります。

<div class = "lvm-task-number"><p>タスク12:</p></div>

`init.pp`マニフェストを開いていない場合は、もう一度開きます。

    vim pasture/manifests/init.pp

関係性メタパラメータを追加し、`package`、`file`、`service`リソースの依存関係を定義します。少し時間をとって、それぞれの関係性メタパラメータがどのようになるか、またその理由を考えてみてください。

```puppet
class pasture {

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File['/etc/pasture_config.yaml'],
  }

  file { '/etc/pasture_config.yaml':
    source  => 'puppet:///modules/pasture/pasture_config.yaml',
    notify  => Service['pasture'],
  }

  file { '/etc/systemd/system/pasture.service':
    source  => 'puppet:///modules/pasture/pasture.service',
    notify  => Service['pasture'],
  }

  service { 'pasture':
    ensure => running,
  }

}
```

終わったら、`puppet parser`ツールを使ってもう一度構文をチェックします。

    puppet parser validate pasture/manifests/init.pp

`pasture.puppet.vm`ノードは、まだこの`pasture`クラスで分類されています。このノードに戻ってもう一度Puppet agentを実行すると、masterが追加されたこれらのファイルおよびサービスリソースを認識し、それらをカタログに含めてノードに返します。

<div class = "lvm-task-number"><p>タスク13:</p></div>

`pasture.puppet.vm`に接続しましょう。

    ssh learning@pasture.puppet.vm

もう一度Puppet agent実行を開始します。

    sudo puppet agent -t

`pasture`サービスが設定され、実行されたら、agentノードとの接続を終えます。

    exit

masterから、`curl`コマンドを使って、`pasture.puppet.vm`ノードのポート4567からASCIIアートの象を検索します。

    curl 'pasture.puppet.vm:4567/api/v1/cowsay?message=Hello!'

## おさらい

このクエストでは、Puppetコードの記述方法を具体的に説明しました。一般的な"パッケージ、ファイル、サービス"パターンを使ってPastureアプリケーションを設定し、サービスを設定してサーバ上で処理を実行しました。

モジュールの`files`ディレクトリにファイルを配置し、Puppetがこのファイルを利用できるようにする方法を学びました。また、ファイルを配置した後、`source`パラメータとURIによって、ファイルを`file`リソース内で使用する方法を学びました。

最後に、リソースの順序付けをしました。`before`および`notify`メタパラメータを使って、クラス内のリソースの関係性を定義し、Puppetが正しい順序でリソースを管理し、設定ファイルが修正された場合にはサービスを再起動できるようにしました。

次のクエストでは、変数を追加し、静的ファイルをテンプレートに置き換えることで、このクラスをさらに柔軟なものにする方法を学びます。
