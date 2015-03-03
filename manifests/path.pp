# == Class: env::path
#
# Set path env variables
#
class env::path (
  $profile_file_ensure   = 'present',
  $profile_file          = 'path',
  $enable_sh             = 'USE_DEFAULTS',
  $enable_csh            = 'USE_DEFAULTS',
  $enable_hiera_array    = false,
  $include_existing_path = true,
  $directories           = 'MANDATORY',
) {

  include env

  validate_re($profile_file_ensure, '^(present|absent)$',
    "env::path::profile_file_ensure is <${profile_file_ensure}>. Must be present or absent.")

  validate_re($profile_file, '^[a-zA-Z0-9\-_]+$',
    'env::path::profile_file must be a string and match the regex.')

  case $::osfamily {
    'RedHat': {
      $enable_sh_default  = true
      $enable_csh_default = true
    }
    'Suse': {
      $enable_sh_default  = true
      $enable_csh_default = true
    }
    'Debian': {
      $enable_sh_default  = true
      $enable_csh_default = true
    }
    'Solaris': {
      $enable_sh_default  = true
      $enable_csh_default = false
    }
    default: {
      fail("env::path supports OS families RedHat, Suse, Debian and Solaris. Detected osfamily is <${::osfamily}>.")
    }
  }

  if $enable_sh == 'USE_DEFAULTS' {
    $enable_sh_real = $enable_sh_default
  } else {
    if is_string($enable_sh) {
      $enable_sh_real = str2bool($enable_sh)
    } elsif is_bool($enable_sh) {
      $enable_sh_real = $enable_sh
    } else {
      fail('env::path::enable_sh must be of type boolean or string.')
    }
    validate_bool($enable_sh_real)
  }

  if $enable_csh == 'USE_DEFAULTS' {
    $enable_csh_real = $enable_csh_default
  } else {
    if is_string($enable_csh) {
      $enable_csh_real = str2bool($enable_csh)
    } elsif is_bool($enable_csh) {
      $enable_csh_real = $enable_csh
    } else {
      fail('env::path::enable_csh must be of type boolean or string.')
    }
    validate_bool($enable_csh_real)
  }

  if is_string($enable_hiera_array) {
    $enable_hiera_array_real = str2bool($enable_hiera_array)
  } elsif is_bool($enable_hiera_array) {
    $enable_hiera_array_real = $enable_hiera_array
  } else {
    fail('env::path::enable_hiera_array must be of type boolean or string.')
  }
  validate_bool($enable_hiera_array_real)

  if is_string($include_existing_path) {
    $include_existing_path_real = str2bool($include_existing_path)
  } elsif is_bool($include_existing_path) {
    $include_existing_path_real = $include_existing_path
  } else {
    fail('env::path::include_existing_path must be of type boolean or string.')
  }
  validate_bool($include_existing_path_real)

  if $directories == 'MANDATORY' {
    fail('env::path::directories is MANDATORY.')
  } elsif is_array($directories) {
    if $enable_hiera_array_real {
      $directories_arr = hiera_array('env::path::directories')
    } else {
      $directories_arr = $directories
    }

    if $enable_sh_real {
      $directories_sh_real = join($directories_arr, ':')
    }
    if $enable_csh_real {
      $directories_csh_real = join($directories_arr, ' ')
    }
  } else {
    fail('env::path::directories must be an array.')
  }

  if $enable_sh_real {
    file { "profile_d_${profile_file}_sh":
      ensure  => $profile_file_ensure,
      path    => "/etc/profile.d/${profile_file}.sh",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('env/path.sh.erb'),
    }
  }

  if $enable_csh_real {
    file { "profile_d_${profile_file}_csh":
      ensure  => $profile_file_ensure,
      path    => "/etc/profile.d/${profile_file}.csh",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('env/path.csh.erb'),
    }
  }
}
