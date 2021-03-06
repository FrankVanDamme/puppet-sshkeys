class sshkeys (
    $manual_keys = {},
    $automatic_keys = {},
) {
    create_resources('sshkeys::manual_authorized_key',hiera_hash('sshkeys::manual_keys', $manual_keys))

    # who needs manual methods if you can automate?
    # hiera example:
    # fromuser@fromhost:
    #     user: localuser
    #     home: usershomedir #optional, if you live in /root or /exotic/location

    $autokeys = hiera_hash('sshkeys::automatic_keys', {})

    $autokeys.each | $name, $args | {
	if ( $args['key'] == undef or $args['key'] == "" ){
	    $key_name = $name
	} else {
	    $key_name = $args['key']
	}

	if ( $args['ensure'] == undef ){
	    $ensure = present
	} else {
	    $ensure = $args['ensure']
	}

	$splitt = split($key_name, '@')
	$fromuser = $splitt[0]
	$fromhost = $splitt[1]
	#$user_ = [ $args['user'] ] 
	$touser = $args['user']
	notify { "from $name, key_name: $key_name ; key: ~${key}~": }

    # pass the home directory of the client user down to
    # set_client_key_pair

    # you can set the location of the home directory of the client user, if and
    # only if you keep the "fromhome" parameter for that user on that host the
    # same across your environment. A user only has one home directory on any
    # given host, right?

    # set fromhome, the client user's home directory, if given as argument
    if ( $args['client_home'] != undef ){
        $fromhome = $args['client_home']
    } else {
        # for root user, default to /root as home directory
        if ( $fromuser == 'root' ){
            $fromhome = '/root'
        }
    }

	# we are running on the node where access should be granted. 
	# So, this sets the process in motion of exporting a wrapper,
	# we need to collect all of these on the puppet master where
	# it will create (only) one 
	@@sshkeys::create_key_wrapper{"${key_name}_to_$touser@$hostname":
	    key_name => $key_name,
	}
	# set_client_key_pair is to install BOTH parts of the key pair, on
	# the host you want to connect FROM. We realize it on the host
	# "fromhost".
	@@sshkeys::set_client_key_pair_wrapper_wrapper{"${key_name}_to_$touser@$hostname":
	    keypair_name => $key_name,
	    user         => $fromuser,
	    tag          => $fromhost,
	    home         => $fromhome,
	}
	# Finally, in the next puppet run (it has to be created first...)
	# , install the public key in the target user's authorized_keys
	# file 
	sshkeys::set_authorized_keys { $name:
	    keyname  => $key_name,
	    user     => $touser,
	    home     => $args['home'],
	    ensure   => $ensure,
	}
    }
    Sshkeys::Set_client_key_pair_wrapper_wrapper <<| tag == $::hostname |>>
}
