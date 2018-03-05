{% include '/version.md' %}

# 制御リポジトリ

## クエストの目的

- 本稼働環境向けのコードを管理する制御リポジトリを作成します。
- Gitを使用してローカル制御リポジトリを初期化してから、
  コンテンツをアップストリームリモートにプッシュします。
- Puppetのコードマネージャツールを使用して、
  コードにアクセスし、アップストリームリポジトリからPuppet masterにコードをデプロイします。
- ローカルにコピーした開発用の制御リポジトリから
  変更をプロモートして、Puppet masterにデプロイするために必要なワークフローを
  理解し、適用します。

## はじめに

このクエストでは、コントロールリポジトリの設定方法を学習したうえで、Gitのソースコントロール管理(SCM)ワークフローを使用して、インフラを定義するPuppetコードの管理を開始します。PuppetコードをSCMにチェックインすると、チームでの協業、変更管理、安全な新機能テストが大幅に容易になります。

このクエストで説明するコンセプトは、Puppetの基礎の学習から、それをもとに本稼働インフラの管理に適したワークフローの構築へと前進するうえで、重要な移行ポイントとなるものです。

Puppetで別のSCMツールを使用することもできますが、このクエストではGitに焦点を合わせて説明します。Gitの効果的な使用法を学習することは、それ自体が1つの課題になります。このクエストはタスクの完了に必要なgitコマンドをすべて紹介しますが、Git自体の学習に重点を置くものではありません。

このクエストに含まれるGitワークフローは、1つの作業例を示すためのものです。組織内で、Gitまたはその他のSCMツールがすでに実装されている場合、ここで説明するワークフローとは異なる手法が確立されている場合があります。

次に進む前にGitについて学習または復習する場合、このクエストの最後にある*その他のリソース*セクションに記載したリンクを参照してください。

準備ができたら、以下のコマンドを入力してください。

    quest begin control_repository

## 制御リポジトリ

ここまでにトレーニングVMで扱ったモジュールは、Puppetのモジュールパスの直下に含まれていました。この方法は直接的で簡単なので、演習には適しています。ただし、Puppetを使用した本稼働インフラを管理する場合、本稼働コードを変更する前に、複数の作業者間で変更を調整、レビュー、テストできるようなワークフローを採用することを強く推奨します。

Puppet制御リポジトリは、Puppetインフラを定義する設定とコードを含むSCMリポジトリです。

Puppetコードベースをソース制御リポジトリに格納することで、各作業者は、masterの本稼働モジュールパス内を直接変更するのではなく、チェックアウトしたコードのコピーを編集することができます。こうして変更したコードには、本稼働コードベースへの統合とmasterの本稼働環境へのデプロイの前に、レビューとテストを実施できます。

はじめに、各自のホームディレクトリ内に`control-repo`ディレクトリを作成します。このディレクトリ内のコンテンツは最終的に、master上の`/etc/puppetlabs/code/environments/production/`ディレクトリにデプロイされるので、 各自の制御リポジトリのコンテンツはこのディレクトリ内の現在の内容と類似したものになります。

ディレクトリの内容を確認してみましょう。

    ls /etc/puppetlabs/code/environments/production/

本稼働のPuppet環境を定義する、以下のファイルおよびサブディレクトリのリストが表示されます。

    data  environment.conf  hiera.yaml  manifests  modules

ほとんどの上記要素の役割は、これまでのクエストから十分に理解されているでしょう。`hiera.yaml`ファイルと`data`サブディレクトリには、Hieraの設定情報とデータが含まれています。`manifests`ディレクトリ内の`site.pp`マニフェストには、ノードの定義および分類が含まれています。また、`modules`ディレクトリには、Forgeからインストールしたモジュールと、ロールおよびプロファイルなどの各自で作成したモジュールが含まれています。[environment.conf](https://puppet.com/docs/puppet/latest/config_file_environment.html)ファイルを使用すると、この環境に割り当てられたノードにPuppet masterがサービスを提供するとき、特定のPuppet master設定をオーバーライドできます。ここまでに、これらの設定を変更する必要はなかったので、まだこのファイルは使用していません。

制御リポジトリの大部分については、現在の`production`ディレクトリと同じ内容になっています。ここで注目すべき相違点は、`modules`サブディレクトリの代わりに、、`site`という名前の別個のサブディレクトリが含まれることです。サイトディレクトリには、チームのインフラ管理を目的に記述したサイト固有のモジュールだけを格納し、ここに含まれるコードはソース管理プロセスを通じて管理します。

Forgeをはじめとする外部ソースのモジュールは、制御リポジトリに直接格納しないでください。外部のモジュールには通常、[GitHub](https://github.com/)などのサイト上に専用のパブリックリポジトリがあり、新しいバージョンがリリースされるたびにForgeに公開されます。これらのモジュールに対するすべての変更を、独自のリポジトリに反映しようとすると、多大な二度手間になります。 一般に、外部モジュールは、[Puppetfile](https://puppet.com/docs/pe/latest/code_management/puppetfile.html)を使用して管理します。

Puppetコードマネージャを使用して、master上の環境に制御リポジトリのコードをデプロイすると、Puppetfileから外部モジュールリストが読み込まれ、環境内の`modules`ディレクトリに自動でインストールされます。これにより、Puppetコードを複製して、各自の制御リポジトリ内でコード変更を管理しなくても、外部モジュールの依存関係を簡単にバージョン管理できます。

次回のクエストでは、Puppetfileを作成してその使用法を詳しく確認します。今回は、各自の制御リポジトリでコードを直接管理する、`site`ディレクトリ内のモジュールに焦点を合わせて説明します。通常、`modules`ディレクトリのコンテンツはPuppetfileによって定義されるので、外部モジュールのインストール時にサイト固有モジュールが削除またはオーバーライドされるのを防ぐため、サイト固有モジュールは別個の`site`ディレクトリ内に保持します。

<div class = "lvm-task-number"><p>タスク1:</p></div>

制御リポジトリをセットアップする第一歩として、`/root/control-repo`ディレクトリと`/root/control-repo/site`サブディレクトリを作成します。

    mkdir -p /root/control-repo/site

次に、既存の`modules`ディレクトリに移動します。

    cd /etc/puppetlabs/code/environments/production/modules

既存のモジュールを一覧表示して、制御リポジトリの`site`モジュールに格納するサイト固有モジュールを特定します。

    ls

以下のようなリストが表示されます。

    apt concat cowsay epel motd  pasture  postgresql  profile  role  stdlib user_accounts

<div class = "lvm-task-number"><p>タスク2:</p></div>

サイト固有のPuppetモジュールである`cowsay`、`pasture`、`motd`、`user_accounts`、`role`、`profile`を、制御リポジトリの`site`ディレクトリにコピーします。

    cp -r {pasture,motd,user_accounts,role,profile} /root/control-repo/site/

<div class = "lvm-task-number"><p>タスク3:</p></div>

各自のモジュールはコピーしたので、残りの本稼働環境コンテンツを制御リポジトリにコピーします。`cd`を使用して、`modules`サブディレクトリから`production`環境ディレクトリに移動します。

    cd ..

ここで、先ほど`site`ディレクトリにコピーしたモジュールをPuppetが見つけられるようにするため、もう1つの変更を加えます。Puppetが見つけられるのは、`modulepath`内のモジュールだけである点に注意してください。デフォルトで、`modules`ディレクトリはここに含まれますが、`site`ディレクトリは含まれません。Puppetがサイトモジュールを見つけられるようにするため、`site`ディレクトリを`modulepath`に追加する必要があります。このために、`environment.conf`設定ファイルを使用して、Puppet masterのデフォルトの`modulepath`設定をオーバーライドします。

はじめに、既存の`environment.conf`ファイルを制御リポジトリにコピーします。このファイルには、まだ何の設定も指定されていませんが、ファイルの一番上に有用な説明コメントが記載されているので、これは残しておきます。

    cp environment.conf /root/control-repo/environment.conf

次に、この設定ファイルを編集します。

    vim /root/control-repo/environment.conf

次の行をファイルの最後に追加して、`site`と`modules`の両方が、この環境の`modulepath`設定に含まれるようにします。

    modulepath = site:modules:$basemodulepath

<div class = "lvm-task-number"><p>タスク4:</p></div>

次に、制御リポジトリの`manifests`ディレクトリを作成します。

    mkdir /root/control-repo/manifests

既存の`site.pp`マニフェストをコピーします。

    cp manifests/site.pp /root/control-repo/manifests/site.pp

<div class = "lvm-task-number"><p>タスク5:</p></div>

コピー対象として最後に残ったのは、Hiera関連の要素です。

はじめに、`hiera.yaml`設定ファイルをコピーします。

    cp hiera.yaml /root/control-repo/hiera.yaml

次に、Hieraのデータディレクトリとそのコンテンツをコピーします。

    cp -r data /root/control-repo/data

## Gitリポジトリの初期化

ここまでで、Puppetインフラの管理に必要な要素がすべて制御リポジトリに格納されました。次は、Puppetコードをソース管理システムにチェックインします。このために、`git`コマンドラインツールを使用します。このクエストでは、このプロセスの完了と、明確にPuppetに関連する手順への対応に必要なすべてのGitコマンドについて説明しますが、GIt内部の仕組みについては詳しく説明しません。Gitはそれ自体が複雑なツールであり、理解を助けるための既存リソースがオンラインで豊富に提供されています(このクエストの最後にある*その他のリソース*セクションでも、サンプルをいくつか紹介しています)。

はじめに、`control-repo`ディレクトリをGitリポジトリとして初期化する必要があります。次に、ホストされているリモートリポジトリが、コードのアップストリームソースとして機能するように設定します。最後に、Puppetがホストされた制御リポジトリからコードをフェッチして、Puppet masterの本稼働環境にデプロイするように設定します。

このアーキテクチャでは、複数の作業者が同じコードベースを使用しながら、同時に、変更をアップストリームリポジトリにコミットして本稼働にデプロイする前に、必ずテストと承認を受けるように設定できます。

![image](../assets/git_workflow.png)

<div class = "lvm-task-number"><p>タスク6:</p></div>

はじめに、`control-repo`ディレクトリに移動します。

    cd /root/control-repo

`git init`コマンドを使用して、`control-repo`ディレクトリをGitリポジトリとして初期化します。このコマンドは、リポジトリデータを格納するための非表示の`.git`サブディレクトリを作成します。

    git init

`git add`コマンドを使用した初回コミット用に、制御リポジトリ内のファイルをステージングします。ここでは、ワイルドカードの`*`を使用し、簡単な方法ですべてのファイルを追加します。ただし、ほとんどのケースでは、コミット用にステージングするファイルを明確にするために、より限定的な`git add`コマンドを使用することを推奨します。

    git add *

`git status`コマンドを使用すると、コミットに追加されるファイルのリストが表示されます。

    git status

対象ファイルがステージングされたので、変更をコミットします。変更をコミットすると、コミットメッセージを入力するように要求するプロンプトが表示されます。このメッセージには、簡潔なタイトルの後に1行空けて、コミットで実施する変更の詳しい説明を入力します。プロジェクトやチームごとに、コミットメッセージの詳細に関する独自の規則を開発して、すべてのコード変更が完全に記録されるようにしてください。

    git commit

プロンプトが表示されたら、以下のようなコミットメッセージを入力します。保存してVimを終了すると、入力したコミットメッセージをGitが取得して、コミットを完了します。

```
Initial commit

This initial commit includes Hiera configuration, site
modules developed in previous Learning VM quests,
classification defined by the site.pp manifest, and
an environment.conf configuration file.
```

<div class = "lvm-task-number"><p>タスク7:</p></div>

先ほど`git status`コマンドを実行したとき、出力の最初に以下の行が表示されていました。

    On branch master

Gitでは、ブランチは一連のコミットチェーン、すなわち、現在の状態にいたるまでにコードに加えられたすべての個別変更を表します。一般に、1つのGitプロジェクトには1つのメインブランチがあり、プロジェクト所有者によるレビューとテストを受けたすべてのコミットがここに含まれています。承認を得てメインブランチに統合される前の進行中の作業を追跡管理するために、通常、開発者は独自の機能ブランチを作成し、メインコードベースの変更に関連するコミットを保管します。

新規リポジトリを初期化すると、Gitはデフォルトのメインブランチとして`master`を作成しますが、Puppet向けの規則では、メインブランチを`production`と呼びます。こうすることで、Puppet master上の`production`コード環境とブランチ名が一致します。

次に進む前に、`master`ブランチの名前を`production`に変更します。

    git branch -m master production

## アップストリームリモートのセットアップ

リポジトリをローカルで初期化し、ブランチ名を正しく設定したので、ローカルリポジトリをアップストリームリモートにプッシュする準備ができました。このアップストリームリモートは、特定のサービスによってホストされたもう1つのリポジトリコピーです。このサービスは、すべての作業者がこのリポジトリを使用できるようにしたうえで、システムにパーミッションを付与してそのアクセスを管理します。デプロイキーを使用して、このホストされたリポジトリへのパーミッションをPuppet自体に付与すると、Puppetのコードマネージャツールで、ホストされたPuppetコードをフェッチして、masterにデプロイすることができます。

ここでは、アップストリームリモートをホストするためにGiteaというツールを使用します。GiteaはオープンソースのGitホスティングサービスで、[GitHub](https://github.com/)とほぼ同等の機能を備えています。ここでGiteaを使用するのは、トレーニングVM上で簡単にインスタンスをホストできるからです。ただし、アップストリームリモートの安定性とセキュリティは非常に重要なので、ほとんどのPEユーザは、オンプレミスで実行できるSaaSオプション(GitHubまたは類似のサポート対象SCMサービスなど)を使用しています。Giteaを使用したセットアップとワークフローを理解しておくと、これらのサービスにも同じ原則を簡単に適用できます。

制御リポジトリのコンテンツをGiteaにプッシュする前に、ユーザアカウントをセットアップし、GiteaのWebインターフェースから 新しいアップストリームリポジトリを作成する必要があります。

<div class = "lvm-task-number"><p>タスク8:</p></div>

GiteaのWeb UIに接続するには、Webブラウザで`<VM IP ADDRESS>:3000`にアクセスします。

はじめに、インターフェース右上の[**Register**]ボタンをクリックします。

![image](../assets/gitea_register.png)

プロンプトが表示されたら、以下の認証情報を入力します。

**ユーザ名:** learning  
**メール:** learning@puppet.vm  
**パスワード** puppet  

(GiteaサーバーはトレーニングVM上でローカル実行されているので、GItHubなどの類似サービスとは異なり、このアカウントはトレーニングVMのローカルGiteaインスタンス上のみに存在します。)

アカウントを作成したら、新しい認証情報でログインします。

<div class = "lvm-task-number"><p>タスク9:</p></div>

[**My Repositories**]ヘッダの右側にある`+`アイコンをクリックして、新規リポジトリを作成します。

![image](../assets/gitea_new_repo.png)

[**Repository Name**]フィールドに`control-repo`と入力します。その他のフィールドは空白かデフォルト値のままにします。ページの一番下にある[**Create Repository**]ボタンをクリックします。

Giteaリポジトリのセットアップが完了したので、トレーニングVMのコマンドラインに戻ります。

<div class = "lvm-task-number"><p>タスク10:</p></div>

`/root/control-repo`ディレクトリから以下のコマンドを実行し、Giteaにホストされたリポジトリをローカルリポジトリのアップストリームリモートとして設定します。ここで、`<gitea_name>`は、Gitea向けに選択したアカウント名で置き換えます。

    git remote add upstream http://localhost:3000/learning/control-repo.git

以下のコマンドを実行し、リモートが正しく追加されたことを確認します。

    git remote -v

以下のような出力が表示されます。

    upstream        http://localhost:3000/learning/control-repo.git (fetch)
    upstream        http://localhost:3000/learning/control-repo.git (push)

<div class = "lvm-task-number"><p>タスク11:</p></div>

次に、ローカルの`production` ブランチをこのアップストリームリモートにプッシュします。アップストリームリモートにコンテンツを追加するのは今回が初めてなので、`production`ブランチに直接プッシュすることになります。通常であれば、レビューやテストなしで本稼働インフラを変更することを防ぐため、新しいブランチを作成して、プルリクエストを送信します。このようなワークフロー全体は、このクエスト内でのちほど確認します。

    git push upstream production

ブラウザでGiteaインターフェースに戻るか、ページをリフレッシュします。Gitea Webインターフェースから、制御リポジトリのすべてのコンテンツにアクセスできるようになりました。

<div class = "lvm-task-number"><p>タスク12:</p></div>

デフォルトのブランチをローカルで`production`に変更しているため、 同様の変更をアップストリームリポジトリにも適用する必要があります。Giteaインターフェースで[**Settings**]ページを開き、[**Branches**]タブをクリックします。

![image](../assets/gitea_settings.png)

[**Default Branch**]セクションで、ドロップダウンメニューから[`production`]を選択します。[**Update Settings**]ボタンをクリックして、変更を保存します。

![image](../assets/gitea_default_branch.png)

## コードマネージャのデプロイキー

コードマネージャツールを使用すると、制御リポジトリからmasterへのPuppetコードのデプロイを自動化できます。コードマネージャを設定するには、RSAキーペアを使用した認証をセットアップする必要があります。これにより、Puppet masterが制御リポジトリからコードをデプロイするように要求したときに、Giteaで認証できます。

はじめに、トレーニングVM上にキーを作成して、`pe-puppet`ユーザアクセスを付与します。次に、Giteaインターフェースから、このキーペアのパブリックキーをアップストリームリモートに追加します。最後に、Puppet Enterprise Webコンソールを使用して、コードマネージャを有効化し、Giteaの認証に使用するキーペアのプライベートキーを探す場所を指定します。

<div class = "lvm-task-number"><p>タスク13:</p></div>

はじめに、`/etc/puppetlabs/puppetserver`内に新しいサブディレクトリ`ssh`を作成します。

    mkdir /etc/puppetlabs/puppetserver/ssh

次に、`ssh-keygen`コマンドを使用して、新しいキーペアを作成します。

    ssh-keygen -t rsa -b 4096 -C "learning@puppet.vm"

プロンプトが表示されたら、以下のファイルにキーを保存します。

    /etc/puppetlabs/puppetserver/ssh/id-control_repo

パスフレーズの入力を要求されたら、Enterを2回押して、パスフレーズなしでキーを作成します。

この`ssh`サブディレクトリの所有者とグループに`pe-puppet`を設定します。

    chown -R pe-puppet:pe-puppet /etc/puppetlabs/puppetserver/ssh

<div class = "lvm-task-number"><p>タスク14:</p></div>

キーペアのセットアップは完了したので、次にこれをGiteaに追加します。

はじめに、ウィンドウ右上の[**Settings**]タブをクリックし、ここから[**Deploy Keys**]セクションに移動します。

デプロイキーの追加方法は2種類あります。1つ目は、単純にキーをコピーしてペーストする方法です。`cat`コマンドを使用すると、vimでパブリックキーを表示できます。

    cat /etc/puppetlabs/puppetserver/ssh/id-control_repo.pub

"ssh-rsa"と"learning@puppet.vm"の間の実際のキー部分だけをクリップボードにコピーします。Giteaインターフェースで[**Add Deploy Key**]ボタンをクリックし、フォームの[**Content**]フィールドにキーをペーストします。トレーニングVMのWebベースコンソールからコピーしている場合、パブリックキーのコピーを正確に入力するために、改行コードをいくつか手動で削除する必要があります。[**Title**]フィールドに"Code Manager"を設定し、[**Add Deploy Key**]ボタンをクリックして、キーを追加します。エラーが表示される場合、挿入したテキストが正確にキーと一致しており、改行コードや余分なスペースがキーの前後にないことを確認します。

もう1つの方法では、以下のコマンドをトレーニングVMで実行して、GiteaのAPIからキーを追加します。

        curl -i \
        -H "Content-Type: application/json" \
        -X POST -d "{\"Title\": \"Code Manager\",\"Key\": \"$(cut -d' ' -f 2 /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub)\"}" \
        http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/keys

このコマンドを実行したら、ブラウザウィンドウをリフレッシュして、キーが正しく追加されたことを確認します。

## コードマネージャの設定

制御リポジトリからコードをデプロイする前に、コードマネージャを有効化して設定する必要があります。Puppet Enterpriseの多くの内部設定オプションと同様に、コードマネージャはPuppet自体が管理しています。コードマネージャ関連を含めて、Puppet masterの設定オプションは、ほとんど`puppet_enterprise::profile::master`クラスによって管理されています。どのPuppetクラスもそうですが、このmasterプロファイルはパラメータを介して設定できます。

ここまでは、ノードへのクラスの割り当てとパラメータの設定に`site.pp`マニフェストを使用してきました。Puppet Enterprise Webコンソールのインターフェースでは、ノードの分類向けに別のインターフェースが提供されています。Puppet Enterprise Webコンソールのノード分類機能には、Puppet自体の関連設定を定義するノードグループおよび分類が組み込まれています。

<div class = "lvm-task-number"><p>タスク15:</p></div>

はじめに、ブラウザでPuppet Enterprise Webコンソールインターフェースを開き、https://<VM IP ADDRESS>`にアクセスします。以下の認証情報を使用してログインします。

**ユーザ名:** admin
**パスワード:** puppetlabs

Puppet Enterprise Webコンソールのナビゲーションメニューで[**Classifaction**]タブをクリックします。ここで、[**All nodes**]と[**PE Infrastructure**]グループを展開し、[**PE Master**]ノードグループを選択します。

![image](../assets/pe_console_master.png)

[**PE Master**]ノードグループのインターフェースで、[**Configuration**]タブを選択します。クラスリストから[`puppet_enterprise::profile::master`]クラスを見つけます。

ドロップダウンメニューで[`code_manager_auto_configure`]パラメータを選択し、値に`true`を設定します。左側の[**Add parameter**]ボタンをクリックします。同じ方法で、[`r10k_remote`]パラメータに`http://localhost:3000/learning/control-repo.git`を設定し、[`r10k_private_key`]パラメータに`/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa`を設定し、[`file_sync_enabled`]パラメータに`true`を設定します。

![image](../assets/pe_console_code_manager.png)

<div class = "lvm-task-number"><p>タスク16:</p></div>

Puppet agentの実行を開始し、これらの設定の変更をmasterに適用します。

    puppet agent -t

## Puppetコードのデプロイ

コードマネージャを設定してデプロイキーをセットアップしたので、リポジトリ内のコードに対する読み取りアクセスがPuppet masterに付与されました。制御リポジトリ内のコードを実際に使用する前に、master上のコード環境にデプロイする必要があります。

このプロセスをさらに自動化する方法がいくつかあります。例えば、[webフックを設定](https://puppet.com/docs/pe/latest/code_management/code_mgr_webhook.html)すると、アップストリームリポジトリに新しいコードが統合されるたびに、デプロイが自動的に開始されます。ここでは、実践的でシンプルな方法として、`puppet code deploy`コマンドを使用して手動でコードのデプロイを開始します。

これまでのPuppet実行で使用してきた`puppet job run`コマンドと同様に、正しい認証情報とPuppet masterへのネットワークアクセスがあれば、どのワークステーションからでもこのコマンドを実行できます。

<div class = "lvm-task-number"><p>タスク17:</p></div>

Puppet Enterprise Webコンソールのインターフェースで、左側のナビゲーションバーにある[**Access Control**]をクリックし、[**User Roles**]リンクを選択します。[**Code Deployers**]ロールをクリックします。[**Member Users**]タブで、ドロップダウンメニューから[`Learning`]ユーザを選択し、[**Add user**]をクリックしてこのユーザをロールに追加します。

<div class = "lvm-task-number"><p>タスク18:</p></div>

`puppet access`コマンドを使用して、トークンを生成します。

    puppet access login --lifetime 1d

プロンプトが表示されたら、以下の認証情報を入力します。

**ユーザ名:** learning  
**パスワード:** puppet  

`puppet code deploy`コマンドを使用して、制御リポジトリのproductionブランチを本稼働コード環境にデプロイします。`--wait`フラグを追加して、デプロイが完了するまで終了を待機するように指示します。

    puppet code deploy production --wait

デプロイプロセスが完了すると、`/etc/puppetlabs/code/environments/production`にある本稼働コードディレクトリが、制御リポジトリと同期されます。

<div class = "lvm-task-number"><p>タスク19:</p></div>

`puppet job`ツールを使用して、`pasture-app.beauvine.vm`ノードでPuppet agentの実行を開始します。このクエストの開始時に、以前の設定を何も適用しない状態でこのノードの新規インスタンスが作成されたので、今回の実行により、リポジトリから新しくデプロイしたコードで、正しいカタログを作成してこのノードに適用できるかどうかをテストできます。このPuppet実行では、`role::pasture_app`に現在定義されている設定が、`site.pp`マニフェストに指定されたとおりに適用されます。

    puppet job run --nodes pasture-app.beauvine.vm

ジョブが完了したら、ノード上でサービスが予想どおりに実行されていることを確認します。

    curl 'pasture-app.beauvine.vm/api/v1/cowsay'

## 制御リポジトリの開発フロー

この時点で、制御リポジトリからデプロイしたコードを使用してPuppetが実行されているので、ここからは、リポジトリのローカルコピーに変更を加え、その変更をアップストリームリポジトリに統合するためのプルリクエストを作成し、最終的に本稼働環境に変更をデプロイするプロセスを確認していきましょう。

<div class = "lvm-task-number"><p>タスク20:</p></div>

現在のディレクトリが`control-repo`ディレクトリになっていることを確認します。

    cd ~/control-repo

作業を開始する前に、Gitリポジトリのステータスを確認します。

    git status

以下のメッセージが表示されます。

    # On branch production
    nothing to commit, working directory clean

現在、productionブランチで作業中であり、作業ディレクトリにはコミットされていない変更が含まれてないことが確認できます。

次に、新しい作業を開始する前に、ベストプラクティスとして、アップストリームリモートの更新をチェックします。ほかの作業者によってアップストリームリポジトリが更新されている可能性があるためです。統合時に競合が発生しないようにするため、新しい作業を開始する前に、ローカルリポジトリにすべての変更をプルします。

    git pull upstream production

ローカルリポジトリがアップストリームのバージョンと同じ最新状態にあり、変更は加えられていないことが示されます。

    From http://localhost:3000/<yourname>/control-repo
    * branch            production -> FETCH_HEAD
    Already up-to-date.

ローカルリポジトリのステータスを確認したので、新しいブランチでの作業を開始します。このクエストでは、制御リポジトリとコードデプロイアのワークフローに焦点を合わせているので、簡単にテストできる小規模な変更を、Hieraデータの `beauvine.vm`ドメイン内にある`default_message`パラメータに加えます。

この変更を開始する前に、新しいブランチを作成します。ブランチには、変更内容を明確に表す短い名前を付けます。ここでは、`beauvine_message_default`という名前を付けましょう。`git checkout`コマンドを使用して、このブランチに切り替えます。`-b`フラグを指定すると、同じ名前が存在しなければ、この名前で新しいブランチが作成されます。

    git checkout -b beauvine_message_default

新しいブランチがセットアップされたら、Vimで`data/domain/beauvine.vm.yaml`ファイルを開きます。

    vim data/domain/beauvine.vm.yaml

ここで、`default_message`変数の値を`'Hello control repository!'`に変更します。

```yaml
profile::pasture::app::default_message: "Hello control repository!"
```

<div class = "lvm-task-number"><p>タスク21:</p></div>

必要な変更が完了したら、リポジトリのステータスを確認します。

    git status

出力には、現在のブランチと、まだコミット用にステージングされていない変更のリストが表示されます。

```
# On branch beauvine_default_message
# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#       modified:   data/domain/beauvine.vm.yaml
#
no changes added to commit (use "git add" and/or "git commit -a")
```

変更をステージングするには、`git add`コマンドを使用します。これにより、このファイルへの変更が次のコミットに含まれます。 変更したファイルが複数ある場合は、それぞれのファイルをすべて追加することで、同じコミットに含めることができます。

    git add data/domain/beauvine.vm.yaml

変更のステージングが完了したら、もう一度ステータスをチェックして、変更したファイルがコミット対象になっていることを確認します。

```
# On branch beauvine_default_message
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#       modified:   data/domain/beauvine.vm.yaml
#
```

変更したファイルがステージングされたので、次にコミットを実行します。

    git commit

プロンプトが表示されたら、変更内容を表す以下のコミットメッセージを入力します。以下とまったく同じメッセージにする必要はありませんが、時間を取って詳しいメッセージをきちんと作成することが重要です。変更のたびに効果的なコミットメッセージを記述しておくと、すべてのコード変更を含む詳細なログができあがるので、問題のトラブルシューティングや新しい変更の計画で、参考資料として使用できます。

```
Change beauvine default_message in Hiera

Change the default_message value for the beauvine domain to "Hello
control repository!" to demonstrate the code management workflow with a
control repository.
# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# Committer: root <root@learning.puppetlabs.vm>
#
# On branch beauvine_default_message
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#       modified:   data/domain/beauvine.vm.yaml
#
```

<div class = "lvm-task-number"><p>タスク22:</p></div>

ローカルブランチに変更をコミットしたので、次に、このブランチをアップストリームリポジトリにプッシュします。

    git push upstream update_cowsay_message

プロンプトが表示されたら、Giteaのユーザアカウント名とパスワードとして、`learning`および`puppet`を入力します。

<div class = "lvm-task-number"><p>タスク23:</p></div>

このブランチに含まれる変更を本稼働ブランチに統合するには、はじめに、プルリクエストを作成します。プルリクエストは、あるプロジェクトの特定ブランチに含まれるコミットを、別のブランチに統合するように指示するための手段です。プルリクエストがあることで、プロジェクトのメインブランチにコード変更が組み込まれる前に、プロジェクトメンバーが最終的なレビューを行う機会が作られます。

ブラウザウィンドウで、Giteaインターフェース(`<VM's IP ADDRESS>:3000`)を開きます。

[**Branch:**]ドロップダウンメニューから、新しい`beauvine_default_message`ブランチを選択します。ドロップダウンメニューの隣にあるアイコンをクリックし、ブランチ同士を比較したら、プルリクエストを開始します。プルリクエストフォームに、タイトルとリクエストの説明を入力します。このプルリクエストに含まれるコミットは1つだけなので、該当コミットのタイトルおよびコミットメッセージと同じものを入力しても構いません。

[**Create Pull Request**]ボタンをクリックして、プルリクエストを作成します。

通常であれば、この後、チームメンバーによってプルリクエストがレビュー、テスト、統合されますが、今回は自分でレビューと統合を実施します。

[**Files changed**]タブをクリックし、表示されるコードの相違点を調べます。このクエストでは、Puppetコードの詳細なテスト方法を説明していないので、納得できる方法で簡単にコード変更をレビューします。

変更に問題ないことが確認できたら、[**Conversation**]タブに戻り、[**Merge Pull Request**]ボタンをクリックします。

<div class = "lvm-task-number"><p>タスク24:</p></div>

以上で、アップストリームリポジトリの本稼働ブランチに変更が統合されたので、トレーニングVMのコマンドラインに戻ります。`puppet code deploy`コマンドを使用して、新しいコードを本稼働環境にデプロイします。

    puppet code deploy production --wait

<div class = "lvm-task-number"><p>タスク25:</p></div>

コードのデプロイが完了したら、自分のノードで別のPuppet実行を開始して、こ変更を適用します。

    puppet job run --nodes pasture-app.beauvine.vm

新しいデフォルトメッセージが返されることを確認します。

    curl 'pasture-app.beauvine.vm/api/v1/cowsay'

## おさらい

このクエストでは、ソース管理システムを使用して基礎となるコードを管理することで、インフラの変更を追跡および承認することの重要性について学習しました。また、制御リポジトリのセットアップと、コード変更の開発およびデプロイに必要なワークフローの設定について、段階的に確認しました。

はじめに、`git`コマンドラインツールを使用して制御リポジトリを作成および初期化したのち、既存コードをこのリポジトリに移動しました。

リポジトリのローカルセットアップが完了したら、Giteaサービスを使用してリモートのアップストリームリポジトリを作成しました。このアップストリームリポジトリは、Puppet masterにデプロイするすべてのコードを集中管理する役割を果たします。

アップストリームリポジトリをセットアップした後で、Puppet Enterprise Webコンソールを使用してPuppetのコードマネージャツールを設定して、Giteaにホストされている制御リポジトリに接続しました。

既存のコードをデプロイしてシステムをテストしてから、`pasture-app.beauvine.vm`ノードでPuppet agentを実行して、masterのPuppetコードが期待どおりに動作することを検証しました。

最後に、ローカルリポジトリを変更し、プルリクエストを使用してアップストリームの本稼働ブランチに変更を統合し、新規コードをデプロイおよびテストするワークフローを確認しました。

## その他のリソース

* 制御リポジトリの使用法、コードマネージャツール、その他の
  関連トピックについては、Puppetマニュアルの[Puppetコードの管理およびデプロイ](https://puppet.com/docs/pe/latest/code_management/managing_puppet_code.html)セクションを参照してください。
* Puppetが提供する[制御リポジトリテンプレート](https://github.com/puppetlabs/control-repo)
  を直接複製して、独自の制御リポジトリとして、または参照用として使用できます。
* 制御リポジトリでの
  ロールおよびプロファイルの使用法については、[こちら](http://garylarizza.com/blog/2017/01/17/roles-and-profiles-in-a-control-repo/)を参照してください。

