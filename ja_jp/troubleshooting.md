{% include '/version.md' %}

# Learning VMのトラブルシューティング

このトラブルシューティングの最新バージョンについては、[GitHubリポジトリをチェックしてください](https://github.com/puppetlabs/puppet-quest-guide/blob/master/en_us/troubleshooting.md)。

Learning VMのセットアップについては、[ビデオチュートリアルをご覧ください](https://youtu.be/Y0nsM4uG9pQ)。

### Learning VMのクエストガイドが見つからない

クエストガイドは、VM上(http://<IPADDRESS>)にホストされています。ここで`IPADDRESS`はVMのIPアドレスです。クエストガイドがホストされているのはhttpであり、httpsではない点に注意が必要です。パスワードを要求された場合は、httpsでホストされているPuppet Enterprise Webコンソールのログイン画面にアクセスしています。

### agentノードが証明書署名リクエストを生成せず、署名済み証明書もない

クエスト開始時にpe-puppetserverサービスがmasterで完全に起動されていない場合、証明書署名リクエストおよび証明書署名プロセスが完了しない場合があります。その場合、 `systemctl--all | grep pe-`コマンドを使用して、すべてのPEサービスが完全に起動していることを確認し、次に`quest`ツールを使用してクエストを再開します。

### Pasture APIに対してcurlコマンドを実行しようとすると、"Connection refused"エラーが表示される

Puppetコード自体は正しく、エラーなしで実行できると思われますが、pasture_config.yamlファイルまたはpasture.serviceファイルに問題があり、Pastureサービスが失敗しています。

ノードに接続して`journalctl -u pasture`を実行すると、pastureログをチェックできます。

 pasture_config.yamlファイルとpasture.serviceファイルの内容が、クエストガイドの記載と正確に一致していることを確認してください。YAMLはホワイトスペースを区別するので、改行コードやインデントを正しく指定する必要があります。間違った個所を特定できない場合は、次のようなオンラインのYAMLパーサを使用することをお勧めします。
http://yaml-online-parser.appspot.com/

### Puppet agentをインストールしようとすると、"Connection refused"エラーが表示される

pe-puppetserverサービスが完全に開始されていないか、メモリ不足でエラーになっていると思われます。マシンを再起動し、`pe-puppetserver`サービスが完全に起動するまで数分待ってから、クエストツールを使用してクエストを再開し、インストールを再試行します。`systemctl --all | grep pe-` コマンドを実行すると、すべてのPuppet Enterpriseサービスのステータスを確認できます。引き続きエラーが発生する場合、セットアップガイドの指定どおりのメモリ容量がVMに割り当てられているかどうか、また、VMに割り当てられたメモリ容量が実際にホストマシンで使用可能であるかどうかを確認します。

### タスクを完了したのに、クエストツールで完了と表示されない

クエストツールでは、各クエストについて一連の[Serverspec](http://serverspec.org/)テストを使用し、タスクの進捗状況を追跡していますが、タスクとテストが常に一致するとは限りません。

システム上でその他の検証可能な影響が見られない一部のタスクについては、入力されたコマンドのbash履歴に基づいて追跡します。入力したコマンドの有効な別バージョンが、テストで予期されていないものである可能性もあります。

Puppetコードや他のファイルのコンテンツに関連するタスクについては、有効な構文のバリエーションを捕捉しない形で、タスクのテストを記述しています。

Learning VMの`/usr/src/puppet-quest-guide/tests`ディレクトリにあるクエストのスペックファイルか、クエストガイド[リポジトリ](https://github.com/puppetlabs/puppet-quest-guide/tree/master/tests)にある最新の該当コードを参照すると、特定のテストを確認できます。また、テストで使用するソリューションファイルは、`tests`ディレクトリの`solution_files`サブディレクトリにあります。

テストまたは付属要素に問題が見つかった場合、learningvm@puppet.comまでEメールでご連絡ください。

### クエストガイドを使用するためにパスワードは必要ですか？

Learning VMのクエストガイドには、`http://<IPAddress>`からアクセスできます。ここで、 `IPAddress`はLearning VMのパスワードです。Puppet Enterprise Webコンソールで使用する`https`ではなく、`http`である点に注意してください。Puppet Enterprise Webコンソールではパスワードが要求されますが、クエストガイドではパスワードは要求されません。

### VMログイン用のパスワードが見つからない

Learning VMのパスワードはランダムに生成され、VM起動時に仮想化ソフトウェアの端末のスプラッシュページに表示されます。

仮想化ソフトウェアの端末からすでにログウインしている場合は、以下のコマンドを使ってパスワードを見ることができます: `cat /var/local/password`。

場合によっては、スプラッシュページがWebインターフェースコンソールに表示されないことがあります。これは通常、ページを更新すれば解決します。

### Learning VMはvSphere、ESXiなどで機能しますか？

VMは通常、これらのプラットフォームと互換性がありますが、この点についてはVMをテストまたはサポートしていません。

### Puppet Enterprise Webコンソールに接続できない

コンソールでは自己署名証明書が用いられます。そのため、ほとんどのブラウザでセキュリティ警告が表示されます。この警告を迂回するには、警告ページに表示される*advanced(詳細)*リンクをクリックする必要がある場合があります。

VMが起動してからすべてのPuppetサービスが完全に起動するまで、少し時間がかかることがあります。サービスが起動する前にコンソールに接続しようとすると、503エラーが表示されます。VMを起動してすぐ、またはPuppet Enterpriseスタックのサービスを再起動してすぐの場合は、数分待ってから、Puppet Enterpriseコンソールへの接続を試みてください。以下のPuppet Enterpriseサービスのセクションを参照してください。

### Puppet Enterprise Webコンソールのログイン認証情報が見つからない

レッスン中にコンソールへのアクセスが必要になる場合、クエストガイドに記載されたPuppet Enterprise Webコンソール用ログイン認証情報を使用できます。ログインは**admin**で、パスワードは**puppetlabs**です。クエストガイドへのアクセス時にPuppet Enterprise Webコンソールのログインプロンプトが表示される場合、urlで、`http`ではなく`https`を使用しています。

### Puppet Enterpriseサービスのいずれかが起動しない、またはクラッシュする

Learning VMのPuppetサービスは、リソースの制限された環境内で実行するように構成されているため、通常の本稼働インストールよりも再起動に時間がかかり、安定性も低くなる可能性があります。

VMを起動してからPuppet Enterpriseサービスが完全に起動するまでに、数分を要することがあります。VMを再起動してすぐにPuppet Enterpriseコンソールへの接続を試みたり、Puppet agent実行を開始したりすると、サービスが完全に起動するまでの間はエラーが表示されることがあります。

以下のコマンドでPuppetサービスのステータスをチェックできます。

    systemctl --all | grep pe-

VM起動後、数分が経ってもPuppet関連サービス(pe-console-servicesなど)が停止する場合は、VMに割り当てられたメモリとホストで利用できるメモリが十分かどうかを二重に確認し、以下のスクリプトを使って、サービスを正しい順序で再起動してください。

    restart_classroom_services.sh

### クエストで使用されるノードの1つに対して、SSH接続もPuppetジョブツールの適用もできない

クエストツールを使用してクエストを開始すると、そのクエストに必要なノードがDockerを使用して生成されます。`docker ps`コマンドを使用すると、実行中のコンテナノードの一覧を確認できます。VMを再起動すると、Dockerサービスがリセットされて生成されたノードが削除されます。この場合、クエストツールを使用してクエストを再開する必要があります。Puppet実行のトリガーなど、生成されたノードに対する変更を含むタスクは、すべて再実行する必要があります。Puppetコードやmasterの設定に対する変更は維持されます。

定義リソース型クエストで別のユーザアカウントに接続するためのパスワードを要求された場合、Puppetコード、Hieraデータ、ssh鍵ペアのいずれかに問題がある可能性があります。設定が正しい場合、接続にパスワードは必要ありません。問題を手動で確認するには、ラーニングユーザとしてシステムにログインし、sudoを使用して/home/gertie/.ssh/authorized_keysを参照します。ここに、自分で生成してHieraファイルに保存した鍵と一致するエントリがあることを確認します。

### Puppet agentを実行すると、"Server Error: Could not parse for environment production"エラーが表示される

Puppet agentからこのエラーが返されるのは、Puppetコードを解析できない場合です。エラーメッセージに、構文エラーを含むファイルが示されます。`puppet parser validate`コマンドを使用して、このファイル内の構文をチェックします。引用符、丸括弧、波括弧のいずれかが対になっていない場合、ファイルの最後で、対応する文字を探すパーサのスキャンが失敗して構文エラーが発生します。この構文検証の出力がはっきりしない場合、コードをクエストガイド内のサンプルと比較するか、自動テストで使用されるソリューションファイル(https://github.com/puppetlabs/puppet-quest-guide/tree/master/tests/solution_files)と比較してください。

### Puppet agentを実行すると、"connect(2) for learning.puppetlabs.vm port 8140"エラーが表示される

これは通常、`pe-puppetserver`サービスがダウンしていることを意味します。上のセクションの説明を参照し、Puppet Enterpriseサービスをチェックして再起動してください。

### Puppet agentを実行すると、"Failed to find facts from PuppetDB at learning.puppetlabs.vm:8140"エラーが表示される

これは通常、`pe-puppetdb`サービスがダウンしていることを意味します。上のセクションの説明を参照し、Puppet Enterpriseサービスをチェックして再起動してください。

### Puppetジョブツールで、ノードがPCPブローカに接続されていないというエラーが表示される

 `puppet job`ツールからPuppetを実行する場合、`Error running puppet on pasture.puppet.vm: pasture.puppet.vm is not connected to the PCP broker`のような形のエラーが表示されることがあります。ノードは最初のPuppet実行時にPCPブローカに接続します。`quest`ツールにより作成されたagentノードは、作成時に自動的にPuppetを実行するため、通常はノードがPCPブローカに接続するはずです。しかし、この最初のPuppet実行が失敗した場合は、ノードがPCPブローカに接続せず、エラーが表示されます。この問題を解決するには、agentノードに直接接続し、手動でPuppet agentを実行してください。これにより、agent実行失敗の原因を示すエラーメッセージが表示されるか、問題なく実行された場合はノードがPCPブローカに接続されます。

### OVAをインポートまたは起動できない

最新バージョンの仮想化ソフトウェアをインストールしていることを確認してください。VirtualBoxの"アップデートチェック"機能は、常に予想通り動作するわけではないため、最新バージョンについてはWebサイトを確認してください。

BIOSで仮想化拡張子が有効になっていることを確認してください。この手順はシステムに固有のもので、通常はオンラインで提供されています。

Mac OS Xを使っていて、`Unable to retrieve kernel symbols`、`Failed to initialize monitor device`、または`Internal error`が表示される場合は、[このVMWare知識ベースページ ](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2061791)を参照してください。

VirtualBoxにはHyper-Vとの互換性はありません。VirtualBoxでVMを問題なく実行するためには、システム上でHyper-Vを無効にする必要があります。

### Learning VMにIPアドレスがない、またはIPアドレスが応答しない

VMロード時からネットワーク接続が変更されている場合は、IPアドレスがLearning VMスプラッシュページに表示されるものとは異なっている可能性があります。仮想化ディレクトリ( SSHではなく)からVMにログインし、`ifconfig | less`コマンドを使って、各ネットワークインターフェースに関連するIPアドレスを表示してください。内部ドッカーネットワークに使用しているものを含め、複数のインターフェースが表示されます。適切なインターフェースは、必ず `eth`または`enp`で始まります。IPアドレスが取得できなかったり、IPアドレスが無効だったりする状況が続く場合は、通常はVMを再起動すれば、ネットワークサービスが適切にリセットされたかどうかを簡単に確認できます(ただし残念ながら、ネットワークサービスの再起動は、常に確実な方法ではありません)。

VirtualBoxには、ホストオンリーアダプタ設定が一部のWindowsシステムに影響するという問題が以前からあります。ネットワークアダプタ設定インターフェースに適用した設定が変更またはリセットされたように見える場合、[このVirtualBoxチケット](https://www.virtualbox.org/ticket/8796#comment:20)を参照し、背景情報と可能な回避策を確認してください。

また、仮想化ソフトウェアのVMネットワーク設定メニューで設定したブリッジアダプタインターフェースが正しくない可能性もあります。これは、初回のインターフェース設定後に、有線ネットワークから無線ネットワークに変更した場合に生じることがあります。ネットワーク設定ダイアログで、アダプタの名前が現在使用している接続と一致しているかどうかを確認してください。

ブリッジネットワークアダプタを使っている場合、一部のネットワーク設定により、Learning VMへのアクセスが妨げられることがあります。その場合は、サイトネットワーク管理者に相談し、VMへのアクセスを妨げる可能性のあるファイアウォールルール、プロキシ、DHCPサーバー設定が存在するかどうかを確認してください。この問題を解決できない場合は、セットアップガイドの指示に従い、VM用にホストのみのネットワークアダプタを設定することを推奨します。

### 端末でスクロールアップできない

Learning VMでは、tmuxというツールを使って、クエストステータスを表示できるようにしています。まず、Ctrl＋bを押し、次に`[` (左側の角括弧)を押すと、tmuxでスクロールできるようになります。その後は、矢印キーを使ってスクロールできます。スクロールを終了するには、`q`を押します。

### クエストガイドにはPDFバージョンがありますか？

異なるバージョンのPDFが多数存在することで、ガイドとVMのユーザにとってバージョンに適した正しいガイドを見つけることが難しくなっていたため、PDFバージョンは廃止されました。Learning VMを実行せずにクエストガイドの内容を確認したい場合、プロジェクトのGitHubページ(https://github.com/puppetlabs/puppet-quest-guide/blob/master/en_us/summary.md)を参照する方法があります。ただし、この方法では、リリースされていない変更が含まれていたり、使用中のLearning VMのコンテンツやタスク検証と一致しない場合があります。

### 問題が解決しない場合

上述の手順を試してもPuppet実行が失敗する場合は、Puppet Enterprise [既知の問題](https://puppet.com/docs/pe/latest/pe_known_issues.html)ページをチェックするか、learningvm@puppet.comまでお問い合わせください。その際は、お使いのホストOS、仮想化ソフトウェアとバージョン、VMを実行しているサイトネットワーク設定の詳細(プロキシや制限的なファイアウォールルールがあるかどうかなど)も併せてお知らせください。問題に関連するログがある場合は、ホストマシンからscpを使えば、ログをローカルディレクトリにコピーすることができます。

    scp root@<IPADDRESS>:/var/log/messages messages

[PuTTY PSCPがインストールされた](http://tartarus.org/~simon/putty-snapshots/htmldoc/Chapter5.html#pscp)Windowsシステムでは、コマンドプロンプトから`pscp`を使用できます。

    pscp root@<IPADDRESS>:/var/log/messages messages
