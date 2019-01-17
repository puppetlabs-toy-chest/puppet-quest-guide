class profile::base::dev_users {
  lookup(profile::base::dev_users::users).each |$user| {
    user_accounts::ssh_user { $user['title']:
        comment => $user['comment'],
        key => $user['pub_key'],
    }
  }
}
