{% include '/version.md' %}

# マニフェストとクラス

## クエストの目的

- *マニフェスト*ファイル内に含まれる*クラス*でPuppetコードを整理する方法を理解する。
- モジュール構造によりPuppetコードを整理し、Puppet masterが認識できる形に保つ方法を学ぶ。
- 新規Puppetモジュールを作成し、`cowsay`および`fortune`パッケージを管理する。

## はじめに

ここまでの内容では、Puppetの*リソース抽象化レイヤー*の基礎、Puppet agentとmasterの関係、Puppet agent実行に関するagentとmasterの通信を学んできました。しかし、いくつかの基本的なリソースを修正した以外は、まだそれほど多くのPuppetコードを書いてはいません。

Puppetコードの構成、維持、デプロイに用いるパターンやワークフローは、コードそのものに劣らず重要です。ここで紹介する一部の例は、管理する対象の単純さを考えると、複雑すぎるように見えるかもしれませんが、最初に優れたデザインを学んでおけば、もっと複雑なPuppetインフラの管理を始めるときにも、すべてがスムーズに動作するよう維持できるはずです。

このクエストでは、Puppetを*マニフェスト*、*クラス*、*モジュール*に組み込む方法と、`site.pp`マニフェストによりクラスをノードに適用する方法を学びます。これらの基礎は、Puppetコードでさらに複雑なコード管理手法を扱うようになっても、確かな基盤になってくれるはずです。

準備ができたら、以下のコマンドを入力してください。

    quest begin manifests_and_classes

### マニフェスト

> 想像力はリアリティを現出する力である。

> -ジェームズ・キャメロン

ごく簡単に言うと、Puppet *マニフェスト*は、 `.pp`エクステンションによりファイルに保存されるPuppetコードです。このコードはPuppet*ドメイン固有言語* (DSL)で記述されます。リソースについて学んだときに、すでにこのDSLの例をいくつか目にしているはずです。Puppet DSLには、リソース定義のほか、他の言語要素の機能が含まれます。これにより、どのリソースをシステムに適用し、リソースのパラメータにどのような値を設定するかをコントロールできます。

<div class = "lvm-task-number"><p>タスク1:</p></div>

まず、このクエストのために作成したノードにSSH接続します。

    ssh learning@cowsay.puppet.vm

`/tmp/`ディレクトリに使い捨てのマニフェストを作成し、どのように機能するかを見てみましょう。

    vim /tmp/hello.pp

前回のクエストで`site.pp`に含めたものと同じ通知のリソース宣言を使用します。

```puppet
notify { 'Hello Puppet!': }
```

(`ESC`の後に`:wq`を使用し、保存して終了するのを忘れないでください。)

masterでこのノードを分類してPuppet agent実行を開始する代わりに、`puppet apply`ツールでこのマニフェストを直接適用します。`puppet apply`ツールを使えば、`puppet resource`ツールを使ってリソースディレクトリの確認や修正を行う場合と同じように、マニフェストのPuppetコードをテストすることができます。 

    sudo puppet apply /tmp/hello.pp 

Puppetコードをファイルに保存する方法はわかりましたが、この保存したPuppetコードと、ノード分類を定義する`site.pp`の間のギャップはどうやって埋めたらいいのでしょうか？　 最初のステップは、Puppetコードを*クラス*および*モジュール*に組み込むことです。

### クラスとモジュール

*クラス*は、名前の付いたPuppetコードブロックです。クラスの*定義*とは、リソースのグループを再利用と設定が可能な1つのユニットにまとめることを意味します。 *定義*したら、クラスを *宣言*し、そこに含まれるリソースを適用するようPuppetに指示します。

クラスは、システムの1つの論理コンポーネントを管理するリソースセットをまとめたものでなければなりません。例えば、MS SQL Serverを管理するために記述されたクラスには、MS SQL Serverインスタンスのためのパッケージ、設定ファイル、サービスを管理するリソースが含まれます。そうした各コンポーネントは別のコンポーネントに依存しているため、ひとまとめにして管理するのは理にかなっています。MS SQLの設定ファイルはあるのに、MS SQLアプリケーションパッケージがないとしたら、そのサーバはあまりメリットがないでしょう。それと同じです。

*モジュール*は、クラスを含むマニフェストを探すべき場所をPuppetが追跡できるようにするためのディレクトリ構造です。モジュールには、設定ファイルのためのテンプレートなど、クラスが依存しない他のデータも含まれます。クラスをノードに適用すると、Puppet masterが *モジュールパス*と呼ばれるディレクトリリストをチェックし、クラス名と一致するモジュールディレクトリを探します。その後、masterはそのモジュールの`manifests`サブディレクトリを調べ、クラス定義を含むマニフェストを見つけ出します。masterはクラス定義に含まれるPuppetコードを読みとり、それを使って、ノードのあるべき状態を定義するカタログをコンパイルします。

このようなステップは、実際に例を見たほうが理解しやすいはずです。それでは、簡単なモジュールを記述してみましょう。

## cowsayモジュールを記述する

例として、cowsayと呼ばれる小さなプログラムを管理するモジュールを記述します。cowsayは、ASCIIアートの牛の口から出る吹き出しにメッセージを入れることのできるプログラムです。

新しいマニフェストを作成する前に、マニフェストを保存する場所を知っておく必要があります。Puppetがコードを見つけるためには、Puppetの*モジュールパス*にマニフェストを保存する必要があります。

まだ`cowsay.puppet.vm`に接続している場合は、接続を解除し、masterシステムに戻ります。

    exit

設定されたモジュールパスを確認するには、以下のコマンドを実行します。

    puppet config print modulepath

アウトプットとして、コロン(`:`)で区切られたディレクトリリストが表示されます。

```
/etc/puppetlabs/code/environments/production/modules:/etc/puppetlabs/code/modules:/opt/puppetlabs/puppet/modules
``` 

とりあえずは、モジュールパスのリストの最初にあるディレクトリで作業します。このディレクトリには、プロダクション環境固有のモジュールが含まれています(2番目のディレクトリには、すべての環境で使われるモジュールが含まれています。3番目は、PEが設定に使用するモジュールです)。

ここではモジュールとクラスの構造に焦点を絞っているので、master上のモジュールパスに直接コードを書きます。ただし、実際のプロダクション環境では、Gitなどのバージョン管理リポジトリにPuppetコードを保存し、Puppetコードマネージャツールを使ってmasterにデプロイするほうがいいかもしれません。VMに依存する重要なインフラはないので、ここではこのステップを省き、直接コードを書いても問題ありません。

<div class = "lvm-task-number"><p>タスク2:</p></div>

`cd`を使って`modules`ディレクトリに移動します。

    cd /etc/puppetlabs/code/environments/production/modules

`cowsay`という名前で新規モジュールのディレクトリ構造を作成します(`-p`フラグを使えば、`cowsay`親ディレクトリと`manifests`サブディレクトリを一度に作成することができます)。

    mkdir -p cowsay/manifests

ディレクトリ構造の準備ができたら、次はマニフェストを作成し、そこで`cowsay`クラスを記述します。

<div class = "lvm-task-number"><p>タスク3:</p></div>

vimを使って、モジュール`manifests`ディレクトリに`init.pp`マニフェストを作成します。

    vim cowsay/manifests/init.pp

このマニフェストに`cowsay`クラスを含めるつもりなのに、`cowsay.pp`ではなく`init.pp`と呼ぶのはなぜだろうと不思議に思うかもしれません。ほとんどのモジュールには、モジュールそのものの名前に対応したメインクラスが含まれています。このメインクラスは常に、特定の名前`init.pp`を持つマニフェストに保存されます。

以下のクラス定義を入力し、保存して終了します(`:wq`)。

```puppet
class cowsay {
  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }
}
```

(このパッケージのプロバイダとして、`gem`を指定した点に注目してください。言うまでもなく、`cowsay`はデフォルトのyumパッケージリポジトリに置くほど重要ではないので、Puppetに`gem`プロバイダを使うよう指示し、Rubyで記述され、RubyGemsで公開されるパッケージのバージョンがインストールされるようにしています。)

適用する前にコードを検証する習慣をつけましょう。`puppet parser`ツールを使って、新規マニフェストの構文をチェックします。

    puppet parser validate cowsay/manifests/init.pp
	
エラーがなければ、構文解析ツールは何も返しません。構文エラーが検出された場合は再びファイルを開き、問題を修正して先へ進みます。この検証で見つかるのは簡単な構文エラーのみで、マニフェストで生じる可能性のあるその他のエラーは見つからない点に注意してください。

モジュールの`init.pp`マニフェスト内で`cowsay`クラスが定義されました。これで、`cowsay`クラスをノードに適用する際にどこを探せば適切なPuppetコードが見つかるか、Puppet masterが認識できるようになりました。

<div class = "lvm-task-number"><p>タスク4:</p></div>

このクエストの設定では、クエストツールとして`cowsay.puppet.vm`ノードが用意されています。`cowsay`クラスをこのノードに適用しましょう。まず、 `site.pp`マニフェストを開きます。

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

`site.pp`マニフェストの末尾に、以下のコードを挿入します。

```puppet
node 'cowsay.puppet.vm' {
  include cowsay
}
```

保存して終了します。

この`include cowsay`行は、 `cowsay.puppet.vm`ノードのためのカタログをコンパイルする際に、`cowsay`クラスのコンテンツを解析するようPuppet masterに指示するためのものです。

<div class = "lvm-task-number"><p>タスク5:</p></div>

`cowsay`クラスを`cowsay.puppet.vm`ノードの分類に追加しました。次にこのノードに接続し、Puppet agent実行を開始して、適用された変更を確認してみましょう。

    ssh learning@cowsay.puppet.vm

システムに変更を適用する前には、必ず`--noop`フラグを使ってPuppet agent実行の予行演習をするようにしましょう。これにより、システムの変更を実際に適用せずに、カタログがコンパイルされ、Puppetが加える変更が通知されます。これは`puppet parser validate`コマンドでは検出できない問題を見つけるのに役立ちます。また、Puppetで予想どおりの変更が行われるかどうかを検証することもできます。

    sudo puppet agent -t --noop

以下のようなアウトプットが表示されるはずです。

    Notice: Compiled catalog for cowsay.puppet.vm in environment production in
    0.62 seconds
    Notice: /Stage[main]/Cowsay/Package[cowsay]/ensure: current_value
    absent, should be present (noop)
    Notice: Class[Cowsay]: Would have triggered 'refresh' from 1
    events
    Notice: Stage[main]: Would have triggered 'refresh' from 1 events
    Notice: Finished catalog run in 1.08 seconds

予行演習で問題がなければ、先へ進んで、`--noop`フラグを付けずにもう一度Puppet agentを実行します。

    sudo puppet agent -t

これで、新しくインストールしたcowsayコマンドを使えるようになりました。

    cowsay Puppet is awesome!

この牛は、よくわかっているようです。

     ____________________
    < Puppet is awesome! >
     --------------------
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||

### 複合クラスとクラススコープ

多くの場合、モジュールには連係して1つの機能を提供する多数のコンポーネントが含まれます。cowsayはそれだけでも素晴らしいものですが、多くのユーザは、コマンド実行のたびに高品質のカスタムメッセージを書く時間はありません。そのため、吹き出しの言葉に使うことわざや名言のデータベースを提供する`fortune`コマンドとcowsayを組み合わせて使うことがよくあります。

<div class = "lvm-task-number"><p>タスク6:</p></div>

`cowsay.puppet.vm`ノードとの接続を解除し、masterに戻ります。

    exit

`fortune`クラス定義の新規マニフェストを作成します。

    vim cowsay/manifests/fortune.pp

ここにクラス定義を記述します。

```puppet
class cowsay::fortune {
  package { 'fortune-mod':
    ensure => present,
  }
}
```

メインの`init.pp`マニフェストとは違い、このマニフェストのファイル名には、マニフェストの定義するクラス名が表示されている点に注目してください。実際、このクラスは`cowsay`モジュールに含まれるため、フルネームは `cowsay::fortune`になります。`cowsay`と`fortune`を結ぶ2つのコロンは"スコープスコープ"と発音し、この`fortune`クラスがcowsayモジュールスコープに含まれることを示しています。クラス名にスコープを完全に記述することで、Puppetがモジュールパス内のクラスの場所(このケースでは`cowsay`モジュールの`manifests`ディレクトリにある`fortune.pp`マニフェスト)を正確に見つけられるようになります。このネーミングパターンは、異なるモジュールによく似た名前のクラスがある場合に競合を避けるためにも役立ちます。

<div class = "lvm-task-number"><p>タスク7:</p></div>

もう一度、`puppet parser validate`コマンドで新規マニフェストの構文を検証します。

    puppet parser validate cowsay/manifests/fortune.pp

`site.pp`マニフェスト内の別のインクルード文を使って、`cowsay::fortune`クラスで`cowsay.puppet.vm`を分類することもできます。しかし、一般には、分類はできるだけシンプルにしておくほうがいいでしょう。

このケースでは、クラス宣言を使って、`cowsay::fortune`クラスをメインの `cowsay`クラスに取り込みます。

    vim cowsay/manifests/init.pp

`cowsay::fortune`クラスのインクルード文をcowsayクラスに追加します。

```puppet
class cowsay {
  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }
  include cowsay::fortune
}
```

`puppet parser validate`コマンドを使って構文をチェックします。

    puppet parser validate cowsay/manifests/init.pp

<div class = "lvm-task-number"><p>タスク8:</p></div>

`cowsay.puppet.vm`ノードに戻り、これらの変更をテストします。

    ssh learning@cowsay.puppet.vm

`--noop`フラグを使ってPuppet agent実行を開始し、Puppetで実行される変更をチェックします。

    sudo puppet agent -t --noop

cowsayパッケージはすでにインストールされているので、Puppetはこのパッケージには何の変更も加えません。`cowsay::fortune`パッケージを含めた場合、Puppetは、ノードで定義したあるべき状態にするためには`fortune-mod`パッケージをインストールする必要があると認識します。

`--noop`フラグなしで再度Puppet実行を開始し、変更を適用します。

    sudo puppet agent -t

すでに両方のパッケージをインストールしたので、2つ一緒に使うことができます。`fortune`コマンドのアウトプットを`cowsay`にパイピングしてみてください。

    fortune | cowsay

Puppet実行の結果を確認したら、接続を解除して Puppet masterに戻ります。

    exit
	
## おさらい

このクエストではまず、Puppetコードを整理された状態に保つことの重要性を説明しました。この*クラス*、*マニフェスト*、*モジュール*という構造により、コードを論理的で再利用可能なユニットにまとめておくことができます。また、Puppetの*モジュールパス*内にモジュールを保存すれば、Puppet masterがモジュールに含まれるクラスを見つけることができます。

ここまで学んだことを使って、`cowsay`パッケージを管理する新規モジュールを作成し、`fortune-mod`パッケージを管理する新規クラスを作成してこのモジュールを拡張しました。

以降のクエストでも引き続き、この整理スキームを用いて、ユーザの記述するPuppetコードを構築していきます。
