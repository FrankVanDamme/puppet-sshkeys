define sshkeys::set_client_key_pair_wrapper ( 
  $user,
  $keypair_name,
) {
    notify {"key_pair $name, user $user":}
    if ! defined( Sshkeys::Set_client_key_pair[$keypair_name] ){
	sshkeys::set_client_key_pair { $keypair_name:
	    user => $user,
	}
    }
}

