# == Class: env
#
# Set /etc/profile
#
class env (
  $profile_file_ensure = 'present',
  $profile_file        = undef,
  $content_sh          = undef,
  $content_csh         = undef,
) {

  validate_re($profile_file_ensure, '^(present|absent)$',
    "env::profile_file_ensure is <${profile_file_ensure}>. Must be present or absent.")

  if $profile_file {
    validate_re($profile_file, '^[a-zA-Z0-9\-_]+$',
      'env::profile_file must be a string and match the regex.')
  }

  if $content_sh {
    validate_string($content_sh)
  }

  if $content_csh {
    validate_string($content_csh)
  }

  if $::osfamily == 'Solaris' {
    file { 'profile_d':
      ensure => directory,
      path   => '/etc/profile.d',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    exec { 'etc_profile':
      command => 'echo "\n#Puppet: Do not removed\nif [ -d /etc/profile.d ]; then\n\tfor i in /etc/profile.d/*.sh; do\n\t\tif [ -r \$i ]; then\n\t\t\t. \$i\n\t\tfi\n\tdone\n\tunset i\nfi\n" >> /etc/profile',
      unless  => 'grep "if \[ \-d \/etc\/profile\.d \]; then" /etc/profile',
      path    => [ '/usr/bin', '/usr/sbin' ],
      require => File['profile_d'],
    }
  }

  if $profile_file {
    if $content_sh {
      file { "profile_d_${profile_file}_sh":
        ensure  => $profile_file_ensure,
        path    => "/etc/profile.d/${profile_file}.sh",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => $content_sh,
      }
    }

    if $content_csh {
      file { "profile_d_${profile_file}_csh":
        ensure  => $profile_file_ensure,
        path    => "/etc/profile.d/${profile_file}.csh",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => $content_csh,
      }
    }
  }
}
