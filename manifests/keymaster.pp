# Keymaster host:
# Create key storage; create, regenerate, and remove key pairs
class sshkeys::keymaster {
  include sshkeys::var
  file { $sshkeys::var::keymaster_storage:
    ensure => directory,
    owner  => puppet,
    group  => puppet,
    mode   => '644',
  }
  # Realize all virtual master keys
  Sshkeys::Setup_key_master <| |>
  # Realize all create_key's exported as part of the automatic_keys logic
  Sshkeys::Create_key_wrapper <<|  |>> 
}
