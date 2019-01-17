class cowsay {
  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }
}
class cowsay {
  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }
  include cowsay::fortune
}
