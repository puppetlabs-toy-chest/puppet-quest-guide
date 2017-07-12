{% include '/version.md' %}

# Facts

## クエストの目的

 - `facter`ツールを使ってシステム情報にアクセスする方法を学ぶ。
 - `facts`ハッシュを使ってシステム情報をPuppetコードに組み込む。

## はじめに

前のクエストで学んだクラスパラメータを使えば、アプリケーション(またはモジュールで管理される各種のシステムコンポーネント)の設定に関する多くのタスクを、明確に定義された単一のインターフェイスにまとめることができます。利用可能なシステムデータを自動的に使用して変数を設定するモジュールを記述すれば、作業がさらに簡単になります。

このクエストでは、`facter`について説明します。`facter`ツールを使えば、agentが稼働しているシステムに関する情報に、Puppetマニフェスト内の変数として自動的にアクセスできるようになります。

このクエストを学ぶとわかりますが、factsはそれ自体がとても役に立ちます。次のクエストでは、factsを*条件文*とともに使用し、さまざまな文脈でそれぞれ異なる挙動をするPuppetコードを記述する方法を説明します。

このクエストを開始するには、以下のコマンドを入力します。

    quest begin facts

## Facter

>まず事実を手に入れろ。そのあとで、それを好きなように歪めろ。

> -マーク・トウェイン

このクエストガイドの設定セクションに`facter ipaddress`を実行するという指示があったので、`facter`ツールはすでに見たことがあるでしょう。Puppet実行におけるこのツールの役割については簡単に説明しました。Puppet agentは`facter`を実行して、システムに関するfactsのリストを入手し、カタログをリクエストする際にこのリストをPuppet masterに送ります。その後、Puppet masterがそれらのfactsを使ってカタログをコンパイルし、Puppet agentに送り返すと、Puppet agentがそれを適用します。

Puppetコードにfactsを組み込む作業の前に、コマンドラインで`facter`ツールを使って、使用できる factsの種類とその構造を見てみましょう。

<div class = "lvm-task-number"><p>タスク1:</p></div>

まず、このクエストのために準備したagentノードに接続します。

    ssh learning@pasture.puppet.vm

`facter`コマンドを使うと、factsの標準セットにアクセスできます。`-p`フラグを追加すると、Puppet masterにインストールし、Puppet実行のpluginsyncステップでagentと同期したカスタムファクトが含まれます。この`facter -p`コマンドを`less`に渡し、ターミナルでアウトプットをスクロールできるようにします。
	
    facter -p | less

終わったら`q`を押して`less`を終了します。

このコマンドのアウトプットがハッシュとして表示される点に注目してください。`os`などの一部のfactsには、ネストされたJSONフォーマットのデータが含まれます。

    facter -p os

ドット(`.`)を使ってハッシュの子レベルでキーを指定すれば、この構造を掘り下げられます。たとえば、以下のようになります。

    facter -p os.family

`facter`で使用できるデータの確認方法とデータの構造を理解しました。次にPuppet masterに戻り、これがPuppetコードにどう組み込まれるか見ていきましょう。

    exit

すべてのfactsは、マニフェスト内で自動的に提供されます。 `$facts['fact_name']`の構文に従った`$facts`ハッシュを使えば、どのfact値にもアクセスできます。構造化されたfactsにアクセスするには、同じ括弧を使用した構文を用いて、複数の名前をつなぎます。たとえば、先ほどアクセスした`os.family` factは、マニフェスト内で`$facts['os']['family']`として提供されます。

ここまで使ってきたPastureモジュールから少し離れ、代わりにMOTD (Message of the Day)ファイルを管理する新しいモジュールを作成しましょう。このファイルは通常、ユーザの接続時にホストに関する情報を表示するために、\*nix\システムで使用されます。factsを使うと、システムに関する基本情報を表示する動的なMOTDを作成することができます。

ここまでに学んだコンセプトを復習しながら、新しいモジュールを作成しましょう。

<div class = "lvm-task-number"><p>タスク2:</p></div>

`modules`ディレクトリから、`motd`という名のモジュールのディレクトリ構造を作成します。`manifests`および`templates`という2つのサブディレクトリが必要になります。

    mkdir -p motd/{manifests,templates}

<div class = "lvm-task-number"><p>タスク3:</p></div>

まず、`init.pp`マニフェストを作成し、メインの`motd`クラスを含めます。

    vim motd/manifests/init.pp

このクラスは、`/etc/motd`ファイルを管理する単一の`file`リソースで構成されます。テンプレートを使って、このリソースの`content`パラメータの値を設定します。

```puppet
class motd {

  $motd_hash = {
    'fqdn'       => $facts['networking']['fqdn'],
    'os_family'  => $facts['os']['family'],
    'os_name'    => $facts['os']['name'],
    'os_release' => $facts['os']['release']['full'],
  }

  file { '/etc/motd':
    content => epp('motd/motd.epp', $motd_hash),
  }

}
```

`$facts`ハッシュとトップレベル(非構造化) factsが、変数としてテンプレートに自動的にロードされます。読みやすさと信頼性を高めるために、ここで示す方法を使用することを強く推奨します。ただし、ここで推奨する`$facts`ハッシュ構文に代わり、一般的な変数構文を用いて直接factsに言及するテンプレートに遭遇する可能性もある点に注意してください。

<div class = "lvm-task-number"><p>タスク4:</p></div>

次に、`motd.epp`テンプレートを作成します。

    vim motd/templates/motd.epp

パラメータタグからはじめ、テンプレートで使用する変数セットを明示します。MOTDは、コメント構文のないプレーンテキストファイルです。そのため、通常の"managed by Puppet"ノートは省略します。

```
<%- | $fqdn,
      $os_family,
      $os_name,
      $os_release,
| -%>
```

次に、シンプルな挨拶メッセージを追加し、fact値から割り当てられた変数を用いて、システムに関する基本情報を提供します。

```
<%- | $fqdn,
      $os_family,
      $os_name,
      $os_release,
| -%>
Welcome to <%= $fqdn %>

This is a <%= $os_family %> system running <%= $os_name %> <%= $os_release %>

```

<div class = "lvm-task-number"><p>タスク5:</p></div>

このテンプレートセットで、シンプルなMOTDモジュールが完成します。`site.pp`マニフェストを開き、`pasture.puppet.vm`ノードに割り当てます。

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

パラメータをいっさい使っていないため、`include`関数を用いて、`motd`クラスを`pasture.puppet.vm`ノード定義に追加します。

```puppet
node 'pasture.puppet.vm` {
  include motd
  class { 'pasture':
    default_character => 'cow',
  }
}
```

<div class = "lvm-task-number"><p>タスク6:</p></div>

終わったら、再び`pasture.puppet.vm`ノードに接続します。

    ssh learning@pasture.puppet.vm

Puppet agent実行を開始します。

    sudo puppet agent -t

MOTDを見るには、まず`pasture.puppet.vm`との接続を終了します。

    exit

次に再接続します。

    ssh learning@pasture.puppet.vm

MOTDを確認したら、Puppet masterに戻ります。

    exit

## おさらい

このクエストでは、`facter`ツールを紹介し、このツールを使ってシステムデータの構造化セットにアクセスする方法を説明しました。

その後、Puppetマニフェスト内からfactsにアクセスし、それらの factsの値を変数に割り当てる方法を説明しました。また、Facterのデータを使って、MOTDファイルを管理するテンプレートを作成しました。

次のクエストでは、*条件文*を用いてPuppetコードの柔軟性をさらに高める方法を説明します。そのような条件文とfactsを組み合わせ、システム情報をもとにインテリジェントなデフォルトを作成する例を紹介します。
