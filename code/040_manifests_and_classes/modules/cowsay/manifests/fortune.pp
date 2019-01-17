class cowsay::fortune {
  package { 'fortune-mod':
    ensure => present,
  }
}
