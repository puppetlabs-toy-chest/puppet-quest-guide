{% include '/version.md' %}

# 定義リソース型

## クエストの目的

- *定義リソース型*を使ってリソースグループを管理する。
- 定義リソース型とクラスの違いを理解する。
- 定義リソース型に含まれるリソースの独特の制約の扱い方を
  理解する。
- 定義リソース型を使ってユーザアカウントとSSHキーを管理する。

## はじめに

このガイドのクラスについての説明で先に述べたとおり、Puppetのクラスは*シングルトン*です。つまり、Puppet言語のクラスは、1つのカタログにつき1回しか存在できません。Puppetコードでクラスを2回宣言するとコンパイルエラーになります。多くのシステムコンポーネントにおいて、このシングルトンクラスの概念は、ノード上のクラスで管理されるコンポーネントのシングルインスタンスまたは単一のインストールに好適です。たとえば、Apacheサーバーは一般的に`httpd`サービスを1インスタンスのみ実行し、1セットの設定ファイルを持ちます。このような場合、Puppetのクラスはシングルトンであるため、対応するコンポーネントの設定について複数の競合する仕様が生じることがありません。

しかし、場合によっては、このような1対1の対応が有効ではないこともあります。たとえば、1つのApache `httpd`プロセスが複数の仮想ホストにサービスを提供している場合などです。このクエストでは、単純な例としてユーザアカウントを取り上げます。Puppetにはビルトインの`user`リソース型がありますが、システム管理者はその他の幅広いリソースをユーザごとに管理しなければならないことも多いでしょう。このクエストでは、各ユーザアカウントにSSHキーをセットアップするエクササイズを行いますが、その原則は、その他のさまざまなユーザ関連リソースに簡単に応用することができます。

Puppet言語でこのような、反復可能なリソースグループのニーズに対応するには、*定義リソース型*を使います。定義リソース型は、構文規則的にはクラスによく似たPuppetコードブロックです。クラスと同様、パラメータをとり、そのパラメータを使用して関連するリソースのグループを設定します。ただし、クラスとは異なり、定義リソース型はシングルトンではありません。つまり、定義リソース型は、同一のノードで複数回宣言することができます。

準備ができたら、以下のコマンドを入力してください。

    quest begin defined_resource_types

## 定義リソース型

> 反復―それは現実であり、真の存在である。

> -セーレン・キェルケゴール

[定義リソース型](https://puppet.com/docs/puppet/latest/lang_defined_types.html)は、単一のノードのカタログ内で複数回評価することのできるPuppetコードのブロックです。

定義リソース型を作成するための構文は、クラスの定義に用いる構文とよく似ています。ただし、`class`キーワードを使う代わりに、このコードブロックは`define`から始まります。

```puppet
define defined_type_name (
  parameter_one = default_value,
  parameter_two = default_value,
){
  ...
}
```

定義した後は、他のリソースと同じように宣言して、定義リソース型を使用できます。

```puppet
defined_type_name { 'title':
  parameter_one => 'foo',
  parameter_two => 'bar',
}
```

定義リソース型はシングルトンではないため、定義リソース型を複数回宣言する際は、そこに含まれるリソースがリソース一意性の制約に違反しないよう注意する必要があります。

次に進む前に、少し時間をとって、その制約について見ていきましょう。コンパイル中に重複リソースエラーが発生しないよう、すべてのリソースは、同じ型の他のリソースと重複しない*title*および*namevar*パラメータを持つ必要があります。

## リソース一意性の制約

リソースの*title*は、Puppetユーザがそのリソースを内部的に追跡するための一意の識別子です。たとえば、リソースの関係性は、リソースタイトルに基づいてリソース間の依存関係を指定します。リソースタイトルは、Puppet実行中にリソースの状態が変化したときのログとレポートにも使用されます。

リソースの*namevar*は、リソースが管理する対象のシステム上で一意の側面を指定するパラメータです。それぞれのリソースが実際に*namevar*という名前のパラメータを持つわけではなく、そのような役割を果たすパラメータを指す用語がnamevarです。たとえば、`file`リソースのnamevarは`path`パラメータです。リソースに一意のnamevarを要求することで、Puppetパーサは対象システムのある1つの側面の状態について競合する複数の定義を作成しないで済みます。もし、Puppetが同一の`path`パラメータを持つ2つの`file`リソース定義を許容したとしたら、そのパスをもつそのファイルについて、どちらのリソース定義を適用すべきか分からなくなるでしょう。

リソースのタイトルとnamevarは別個のものですが、一般的に、あるリソースのnamevarに指定する値は、分かりやすい一意のタイトルの良い候補になります。たとえば、ファイルリソースの`path`が`/etc/hosts`の場合、そのパスをリソースタイトルにすれば、リソースの管理対象がすぐ分かります。そのため、リソースのnamevarをタイトルとして使用することが通例です。この通例をサポートするため、タイトルを明示的に異なる値に設定しない限り、タイトルのデフォルト値としてリソースのnamevarが設定されます。`file`リソースや`package`リソースのタイトルとしてファイルパスやパッケージ名が使用され、`path`や`name`パラメータが未設定になっていることが多いのはこのためです。

## 定義リソース型における一意性の維持

ここまででリソース一意性の制約について理解しましたが、定義リソース型に含まれるリソースの一意性を保証するにはどうしたらよいでしょうか。

Puppetにビルトインされた任意のリソース型を宣言する際にタイトルを含めるのと同様に、定義リソース型を宣言する際にもタイトルを含めます。定義リソース型を宣言する際に指定したタイトルは、定義リソース型のコードブロック内で`$title`変数として利用できるようになります。この`$title`変数を定義リソース型に含まれる各リソースのタイトルに組み込むことで、 定義リソース型が一意のタイトルで宣言されている限り、そこに含まれるリソースも一意になります。

## ユーザアカウントの管理

以上すべてを組み合わせて使用する方法について、`ssh_user`定義リソース型を例に見ていきましょう。

クラスと同様、定義リソース型はモジュール内で定義する必要があります。多くの場合、定義リソース型は、モジュールに含めることで、そのモジュールのクラスが提供する機能をサポートします。たとえば、前回のクエストで使用した`postgresql`モジュールで提供する定義リソース型は、データベース、ユーザ、許可などのさまざまなデータベース設定管理に関係するリソースのグループを管理するのに役立ちます。しかしここでは、分かりやすくするため、定義リソース型を含むスタンドアロンのモジュールを作成します。

<div class = "lvm-task-number"><p>タスク1:</p></div>

始める前に、モジュールディレクトリで作業していることを確認します。

    cd /etc/puppetlabs/code/environments/production/modules

`user_accounts`モジュールのディレクトリ構造を作成します。

    mkdir -p user_accounts/manifests

<div class = "lvm-task-number"><p>タスク2:</p></div>

次に、`ssh_user.pp`マニフェストを作成し、その中に`user_accounts::ssh_user`定義リソース型を含めます。

    vim user_accounts/manifests/ssh_user.pp

ここでは、ユーザアカウントとそのユーザのSSH公開キーを管理するため、ユーザリソースの基本的なパラメータいくつかと、ユーザの公開キーの`key`パラメータを提示します。

この定義リソース型のパラメータリストは次のようになるはずです。

```puppet
define user_accounts::ssh_user (
  $key,
  $group   = undef,
  $shell   = undef,
  $comment = undef,
){
  ...
}
```

`$key`パラメータにはデフォルト値が存在せず、その他のパラメータのデフォルト値は'undef'に設定されていることに注意してください。ここには重要な違いがあります。

デフォルト値のないパラメータが必要なのです。`$key`パラメータのデフォルト値を省略するということは、`$key`パラメータに値を指定せずにこの`ssh_user`定義リソース型のインスタンスを宣言して、コンパイルエラーになるということです。このリソースには、公開鍵認証によってSSHアクセスを適切に提供するためにユーザの公開鍵が必要なため、これは望ましい挙動です。

```puppet
  ssh_authorized_key { "${title}@puppet.vm":
    ensure => present,
    user   => $title,
    type   => 'ssh-rsa',
    key    => $key,
  }
```

一方、`group`、`shell`、`comment`パラメータは必須ではありません。`ssh_user`定義リソース型は、システム上の実際のユーザアカウントに対する通常の`user`リソースを含んでいます。

```puppet
  user { $title:
    ensure  => present,
    groups  => $group,
    shell   => $shell,
    home    => "/home/${title}",
    comment => $comment,
  }
```

`user`リソースには、`group`、`shell`、`comment`を扱う自身のデフォルト値が既にあります。そのため、望ましい挙動は、パラメータで値が受け渡された場合はその値を使い、定義リソース型宣言時に提供されなかったパラメータについては`user`型自身のデフォルト値に戻すことです。

`undef`という特別な値を使えば、その両方を実現することができます。`undef`は、内部的には、未設定の変数またはパラメータを評価するときにPuppetが扱う値そのものです。これをオプションのパラメータのデフォルト値として設定しておけば、文字通り「undefined=未定義」のパラメータ状態を配下の`user`リソースに受け渡し、`user`リソースのパラメータをデフォルト動作に戻すことができます。

これらの`user`リソースおよび`ssh_authorized_key`リソースと、ユーザのホームディレクトリと`.ssh`ディレクトリを管理する`file`リソースを組み合わせると、`user_accounts::ssh_user`定義リソース型は次のようになります。

[//]: # (code/130_defined_resource_types/modules/user_accounts/manifests/ssh_user.pp)

```puppet
define user_accounts::ssh_user (
  $key,
  $group   = undef,
  $shell   = undef,
  $comment = undef,
){
  ssh_authorized_key { "${title}@puppet.vm":
    ensure => present,
    user   => $title,
    type   => 'ssh-rsa',
    key    => $key,
  }
  file { "/home/${title}/.ssh":
    ensure => directory,
    owner  => $title,
    group  => $title,
    mode   => '0700',
    before => Ssh_authorized_key["${title}@puppet.vm"],
  }
  user { $title:
    ensure  => present,
    groups  => $group,
    shell   => $shell,
    home    => "/home/${title}",
    comment => $comment,
  }
  file { "/home/${title}":
    ensure => directory,
    owner  => $title,
    group  => $title,
    mode   => '0755',
  }
}
```

## 文字列の補間

このコードに、もう1つ新しい構文規則要素が加わったことにお気付きでしょうか。このマニフェストでダブルクォートで囲まれた文字列(`"..."`)に`${var_name}`形式の変数が含まれている箇所があります。これは、Puppetの[文字列の補間](https://puppet.com/docs/puppet/latest/lang_variables.html#interpolation)という構文規則です。文字列の補間を使用すると、ダブルクォートで囲まれた任意の文字列に変数を挿入できます。

文字列の補間はPuppet全体で役に立ちますが、その中でも、定義リソース型では特に重要な役割を果たします。なぜなら、文字列の補間を使用することで、定義リソース型の`$title` 変数を、その構成要素である各リソースのタイトルに組み込むことが可能になるからです。たとえば、`ssh_authorized_key`リソースのタイトルは、`"${title}@puppet.vm"`のようになります。

なぜ、これがそれほど重要なのでしょうか。定義リソース型の本体に含まれるすべてのリソースは、その他のPuppetリソースと同じ一意性の制約を満たす必要があるということを思い出してください。`user`リソースの場合のように直接的に、もしくは文字列の補間によって間接的に、定義リソース型に与えた一意性をその構成要素となる各リソースに受け渡すことで、定義リソース型に含まれるすべてのリソースの一意性を保証することが可能になるのです。

<div class = "lvm-task-number"><p>タスク3:</p></div>

通常は、このシステム上にアカウントを必要とするユーザに、各自の公開鍵を提供するよう要求するでしょう。しかし、ここではデモという目的上、鍵のペアを1つ生成し、管理対象のすべてのユーザに対して利用することにします。そうすることで、あなたも管理対象ユーザの1人としてログインし、定義リソース型が期待通りに動作しているか検証できるようになります。

`ssh-keygen`コマンドを使用して新しい鍵ペアを作成します。

    ssh-keygen -t rsa

デフォルトのロケーションを許可し、パスワード*puppet*を入力します。

この鍵が作成されたので、システムへのアクセスを許可するユーザを宣言するためのPuppetコードを記述する準備が整いました。

<div class = "lvm-task-number"><p>タスク4:</p></div>

ロールおよびプロファイルパターンについて学習する前は、これを`site.pp`マニフェストに直接配置していたかもしれませんが、ここでは、`pasture_dev_users`プロファイルクラスを作成し、Hieraルックアップを使用して、インフラストラクチャ内の各システムに必要なユーザをプログラム的に作成します。

ここでは、`beauvine.vm`ドメインに含まれるすべてのノード上のユーザアカウントを含めるため、`/etc/puppetlabs/code/environments/production/data/domain/beauvine.vm.yaml`にある`domain/beauvine.vm.yaml` Hieraデータソースを編集します。

まだモジュールディレクトリで作業しているものとして、1階層上の`/etc/puppetlabs/code/environments/production/`に上がり、この`data`ディレクトリにアクセスしやすくします。

    cd ..

編集するデータファイルを開く前に、少々手間を省くため、bashの`>>`アペンド演算子を使用して、`id_rsa.pub`公開鍵をデータファイルの末尾に付加します。

    cat ~/.ssh/id_rsa.pub >> data/domain/beauvine.vm.yaml

次のファイルを開きます。

    vim data/domain/beauvine.vm.yaml

`profile::base::dev_users::users:`のHiera値を定義するために新しい行を作成します。ここで、Hieraの構造化データの特性を利用して、新規に`ssh_user`のインスタンスを2つ定義し、それぞれにパラメータを設定します。ここでは、YAMLデータファイルにこのデータを正しく入力することだけに集中しましょう。この構造化データがPuppetマニフェストによって実際にどのように実装されるかについては、少し後で説明します。

ファイルの最終的な内容を以下に示していますが、Vimに慣れていない場合、大きい`pub_key`ブロックは扱いにくいかもしれません(Vimを使い慣れている場合は、この段落を省略して構いません)。

VMまず、鍵の冒頭と末尾から、文字列`ssh-rsa`および`root@learning.puppetlabs.vm`を削除する必要があります。そのため、鍵が記述されている行にカーソルを置きます。必ず、`ESC`キーを押して、コマンドモードになっていることを確認しておいてください。コマンドモードなら、`^`キーで行頭、`$`キーで行末へと簡単に移動できます。`ssh-rsa`または`root@learning.puppetlabs.vm`文字列の上にカーソルが来たら、コマンドモードでコマンド`daW`を使用して削除できます。同じ鍵を両方のユーザで使用するため、鍵をコピーする必要もあります。コマンド`yy`で行をコピーし、`p`キーでカーソル位置にペーストできます。また、`dd`コマンドで行を削除できます。

完了すると、データファイルは次の例のようになるはずです(公開鍵の内容は例と異なる可能性があります)。`pub_key:`はすべて1行に収まっている必要があることに注意してください。

[//]: # (code/130_defined_resource_types/data/domain/beauvine.vm.yaml)

```yaml
---
profile::pasture::app::default_message: "Welcome to Beauvine!"
profile::base::dev_users::users:
  - title: 'bessie'
    comment: 'Bessie Johnson'
    pub_key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCVWbkvtB4G/x9eEHXUkFfQgJuxBNJ3MCJ
3BWbYHb+Ksmd2I92G9wSVFWRDvLzciOsWkbjfSWHrql+82lgplyxBHZZYlf0eK3ytkSL5hvQtOmLW
MDcWNbHnt7qZFA0j6/h43SG0POmkG1iHSHnlwvbcpJoYZZpKz5+Iq7P9JmOv7zf8UsJtQccWHxAHc
J+xJ6xZJ2EBziWUCMPxLnD3zNQaW0r/B3pRMT+7F1gDHJ8HuNVklcQGCpVS+WrfpNMJ5+L25Aw/H2
Bg33o+0esH5FL8M8IR3Xkgp80NAQqmyVi7cx+c9n4RjEdMGk3XtutPNsSLcgm8/YZqv/yTRH6wAQl
/'
  - title: 'gertie'
    comment: 'Gertie Philips'
    pub_key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCVWbkvtB4G/x9eEHXUkFfQgJuxBNJ3MCJ
3BWbYHb+Ksmd2I92G9wSVFWRDvLzciOsWkbjfSWHrql+82lgplyxBHZZYlf0eK3ytkSL5hvQtOmLW
MDcWNbHnt7qZFA0j6/h43SG0POmkG1iHSHnlwvbcpJoYZZpKz5+Iq7P9JmOv7zf8UsJtQccWHxAHc
J+xJ6xZJ2EBziWUCMPxLnD3zNQaW0r/B3pRMT+7F1gDHJ8HuNVklcQGCpVS+WrfpNMJ5+L25Aw/H2
Bg33o+0esH5FL8M8IR3Xkgp80NAQqmyVi7cx+c9n4RjEdMGk3XtutPNsSLcgm8/YZqv/yTRH6wAQl
/'
```

Rubyのワンライナーを使用して、YAMLファイルが正常に解析できることを確認できます。

    ruby -e "require 'yaml';require 'pp';pp YAML.load_file('./data/domain/beauvine.vm.yaml')"

アウトプットは以下のようになるはずです。

```json
{"profile::pasture::app::default_message"=>"Welcome to Beauvine!",
 "profile::base::dev_users::users"=>
  [{"title"=>"bessie",
    "comment"=>"Bessie Johnson",
    "pub_key"=>
     "AAAAB3NzaC1yc2EAAAADAQABAAABAQCVWbkvtB4G/x9eEHXUkFfQgJuxBNJ3MCJ3BWbYHb+
Ksmd2I92G9wSVFWRDvLzciOsWkbjfSWHrql+82lgplyxBHZZYlf0eK3ytkSL5hvQtOmLWMDcWNbHn
t7qZFA0j6/h43SG0POmkG1iHSHnlwvbcpJoYZZpKz5+Iq7P9JmOv7zf8UsJtQccWHxAHcJ+xJ6xZJ
2EBziWUCMPxLnD3zNQaW0r/B3pRMT+7F1gDHJ8HuNVklcQGCpVS+WrfpNMJ5+L25Aw/H2Bg33o+0e
sH5FL8M8IR3Xkgp80NAQqmyVi7cx+c9n4RjEdMGk3XtutPNsSLcgm8/YZqv/yTRH6wAQl/"},
   {"title"=>"gertie",
    "comment"=>"Gertie Philips",
    "pub_key"=>
     "AAAAB3NzaC1yc2EAAAADAQABAAABAQCVWbkvtB4G/x9eEHXUkFfQgJuxBNJ3MCJ3BWbYHb+
Ksmd2I92G9wSVFWRDvLzciOsWkbjfSWHrql+82lgplyxBHZZYlf0eK3ytkSL5hvQtOmLWMDcWNbHn
t7qZFA0j6/h43SG0POmkG1iHSHnlwvbcpJoYZZpKz5+Iq7P9JmOv7zf8UsJtQccWHxAHcJ+xJ6xZJ
2EBziWUCMPxLnD3zNQaW0r/B3pRMT+7F1gDHJ8HuNVklcQGCpVS+WrfpNMJ5+L25Aw/H2Bg33o+0e
sH5FL8M8IR3Xkgp80NAQqmyVi7cx+c9n4RjEdMGk3XtutPNsSLcgm8/YZqv/yTRH6wAQl/"}]}
```

また、`common.yaml`データソースに変更を加え、この鍵のデフォルト値を設定します。
この場合、値は空のリストに設定します。そうすることで、Hieraが`beauvine.vm`ドメインの外でこの値をルックアップしようとした場合でも、有効な結果を得られるようになります。

    vim data/common.yaml

`common.yaml`ファイルは、以下のようになるはずです。

[//]: # (code/130_defined_resource_types/data/common.yaml)

```yaml
---
profile::pasture::app::default_message: "Baa"
profile::pasture::app::sinatra_server: "thin"
profile::pasture::app::default_character: "sheep"
profile::pasture::app::db: "none"
profile::base::dev_users::users: []
```

<div class = "lvm-task-number"><p>タスク5:</p></div>

これでデータがHieraで利用できるようになったので、`profile/manifests/base/`に`dev_users.pp`マニフェストを作成します。

    vim profile/manifests/base/dev_users.pp

これで、`user_accounts::ssh_user`定義リソース型が、ひと組のパラメータ入力からのSSH鍵を利用して新しいユーザアカウントを作成する方法を提供し、Hieraデータファイルが各ユーザのための入力リストを定義するよう設定されました。しかし、コードにおいてこれらのデータを組み合わせる方法についてはまだ取り組んでいません。

ここで、[イテレータ](https://puppet.com/docs/puppet/latest/lang_iteration.html)と呼ばれるPuppet言語の機能を使用します。イテレータを使用すると、Puppetコードのブロックを複数回反復することができます。このとき、ハッシュまたは配列のデータを使用して、各反復につき、ブロック内の変数に異なる値をバインドします。今回の場合、イテレータはHieraデータソースで定義されたユーザアカウントのリストを処理して、それぞれについて`user_accounts::ssh_user`定義リソース型のインスタンスを宣言します。

[//]: # (code/130_defined_resource_types/modules/profile/manifests/base/dev_users.pp)

```puppet
class profile::base::dev_users {
  lookup(profile::base::dev_users::users).each |$user| {
    user_accounts::ssh_user { $user['title']:
        comment => $user['comment'],
        key => $user['pub_key'],
    }
  }
}
```

反復を使用する際は、コードの読みやすさとメンテナンスしやすさに十分注意を払ってください。Puppet言語の良い点の1つは、宣言型言語としての特性上、Puppetのコードそのものが人間が理解できる言語でシステムの望ましい状態を表せることです。反復をむやみに使用すると、Puppetコードの複雑性が増し、コードの読みやすさが損なわれ、メンテナンスが困難になることがあります。

今回の場合、ロールおよびプロファイルパターン、Hiera、および定義リソース型を用いることで、残りのコードが十分シンプルなため、イテレータの役割が非常に明確です。Puppetの構文規則の基本を理解していれば、簡単に行に沿って「Hieraからユーザのリストを取得する、そしてそれぞれについて、SSHユーザアカウントを作成する」というように、クラスを文章に翻訳していくことができます。もし、このレベルをはるかに超える複雑なイテレータを記述しているとしたら、立ち止まって、より分かりやすいPuppetコードを記述する方法がないか考えてみる良いきっかけになるでしょう。

<div class = "lvm-task-number"><p>タスク6:</p></div>

この`profile::base::dev_users`クラスを設定したら、これを`role::pasture_app`クラスに追加します。

    vim /etc/puppetlabs/code/environments/production/modules/role/manifests/pasture_app.pp

[//]: # (code/130_defined_resource_types/modules/role/manifests/pasture_app.pp)

```puppet
class role::pasture_app {
  include profile::pasture::app
  include profile::base::dev_users
  include profile::base::motd
}
```

<div class = "lvm-task-number"><p>タスク7:</p></div>

`puppet job`ツールを使ってPuppet agent実行を開始します(トークンの期限が切れている場合は、`puppet access login --lifetime 1d`を実行し、認証情報**learning**および**puppet**を使って新規アクセストークンを生成してください)。

    puppet job run --nodes pasture-app.beauvine.vm

Puppet実行が完了したら、ユーザ`gertie`として`pasture-app.beauvine.vm`に接続します。

    ssh gertie@pasture-app.beauvine.vm

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

## その他のリソース

* 定義リソース型については、[ドキュメントページ](https://puppet.com/docs/puppet/latest/lang_defined_types.html)をご覧ください。
* 定義リソース型は、Puppet Practitionerコースで詳しく説明しています。詳細については、[対面](https://learn.puppet.com/category/instructor-led-training)および[オンライン](https://learn.puppet.com/category/online-instructor-led-training)トレーニングオプションをチェックしてみてください。
