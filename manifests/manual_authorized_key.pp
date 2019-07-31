define sshkeys::manual_authorized_key (
    $key,
    $keyname = "${key}_$user",
    $ensure  = present,
    $type    = 'ssh-rsa',
    $user    ,
    $options = []
){
    ssh_authorized_key{ $keyname:
	ensure  => $ensure,
	type    => $type,
	user    => $user,
	key     => lookup($key, String),
	options => $options,
    }
}

