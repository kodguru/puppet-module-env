# == Class: env::proxy
#
# Set proxy env variables
#
class env::proxy (
  $profile_file_ensure = 'present',
  $profile_file        = 'proxy',
  $enable_sh           = 'USE_DEFAULTS',
  $enable_csh          = 'USE_DEFAULTS',
  $enable_hiera_array  = false,
  $url                 = 'MANDATORY',
  $port                = 8080,
  $exceptions          = undef,
) {

  include env

  validate_re($profile_file_ensure, '^(present|absent)$',
    "env::proxy::profile_file_ensure is <${profile_file_ensure}>. Must be present or absent.")

  validate_re($profile_file, '^[a-zA-Z0-9\-_]+$',
    'env::proxy::profile_file must be a string and match the regex.')

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
      fail("env::proxy supports OS families RedHat, Suse, Debian and Solaris. Detected osfamily is <${::osfamily}>.")
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
      fail('env::proxy::enable_sh must be of type boolean or string.')
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
      fail('env::proxy::enable_csh must be of type boolean or string.')
    }
    validate_bool($enable_csh_real)
  }

  if is_string($enable_hiera_array) {
    $enable_hiera_array_real = str2bool($enable_hiera_array)
  } elsif is_bool($enable_hiera_array) {
    $enable_hiera_array_real = $enable_hiera_array
  } else {
    fail('env::proxy::enable_hiera_array must be of type boolean or string.')
  }
  validate_bool($enable_hiera_array_real)

  if $url == 'MANDATORY' or empty($url) {
    fail('env::proxy::url is MANDATORY.')
  } else {
    validate_re($url, '(?=^[a-zA-Z0-9\-\.]{1,254}$)(^(?!\-)([a-zA-Z0-9\-]{1,63}\.)+[a-zA-Z]{2,63}$)',
      "env::proxy::url is <${url}>. Must be an url.")
  }

  if is_integer($port) {
    $port_real = num2str($port)
  } elsif is_string($port) {
    $port_real = $port
  } else {
    fail("env::proxy::port is <${port}>. Must be an integer or a string.")
  }
  validate_re($port_real, '^([1-9]{1}|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$',
    "env::proxy::port is <${port_real}>. Must match the regex.")

  if $exceptions {
    if is_array($exceptions) {
      if $enable_hiera_array_real {
        $exceptions_arr = hiera_array('env::proxy::exceptions')
      } else {
        $exceptions_arr = $exceptions
      }

      $exceptions_real = join($exceptions_arr, ',')
    } else {
      fail('env::proxy::exceptions must be an array.')
    }
  } else {
    $exceptions_real = undef
  }

  if $enable_sh_real {
    file { "profile_d_${profile_file}_sh":
      ensure  => $profile_file_ensure,
      path    => "/etc/profile.d/${profile_file}.sh",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('env/proxy.sh.erb'),
    }
  }

  if $enable_csh_real {
    file { "profile_d_${profile_file}_csh":
      ensure  => $profile_file_ensure,
      path    => "/etc/profile.d/${profile_file}.csh",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('env/proxy.csh.erb'),
    }
  }
}
