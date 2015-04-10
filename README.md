# Env module
===

[![Build Status](https://api.travis-ci.org/juliengk/puppet-module-env.png?branch=master)](https://travis-ci.org/juliengk/puppet-module-env)

Module to manage path and http_proxy env variables.

## Compatibility ##

This module is built for use with Puppet v3 on the following platforms and supports Ruby versions 1.8.7, 1.9.3, and 2.0.0.

* EL 5
* EL 6
* EL 7
* Suse 10
* Suse 11
* Suse 12
* Debian 7
* Ubuntu 12.04 LTS
* Solaris 9
* Solaris 10
* Solaris 11

===

## Class `env::path` ##

### Components ###

<pre>
PATH="${PATH}:/opt/example/bin"
</pre>

### Parameters ###

ensure
------
Whether to set or unset path settings to pass to path::ensure. Valid values 'present' or 'absent'

- *Default*: 'present'

include_existing_path
---------------------
Boolean to add already path variable to pass to env::path::include_existing_path

- *Default*: true

directories
-----------
Array of directories to pass to env::path::directories

- *Default*: undef

enable_hiera_array
------------------
Boolean to enable the merge of hiera array to pass to env::path::enable_hiera_array

- *Default*: false

existing_file
-------------
Boolean of whether create a new file or update an existing one to pass to env::path::existing_file

- *Default*: 'USE_DEFAULTS'

profile_proxy
-------------
Path to the file to create or update to pass to env::path::profile_proxy

- *Default*: 'USE_DEFAULTS'

# Example usage #

<pre>
env::path::include_existing_path: false
env::path::directories:
  - '/opt/example/bin'
</pre>

## Class `env::proxy` ##

### Components ###

<pre>
http_proxy="http://proxy.example.com:8080"
https_proxy=${http_proxy}
HTTP_PROXY=${http_proxy}
HTTPS_PROXY=${http_proxy}
ftp_proxy=${http_proxy}

no_proxy="localhost,.example.com"

export http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ftp_proxy no_proxy
</pre>

### Parameters ###

ensure
------
Whether to set or unset proxy settings to pass to env::proxy::ensure. Valid values 'present' or 'absent'

- *Default*: 'present'

url
---
String with the proxy url to pass to env::proxy::url

- *Default*: undef

port
----
Port number to pass to env::proxy::port

- *Default*: undef

exceptions
----------
Array of exceptions to pass to env::proxy::exceptions

- *Default*: undef

enable_hiera_array
------------------
Boolean to enable the merge of hiera array to pass to env::proxy::enable_hiera_array

- *Default*: false

existing_file
-------------
Boolean of whether create a new file or update an existing one to pass to env::proxy::existing_file

- *Default*: 'USE_DEFAULTS'

profile_file
------------
Path to the file to create or update to pass to env::proxy::profile_file

- *Default*: 'USE_DEFAULTS'

# Example usage #

<pre>
env::proxy::url: 'proxy.example.com'
env::proxy::port: 8080
env::proxy::exceptions:
  - 'localhost'
  - "%{::ipaddress}"
  - '.example.com'
</pre>
