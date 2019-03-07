{% include '/version.md' %}

# ハロー、Bolt

## クエストの目的

- Puppet Boltのインストール
- Puppet Boltインストールの検証
- Boltを使用して簡単なコマンドを実行する

## はじめましょう

このクエストでは、Puppet Boltをインストールして初歩的なコマンドをいくつか実行します。前のクエストで述べたように、Boltは1つまたは複数のターゲットノードでコマンドを実行可能なタスクランナーです。ノードを長期的に管理するというよりも、非定型のアクションを実行するのに適しています。

準備ができたらLearning VMで以下のコマンドを実行し、クエストを開始してください。

    quest begin hello_bolt

## Puppet Boltのインストール

<div class = "lvm-task-number"><p>タスク1:</p></div>

各種Red Hat Enterprise Linux、SUSE、Debian、Ubuntu、Fedoraディストリビューション、Windows、macOS用に、ビルド済みのBoltパッケージが用意されています。Learning VMはCentOS (Red Hat Enterprise Linuxと同等) 7イメージをベースとしているため、次のコマンドを実行してBoltをインストールします。

    rpm -Uvh https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm

    yum install puppet-bolt

## Puppet Boltインストールの検証

<div class = "lvm-task-number"><p>タスク2:</p></div>

Puppet Boltのインストールが完了したら、いくつかコマンドを実行し、正しく動作することを確認しましょう。

    bolt --help

    bolt --version

<div class = "lvm-task-number"><p>タスク3:</p></div>

Boltは、コマンド、スクリプト、タスク、計画をローカルマシンまたはリモートノードで実行するためのコマンドラインインターフェースを備えています。練習として簡単なコマンドを実行してみましょう。

    bolt command run 'free -th' --nodes localhost

このコマンドは、ローカルマシンに割り当てられた総メモリ容量、使用量、空き容量のレポートを人間が読める形式で表示します。出力は次のようになります。

```
Started on localhost...
Finished on localhost:
  STDOUT:
                  total        used        free      shared  buff/cache   available
    Mem:           3.7G        2.3G        143M        183M        1.2G        878M
    Swap:          1.0G         10M        1.0G
    Total:         4.7G        2.3G        1.1G
Successful on 1 node: localhost
Ran on 1 node in 0.01 seconds
```

これはboltのちょっとした使い方のデモですが、このコマンドはローカルマシン上で実行されているため、`free -th`を実行すれば簡単に同じ出力結果を得ることができます。

Boltは、1つまたは複数のノード上でコマンドを実行し、出力を収集して他のツールで何らかの処理を実行する可能性がある場合に適しています。また、sshなどのツールを`for`ループで利用するかわりに、ノードのリストをBoltに与えれば、Boltが各ノードに接続して必要なコマンドを実行してくれます。では、Dockerホストマシンをターゲットノードとして使用する例をいくつか試してみましょう。

    bolt command run hostname --nodes docker://bolt.puppet.vm

    bolt command run 'cat /etc/hosts' --nodes docker://bolt.puppet.vm

コマンドの出力は次のようになります。

```
Started on bolt.puppet.vm...
Finished on bolt.puppet.vm:
  STDOUT:
    bolt.puppet.vm
Successful on 1 node: docker://bolt.puppet.vm
Ran on 1 node in 0.05 seconds
```

```
Started on bolt.puppet.vm...
Finished on bolt.puppet.vm:
  STDOUT:
    127.0.0.1   localhost
    ::1 localhost ip6-localhost ip6-loopback
    fe00::0     ip6-localnet
    ff00::0     ip6-mcastprefix
    ff02::1     ip6-allnodes
    ff02::2     ip6-allrouters
    172.18.0.1  learning.puppetlabs.vm puppet
    172.18.0.2  bolt.puppet.vm bolt
Successful on 1 node: docker://bolt.puppet.vm
Ran on 1 node in 0.05 seconds
```

マシン解析可能な出力が必要な場合、`bolt`コマンドに`--format`オプションを使用することで可能です。次のようにします。

    bolt --format json command run 'cat /etc/hosts' --nodes docker://bolt.puppet.vm

出力は次のようになります。

```
{ "items": [
{"node":"docker://bolt.puppet.vm","status":"success","result":{"stdout":"127.0.0.1\tlocalhost\n::1\tlocalhost ip6-localhost ip6-loopback\nfe00::0\tip6-localnet\nff00::0\tip6-mcastprefix\nff02::1\tip6-allnodes\nff02::2\tip6-allrouters\n172.18.0.1\tlearning.puppetlabs.vm puppet\n172.18.0.2\tbolt.puppet.vm bolt\n","stderr":"","exit_code":0}}
],
"node_count": 1, "elapsed_time": 0 }
```

この出力は`jq`などのJSONクエリツールにパイプで渡して加工できます。boltには、他にも便利なコマンドラインオプションがたくさんあります。`bolt --help`でご確認ください。

## おさらい

このクエストでは、Puppet Boltツールをインストールし、インストールを検証し、簡単なコマンドをいくつか実行して使い方を体験しました。このクエストを通して体験したとおり、Boltは複数のノードを一度にターゲットにし、SSH、WinRM、Dockerなどのさまざまなプロトコルでさまざまな種類のノードに接続できるフレキシブルなタスクランナーです。

## その他のリソース

* 詳細情報とすべての使用事例については、Puppet Boltの[マニュアル](https://puppet.com/docs/bolt/latest/bolt.html)を参照してください。
* Puppet Boltとタスクの詳細については、[自分のペースでできるトレーニングコース](https://learn.puppet.com/course/puppet-orchestration-bolt-and-tasks)で、コマンドラインとPuppet Enterprise ConsoleからBoltを使用してノードを管理する方法を学びましょう。
