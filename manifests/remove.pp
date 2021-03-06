# Remove any specified users and groups
class local_users::remove (
  # Class parameters are populated from module hiera data
) {

  $users_to_remove = lookup('local_users::remove::users', Collection, 'unique', [])
  $groups_to_remove = lookup('local_users::remove::groups', Collection, 'unique', [])

  $users_to_remove.each | $user | {
    exec { "killing ${user}":
      command => "pkill -9 -u ${user}",
      onlyif  => "grep '^${user}' /etc/passwd && ps -u ${user}",
      path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    }
    -> user { $user:
      ensure     => absent,
      forcelocal => true,
    }
  }

  $groups_to_remove.each | $group | {
    group { $group:
      ensure     => absent,
      forcelocal => true,
    }
  }
}
