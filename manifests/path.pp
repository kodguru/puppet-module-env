# ## Class: env::path ##
#
# Set custom path env variables
#
class env::path (
  $ensure                = 'present',
  $include_existing_path = true,
  $directories           = undef,
  $enable_hiera_array    = false,
  $existing_file         = 'USE_DEFAULTS',
  $profile_file          = 'USE_DEFAULTS',
) {

  validate_re($ensure, '^(present|absent)$',
    "env::path::ensure is <${ensure}>. Must be present or absent.")

  $include_existing_path_type = type($include_existing_path)

  case $include_existing_path_type {
    'string': {
      $include_existing_path_real = str2bool($include_existing_path)
    }
    'boolean': {
      $include_existing_path_real = $include_existing_path
    }
    default: {
      fail("env::path::include_existing_path must be of type boolean or string. Detected type is <${include_existing_path_type}>.")
    }
  }

  $enable_hiera_array_type = type($enable_hiera_array)

  case $enable_hiera_array_type {
    'string': {
      $enable_hiera_array_real = str2bool($enable_hiera_array)
    }
    'boolean': {
      $enable_hiera_array_real = $enable_hiera_array
    }
    default: {
      fail("env::path::enable_hiera_array must be of type boolean or string. Detected type is <${enable_hiera_array_type}>.")
    }
  }

  case $::osfamily {
    'RedHat': {
      case $::lsbmajdistrelease {
        '5': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/path.sh'
        }
        '6': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/path.sh'
        }
        '7': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/path.sh'
        }
        default: {
          fail("Path is only supported on EL 5, 6 and 7. Your lsbmajdistrelease is identified as <${::lsbmajdistrelease}>.")
        }
      }
    }
    'Suse': {
      case $::lsbmajdistrelease {
        '10': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/path.sh'
        }
        '11': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/path.sh'
        }
        '12': {
          $existing_file_default = false
          $profile_file_default  = '/etc/profile.d/path.sh'
        }
        default: {
          fail("Path is only supported on Suse 10, 11 and 12. Your lsbmajdistrelease is identified as <${::lsbmajdistrelease}>.")
        }
      }
    }
    'Debian': {
      case $::lsbdistid {
        'Debian': {
          case $::lsbmajdistrelease {
            '7': {
              $existing_file_default = false
              $profile_file_default  = '/etc/profile.d/path.sh'
            }
            default: {
              fail("Path is only supported on lsbdistid Ubuntu of the Debian osfamily. Your lsbdistid is <${::lsbdistid}>.")
            }
          }
        }
        'Ubuntu': {
          case $::lsbdistrelease {
            '12.04': {
              $existing_file_default = false
              $profile_file_default  = '/etc/profile.d/path.sh'
            }
            default: {
              fail("Path is only supported on Ubuntu 12.04. Your lsbdistrelease is identified as <${::lsbdistrelease}>.")
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
          fail("Path is only supported on Solaris 9, 10 and 11. Your kernelrelease is identified as <${::kernelrelease}>.")
        }
      }
    }
    default: {
      fail("Path supports OS families Debian, RedHat, Suse and Solaris. Detected osfamily is <${::osfamily}>.")
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

  if $directories {
    if $enable_hiera_array_real {
      $directories_arr = hiera_array('env::path::directories')
    } else {
      $directories_arr = $directories
    }

    $directories_real = join($directories_arr, ':')
  } else {
    $directories_real = undef
  }

  if $existing_file_real {
    $state_real = 'update'
  } else {
    $state_real = 'new'
  }

  path_env { 'profile_path':
    ensure                => $ensure,
    state                 => $state_real,
    include_existing_path => $include_existing_path_real,
    directories           => $directories_real,
    path                  => $profile_file_real,
  }
}
