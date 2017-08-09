{% include '/version.md' %}

# クラスパラメータ

## クエストの目的

- 設定可能なクラスを記述する価値を理解する。
- *パラメータ化されたクラス*を作成するための構文を学ぶ。
- *リソースライクな*クラス宣言構文を用いて、
  クラスのパラメータを設定する方法を学ぶ。

## はじめに

前回のクエストでは、変数を用いて`pasture`モジュールに若干の柔軟性を持たせました。しかし、これまでのところ、変数はすべて、クラスそのもののなかで割り当てられています。

Puppetでは、モジュールを適切に記述することで、モジュール自体を編集しなくても重要な変数をすべてカスタマイズすることが可能です。これには*クラスパラメータ*を使用します。パラメータをクラスに書き込めば、リソース宣言構文と同様のパラメータ値ペアのセットを用いて、そのクラスを宣言することができます。これにより、変数を定義するモジュールに変更を加えずに、クラス内のすべての重要な変数をカスタマイズすることが可能になります。

準備ができたら、以下のコマンドを入力してください。

    quest begin class_parameters

## パラメータ化されたクラスの記述

クラスのパラメータは、パラメータ名とデフォルト値のペア(`$parameter_name = default_value,`)のカンマ区切りリストとして定義されます。これらのパラメータ値ペアは、括弧 (`(...)`)で囲み、クラス名と、クラス本体の開始を示す開き波括弧 (`{`) の間に置きます。読みやすくするために、複数のパラメータは1行に1つずつ記載します。例えば、以下のようになります。

```puppet
class class_name (
  $parameter_one = default_value_one,
  $parameter_two = default_value_two,
){
 ...
}
```

パラメータのリストはカンマで区切る必要がありますが、クラス本体内の変数セットはカンマ区切りがない点に注意してください。これは、Puppetの構文解析ツールがこれらのパラメータをリストとして処理する一方で、クラス本体の割り当てられた変数は個々の文として処理されるためです。これらのパラメータは、クラス本体内で変数として使用できます。

<div class = "lvm-task-number"><p>タスク1:</p></div>

はじめに、メインの`pasture`クラスを修正し、クラスパラメータを使用するようにしましょう。`init.pp`マニフェストを開きます。

    vim pasture/manifests/init.pp

パラメータリストが、前のクエストで使用した変数割り当てに置き換えられます。パラメータのデフォルトをそれらの変数に割り当てたものと同じ値に設定すれば、そのクラスのデフォルト挙動を同じ状態に保つことができます。

クラスの最初の変数セットを削除し、対応するパラメータセットを追加します。これが終わると、クラスは以下の例のようになるはずです。

```puppet
class pasture (
  $port                = '80',
  $default_character   = 'sheep',
  $default_message     = '',
  $pasture_config_file = '/etc/pasture_config.yaml',
){

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

これらの変更を加えたら、ファイルを保存して閉じます。`puppet parser`ツールを使って構文をチェックします。

    puppet parser validate pasture/manifests/init.pp

## リソースライクなクラス宣言

これで、クラスにパラメータを持たせることができました。次はこのパラメータの設定方法を見ていきましょう。

これまでは、`include`を用いて、`site.pp`マニフェスト内でノード分類の一環としてクラスを宣言してきました。この`include`関数は、パラメータを明示的に設定せずにクラスを宣言するものです。これにより、クラス内のパラメータでデフォルト値を使用できます。デフォルトのないパラメータは、特別な`undef`値をとります。

特定のパラメータでクラスを宣言するには、*リソースライクなクラス宣言*を使用します。リソースライクなクラス宣言の構文は、名前どおり、リソース宣言とよく似ています。キーワード`class`の後に、波括弧(`{...}`)で囲まれたクラス名とコロン (`:`)、パラメータと値のリストが続く構成になっています。この宣言で省略された値は、クラス内で定義されたデフォルトに設定されます。デフォルトが設定されていない場合は、`undef`に設定されます。

```puppet
class { 'class_name':
  parameter_one => value_one,
  parameter_two => value_two,
}
```

複数の場所で同じクラスに使用できる`include`関数とは異なり、リソースライクなクラス宣言は、1つのクラスにつき一度しか使用できません。`include`で宣言されたクラスはデフォルトを使用するため、常にカタログ内と同じリソースセットとして扱われます。つまり、同一クラスに関する複数の`include`コールをPuppetが安全に処理できるということです。複数のリソースライクなクラス宣言は、同じリソースセットにつながることが保証されていないため、Puppetには、同じクラスの複数のリソースライクなクラス宣言を処理する一義的な方法はありません。同じクラスで複数のリソースライクなクラス宣言を試みると、Puppetの構文解析ツールによりエラーが生じます。

ここでは詳細は説明しませんが、`facter`や`hiera`といった外部データソースを使えば、include構文を用いる場合でも、クラスに関して大幅な柔軟性を得られる点は知っておいてください。 今の時点では、`include`関数ではデフォルトを使うものの、このデフォルトをインテリジェントなものにする方法があることに留意しておいてください。

<div class = "lvm-task-number"><p>タスク2:</p></div>

では、リソースライクなクラス宣言を使って、`site.pp`マニフェストから`pasture`クラスをカスタマイズしていきましょう。 ほとんどのデフォルトはまだきちんと機能していますが、この例に関しては、Pastureアプリケーションのインスタンスを設定し、パラメータのデフォルトとして設定した「sheep」のかわりに、典型的な文字の「cow」を使いましょう。

`site.pp`マニフェストを開きます。

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

`pasture.puppet.vm`のノード定義を修正し、リソースライクなクラス宣言を含めます。`default_character`パラメータを`'cow'`という文字列に変更し、その他の2つのパラメータは設定せずに、デフォルト値をとるようにします。

```puppet
node 'pasture.puppet.vm' {
  class { 'pasture':
    default_character => 'cow',
  }
}
```

注目すべき点は、クラスパラメータ設定では、Pastureアプリケーションのすべてのコンポーネントで必要なすべての設定を、単一のリソースライクなクラス宣言で処理できることです。通常はこのアプリケーションの管理には様々なコマンドやファイルフォーマットが関係していますが、クラスパラメータ設定ではこれを単一のパラメータと値のセットに集約できます。

<div class = "lvm-task-number"><p>タスク3:</p></div>

`pasture.puppet.vm`ノードに接続しましょう。

    ssh learning@pasture.puppet.vm

Puppet agent実行を開始し、このパラメータ化したクラスを適用します。

    sudo puppet agent -t

実行が完了したら、masterに戻ります。

    exit

変更が反映されていることを確かめます。

    curl 'pasture.puppet.vm/api/v1/cowsay?message=Hello!'

## おさらい

このクエストでは、宣言されたクラスをカスタマイズする方法として*クラスパラメータ*を紹介しました。このパラメータを使えば、単一のインターフェースを設定し、Puppetモジュールで管理するシステムのあらゆる面をカスタマイズすることができます。

また、`include`関数を復習し、*リソースライクなクラス宣言*についても説明しました。これは、宣言されたクラスのパラメータの値を指定するための構文です。

次のクエストでは、*facts*を扱います。これを使えば、agentシステムに関するデータをPuppetコードに簡単に盛り込むことができます。
