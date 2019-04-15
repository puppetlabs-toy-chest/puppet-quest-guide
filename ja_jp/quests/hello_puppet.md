{% include '/version.md' %}

# ハロー、Puppet

## クエストの目的

- まずは基本から: Puppetとは何か？　何ができるのか？ 
- 新規システムにPuppet agentをインストールする。
- Puppetのリソースとリソース抽象化レイヤーについて理解する。

## はじめに

> 十分に発達した技術は、どんなものも魔法と区別できない。

> - アーサー・C・クラーク

このクエストから、Puppetのツールとサービスを使用したインフラストラクチャの管理方法についての実践的な入門がはじまります。まずはagentをインストールし、Puppetによるインフラ管理の核となる概念を学びます。agentを新規システムにインストールしたら、`puppet resource`ツールを使って、そのシステムの状態を見ていきます。このツールを通じて、*リソース*について学んでいきます。リソースは、Puppetがシステムの記述と管理に使用する基本ユニットです。

準備ができたらLearning VMで以下のコマンドを実行し、クエストを開始してください。

    quest begin hello_puppet

## Puppetとは？

Puppetツールの機能とその使い方を詳しく学ぶ前に、Puppetとは何か、なぜ学ぶ価値があるのかを説明しましょう。「Puppet」という名称は多くの場合、インフラの設定を定義し、システムをあるべき状態に維持するプロセスを自動化するために協調して動作するツールおよびサービスの集合を指す総称として用いられます。

本ソフトウェアの個々のコンポーネントについては、このガイドを進めながらより詳しく学んでいきますが、ここでは、他のシステム管理ツールとの違いについて、重要なポイントをいくつか紹介します。

Puppetを使用すると、インフラ内のすべてのシステムのあるべき状態を定義することができます。Puppetは自動プロセスによってシステムを定義された状態に維持します。

システムのあるべき状態は、Puppetコードで記述されます。これはドメイン固有言語(DSL)です。この**コードとしてのインフラ**アプローチなら、バージョン管理やコンプライアンス、継続的インテグレーションとデプロイ、テストなどに関わるユーザが、それぞれの開発やリリースのワークフローにインフラを簡単に組み入れることができます。

Puppetコードは**宣言型**言語です。つまり、システムのあるべき状態のみを記述し、そこに至るまでに必要なステップは記述しません。Puppetで管理するシステムのあるべき状態をコードで指定すると、バックグラウンドで稼働するagentサービスにより、システムをあるべき状態に一致させるために必要な変更が加えられます。 

宣言型アプローチでは、スクリプトやゴールデンイメージ、ランブックを使用する場合とは違う形で、インフラ内のシステムを考える必要があります。インフラを**どうすれば**よいかではなく、インフラで**何が**できるかという点に注力し、時間をかけることができます。

宣言型のPuppet言語には、WindowsやUnixなどのオペレーティングシステム、ネットワークデバイス、コンテナ全体にわたってあるべき状態を記述するための共通の構文が用意されています。新しいシステムの作業を始めるときに、毎回言語やツールセットを切り替える必要はありません。Puppetを学べば、複数のプロジェクトや役割をまたいで活用できるスキルセットが手に入ります。

master-agentアーキテクチャでは、個々のシステムに接続して変更を加える必要がありません。ひとたびagentサービスをシステム上で実行すれば、agentはmasterとの間で安全な接続を定期的に確立し、割り当てられたコードを取得し、記述されたあるべき状態とシステムを一致させるために必要な変更を加えます。Puppetはこのような集中型コントロールを基盤として構築されているため、モニタリングやコンプライアンスが非常に楽です。

## Puppet agent

前述したように、「Puppet」とは、各種のツールとサービスの集合を指しています。それらが連携してインフラ内のシステムを管理して調整します。このエコシステムは大きなパワーとコントロールを与えてくれますが、複雑なために、初心者はどこから始めればよいかわからなくなることもあります。

最初にBoltを紹介してから、ここでPuppet agentとagentのインストールに含まれるコマンドラインツールについて説明すると、Puppetの全体像とボトムアップの基礎をバランスよく学べるのではないかと思います。まずは、全体的なPuppetのインフラにおけるagentの役割と、agentがインストールされたシステムとの相互作用の詳細を理解しましょう。

Puppet agentは、Puppetで管理するすべてのシステム上で稼働します。 agentは、インストールされたシステムと Puppet masterサーバをつなぐ橋として機能します。agentは2つの方向に通信します。外方向のmasterに対する通信では、システムをどう設定すべきかを確認します。内方向のネイティブシステムツールに対する通信では、システムの実際の状態を確認し、あるべき状態と一致させるために必要な変更を加えます。 

Puppet agentをインストールすると、Puppet agentと同じようにシステムと直接やりとりする際に役立つコマンドラインツールセットが利用できるようになります。これらのツールを使うと、Puppet agentがシステムの状態をどのように確認し、修正しているか理解しやすくなります。

## Agentのインストール

Learning VM自体に、Puppet masterを含むPuppet Enterpriseがプリインストールされています。各クエストのクエストツールでは、1つまたは複数のagentシステムを取り上げ、それについて確認しながらPuppetで詳細な設定を行います。

このクエストには、Puppet agentをインストールし、一部のツールについて学べる新しいシステムが用意されています。Puppet masterのホストするagentインストールスクリプトを使って、masterにアクセスできるあらゆるシステム上に Puppet agentを簡単にインストールすることができます。

<div class = "lvm-task-number"><p>タスク1:</p></div>

はじめに、前のクエストで紹介した`bolt`ツールを使用します。以下のコマンドをコピーして実行し、masterからagentインストーラをロードしてagentシステム上で実行します。

    bolt command run "sh -c 'curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | sudo bash'" --nodes docker://hello.puppet.vm

インストールの実行中は、画面に文字が表示されます。

agentインストールプロセスの詳しいドキュメントと、Windowsなどのオペレーティングシステムに関する具体的な説明については[インストールマニュアル](https://puppet.com/docs/pe/latest/installing_agents.html)を参照してください。

## リソース

すでに説明したように、Puppet agentにはシステムの探索に役立つツールセットが付随しています。agentのインストールが終わったので、これらのツールを使用してPuppetの仕組みを見ていきましょう。

Puppetの核となるコンセプトの1つが、*リソース抽象化レイヤー*です。Puppetでは、管理するシステムの各要素(ユーザ、ファイル、サービス、パッケージなど)を、*リソース*と呼ばれるユニットとしてコードで表現します。`puppet resource`ツールを使えば、これらのリソースを直接表示し、修正することができます。

<div class = "lvm-task-number"><p>タスク2:</p></div>

次のコマンドを使用して、先ほどagentをインストールしたシステムに接続します。プロンプトが表示されたら、パスワード`puppet`を入力します。

    ssh learning@hello.puppet.vm

次に、以下のコマンドを実行し、Puppetにファイルリソースを記述させます。

    sudo puppet resource file /tmp/test

リソースを表すPuppetコードが表示されます。このケースでは、リソースタイプが`file`で、パスが`/tmp/test`です。

```puppet
file { '/tmp/test':
  ensure => 'absent',
}
```

このリソース構文を各コンポーネントに分解すると、その構造をよりはっきりと理解できるようになります。

```puppet
type { 'title':
  parameter => 'value',
}
```

**タイプ**は、リソースが記述しているものの種類です。ユーザ、ファイル、サービス、パッケージなどの**コアタイプ**と、モジュールから独自に実装またはインストールした**カスタムタイプ**があります。

カスタムタイプは、そのままではPuppetで認識されない可能性のあるサービスやアプリケーション(例えば、Apache vhostやMySQLデータベースなど)固有のリソースを記述します。

リソースの本体は、**パラメータ値ペア**のリストです。これは`parameter => value`のパターンに従います。パラメータと可能な値は、タイプによって異なります。これらは、システム上のリソースの状態を指定するものです。リソースパラメータに関するドキュメントは、[リソースタイプリファレンス](https://puppet.com/docs/puppet/latest/types/)で提供されています。

**リソースタイトル**は、そのリソースを内部で識別するためにPuppetが用いる固有名です。先ほどのファイルリソースの例では、リソースのタイトルはシステム上のファイルパス`/tmp/test`でした。それぞれのリソースタイプには、リソースタイトルとして使用できる固有の識別要素があります。たとえば、`user`リソースはタイトルとしてアカウント名を、 `package`リソースは管理するパッケージ名を使用します。

リソースの構文に慣れたら、先ほどのファイルリソースをもう少し見ていきましょう。

```puppet
file { '/tmp/test':
  ensure => 'absent',
}
```

1つのパラメータ値ペア`ensure => 'absent'`がある点に注目してください。`ensure`パラメータは、リソースの基本状態を伝えるものです。 *ファイル*タイプの場合、このパラメータは、システムにファイルが存在するかどうかと、存在する場合には、それが通常のファイル、ディレクトリ、またはリンクかを示します。

<div class = "lvm-task-number"><p>タスク3:</p></div>

Puppetは、このファイルが存在しないことを示しています。`touch`コマンドを使って、このパスに新しい空ファイルを作成したらどうなるでしょうか?以下を実行します。

    touch /tmp/test

`puppet resource`ツールを使って、この変更がPuppetのリソース構文でどう表現されているかを確認します。

    sudo puppet resource file /tmp/test

システムにファイルが存在するようになったので、Puppetの情報も先ほどより増えています。`ensure`および`content`パラメータとその値が示されているほか、ファイルのオーナー、作成日時、最終修正日時に関する情報が示されています。

```puppet
file { '/tmp/test':
  ensure  => 'file',
  content => '{md5}d41d8cd98f00b204e9800998ecf8427e',
  ...
}
```

`content`パラメータの値は、予想したものとは違うかもしれません。`puppet resource`ツールは、このリソース宣言構文のファイルを解釈すると、コンテンツをMD5ハッシュに変換します。Puppetはこのハッシュを使用することにより、システム上の実際のファイルの内容を予想される内容と迅速に比較し、変更があったかどうかを確認することができます。

<div class = "lvm-task-number"><p>タスク4:</p></div>

次に、`puppet resource`ツールを使って、ファイルにいくつかのコンテンツを追加します。

`parameter=value`引数を使って`puppet resource`を実行すると、設定した値と一致するシステム上のリソースを修正するようPuppetに命じることができます(これは開発環境において変更をテストする方法としては優れていますが、プロダクションインフラを管理する方法としては推奨できません)。

以下のコマンドを実行します。

    sudo puppet resource file /tmp/test content='Hello Puppet!'

提供した新規コンテンツに照らして既存コンテンツのハッシュが確認され、アウトプットが表示されます。ハッシュが一致しない場合は、ファイルのコンテンツがコマンドの`content`パラメータの値に設定されます。

以下を実行してファイルを見て、修正されたコンテンツを確認しましょう。

    cat /tmp/test

### タイプとプロバイダ

システムの状態とPuppetのリソース構文との間でのこうした変換は、Puppetのリソース抽象化レイヤーの中核です。この仕組みをさらに深く理解するために、別のリソースタイプ、`package`を見ていきましょう。

<div class = "lvm-task-number"><p>タスク5:</p></div>

例として、以下のコマンドを実行し、Apache Webサーバーの`httpd`パッケージをインストールします。

    sudo puppet resource package httpd

このパッケージはシステム上に存在していないため、Puppetは`ensure => purged`パラメータ値ペアを表示します。この`purged`値は、先ほど`file`リソースで見た`absent`値と同様のものですが、パッケージリソースの場合は、パッケージそのものと、パッケージマネージャによりインストールされた構成ファイルのどちらも存在しないことを示しています。

```puppet
package { 'httpd':
  ensure => 'purged',
}
```

それぞれのリソース**タイプ**には一群の**プロバイダ**があります。**プロバイダ**は、Puppetのリソース表現と、基本的なシステム状態の確認と修正に用いられるネイティブシステムツールとの間にある変換レイヤーです。通常、それぞれのリソースタイプには、さまざまなプロバイダがあります。

プロバイダの内部機能を確認する最も手軽な方法は、不具合を生じさせてみることです。以下を実行し、`bogus-package`という存在しないパッケージをインストールするようPuppetに指示します。

    sudo puppet resource package bogus-package ensure=present

エラーメッセージにより、yumが指定されたパッケージを見つけられなかったことが伝えられ、パッケージがまだインストールされていないことを確認した際にPuppetのyumプロバイダが実行を試みたコマンドのリストが示されます。

```
Error: Execution of '/bin/yum -d 0 -e 0 -y install bogus-package' returned 1:
Error Nothing to do
```

Puppetは、agentのオペレーティングシステムと、プロバイダに関連するコマンドを利用できるかどうかをもとに、デフォルトのプロバイダを選択します。リソースの`provider`パラメータを設定すれば、このデフォルトをオーバーライドすることができます。

同じ偽パッケージをもう一度インストールしてみましょう。今回は、`gem`プロバイダを使用します。

     sudo puppet resource package bogus-package ensure=present provider=gem

同様のエラーメッセージが表示されますが、`yum`コマンドのかわりに、失敗した`gem`コマンドが表示されます。

```
Error: Execution of '/bin/gem install --no-rdoc --no-ri bogus-package'
returned 2: ERROR:  Could not find a valid gem 'bogus-package' (>= 0) in any repository
Error: /Package[bogus-package]/ensure: change from absent to present failed: 
Execution of '/bin/gem install --no-rdoc --no-ri bogus-package' returned 2: 
ERROR:  Could not find a valid gem 'bogus-package' (>= 0) in any repository
```

バックグラウンドで何が行われているかを確認しました。次はデフォルトのプロバイダを使って本物のパッケージをインストールしてみましょう。

    sudo puppet resource package httpd ensure=present

今回は、Puppetがパッケージをインストールします。 `ensure`パラメータの値は、インストールされたパッケージの具体的なバージョンを示しています。

```puppet
package { 'httpd':
  ensure => '2.4.6-45.el7.centos',
}
```

インストールするパッケージのバージョンを指定しない場合は、利用可能な最新のバージョンがデフォルトでインストールされ、そのバージョン番号が`ensure`属性の値として表示されます。

新たにインストールされたPuppet agentでこのシステムを確かめたら、終了してPuppet masterへ戻り、次のクエストに進みましょう。 

    exit

## おさらい

このクエストでは、Puppetとは何かについて学び、Puppetの宣言型ドメイン固有言語とmaster-agentアーキテクチャを使ってインフラを管理する利点を見ていきました。

Boltを使って、新規システムにPuppet agentをインストールしました。agentと対応する一連のツールをインストールした後で、Puppetの**リソース抽象化レイヤー**の基礎を学びました。これには**リソース**、リソース**タイプ**、**プロバイダ**などが含まれ、Puppetコードとネイティブシステムツールの間で変換されます。

Puppetを支える主要コンセプトを学ぶと、より現実的なワークフローでそのアイデアを活用できるようになります。`puppet resource`コマンドは、システムの探索やPuppetコードをテストするには非常に役立ちますが、設定管理の自動化に使用するツールではありません。

次のクエストでは、**マニフェスト**と呼ばれるファイルに Puppetコードを保存し、Puppet masterの**codedir**内で**モジュール**にまとめる方法を見ていきます。この構造により、インフラ管理に必要なすべてのリソースの場所をPuppetが追跡することが可能になります。

また、Puppet agentがPuppet masterと通信し、masterに保存されているPuppetコードをもとにコンパイルされた、**カタログ**と呼ばれるリソースリストを入手する仕組みについても説明します。

## その他のリソース

* オンデマンドウェビナー ["Puppet Enterprise入門"](https://puppet.com/resources/webinar/introduction-puppet-enterprise)をご覧ください。
* Puppet Enterpriseのインストールについては、[ドキュメントページ](https://puppet.com/docs/pe/latest/installing_pe.html)を参照してください。
*  [Puppetとは何か](https://learn.puppet.com/course/what-is-puppet)、[Puppet Enterpriseとは何か](https://learn.puppet.com/course/what-is-puppet-enterprise)、[リソース](https://learn.puppet.com/course/resources)、[自己ペースレッスン](https://learn.puppet.com/category/self-paced-training)もご覧ください。
* Puppetの基礎については、Getting Started with Puppetコースで詳しく説明しています。詳細については、[対面](https://learn.puppet.com/category/instructor-led-training)および[オンライン](https://learn.puppet.com/category/online-instructor-led-training)トレーニングオプションをチェックしてみてください。
