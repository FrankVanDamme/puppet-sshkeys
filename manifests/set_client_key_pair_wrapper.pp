define sshkeys::set_client_key_pair_wrapper ( 
  $user,
  $keypair_name,
  $home = undef,
) {
    notify {"key_pair $name, user $user":}
    sshkeys::set_client_key_pair { $keypair_name:
        user => $user,
        home => $home,
    }
}

