{% include '/version.md' %}

# Hiera

## クエストの目的

- Hieraを使用して、サイト固有データをPuppetマニフェストから抽象化します。
- Hiera設定ファイルを管理します。
- YAMLデータソースでHieraを使用できるように設定します。
- PuppetマニフェストでHieraルックアップを使用します。

## はじめに

HieraはPuppetのデータルックアップシステムです。PuppetインフラにHieraを導入すると、サイト固有データをPuppetコードベースから切り離すことができます。そのうえで、Puppetコード内のHieraルックアップを使用して、コードが適用される各ノードの固有情報に従ってインテリジェントに変数を設定できます。

準備ができたら、以下のコマンドを入力してください。

    quest begin hiera

## Hieraとは?

このガイドでここまでに学習したすべてのデータ管理手法は、変数やテンプレートからロールおよびプロファイルまで、さまざまなデータをコードから明確に分離するために役立ちます。
[Hiera](https://docs.puppet.com/puppet/latest/hiera_intro.html)は、Puppetのビルトインデータルックアップシステムで、Puppetマニフェストから別のデータソースにデータを移動することで、この分離を実現します。

Hieraという名前は、データを*階層的*に構成できるという事実にちなんで付けられています。ほとんどのHiera導入は、インフラ全体にデフォルト値を設定する共通データから始まり、独自システムの設定に必要なノード固有データで終わります。より限定的なレベルで指定されたデータが、より一般的なレベルに設定されたデフォルト値をオーバーライドします。Hieraでは、最も一般的なレベルから最も限定的なレベルまでの間に、いくつでも中間レベルを指定できます。

このガイドではまだ説明していませんが、(カスタムおよび外部fact) [https://docs.puppet.com/facter/latest/custom_facts.html]を導入すると、Hiera階層を非常に柔軟にセットアップできます。例えば、国に相当するHieraレベルを設定して、一連のワークステーションにデフォルトロケールを指定したり、データセンターに相当するレベルを設定して、ネットワーク構成の管理に使用したりすることができます。

Puppet自体と同様に、Hieraはさまざまな方法で設定および使用できる柔軟性の高いツールです。このクエストの目標は、Hieraの機能や考えられる実装をすべて網羅することではなく、小規模デプロイと大規模デプロイの両方で、多くのPuppetユーザが問題なく使用してきたシンプルなパターンを提示することにあります。

実装について詳しく説明する前に、このクエストの目標について確認しましょう。

このクエストの開始時に、 `quest` ツールによって以下の4つの新規ノードが作成されました。

    1. `pasture-app.beauvine.vm`
    2. `pasture-db.auroch.vm`
    3. `pasture-app.auroch.vm`
    4. `pasture-app-dragon.auroch.vm`

前のクエストでは、`profile::pasture::app`クラス内の条件文を使用して、ホスト名に`large`および`small`を含むノードを識別することで、データベースノードに接続するノードを決定しました。

このクエストでも同じような識別を行いますが、少し異なる方法を使用します。例として、Cowsay as a Serviceアプリケーションに階層型価格構造を設定したとしましょう。基本レベルで使用できるのは基本的なCowsay API機能だけですが、プレミアムレベルでは追加のデータベース機能を使用できます。新興スタートアップ企業のBeauvine社は基本サービスを契約していますが、既存企業のAuroch社はプレミアムサービスを選択しています。Auroch社はまた、Cowsayのドラゴンキャラクターをデフォルトで使用する、1回限りのカスタムインスタンスを設定するように要求しています。

ここでの目標は、グローバル、ドメイン別、ノード別の各レベルでPastureアプリケーションサーバーを設定するためのパラメータ値を渡すHiera構成を作成することです。

<div class = "lvm-task-number"><p>タスク1:</p></div>

Hiera実装の第1ステップは、使用する環境のコードディレクトリに`hiera.yaml`設定ファイルを追加することです。この設定ファイルは階層内のレベルを定義し、各レベルに対応するデータソースの場所をHieraに伝えます。

はじめに、作業環境として本番環境のコードディレクトリに移動します。

    cd /etc/puppetlabs/code/environments/production

新しい'hiera.yaml`ファイルでの作業を開始します。

    vim hiera.yaml

ここでは、3つのレベルを持つ単純な階層を実装します。"Common data"には、環境のデフォルト値を設定し、"Per-Domain defaults"にはドメイン固有のデフォルト値を定義し、"Per-node data"には個々のノードに固有のデータ値を定義します。

```yaml
---
version: 5

defaults:
  datadir: data
  data_hash: yaml_data

hierarchy:
  - name: "Per-node data"
    path: "nodes/%{trusted.certname}.yaml"

  - name: "Per-domain data"
    path: "domain/%{facts.networking.domain}.yaml" 

  - name: "Common data"
    path: "common.yaml"
``` 

PuppetでHieraを使用して値を探す場合、この設定ファイルの`hierarchy:`セクションに記載されたレベルの順序に従って検索が行われます。"Per-node data"レベルに定義されたデータソース内で値が見つかった場合、この値が使用されます。一致する値がここで見つからない場合、次のレベル( ここでは、"Per-OS defaults")に進みます。このデータソースにも値が見つからない場合、最終的に、"Common data"レベルの`common.yaml`ファイルが検索されます。

この設定ファイルは、Puppetコードではなく[YAML](http://www.yaml.org/start.html)で記述されているので、構文チェックに`puppet parser validate`コマンドを使用することはできません。代わりに、以下のRubyの1行コマンドをコマンドラインで実行して、YAML構文をチェックします。このコマンドは、`puppet parser`と同様に、ファイルが解析できるかどうかだけをチェックするものであり、内容の正しさは保証しません。

    ruby -e "require 'yaml';require 'pp';pp YAML.load_file('./hiera.yaml')"

以下のような出力が表示されます。

```ruby
{"version"=>5,
 "defaults"=>{"datadir"=>"data", "data_hash"=>"yaml_data"},
 "hierarchy"=>
  [{"name"=>"Per-node data", "path"=>"nodes/%{trusted.certname}.yaml"},
   {"name"=>"Per-domain data",
    "path"=>"domain/%{facts.networking.domain}.yaml"},
   {"name"=>"Common data", "path"=>"common.yaml"}]}
```

<div class = "lvm-task-number"><p>タスク2:</p></div>

各レベルに対してデータソースを設定する前に、`profile::pasture::app`クラスにHieraルックアップを追加します。はじめに追加することで、各データソースに定義する必要のある値を確認できます。

    vim modules/profile/manifests/pasture/app.pp

Hieraのビルトイン関数`lookup()`を使用して、管理する`pasture`コンポーネントの各クラスパラメータに対して、どのデータをフェッチするかを指定します。

```puppet
class profile::pasture::app {
  class { 'pasture':
    default_message   => lookup('profile::pasture::app::default_message'),
    sinatra_server    => lookup('profile::pasture::app::sinatra_server'),
    default_character => lookup('profile::pasture::app::default_character'),
    db                => lookup('profile::pasture::app::db'),
  }
}
```

これらのルックアップキーには完全修飾スコープが含まれています。Hiera自体では、この命名パターンをキーに指定する必要はありませんが、このパターンを使用すれば、データソース内のキーを見ただけで、これがPuppetコード内のどこで、どのように使用されているかが正確にわかります。

(Hieraには暗黙データバインディング機能があるので、完全修飾キーを直接使用することで、明示的なルックアップなしでクラスパラメータを設定できます。ただし、この機能を使用した場合、PuppetコードとHieraデータの関係がわかりにくくなるので、チームメンバーがHieraに精通していない場合などでは、`lookup()`関数の使用を推奨します。)

以上で、プロファイルにルックアップ機能を追加したので、次にHieraデータソースにこれらのデータを定義します。

Hieraは、さまざまな種類のデータソースを非常に柔軟に使用できます。Hieraデータソース向けとして最も一般的なプレーンテキストフォーマットはYAMLとJSONですが、キーを入力値として受け取り、対応する値を返すフォーマットであれば、何でも(データベースやカスタムスクリプトなど)使用できます。

このように柔軟性が高いと、独創的なソリューションを実装したくなりますが、最も単純に要件を満たすデータソースを使用するのがベストです。そのため、このクエストでは、すべてのデータソースにYAMLファイルを使用します。

<div class = "lvm-task-number"><p>タスク3:</p></div>

`domain`と`nodes`というサブディレクトリを持つ`data`ディレクトリを作成します。

    mkdir -p data/{domain,nodes}

<div class = "lvm-task-number"><p>タスク4:</p></div>

`data`ディレクトリ直下にある`common.yaml`データソースを開きます。

    vim data/common.yaml

ここには、より高いレベルで値が設定されない場合に使用される共通のデフォルト値を設定します。

```yaml
---
profile::pasture::app::default_message: "Baa"
profile::pasture::app::sinatra_server: "thin"
profile::pasture::app::default_character: "sheep"
profile::pasture::app::db: "none"
```

<div class = "lvm-task-number"><p>タスク5:</p></div>

次に、`data/domain/beauvine.vm.yaml`データソースを作成し、`beauvine.vm`ドメイン名に対するデフォルト値を定義します。 ドメインレベルは共通レベルよりも階層の上位にあるので、ここに設定された値は共通レベルで設定された値に優先し、未定義のままの値には共通レベルの値がデフォルト設定されます。

    vim data/domain/beauvine.vm.yaml

```yaml
---
profile::pasture::app::default_message: "Welcome to Beauvine!"
```

<div class = "lvm-task-number"><p>タスク6:</p></div>

次に、`data/domain/auroch.vm.yaml`データソースを作成します。

    vim data/domain/auroch.vm.yaml

```yaml
---
profile::pasture::app::default_message: "Welcome to Auroch!"
profile::pasture::app::db: "postgres://pasture:m00m00@pasture-db.auroch.vm/pasture"
```

<div class = "lvm-task-number"><p>タスク7:</p></div>

ドメインレベルのデータソースは完成したので、ノードレベルに進みます。

    vim data/nodes/pasture-app-dragon.auroch.vm.yaml

ここでは、`default_character`に`dragon`を設定するだけです。

```yaml
---
profile::pasture::app::default_character: 'dragon'
```

データディレクトリは以下のようになります。

```
[/etc/puppetlabs/code/environments/production]
root@learning: # tree data
data
├── common.yaml
├── domain
│   ├── auroch.vm.yaml
│   └── beauvine.vm.yaml
└── nodes
    └── pasture-app-dragon.auroch.vm.yaml
```
2ディレクトリ、4ファイル

<div class = "lvm-task-number"><p>タスク8:</p></div>

次に、`puppet job`ツールを使用して、各ノードでのPuppet agentの実行を開始します。トレーニングVMがPE masterと中央agentノードの両方で実行されており、以下の推奨最小値がメモリに割り当てられています。このため、Puppet agentの同時実行を開始する場合は配慮が必要です。`--concurrency 2`フラグを使用して、同時agent実行の数が2になるように制限します。

    puppet job run --nodes pasture-db.auroch.vm,pasture-app-dragon.auroch.vm,pasture-app.auroch.vm,pasture-app.beauvine.vm --concurrency 2

ここで、これらのノードに対してAPIエンドポイントをいくつかテストして、結果を確認します。
以下のコマンドを入力する前に、結果を推測してみましょう。

    curl pasture-app-dragon.auroch.vm/api/v1/cowsay/sayings

    curl -X POST 'pasture-app-dragon.auroch.vm/api/v1/cowsay/sayings?message=Hello!'

    curl pasture-app-dragon.auroch.vm/api/v1/cowsay/sayings

    curl pasture-app.auroch.vm/api/v1/cowsay/sayings/1

    curl pasture-app.beauvine.vm/api/v1/cowsay

    curl pasture-app.beauvine.vm/api/v1/cowsay/sayings

## おさらい

このクエストで紹介したHieraは、データをPuppetコードから切り離す、データ抽象化ツールです。

ここではHieraの*階層型*モデルについて学習しました。Hieraは、はじめに、最も限定的な階層レベル(ここではノードレベル)に割り当てられたデータソースをルックアップします。この最初のレベルで値が見つかった場合、値が返されてルックアップは終了します。値が見つからない場合、Hieraは、値が見つかるか、何の値も設定されていないと判断するまで、より高いレベルの階層をチェックし続けます。

データソースの階層設定には、`hiera.yaml` 設定ファイルを使用しました。また、環境全体のデフォルト値をcommon.yaml`ファイルに設定し、`beauvine.vm`ドメインおよび`auroch.vm`ドメインに対するドメイン別の中間レベルのデフォルト値を設定し、最後に`pasture-app-dragon.auroch.vm`ノードに固有のデータを設定しました。

`lookup`関数を使用して、Puppetマニフェストで使用する値をこれらのデータソースから取得する方法を学習しました。このルックアップ関数では、Hieraデータに基づいて`pasture`クラスにパラメータを設定しました。

## その他のリソース

* Puppetドキュメントは、[Hiera] (https://puppet.com/docs/puppet/latest/hiera_intro.html)を参照してください。
* [インタラクティブなHieraデモ](http://puppetlabs.github.io/hierademo/)を参照して、
  異なるルックアップがHiera階層設定に応じてどう解決されるかを
  確認してください。
* Hiera 5(このクエストで使用したバージョン)で導入された変更の一部についてのレビューは、
  [こちらのブログ記事](https://www.example42.com/2017/04/17/hiera-5/)を参照してください。
* Hieraについては、複数のオンラインおよび対面[コース](https://learn.puppet.com/course-catalog)と、
  [自分のペースで学習できるトレーニングモジュール](https://learn.puppet.com/category/self-paced-training)で扱っています。
