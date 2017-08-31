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

	@@sshkeys::create_key_wrapper{"${name}_to_$touser@$hostname":
	    key_name => $name,
	}
	@@sshkeys::set_client_key_pair_wrapper{"${name}_to_$touser@$hostname":
	    keypair_name => $name,
	    user         => $fromuser,
	    tag          => $fromhost,
	}
	sshkeys::set_authorized_keys { $name:
	    user => $touser,
	    home => $args['home'],
	}
    }
    Sshkeys::Set_client_key_pair_wrapper <<| tag == $::hostname |>>
}
