define sshkeys::create_key_wrapper ( 
  $key_name,
) {
    # simple hack to not create identical keys with identical names
    if ! defined( Sshkeys::Create_key[$key_name] ){
	sshkeys::create_key { $key_name: }
    }
}
