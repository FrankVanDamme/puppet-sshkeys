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
	$splitt = split($name, '@')
	$fromuser = $splitt[0]
	$fromhost = $splitt[1]
	$touser = $args['user']

	# pass the home directory of the client user down to
	# set_client_key_pair
	# an implementation where you specify this is possible, but you 
	# could end up with multiple Set_client_key_pair resources, only
	# the first of which occurs in the catalog would be declared, and
	# cause a confusion in case you have "from" users with the same
	# name but different home directories
	# So if you really want to go exotic and think up non-standard
	# home directory locations, it may be best to define the necessary
	# resources your own way
	if ( $fromuser == 'root' ){
	    $fromhome = '/root'
	}

	# we are running on the node where access should be granted. 
	# So, this sets the process in motion of exporting a wrapper,
	# we need to collect all of these on the puppet master where
	# it will create (only) one 
	@@sshkeys::create_key_wrapper{"${name}_to_$touser@$hostname":
	    key_name => $name,
	}
	# set_client_key_pair is to install BOTH parts of the key pair, on
	# the host you want to connect FROM. We realize it on the host
	# "fromhost".
	@@sshkeys::set_client_key_pair_wrapper{"${name}_to_$touser@$hostname":
	    keypair_name => $name,
	    user         => $fromuser,
	    tag          => $fromhost,
	    home         => $fromhome,
	}
	# Finally, in the next puppet run (it has to be created first...)
	# , install the public key in the target user's authorized_keys
	# file 
	sshkeys::set_authorized_keys { $name:
	    user => $touser,
	    home => $args['home'],
	}
    }
    Sshkeys::Set_client_key_pair_wrapper <<| tag == $::hostname |>>
}
