{% include '/version.md' %}

# ロールとプロファイル

## クエストの目的

- ロールとプロファイルのパターンを理解する。
- コンポーネントクラスをラッピングし、サイトインフラに固有のパラメータを設定する*プロファイル*クラスを
  作成する。
- *ロール*クラスを作成し、プロファイルクラスの組み合わせを通じて、システムの設定全体を
  定義する。
- 正規表現を用いて、ノード定義をより柔軟に作成する方法を
  学ぶ。

## はじめに

前回のクエストでは、単一システムでのPastureアプリケーションの管理から、`pasture-app.puppet.vm`および`pasture-db.puppet.vm`ホストでのコンポーネントの分散に移行しました。設定したアプリケーションサーバとデータベースサーバは、インフラ内でそれぞれ異なる役割を果たし、Puppet内での分類がそれぞれ異なります。

Puppetで構成したインフラストラクチャの規模と複雑さが増すにつれて、より多様なシステムを管理する必要が生じます。そうしたシステムのクラスとパラメータをすべて`site.pp`マニフェストで直接定義するのは、スケールアップの方法としてあまり効果的ではありません。*ロールとプロファイル*パターンを使えば、一貫したモジュール形式の方法で、Puppetモジュールで提供されるコンポーネントをまとめ、管理が必要なさまざまなシステムを定義することができます。

準備ができたら、以下のコマンドを入力してください。

    quest begin roles_and_profiles

## ロールとプロファイルとは？

このクエストで扱う*ロールとプロファイル*パターンは、Puppetのエコシステムにおける新しいツールや機能ではありません。むしろ、Puppetで構成したインフラの成長に応じて、すでに紹介したツールを活用して維持や管理を可能にするための手法です。

ロールとプロファイルについて、まず*コンポーネントモジュール*と呼ばれるものから説明しましょう。コンポーネントモジュールは、PastureモジュールやForgeからダウンロードしたPostgreSQLモジュールと同じく、システム上にある特定の技術を構成するためのものです。これらのモジュールが提供するクラスは、柔軟性が得られるように記述されています。パラメータで提供されるAPIを使えば、コンポーネント技術をどのように設定すればよいか、正確に指定することができます。

ロールとプロファイルのパターンを使えば、インフラ内の特定のアプリケーションに従って、このようなコンポーネントモジュールを一貫した方法で体系的に整理することができます。

*プロファイル*は、1つまたは複数の関連するコンポーネントモジュールを宣言し、必要に応じてそのパラメータを設定するものです。システム上のプロファイルセットは、ビジネス上のロールを満たす必要のある技術スタックを定義および設定します。 

*ロール*は、システム全体のあるべき状態を定義するために、1つまたは複数のプロファイルを組み合わたものです。ロールは、サーバのビジネス上の目的と対応しています。つまり、CTOにシステムの目的を問われた場合には、このロールが概要を示す答えになります。例えば、"Pastureアプリケーションのためのデータベースサーバ"などが、それにあたります。ただし、ロールはプロファイルを構成しパラメータを設定する**だけ**です。ロール自体にパラメータはありません。 

## プロファイルの記述

ロールとプロファイルの使用は設計パターンであり、Puppetソースコードに書き込むものではありません。Puppet構文解析ツールの観点から言えば、ロールとプロファイルを定義するクラスは、他のクラスと何も変わりません。

<div class = "lvm-task-number"><p>タスク1:</p></div>

プロファイルを設定するには、新しい`profile`モジュールディレクトリをモジュールパスに作成します。

    mkdir -p profile/manifests

まず、Pastureアプリケーションに関連するプロファイルペアを作成します。アプリケーションサーバのプロファイルでは、2つの異なる設定を条件文を使って管理します。'large'デプロイは外部データベースに接続し、'small'デプロイは基本的な'cowsay'エンドポイントのみを提供します。第2のプロファイルは、アプリケーションサーバの'large'インスタンスに対応する PostgreSQLデータベースを管理します。

これらすべてのプロファイルがPastureアプリケーションに関連することを明確に示すため、これらのプロファイルを`profile/manifests`内の `pasture` サブディレクトリに置きます。

そのサブディレクトリを作成します。

    mkdir profile/manifests/pasture

<div class = "lvm-task-number"><p>タスク2:</p></div>

次に、Pastureアプリケーションのプロファイルを作成します。

    vim profile/manifests/pasture/app.pp

ここで、`profile::pasture::app`クラスを定義します。

このクエストのクエストツールでは、`pasture-app-small.puppet.vm`および`pasture-app-large.puppet.vm`ノードが作成されています。そのため、ノード名に基づいて適切なプロファイルを決定することができます。条件文を用いて、ノードの`fqdn` factに文字列'large'または'small'が含まれているかどうかに応じて、`$default_character`および`$db`パラメータを設定します。'small'の場合は、特殊な`undef`値を用いてこれらのパラメータを設定しないまま残し、`pasture`コンポーネントクラスで設定されたデフォルトを使用するようにします。また、`else`ブロックを追加し、`fqdn`変数が'small'または'large'のどちらとも一致しない場合に、適切なエラーメッセージを表示して失敗するようにします。

```puppet
class profile::pasture::app {
  if $facts['fqdn'] =~ 'large' {
    $default_character = 'elephant'
    $db                = 'postgres://pasture:m00m00@pasture-db.puppet.vm/pasture'
  } elsif $facts['fqdn'] =~ 'small' {
    $default_character = undef
    $db                = undef
  } else {
    fail("The ${facts['fqdn']} node name must match 'large' or 'small'.")
  }
  class { 'pasture':
    default_message   => 'Hello Puppet!',
    sinatra_server    => 'thin',
    default_character => $default_character,
    db                => $db,
  }
}
```

<div class = "lvm-task-number"><p>タスク3:</p></div>

次に、`pasture::db`コンポーネントクラスを用いて、Pastureデータベースのプロファイルを作成します。

    vim profile/manifests/pasture/db.pp

ここではパラメータをカスタマイズする必要はありません。そのため、`include`構文を使って`pasture::db`クラスを宣言することができます。

```puppet
class profile::pasture::db {
  include pasture::db
}
```

これらのプロファイルは、Pastureアプリケーションに直接関連するコンポーネントディレクトリの設定を定義するものですが、一般には、そのビジネス上のロールに直接関連しないシステム要素を管理する必要があります。1つのプロファイルモジュールには、ユーザアカウント、DHCP設定、ファイアウォールのルール、NTPなどを管理するプロファイルクラスを含めることができます。これらのクラスは、インフラ内の多くの、またはすべてのシステムに適用されるため、通常は`base`サブディレクトリに置かれます。基本的なプロファイルの例を示すために、先ほど作成した`motd`コンポーネントクラスをラッピングする`profile::base::motd`プロファイルクラスを作成します。 

<div class = "lvm-task-number"><p>タスク4:</p></div>

`profile`モジュールの`manifests`ディレクトリに、`base`サブディレクトリを作成します。

    mkdir profile/manifests/base

次に、`profile::base::motd`プロファイルを定義するマニフェストを作成します。

    vim profile/manifests/base/motd.pp

`profile::pasture::db`プロファイルクラスと同様、`profile::base::motd`クラスは、`motd`クラスの`include`文を持つラッパークラスです。

```puppet
class profile::base::motd {
  include motd
}
```

ラッパークラスの記述は、最初のうちは必要以上に複雑に見えるかもしれません。特に`motd`や`pasture::db`といったシンプルなコンポーネントクラスでは、その複雑さが目立つかもしれませんが、これにより得られる一貫性には、ラッパークラスを作成する手間を上回る価値があります。

プロファイルクラスは、サイトインフラ内でコンポーネントをどのように設定するかを正確に示す唯一の情報源です。例えば、MOTDモジュールにパラメータを追加する場合に、単一のプロファイルクラスでそのパラメータを簡単に設定し、そのプロファイルを含むロールを持つすべてのノードに変更を加えることができます。一方、ロールやノードレベルで個別にパラメータを設定する場合は、すべてのシステムで変更を繰り返す必要があります。

これで、いくつかのプロファイルを使用できるようになりました。それぞれのプロファイルは、システム上のコンポーネントをどのように設定すべきかを定義しています。次のステップは、それらを組み合わせてロールにすることです。

## ロールの記述

ロールは、プロファイルを組み合わせ、Puppetで管理するシステム上のコンポーネントセット全体を定義するものです。ロールは、そのロールを構成するプロファイルクラスのリストをプルインする `include`文のみで構成する必要があります。また、プロファイルではないクラスや個々のリソースを直接宣言することはできません。

ロールには、そのロールで記述するシステムのビジネス上の目的を簡単に説明する名前を付けます。技術スタックに関連する具体的な実装の詳細は、プロファイルに任せておきます。例えば、`role::myapp_webserver`と`role::myapp_database`は、ロールクラスに適した名前ですが、`role::postgres_db`や`role::apache_server`は適切ではありません。

<div class = "lvm-task-number"><p>タスク5:</p></div>

このケースでは、Pastureアプリケーションに関連するシステムを定義する、`role::pasture_app`および`role::pasture_db`という2つのロールが必要です。まず、`role`モジュールのディレクトリ構造を作成します。

    mkdir -p role/manifests

`role::pasture_app`ロールを定義するマニフェストを作成します。

    vim role/manifests/pasture_app.pp

```puppet
class role::pasture_app {
  include profile::pasture::app
  include profile::base::motd
}
```

次に、データベースサーバのロールを作成します。

    vim role/manifests/pasture_db.pp

```puppet
class role::pasture_db {
  include profile::pasture::db
  include profile::base::motd
}
```

## 分類

ロールを明確に定義してしまえば、分類はとても簡単です。インフラ内の各ノードを、1つのロールクラスに分類できます。

Puppetのノード定義構文の別の機能を使えば、分類モデルをさらに簡潔にできます。ここまでは`site.pp`マニフェスト内のノード定義ブロックのタイトルとして、シンプルな文字列を使ってきましたが、文字列の代わりに、[正規表現](http://www.regular-expressions.info/)をノード定義のタイトルとして使うことができます。これにより、正規表現で指定したパターンと一致するタイトルを持つすべてのノードに、ノード定義を適用できるようになります。

ここでは、Pastureアプリケーションサーバとして分類する2つのノードの一致条件として、`/^pasture-app/`という正規表現を使用します。`/`は、通常の文字列ではなく正規表現であることを示すデリミターです。`^` は、文字列の開始を示します。後に続く文字が、ノード名の一致条件となります。

正規表現についてさらに詳しく学ぶには、[rubular.com](http://rubular.com/)を参照してください。これはクイックリファレンスとしても、テストツールとしても役立ちます。例えば、上述の正規表現を適用して一致するノード名があるかどうか検証できます。また、正規表現の詳しいガイドとしては、[regular-expressions.info](http://www.regular-expressions.info/)も参考になります。一般に、ノード定義で使用する正規表現は、きわめてシンプルです。

ノード名の一致条件として正規表現を使用する場合、エスケープすべき特殊文字がある点に注意してください。たとえば、ドット(`.`)は、あらゆる文字と一致する特殊文字です。ドットなどの特殊文字を含む名前と一致させるには、バックスラッシュ(`\.`)を付けてエスケープする必要があります。ノード定義の正規表現があまりに複雑になる場合は、ノードのネーミングスキームを再考するか、PEコンソールの[ノード分類子](https://docs.puppet.com/pe/latest/console_classes_groups.html)や[外部のノード分類子](https://docs.puppet.com/puppet/latest/nodes_external.html)など、別の分類手法の検討が必要かもしれません。

<div class = "lvm-task-number"><p>タスク6:</p></div>

ノード定義を作成するために、`site.pp`マニフェストを開きます。

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

アプリケーションサーバノードのノード定義ブロックを作成します。`/^pasture-app/`正規表現をノード定義のタイトルとして使用し、`role::pasture_app`ロールクラスを含めます。

```puppet
node /^pasture-app/ {
  include role::pasture_app
}
```

データベースロールの第2のノード定義を追加します。ここではデータベースノードは1つだけですが、ここで使う正規表現は、後から簡単にスケールアップできます。

```puppet
node /^pasture-db/ {
  include role::pasture_db
}
```

ロールとプロファイルパターンを使用するので、`pasture-app.puppet.vm`および`pasture-db.puppet.vm`ノードの過去のノード定義を削除する必要があります。

<div class = "lvm-task-number"><p>タスク7:</p></div>

`puppet job`ツールを使って、`pasture-db.puppet.vm`ノードでPuppet agent実行を開始します。

    puppet job run --nodes pasture-db.puppet.vm

この実行が完了したら、2つのアプリケーションサーバノードで実行を開始します。

    puppet job run --nodes pasture-app-small.puppet.vm,pasture-app-large.puppet.vm

これらのPuppet実行が完了したら、`curl`コマンドを使って、2種類のサーバ上のアプリケーションの機能をテストします。

    curl 'pasture-app-small.puppet.vm/api/v1/cowsay?message="hello"'
    curl 'pasture-app-large.puppet.vm/api/v1/cowsay?message="HELLO!"'

前回のクエストで導入したデータベース機能が、アプリケーションの'large'インスタンスで稼働していること、また一方で'small'インスタンスは501エラーを返すことに注目してください。

    curl 'pasture-app-small.puppet.vm/api/v1/cowsay/sayings'

## おさらい

このクエストでは、ロールとプロファイルパターンについて説明しました。これは、インフラ内の各システムのロールに応じて、コンポーネントモジュールによって提供される機能を体系的に整理するための方法です。

コンポーネントモジュールをラッピングしてパラメータを指定するプロファイルクラスを作成し、これらのプロファイルクラスをロールにまとめました。

最後に、`site.pp`マニフェストで正規表現を使って、インフラ内の各システムに適切なロールを割り当てる柔軟なノード定義を作成しました。

