# ## Class: proxy ##
#
# Set proxy env variables
#
class env::proxy (
  $ensure             = 'present',
  $url                = undef,
  $port               = 8080,
  $exceptions         = undef,
  $enable_hiera_array = false,
  $existing_file      = 'USE_DEFAULTS',
  $profile_file       = 'USE_DEFAULTS',
) {

  validate_re($ensure, '^(present|absent)$',
    "env::proxy::ensure is <${ensure}>. Must be present or absent.")
  validate_re($url, '(?=^[a-zA-Z0-9\-\.]{1,254}$)(^(?!\-)([a-zA-Z0-9\-]{1,63}\.)+[a-zA-Z]{2,63}$)',
    "env::proxy::url is <${url}>. Must be an url.")

  $enable_hiera_array_type = type($enable_hiera_array)

  case $enable_hiera_array_type {
    'string': {
      $enable_hiera_array_real = str2bool($enable_hiera_array)
    }
    'boolean': {
      $enable_hiera_array_real = $enable_hiera_array
    }
    default: {
      fail("env::proxy::enable_hiera_array must be of type boolean or string. Detected type is <${enable_hiera_array_type}>.")
    }
  }

  case $::osfamily {
    'RedHat': {
      case $::lsbmajdistrelease {
        '5': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/proxy.sh'
        }
        '6': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/proxy.sh'
        }
        '7': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/proxy.sh'
        }
        default: {
          fail("Proxy is only supported on EL 5, 6 and 7. Your lsbmajdistrelease is identified as <${::lsbmajdistrelease}>.")
        }
      }
    }
    'Suse': {
      case $::lsbmajdistrelease {
        '10': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/proxy.sh'
        }
        '11': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/proxy.sh'
        }
        '12': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/proxy.sh'
        }
        default: {
          fail("Proxy is only supported on Suse 10, 11 and 12. Your lsbmajdistrelease is identified as <${::lsbmajdistrelease}>.")
        }
      }
    }
    'Debian': {
      case $::lsbdistid {
        'Debian': {
          case $::lsbmajdistrelease {
            '7': {
              $existing_file_default = false
              $profile_file_default  = '/etc/profile.d/proxy.sh'
            }
            default: {
              fail("Proxy is only supported on lsbdistid Ubuntu of the Debian osfamily. Your lsbdistid is <${::lsbdistid}>.")
            }
          }
        }
        'Ubuntu': {
          case $::lsbdistrelease {
            '12.04': {
              $existing_file_default = false
              $profile_file_default  = '/etc/profile.d/proxy.sh'
            }
            default: {
              fail("Proxy is only supported on Ubuntu 12.04. Your lsbdistrelease is identified as <${::lsbdistrelease}>.")
            }
          }
        }
      }
    }
    'Solaris': {
      case $::kernelrelease {
        '5.9': {
          $existing_file_default = true
          $profile_file_default  = '/etc/profile'
        }
        '5.10': {
          $existing_file_default = true
          $profile_file_default  = '/etc/profile'
        }
        '5.11': {
          $existing_file_default = true
          $profile_file_default  = '/etc/profile'
        }
        default: {
          fail("Proxy is only supported on Solaris 9, 10 and 11. Your kernelrelease is identified as <${::kernelrelease}>.")
        }
      }
    }
    default: {
      fail("Proxy supports OS families Debian, RedHat, Suse and Solaris. Detected osfamily is <${::osfamily}>.")
    }
  }

  if type($existing_file) == 'boolean' {
    $existing_file_real = $existing_file
  } else {
    $existing_file_real = $existing_file ? {
      'USE_DEFAULTS' => $existing_file_default,
      default        => str2bool($existing_file)
    }
  }

  if $profile_file == 'USE_DEFAULTS' {
    $profile_file_real = $profile_file_default
  } else {
    $profile_file_real = $profile_file
  }

  if $exceptions {
    if $enable_hiera_array_real {
      $exceptions_arr = hiera_array('proxy::exceptions')
    } else {
      $exceptions_arr = $exceptions
    }

    $exceptions_real = join($exceptions_arr, ',')
  } else {
    $exceptions_real = undef
  }

  if $existing_file_real {
    $state_real = 'update'
  } else {
    $state_real = 'new'
  }

  proxy_env { 'profile_proxy':
    ensure     => $ensure,
    state      => $state_real,
    fqdn       => $url,
    port       => $port,
    exceptions => $exceptions_real,
    path       => $profile_file_real,
  }
}
