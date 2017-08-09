{% include '/version.md' %}

# 変数とテンプレート

## クエストの目的

- 変数の割り当てと使用について学ぶ。
- EPPテンプレートの作成方法を学ぶ。
- ハッシュ構文を使って変数をEPPテンプレートに渡す。

## はじめに

このクエストでは、変数とテンプレートについて説明します。Puppetマニフェスト内で変数に値を割り当てると、マニフェスト全体でその変数を使って割り当てられた値を生成できるようになります。テンプレートを通じて、Puppetマニフェストの管理するファイルのコンテンツにこれらの変数を組み込むことができます。

ここでは、わかりやすくするために変数とテンプレートをペアとして説明しますが、このクエストガイドを先へ進めるうちに、その他のさまざまなPuppetの機能と変数を組み合わせることで、柔軟性のあるPuppetコードを記述できるようになることがわかるはずです。

準備ができたら、以下のコマンドを入力してください。

    quest begin variables_and_templates

## 変数

> 美しさは変わるもの、醜さは定まったもの。

> -ダグラス・ホートン

変数を使えば、値に特定の名前を付けておき、後からマニフェスト内でその値を使うことができます。

変数の名前には、`$` (ドルマーク)の接頭辞が付きます。値は`=`オペレータで割り当てられます。例えば、短い文字列を変数に割り当てる場合は、以下のようになります。

```puppet
$my_variable = 'look, a string!'
```

いったん定義した変数は、マニフェスト内のどこででも、割り当てられた値を使いたい場所で使うことができます。変数は構文解析順序に依存する点に注意してください。つまり、使用する前に、変数を定義する必要があります。定義されていない変数を使おうとすると、特殊な`undef`値が生じる結果になります。一部のケースでは、これは明示的なエラーになりますが、予期せぬコンテンツを持つ有効なカタログにつながるケースもあります。

技術的には、Puppetコードを解析してカタログを生成するPuppet構文解析という観点から言えば、Puppet変数は実際には*定数*です。変数をいったん割り当てたら、その値は固定され、変更できません。ここで言う*変動性*とは、インフラ内のさまざまなPuppet実行やさまざまなシステムで、変数として異なる値を設定できるという意味です。

<div class = "lvm-task-number"><p>タスク1:</p></div>

まず、いくつかの変数を設定します。cowsayアプリケーションで使用するデフォルトのキャラクター、サービスを実行したいポート、設定ファイルのパスを定義します。

`init.pp`マニフェストを開きます。

    vim pasture/manifests/init.pp

クラスの冒頭でこれらの変数を割り当てます。ハードコードされたリファレンスを、この変数により`/etc/pasture_config.yaml`設定ファイルパスに置き換えます。

```puppet
class pasture {

  $port                = '80'
  $default_character   = 'sheep'
  $default_message     = ''
  $pasture_config_file = '/etc/pasture_config.yaml'

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }
  file { $pasture_config_file:
    source  => 'puppet:///modules/pasture/pasture_config.yaml',
    notify  => Service['pasture'],
  }
  file { '/etc/systemd/system/pasture.service':
    source => 'puppet:///modules/pasture/pasture.service',
    notify  => Service['pasture'],
  }
  service { 'pasture':
    ensure    => running,
  }
}
```

この段階ではまだ、`$pasture_port`や`$default_character`変数を使って何もしていません。これらの変数を使うには、変数を設定ファイルに渡す方法が必要です。また、`$pasture_config_file`変数をサービスユニットファイルに渡し、デフォルト以外の何かを変更した場合に、指定した設定ファイルによりサービスがPastureプロセスを起動するようにする必要もあります。

## テンプレート

システム設定および管理に関わる多くのタスクは、最終的にはテキストファイルのコンテンツを管理することに行き着きます。これに対処するもっとも直接的な方法は、テンプレート言語を使用することです。テンプレートはテキストファイルと似ていますが、変数のほか、条件や反復といったより高度な言語機能を挿入する構文を備えています。この柔軟性の高さにより、1つのツールで幅広いファイルフォーマットを管理することが可能になります。 

テンプレートの制約は、全部かゼロかという点です。テンプレートは、管理したいファイル全体を定義するものです。ファイルの別の部分は異なるプロセスやPuppetモジュールで管理していて、ファイル内の1行だけ、または値だけを管理する必要がある場合は、[Augeas](https://docs.puppet.com/guides/augeas.html)、
[concat](https://forge.puppet.com/puppetlabs/concat)、[file_line](https://forge.puppet.com/puppetlabs/stdlib#file_line)リソースタイプを調べてみるほうがいいかもしれません。 

## 埋め込み型Puppetテンプレート言語

Puppetは、[埋め込み型Puppet(EPP)](https://docs.puppet.com/puppet/latest/lang_template_epp.html)および[埋め込み型Ruby(ERB)](https://docs.puppet.com/puppet/latest/lang_template_erb.html)という2つのテンプレート言語をサポートしています。

 Puppet 4でリリースされたEPPテンプレートは、Puppetネイティブのテンプレート言語を提供するもので、Rubyから受け継がれたERB言語に比べて多くの点が改善されています。現在はEPPが推奨手法になっているため、このクエストでもEPPを使用します。ただし、いったんテンプレートの基礎を理解してしまえば、ドキュメントを参照しながら、ERBフォーマットを簡単に使うことができます。

EPPテンプレートはプレーンテキストドキュメントで、コンテンツをカスタマイズするタグが組み込まれています。

<div class = "lvm-task-number"><p>タスク2:</p></div>

具体例を挙げて構文を説明するため、Pastureの設定ファイルの管理に役立つテンプレートを作成してみましょう。

まず、`pasture`モジュールディレクトリに`templates`ディレクトリを作成する必要があります。

    mkdir pasture/templates

次に、`pasture_config.yaml.epp`テンプレートファイルを作成します。

    vim pasture/templates/pasture_config.yaml.epp

EPPテンプレートは*パラメータタグ*から始めることをおすすめします。これにより、テンプレートが受け入れるパラメータを宣言し、それぞれのデフォルト値を設定することができます。このタグがなくてもテンプレートは機能しますが、ここで変数を明示的に宣言すれば、テンプレートが読みやすくなり、メンテナンスも簡単になります。

また、ファイルの冒頭にコメントを追加することもおすすめします。これにより、このファイルがPuppetで管理されており、手動で変更した場合には次回のPuppet実行の際に復元されることが、このファイルを見た人にわかるようになります。このコメントは、最終ファイルに直接含めることを意図したものです。ですから、作業対象のファイルフォーマットのネイティブなコメント構文を使用するのを忘れないようにしてください。

テンプレートの冒頭は、以下のようになるはずです。以下の構文の詳細は、後から説明します。

```
<%- | $port,
      $default_character,
| -%>
# This file is managed by Puppet. Please do not make manual changes.
```

パラメータリストを囲むバー(`|`)は、パラメータタグを定義する特殊な構文です。 `<%`と`%>`は、開始および終了側のタグデリミタで、ファイル本体とEPPタグを区別するものです。タグデリミタの隣のハイフン(`-`)は、タグ前後のインデントと余白を削除します。これにより、例えばアウトプットファイルの冒頭に空行を作成する改行文字をタグの後に入れなくても、このパラメータタグをファイルの冒頭に置けるようになります。

次に、設定した変数を使って、ポートおよびキャラクター設定オプションの値を定義します。

```
<%- | $port,
      $default_character,
      $default_message,
| -%>
# This file is managed by Puppet. Please do not make manual changes.
---
:default_character: <%= $default_character %>
:default_message:   <%= $default_message %>
:sinatra_settings:
  :port: <%= $port %>
```

変数をファイルに挿入するために使用した`<%= ... %>`タグは、*表示式タグ*と呼ばれます。このタグは、Puppetの式のコンテンツを挿入します。このケースでは、変数に割り当てられた文字列の値を挿入します。

テンプレートを設定したら`init.pp`マニフェストに戻り、これを使って`file`リソースのコンテンツを定義する方法を見ていきましょう。

まず、テンプレートファイルを保存し、Vimを終了します。

<div class = "lvm-task-number"><p>タスク3:</p></div>

`init.pp`マニフェストを開きます。

    vim pasture/manifests/init.pp

`file`リソースタイプには、管理するファイルのコンテンツの定義に使用できる2種類のパラメータがあります。`source`と`content`です。

すでに説明したように、`source`パラメータは、その値として、モジュールの`files`ディレクトリに置いたようなソースファイルのURIをとります。`content`パラメータは、値とした文字列をとり、管理するファイルのコンテンツをその文字列に設定します。 

テンプレートを用いてファイルのコンテンツを設定するために、ここではPuppet内蔵の`epp()`関数を使って、EPPテンプレートファイルを構文解析し、その結果得られた文字列を`content`パラメータの値に使用します。

この`epp()`関数は、2つの引数をとります。1つ目は、`'<MODULE>/<TEMPLATE_NAME>'`という形式のファイルリファレンスです。これは、使用するテンプレートファイルを指定します。2つ目は、テンプレートに渡す変数名と値のハッシュです。

`epp()`関数にすべての変数を詰め込むのを避けるために、`$pasture_config_hash`と呼ばれる変数にまとめ、ファイルリソースの直前に置きます。

```puppet
class pasture {

  $port                = '80'
  $default_character   = 'sheep'
  $default_message     = ''
  $pasture_config_file = '/etc/pasture_config.yaml'

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }
  $pasture_config_hash = {
    'port'              => $port,
    'default_character' => $default_character,
    'default_message'   => $default_message,
  }
  file { $pasture_config_file:
    content => epp('pasture/pasture_config.yaml.epp', $pasture_config_hash),
    notify  => Service['pasture'],
  }
  file { '/etc/systemd/system/pasture.service':
    source => 'puppet:///modules/pasture/pasture.service',
    notify  => Service['pasture'],
  }
  service { 'pasture':
    ensure    => running,
  }
}
```

設定できたら、サービスユニットファイルでもこのプロセスを繰り返すことができます。

`init.pp`ファイルを保存して閉じます。

<div class = "lvm-task-number"><p>タスク4:</p></div>

一から始める代わりに既存のファイルをコピーし、テンプレートの基礎として利用しましょう。

    cp pasture/files/pasture.service pasture/templates/pasture.service.epp

Vimでファイルを開き、テンプレート化します。

    vim pasture/templates/pasture.service.epp

ファイルの冒頭にパラメータタグとコメントを追加します。開始コマンドの`--config_file`引数を`$pasture_config_fle`の値に設定します。

```
<%- | $pasture_config_file = '/etc/pasture_config.yaml' | -%>
# This file is managed by Puppet. Please do not make manual changes.
[Unit]
Description=Run the pasture service

[Service]
Environment=RACK_ENV=production
ExecStart=/usr/local/bin/pasture start --config_file <%= $pasture_config_file %>

[Install]
WantedBy=multi-user.target
```

<div class = "lvm-task-number"><p>タスク5:</p></div>

`init.pp`マニフェストに戻ります。

    vim pasture/manifests/init.pp

サービスユニットファイルのファイルリソースを修正し、作成したばかりのテンプレートを使用するようにします。

```puppet
class pasture {

  $port                = '80'
  $default_character   = 'sheep'
  $default_message     = ''
  $pasture_config_file = '/etc/pasture_config.yaml'

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }
  $pasture_config_hash = {
    'port'              => $port,
    'default_character' => $default_character,
    'default_message'   => $default_message,
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
}
```

終わったら、`puppet parser`ツールを使って構文をチェックします。

    puppet parser validate pasture/manifests/init.pp

<div class = "lvm-task-number"><p>タスク6:</p></div>

`pasture.puppet.vm`に接続してPuppet実行を開始し、変更をテストします。クエストツールにより、このクエストの名前が付いた新規ノードが作成され、そのシステムがLearning VMの`/etc/hosts`に追加され、証明書署名プロセスが処理されました。これは新規システムですが、前回のクエストで扱っていたものと同じ名前がついています。そのため、`site.pp`マニフェストの分類が引き続き適用されます。

    ssh learning@pasture.puppet.vm

Puppet agent実行を開始します。

    sudo puppet agent -t

実行によりエラーが生じたら、コードに戻って検証してください。`puppet parser`ツールは構文エラーはチェックしますが、そのPuppetコードが適切にカタログにコンパイルされ、あるべき状態を定義することが保証されるわけではない点に留意してください。

Puppet実行が問題なく完了したら、接続を解除してLearning VMのセッションに戻ります。

もう一度`curl`コマンドを使って、デフォルトの変更が有効になっていることを確認します。

    curl 'pasture.puppet.vm/api/v1/cowsay?message=Hello!'

## おさらい

このクエストでは、*変数*と*テンプレート*について説明しました。`pasture`モジュールに手を加え、リソースおよび設定ファイル内のハードコードされた値を変数に置き換えました。

マニフェスト内で変数を設定し、ハッシュ構文とEPPテンプレート関数を使ってこれらの変数をテンプレートに渡す方法を学びました。`.epp`テンプレートでは、*パラメータタグ*を扱いました。これは、テンプレートの冒頭で使用し、テンプレート内で使用できる変数を指定するためのものです。また、テンプレート化したファイルのコンテンツに変数値を挿入する*表示式タグ*も扱いました。

変数は重要なコンセプトの要素で、今後のクエストでも扱うことは、すでにお話ししました。次のクエストでは、*パラメータ化したクラス*の作成方法を説明します。これを使えば、クラスの宣言時にクラス内の重要な値を設定することができます。パラメータを使えば、クラスが定義されているモジュールのコードを編集せずに、クラスの設定をカスタマイズすることが可能です。
