{% include '/version.md' %}

## リリースノート

### v2.0.1
  * puppet-2017.2.2-learning-6.0 VMビルドとの互換性についてコンテンツをテスト
  * 定義リソース型クエストに不足していたタスクラベルを追加
  * タイポとスペルを修正
  * 複数のタスクバリデーションテストを改良
  * セットアップガイドにいくつかの説明を追加

### v2.0.0
  * クエストコンテンツおよびタスクスペックテストのリライトを完了
  * puppet-2017.2.1-learning-5.15 VMビルドとの互換性についてコンテンツをテスト
  * [クエストツール](https://github.com/puppetlabs/quest)のアップデートによりクエストセットアッププロセスを改良
  * [pltraining-learning](https://github.com/puppetlabs/pltraining-learning)モジュールを[pltraining-bootstrap](https://github.com/puppetlabs/pltraining-bootstrap)に統合
  * [pltraining-bootstrap](https://github.com/puppetlabs/pltraining-bootstrap)モジュールのアップデートにより、ローカルgemサーバおよびForgeサーバを追加
  * [pltraining-bootstrap](https://github.com/puppetlabs/pltraining-bootstrap)モジュールのアップデートにより、必要なすべてのコンテンツをキャッシュし、オフライン使用を完全にサポート
  * [pltraining-dockeragent](https://github.com/puppetlabs/pltraining-dockeragent)のアップデートにより、ローカルgemサーバのサポート、sshログイン、Puppet証明書、PostgreSQL依存関係など、クエスト記載のたagent使用事例をサポート

### v1.2.6
  * ビルド内であらかじめ作成されたものを使用するのではなく、
    「マニフェストとクラス」クエストでcowsayingsディレクトリ構造を作成するための説明を追加

### v1.2.5
  * puppet-2016.2.1-learning-5.6 VMビルとの互換性についてコンテンツのテストを実施
  * [pltraining-bootstrap](https://github.com/puppetlabs/pltraining-bootstrap)モジュールのアップデートにより、vimのデフォルトの行ナンバリングを消去
  * [pltraining-learning](https://github.com/puppetlabs/pltraining-learning)モジュールのアップデートにより、cowsayモジュールのモジュール構造ディレクトリを作成

### v1.2.4
  * puppet-2016.2.1-learning-5.5 VMビルドとの互換性についてコンテンツをテスト
  * CSSスタイリングをアップデート
  * RESTfulクエストツールバージョンと互換性を持つようにテストをマイナーチェンジ
  * コンテンツの若干の修正

### v1.2.3
  * puppet-2016.2.0-learning-5.4 VMビルドとの互換性についてコンテンツをテスト
  * Puppetのプライバシーポリシーにプライバシーリンクを追加
  * タスクアイコンに関するCSSアラインメントの問題を修正
  * ヘッダとサイドバーのCSSを調整
  * 「変数とパラメータ」クエストにおいて不足していたコードと命令コードに関する問題を修正
  * バージョンヘッダノートを作成し、本リリースノートページへのリンクを追加
  * book.jsonでgitbook 3.1.1を指定

### v1.2.2
  * タスク仕様のフォーマットを整理、Puppetコードで考えられるバリエーションとの一致率を高めるために一部のテストを一般化
  * PE 2016.2コンソールのスタイル変更に合わせてスクリーンショットを更新 
  * ベストプラクティスとの一致度を高めるためにファイルリソース宣言をアップデート

### v1.2.1
  * タイムゾーンの更新に関する説明を追加
  * Power of PuppetおよびNTPクエストの説明を明確化
  * ビルドプロセスを修正し、VirtualBox互換性を改善
  * CPU割り当て数の提案を2に増加
  * クエストテストをテストするためのテストを追加
  * トラブルシューティングガイドを更新

### v1.2.0
  * ブランド化したCSSスタイリングを追加
  * 不正確なオフラインモジュールのインストールに関する説明を修正
  * オフライン作業時におけるキャッシュしたgemのインストールに関する説明を追加
  * GA gitbookのプラグインを追加
  * スプラッシュ画面を調整(pltraining-bootstrapモジュール)
  * PEスタックサービスを適切な順序で再起動するためのスクリプトを追加
  * 各種のタイポ修正とコンテンツのマイナーチェンジ

### v1.0.0
  * 本リポジトリへの移行後の最初のリリース。Gitbookベースのディスプレイフォーマットと新しいgemクエストツールとのコンテンツの互換性
  * 2016.1リリースのスクリーンショットを更新
  * タイポ修正と言い回しの改善
  * セットアップおよびトラブルシューティングの説明の変更により、VirtualBox I/O APIC問題に対応
  * 不具合があるタスクスペックや限定的すぎるタスクスペックを修正
  * 今後の互換性を破る変更を回避するために、dwerder-graphiteモジュールバージョンを固定
  * Gitbookフォーマットのcssスタイリングを追加
