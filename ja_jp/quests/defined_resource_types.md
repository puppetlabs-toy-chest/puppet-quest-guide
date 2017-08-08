{% include '/version.md' %}

# 定義リソース型

## クエストの目的

- *定義リソース型*を使ってリソースグループを管理する。
- 定義リソース型とクラスの違いを理解する。
- 定義リソース型に含まれるリソースの独特の制約の扱い方を
  理解する。
- 定義リソース型を使ってユーザアカウントとSSHキーを管理する。

## はじめに

このクエストでは、ユーザアカウントとそのSSHキーの管理に役立つモジュールを作成します。各ユーザについて、ユーザアカウント本体、ユーザのSSHキー、ユーザのホームディレクトリを管理します。このリソースセットを1人のユーザについてのみ管理する場合は、クラスを作成すれば対処できます。しかし、システムにアクセスする多数のユーザを対象に、それぞれ多数のリソースを管理する可能性のほうが高いでしょう。このような場合はクラスだけでは不十分です。Puppetのクラスは*シングルトン*のため、1つのノードのカタログ内で一度しか宣言できません。

かわりに、ここでは*定義リソース型*を使います。定義リソース型は、構文という点ではクラスによく似たPuppetコードブロックです。パラメータをとり、変数や条件などの他のPuppetコードとともにリソースの集合を含み、そうしたリソースがノードのカタログ内でどのように定義されるかを制御します。クラスとは異なり、定義リソース型はシングルトンではないため、同一のノードで複数回宣言することができます。

準備ができたら、以下のコマンドを入力してください。

    quest begin defined_resource_types

## 定義リソース型

> 反復―それは現実であり、真の存在である。

> -セーレン・キェルケゴール

[定義リソース型](https://docs.puppet.com/puppet/latest/lang_defined_types.html)は、単一のノードのカタログ内で複数回評価することのできるPuppetコードのブロックです。

定義リソース型を作成するための構文は、クラスの定義に用いる構文とよく似ています。ただし、`class`キーワードを使う代わりに、このコードブロックは`define`から始まります。

```puppet
define defined_type_name (
  parameter_one = default_value,
  parameter_two = default_value,
){
  ...
}
```

定義した後は、定義リソース型を他のリソースと同じように使用できます。

```puppet
defined_type_name { 'title':
  parameter_one => 'foo',
  parameter_two => 'bar',
}
```

定義リソース型はシングルトンではないため、定義リソース型を複数回宣言する際に、そこに含まれるリソースがリソース一意性の制約を違反しないよう注意する必要があります。

リソースには、一意の*タイトル*と*namevar*が必要です。リソースのタイトルは、Puppet内における一意の識別子であり、namevarはリソースが管理するシステムの固有の要素を指定するものです。

では、リソースの一意性はどのように保証すればよいでしょうか？　定義リソースを定義するコードブロック内に、「フリーの」`$title`を用意します。定義リソースインスタンスを宣言する際には、この`$title`変数を定義リソースインスタンスのタイトルに設定します。この `$title`変数を、定義リソース型に含まれる各リソースのタイトルに組み込めば、定義リソース型のタイトルが一意である限り、そこに含まれるリソースも一意になります。

まずは、`user_accounts`モジュールで、この機能の例を見ていきましょう。クラスと同様、定義リソース型はモジュール内で定義する必要があります。多くの場合、定義リソース型は、モジュールに含めれば、そのモジュールのクラスが提供する機能をサポートすることができます。たとえば、前回のクエストで使用した`postgresql`モジュールの提供する定義リソース型は、データベース、ユーザ、許可などを管理するのに役立ちます。しかしここでは、定義リソース型のスタンドアロンモジュールを作成します。 

まず、モジュールのディレクトリ構造を作成します。

    mkdir -p user_accounts/manifests

`user_account.pp`マニフェストからはじめます。ここに、`ssh_users::user_account`定義リソース型を記述します。

    vim user_accounts/manifests/ssh_user.pp

ここでは、ユーザアカウントとそのユーザのSSH公開キーを管理するため、ユーザリソースの基本的なパラメータいくつかと、ユーザの公開キーの`pub_key`パラメータを提示します。

```puppet
define user_accounts::ssh_user (
  $key     = undef,
  $group   = undef,
  $shell   = undef,
  $comment = undef,
){
  ...
}
```

これらのパラメータのデフォルトが特殊な値`undef`に設定されている点に注目してください。リソースパラメータの値として`undef`を渡すと、設定していない状態と同じ扱いになります。これらのパラメータを、定義リソース型ブロック内の実際の`user`リソースに渡すと、`user`タイプでそれぞれのデフォルトを使用することができます。

`$key`パラメータについては、パラメータが設定されていない場合にユーザの認証済みキーの `ssh_authorized_key`リソースの管理をスキップするように 、条件を使って定義リソース型に指示します。この方法が使えるのは、`undef`値が条件文で `false`と評価されるためです。

定義リソース型を完成させるのに必要なツールはあと1つ、変数について説明した際に簡単に紹介したツールだけです。すでに述べたように、定義リソース型内のすべてのリソースの一意性を確保するためには、定義リソース型そのもののタイトルを、それに含まれるリソースのタイトルに(明示的に設定されている場合にはnamevarsにも)組み込む必要があります。

しかし、多くの場合は、この`$title`を文字列に挿入し、リソースのフルタイトルを作成する必要があります。例えば、`ssh_authorized_key`リソースのタイトルは、`"${title}@puppet.vm"`のようになります。これは[文字列補間](https://docs.puppet.com/puppet/latest/lang_variables.html#interpolation)と呼ばれます。Puppetでは、ダブルクォーテーションで囲まれた文字列(`"..."`)内の変数のみが補間されます。

`ssh_authorized_key`、`user`、`file`の各リソースを定義型の本体に追加します。 

```puppet
define user_accounts::ssh_user (
  $key     = undef,
  $group   = undef,
  $shell   = undef,
  $comment = undef,
){

  if $key {
    ssh_authorized_key { "${title}@puppet.vm":
      ensure => present,
      user   => $title,
      type   => 'ssh-rsa',
      key    => $key,
    }
  }

  user { $title:
    ensure  => present,
    groups  => $group,
    shell   => $shell,
    home    => "/home/${title}",
    comment => $comment,
  }

  file { ["/home/${title}", "/home/${title}/.ssh"]:
    ensure  => directory,
    owner   => $title,
    group   => $title,
    mode    => '0775',
  }
} 
```

通常、このシステム上にアカウントを必要とするユーザには、各自の公開キーを提供することを求めるはずです。ここでは、デモンストレーションのために自身のキーを生成します。キーペアのプライベートキーは、学習中のユーザの`~/.ssh`ディレクトリに保存されているので、これらのアカウントをテストします。

    ssh-keygen -t rsa

デフォルトのロケーションを許可し、パスワード*puppet*を入力します。

このキー設定により、システム上に必要なユーザを実際に宣言するPuppetコードを書く準備ができました。このディレクトリを`site.pp` マニフェスト内に置く代わりに`pasture_dev_users`プロフィールクラスを作成し、ここで定義リソース型を使って、システムで管理するユーザセットを指定します。

このクラスを定義するマニフェストを作成する前に、生成した公開キーファイルを開き、コンテンツをコピーして、マニフェストにペーストできるようにしておきます。 

    vim ~/.ssh/id_rsa.pub

`ssh-rsa`と`root@learning.puppet.vm`は含めず、実際のキーのみをコピーしてください。前後の余白を含めないように注意してください。コンソールでの改行の表示方法によっては、キーをペーストした後で改行文字や余白を手動で削除する必要があるかもしれません。

次に、`dev_users.pp`プロフィールマニフェストを作成します。

    vim profile/manifests/pasture/dev_users.pp

ここでは、BertとErnieのユーザアカウントを作成します。いずれも、サーバへのアクセスを必要とする想像上の同僚です。

```puppet
class profile::pasture::dev_users {
  user_accounts::ssh_user { 'bert':
    comment => 'Bert',
    key => '<PASTE KEY HERE>',
  }
  user_accounts::ssh_user { 'ernie':
    comment => 'Ernie',
    key => '<PASTE KEY HERE>',
  }
}
```

この`profile::pasture::dev_users`クラスを設定したら、これを`role::pasture_app`クラスに簡単に入れ込み、ユーザアカウントを追加し、そのSSHキーを設定することができます。

    vim /etc/puppetlabs/code/environments/production/modules/role/manifests/pasture_app.pp

```puppet
class role::pasture_app {
  include profile::pasture::app
  include profile::pasture::dev_users
  include profile::base::motd
}
```

`puppet job`ツールを使ってPuppet agent実行を開始します(トークンの期限が切れている場合は、`puppet access login --lifetime 1d`を実行し、認証情報**learning**および**puppet**を使って新規アクセストークンを生成してください)。

    puppet job run --nodes pasture-app-small.puppet.vm

Puppet実行が完了したら、ユーザ`bert`として`pasture-app-small.puppet.vm`に接続します。

    ssh bert@pasture-dev.puppet.vm

このユーザとして接続できることを確認したら、そのまま接続を終了します。

    exit

## おさらい

このクエストでは、定義リソース型について説明しました。これは、一群のリソース宣言を、反復と設定が可能なグループにまとめるためのものです。

ここでは、定義リソース型を使用する際に覚えておくべきポイントをいくつか説明しました。

  * 定義リソース型の定義はクラス宣言の構文と似ていますが、
    `class`のかわりに`define`キーワードを使用します。
  * 構成要素となるリソースのタイトルに`$title`変数を使用し、
    一意性を確保します。
  * デフォルトとして`undef`値を使用すれば、定義リソース型の宣言時に、パラメータを
    指定しないままにしておくことができます。
