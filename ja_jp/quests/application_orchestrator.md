{% include '/version.md' %}

# Puppetアプリケーションオーケストレータ

## クエストの目的

- インフラストラクチャの管理におけるオーケストレーションの役割を理解する。
- Puppetアプリケーションオーケストレーションサービスとオーケストレータクライアントを 
  設定する。
- Puppetコードを使ってコンポーネントを定義し、アプリケーションスタックに
  組み込む。

## はじめに

多数のノードで展開する多数のサービスからなるアプリケーションを管理している場合、このようなノード全体の変更のオーケストレーションは、特に難しい課題となります。関係するノード全体で情報を共有する必要があるかもしれませんし、コンポーネントの同期が乱れないようにするためには、設定を正しい順番で変更する必要もあります。

Puppetのアプリケーションオーケストレータは、Puppetの宣言モデルを単一のノードからマルチノードのアプリケーションに拡大するためのものです。Puppetコードでアプリケーションを記述すると、オーケストレータがその実装を処理します。

準備ができたら、以下のコマンドを入力してください。

    quest begin application_orchestrator

## アプリケーションオーケストレータ

Puppetアプリケーションオーケストレータの仕組みを理解するために、ロードバランサを備えた単純な2層Webアプリケーションを思い描いてみましょう。

![image](../assets/orchestrator1.png)

この例では、1つのロードバランサで、3つのWebサーバにリクエストを分散させています。Webサーバはすべて同じデータベースサーバに接続しています。

このアプリケーションに関連する各ノードでは、アプリケーションに直接関連しないものは同じ設定になります。SSHDやNTPなどは、おそらくインフラストラクチャ内の多くのノードで共通しているはずです。Puppetは、それらを正しく設定するにあたり、ノードが関係するアプリケーションについての具体的な情報を必要としません。アプリケーションに関係しないこれらのクラスとリソースに加え、この例の各ノードには、Webサーバ、データベース、ロードバランサのほか、アプリケーション固有のコンテンツやサービスをサポートおよび設定するのに必要な、リソースアプリケーションの一部のコンポーネントも含まれています。

![image](../assets/orchestrator2.png)

アプリケーションオーケストレーションにおいて、構成のなかでアプリケーション固有の各部分を、コンポーネントと呼びます。この例では、データベース、Webサーバ、ロードバランサのコンポーネントを定義します。各コンポーネントには、アプリケーションにおける役割を果たすためにノードに必要なクラスとリソースがすべて含まれます。コンポーネントは通常、定義リソース型により定義されます。チェックインしたノードのカタログをコンパイルする通常のPuppet実行とは異なり、アプリケーションオーケストレーションジョブのコンポーネントは、特別な `site`コンテキストでコンパイルされます。つまり、最終的にはWebサーバコンポーネントの各インスタンスを特定のノードに適用することになるとしても、Puppetのシングルトンクラスルールに抵触するのを避けるためには、クラスではなく、定義リソース型を使用する必要があるということです。

![image](../assets/orchestrator3.png)

すべてのコンポーネントを定義したら、次のステップでは、アプリケーションとしての各コンポーネントの関連性を定義します。アプリケーションがモジュールとしてパッケージングされている場合は、このアプリケーション定義は通常、`init.pp`マニフェストで行われます。

![image](../assets/orchestrator4.png)

アプリケーション定義では、これらのコンポーネント間の通信方法を指定します。また、インフラストラクチャ内のノードにアプリケーションを適切にデプロイするために必要なPuppet実行の順序を、Puppetアプリケーションオーケストレータが決定できるようにします。

このPuppet実行の順序は、オーケストレータのツールの機能における重要な要素です。アプリケーションに関係するノード上で、Puppet agentをいつ、どのように実行するかについて、やや直接的にコントロールする必要があります。30分というデフォルトの間隔でPuppetが実行される場合、アプリケーションのコンポーネントを正しい順序で確実に設定する方法はありません。例えば、データベースサーバよりも前にWebサーバ上でPuppetが実行される場合、データベース名を変更すると、アプリケーションに乱れが生じます。Webサーバは前回の設定をもとにデータベースに接続しようとするため、データベースが見つからないとエラーが生じることになります。

## Puppet化したアプリケーション

コードにとりかかる前に、少し時間をとって、このアプリケーションの計画をおさらいしましょう。ここでする作業は、上で説明したロードバランスアプリケーションよりも少し単純です。入力を若干省略していますが、Puppetアプリケーションオーケストレータの主な特性を説明しています。

![image](../assets/orchestrator5.png)

ここでは、異なる2つのノードに適用する2つのコンポーネントを定義します。1つは、PostgreSQLデータベース設定を定義し、`pasture-db.puppet.vm`ノードに適用するものです。もう1つは、アプリケーションの設定を定義し、`pasture-app.puppet.vm`ノードに適用するものです。

前に作成した`pasture`モジュールと、Forgeからダウンロードした`postgres`モジュールによって、このアプリケーションに関係するすべてのリソースはすでに管理可能な状態にあります。ここで必要な作業は、アプリケーションデプロイのコンポーネントとして、これらがどのように連係するかを定義するコードを作成することです。

では、この2つのノードを適切にデプロイするためには、何が必要でしょうか？

まず、ノード間で情報を受け渡すため方法が必要です。Webサーバがデータベースに接続するために必要な情報は、コンポーネントを定義するPuppetマニフェストのFacter fact、条件付きロジック、関数に基づいている可能性があります。そのため、データベースノードのためのカタログを実際に生成するまで、Puppetはそれがどのようなものかわかりません。この情報を得たあと、PuppetがWebサーバコンポーネントのパラメータとして情報を受け渡す方法が必要となります。 

次に、これらのノード上で、適切な順序でPuppetを実行する必要があります。アプリケーションサーバノードはデータベースサーバに依存しているため、まずデータベースサーバでPuppetを実行してから、Webサーバで実行する必要があります。

この2つの要件を満たすものを、環境リソースと呼びます。単一マシンの設定方法をPuppetに指示するノード固有のリソース(`user`や`file`など)とは異なり、環境リソースは、任意の環境内にある複数のノード全体のデータを保持し、関連性を定義します。アプリケーションを実装しながら、この仕組みをもっと詳しく見ていきましょう。

アプリケーション作成の最初のステップは、コンポーネント間で受け渡す必要のある情報を正確に決定することです。この例では、どのようになるでしょうか？

1. **ホスト**: Webサーバがデータベースサーバのホスト名を知っている必要があります。
1. **データベース**: 接続する特定のデータベースの名前を知る必要があります。
1. **ユーザ**: データベースに接続するには、データベースユーザの名前が必要です。
1. **パスワード**: そのユーザに関連するパスワードも知る必要があります。

このリストは、データベースサーバが*作成*し、Webサーバが*使用*するものを記しています。この情報をWebサーバに渡せば、データベースサーバ上でホストされているデータベースと接続するのに必要な情報がすべてそろいます。

データベースサーバでのPuppet実行時にこの情報を作成し、Webサーバで使用できるようにするために、`sql`と呼ばれるカスタムリソースタイプを作成します。通常のノードリソースとは異なり、`sql`リソースは、ノードに加えられる変更を直接指定するものではありません。一種のダミーリソースと考えてもいいでしょう。データベースコンポーネントによりパラメータが設定されると、このリソースはサイトレベルのカタログ内にとどまります。こうして、このパラメータをWebサーバコンポーネントが使用できるようになります。

ネイティブのPuppetコードで記述できる定義リソース型とは異なり、カスタム型を作成するには、回り道をしてRubyを使う必要があります。構文は単純なので、Rubyに慣れていなくても心配はありません。

<div class = "lvm-task-number"><p>タスク1:</p></div>

前と同様、最初のステップでは、モジュールディレクトリ構造を作成します。モジュールディレクトリにいることを確認してください。

    cd /etc/puppetlabs/code/environments/production/modules

ディレクトリを作成します。

    mkdir -p pasture_app/{manifests,lib/puppet/type}

現在作成しているのは、`lib/puppet/type` ディレクトリです。`lib/puppet/`ディレクトリは、モジュールの提供するコアPuppet言語のエクステンションが保存される場所です。ここに、Rubyコードで定義するカスタム`sql`型を置きます。

<div class = "lvm-task-number"><p>タスク6:</p></div>

次に、この新しい`sql`リソース型を追加します。

    vim pasture_app/lib/puppet/type/sql.rb

新しい型は、Rubyコードのブロックにより定義され、したがって以下のようになります。

```ruby
Puppet::Type.newtype :sql, :is_capability => true do
  newparam :name, :is_namevar => true
  newparam :user
  newparam :password
  newparam :host
  newparam :database
end
```

これが*環境リソース*であることをPuppetに伝えるために、`is_capability => true`に設定します。通常のリソースは個々のノードのカタログに制限されますが、環境リソースは、アプリケーションオーケストレータのジョブ実行に関係するすべてのノードがアクセスできます。つまり、環境リソースは、オーケストレーションジョブに関連するノード間で情報を受け渡せるということです。

2番目の特徴は、この`sql`リソースには関連する*プロバイダ*がないという点です。ほとんどのリソースは、システムのなんらかの面を管理するためのものですが、この`sql` リソースの唯一の機能は、パラメータ値を、それが定義されたデータベースノードから、それを使用する必要のあるWebサーバノードに渡すことです。その意味では、一種のダミーリソースと考えてもいいでしょう。このリソースは、Puppetのリソース構文を用いて環境レベルで一連のキー値ペアを提供しますが、システム状態を直接的に指定するものではありません。

アプリケーションに関係する他のコンポーネントを扱っていくなかで、この`sql`リソースがどのように生成され、使用されるか確認していきます。

<div class = "lvm-task-number"><p>タスク7:</p></div>

これで新しい`sql`リソース型ができました。データベースコンポーネントに進みましょう。このコンポーネントは、役割およびプロフィールのクエストで作成した`profile::pasture_db`プロフィールクラスによく似た、定義されたリソース型で構成されます。

定義リソース型の作業が終わったあとに、同じマニフェストに、定義リソース型`pasture_app::db`と先ほど定義した`sql`カスタムリソースとの関連性を定義する`produces`命令文も含めます。この`produces`文は、定義リソース型`pasture_app::db`のパラメータセットを使用して、アプリケーションサーバが使用できる環境レベルの`sql`リソースを作成します。

    vim pasture_app/manifests/db.pp

以下のようになります。

```puppet
define pasture_app::db (
  $user,
  $password,
  $host     = $::fqdn,
  $database = $name,
){
  class { 'postgresql::server':
    listen_addresses => '*',
  }
  postgresql::server::db { $name:
    user     => $user,
    password => postgresql_password($user, $password),
  }
  postgresql::server::pg_hba_rule { 'allow pasture app access':
    type        => 'host',
    database    => $database,
    user        => $user,
    address     => '172.18.0.2/24',
    auth_method => 'password',
  }
}
Pasture_App::Db produces Sql {
  user     => $user,
  password => $password,
  host     => $fqdn,
  database => $database,
}
```

`puppet parser`ツールでマニフェストをチェックします。`--app_management`フラグを使い、アプリケーションオーケストレーション構文の構文解析チェックを有効にします。

    puppet parser validate --app_management pasture_app/manifests/db.pp

<div class = "lvm-task-number"><p>タスク8:</p></div>

次に、`app`コンポーネントを作成し、Pastureアプリケーションサーバそのものを設定します。

    vim pasture_app/manifests/app.pp

以下のようになります。

```puppet
define pasture_app::app (
  $db_user,
  $db_password,
  $db_host,
  $db_name,
) {

  class { 'pasture':
    sinatra_server  => 'thin',
    db              => "postgres://${db_user}:${db_password}@${db_host}/${db_name}",
    default_message => "Hi! I'm connected to ${db_host}!",
  }

}
Pasture_App::App consumes Sql {
  db_user     => $user,
  db_password => $password,
  db_host     => $host,
  db_name     => $database,
}
```

マニフェストの構文を再度チェックします。

    puppet parser validate --app_management pasture_app/manifests/app.pp

<div class = "lvm-task-number"><p>タスク9:</p></div>

これで定義リソース型が完成しました。ここでアプリケーションそのものを定義します。アプリケーションは`pasture_app`モジュールが提供する主要な要素であるため、`init.pp`マニフェストを使用します。

    vim pasture_app/manifests/init.pp

すでにコンポーネントで多くの作業を済ませているので、この作業はとても簡単です。アプリケーションの構文は、クラスや定義リソース型のものとよく似ています。唯一の違いは、`define`や`class`のかわりに`application`というキーワードを使用する点です。

```puppet
application pasture_app (
  $db_user,
  $db_password,
) {

  pasture_app::db { $name:
    user     => $db_user,
    password => $db_password,
    export   => Sql[$name],
  }

  pasture_app::app { $name:
    consume => Sql[$name],
  }

}
```

アプリケーションには、`db_user`と`db_password`という2つのパラメータがあります。アプリケーションの本体は、`pasture_app::db`および`pasture_app::app`コンポーネントを宣言します。`db_user`および`db_password`パラメータを`pasture_app::db`コンポーネントを受け渡します。ここでは、特別な`export`メタパラメータも使用し、このコンポーネントに`sql`環境リソースを作成させたいことをPuppetに伝えます。`pasture_app::app`コンポーネントには、それに対応する`comsume` メタパラメータが含まれます。これは、そのリソースを使用することを指示するものです。

アプリケーションの定義を終えたら、構文を確認し、必要に応じて修正します。

    puppet parser validate --app_management pasture_app/manifests/init.pp

この時点で、`tree`コマンドを使用し、モジュールのすべてのコンポーネントが整ったことを確認します。

    tree pasture_app

モジュールは以下のようになります。

    pasture_app/
    ├── lib
    │   └── puppet
    │       └── type
    │           └── sql.rb
    └── manifests
        ├── init.pp
        ├── db.pp
        └── app.pp

    4 directories, 4 files

<div class = "lvm-task-number"><p>タスク10:</p></div>

これらのノードの管理にはオーケストレータを使用するため、アプリケーション関連のクラスをノードの役割から削除します。これらのクラスがベースプロファイルと依存関係にない限り、そのまま役割に残し、引き続き通常のPuppet agent実行スケジュールで管理されるようにすることができます。

`role/manifests/pasture_app.pp`マニフェストを開き、`profile::pasture::app`クラスを削除します。

```puppet
class role::pasture_app {
  include profile::base::motd
  include profile::pasture::dev_users
}
```

`role/manifests/pasture_db.pp`マニフェストも同じようにします。

```puppet
class role::pasture_db {
  include profile::base::motd
  include profile::pasture::dev_users
}
```

<div class = "lvm-task-number"><p>タスク10:</p></div>

最後のステップは、`site.pp`マニフェストでアプリケーションを宣言することです。

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

これまでは、`site.pp`内で作成した設定は、ノードブロックの文脈内にありました。しかし、アプリケーションには、個々のノードレベルよりも上位の抽象レベルが必要です。この特徴を表現するために、`site`と呼ばれる特別なブロック内でアプリケーションインスタンスを宣言します。

```puppet
site { 
  pasture_app { 'pasture_01':
    db_user     => 'pasture',
    db_password => 'm00m00',
    nodes       => {
      Node['pasture-app-large.puppet.vm'] => Pasture_app::App['pasture_01'],
      Node['pasture-db.puppet.vm']        => Pasture_app::Db['pasture_01'],
    }
  }
}
```

アプリケーション宣言の構文は、クラスやリソースのものとよく似ています。`db_user` および`db_password`パラメータを通常どおりに設定します。

`nodes`パラメータは、オーケストレーションの魔法が生じる場所です。このパラメータは、1つまたは複数のコンポーネントと対になったノードのハッシュをとります。このケースでは、`Pasture::Db['pasture01']` コンポーネントを`pasture-db.puppet.vm`に、`Pasture::App['pasture_01']`コンポーネントを`pasture-app-large.puppet.vm`に割り当てています。オーケストレータの実行時には、アプリケーション定義内(`pasture_app/manifests/init.pp`マニフェスト内など) の`exports`および`consumes`メタパラメータを用いて、アプリケーション内のノード全体でPuppet実行の適切な順序が決定されます。

`site.pp`マニフェストでアプリケーションを宣言しました。`puppet job`ツールを使うと、これを表示させることができます。

    puppet job plan --application Pasture_app

以下のような結果が表示されるはずです。

    +-------------------+-------------+
    | Environment       | production  |
    | Target            | Pasture_app |
    | Concurrency Limit | None        |
    | Nodes             | 2           |
    +-------------------+-------------+
    Application instances: 1
      - Pasture_app[pasture_01]
    Node run order (nodes in level 0 run before their dependent nodes in level 1, etc
    .):
    0 -----------------------------------------------------------------------
    pasture-db.puppet.vm
        Pasture_app[pasture_01] - Pasture_app::Db[pasture_01]
    1 -----------------------------------------------------------------------
    pasture-app-large.puppet.vm
        Pasture_app[pasture_01] - Pasture_app::App[pasture_01]

<div class = "lvm-task-number"><p>タスク11:</p></div>

`puppet job`コマンドを使用し、アプリケーションをデプロイします。

    puppet job run --application Pasture_app['pasture_01']

`puppet job list`コマンドを使うと、実行中のジョブや完了したジョブの状況を確認することができます。

アプリケーションをデプロイしたら、`curl`コマンドを使って、 `pasture-app-large.puppet.vm`上のPastureに関して設定されたデフォルトメッセージをチェックします。 

    curl 'pasture-app-large.puppet.vm/api/v1/cowsay'

## おさらい

このクエストでは、複数のノード間でPuppet実行を調整する際のPuppetオーケストレータの役割を説明しました。

アプリケーションの定義やジョブとして実行する方法を具体的に説明する前に、Puppet agent上の設定の詳細と、Puppetアプリケーションオーケストレータクライアントの設定について説明しました。これらのステップとさらに詳しい情報については、[Puppetドキュメンテーション](https://docs.puppet.com/pe/latest/app_orchestration_overview.html)Webサイトを参照してください。

アプリケーションの定義には通常、いくつかの特徴的なマニフェストとRubyエクステンションが必要です。

*  アプリケーションコンポーネント。これは、通常は定義リソース型として記述されます。
*  コンポーネント間でパラメータを受け渡すために必要な環境リソースの
   新しいタイプ定義。
*  アプリケーションコンポーネントを宣言し、相互の関係性を指定するための
   アプリケーション定義。
*  インフラストラクチャ内のノードにコンポーネントを割り当てるための、`site.pp`マニフェストの`site`ブロックでの
   アプリケーションの宣言。

定義したアプリケーションは、`puppet job plan`コマンドで確認したり、`puppet job run`コマンドで実行したりできます。`puppet job list`コマンドを使うと、実行中のジョブや完了したジョブを確認できます。
