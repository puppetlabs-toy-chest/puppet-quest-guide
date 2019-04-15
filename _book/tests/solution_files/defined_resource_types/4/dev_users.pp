class profile::pasture::dev_users {
  user_accounts::ssh_user { 'bert':
    comment => 'Bert',
    key => '<PASTE KEY HERE>',
  }
  user_accounts::ssh_user { 'ernie':
    comment => 'Ernie',
    key => '<PASTE KEY HERE>',
  }
}
