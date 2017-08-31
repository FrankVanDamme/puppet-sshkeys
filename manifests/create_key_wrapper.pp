define sshkeys::create_key_wrapper ( 
  $key_name,
) {
    if ! defined( Sshkeys::Create_key[$key_name] ){
	sshkeys::create_key { $key_name: }
    }
}

