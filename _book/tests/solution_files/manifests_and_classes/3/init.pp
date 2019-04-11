class cowsay {
  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }
}
