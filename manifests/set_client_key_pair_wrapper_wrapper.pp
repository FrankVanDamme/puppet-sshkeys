define sshkeys::set_client_key_pair_wrapper_wrapper ( 
  $user,
  $keypair_name,
  $home = undef,
) {

    # A double set of wrappers for the client key pair.

    # The purpose of this is: 
    # 1) avoid duplicate declaration of set_client_key_pair resources
    # 2) if you allow access from a user to multiple other machines/user accounts,
    #   and the home directory of the client user is cuctomized, to make sure
    # you DO get a duplicate resource error.

    # This works like this: 

    # a set_client_key_pair_wrapper_wrapper is exported on the destination
    # host. This will create set_client_key_pair_wrapper resources but filters
    # the duplicates that have the same keypair name AND client home directory.
    # So if somewhere in hiera, two client key names are created with a
    # different home directory, and since set_client_key_pair is named after
    # user@host without incorporating a home directory in its name, a duplicate
    # resource error will be produced on the client host. 

    $keypair_name_home="${keypair_name}_$home"

    if ! defined( Sshkeys::Set_client_key_pair_wrapper[$keypair_name_home] ){
        sshkeys::set_client_key_pair_wrapper { $keypair_name_home:
            keypair_name => $keypair_name,
            user         => $user,
            home         => $home,
        }
    }
}
