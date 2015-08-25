# Env module

[![Build Status](https://api.travis-ci.org/juliengk/puppet-module-env.png?branch=master)](https://travis-ci.org/juliengk/puppet-module-env)

Module to manage path and http_proxy env variables.

## Compatibility ##

This module is built for use with Puppet v3 on the platforms bellow and supports Ruby versions 1.8.7, 1.9.3, and 2.0.0.

* RedHat
* Suse
* Debian
* Solaris

===

## Class `env` ##

ensure
------
Whether to set or unset path settings to pass to ensure. Valid values 'present' or 'absent'

- *Default*: 'present'

profile_file
------------

- *Default*: 'undef'

content_sh
----------

- *Default*: 'undef'

content_csh
-----------

- *Default*: 'undef'

===

## Class `env::path` ##

### Components ###

```
PATH="${PATH}:/opt/example/bin"
```

### Parameters ###

ensure
------
Whether to set or unset path settings to pass to env::path::ensure. Valid values 'present' or 'absent'

- *Default*: 'present'

profile_file
------------
Name of the file to create or update to pass to env::path::profile_file

- *Default*: 'path'

enable_sh
---------
Boolean to enable sh support

- *Default*: 'USE_DEFAULTS'

enable_csh
----------
Boolean to enable csh support

- *Default*: 'USE_DEFAULTS'

enable_hiera_array
------------------
Boolean to enable the merge of hiera array to pass to env::path::enable_hiera_array

- *Default*: false

include_existing_path
---------------------
Boolean to add already existing path variable to pass to env::path::include_existing_path

- *Default*: true

directories
-----------
Array of directories to pass to env::path::directories

- *Default*: 'MANDATORY'

# Example usage #

```
env::path::include_existing_path: false
env::path::directories:
  - '/opt/example/bin'
```

## Class `env::proxy` ##

### Components ###

```
http_proxy="http://proxy.example.com:8080"
https_proxy=${http_proxy}
HTTP_PROXY=${http_proxy}
HTTPS_PROXY=${http_proxy}
ftp_proxy=${http_proxy}

no_proxy="localhost,.example.com"

export http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ftp_proxy no_proxy
```

### Parameters ###

ensure
------
Whether to set or unset proxy settings to pass to env::proxy::ensure. Valid values 'present' or 'absent'

- *Default*: 'present'

profile_file
------------
Name of the file to create or update to pass to env::proxy::profile_file

- *Default*: 'proxy'

enable_sh
---------
Boolean to enable sh support

- *Default*: 'USE_DEFAULTS'

enable_csh
----------
Boolean to enable csh support

- *Default*: 'USE_DEFAULTS'

enable_hiera_array
------------------
Boolean to enable the merge of hiera array to pass to env::proxy::enable_hiera_array

- *Default*: false

url
---
String with the proxy url to pass to env::proxy::url

- *Default*: 'MANDATORY'

port
----
Port number to pass to env::proxy::port

- *Default*: '8080'

exceptions
----------
Array of exceptions to pass to env::proxy::exceptions

- *Default*: 'undef'

# Example usage #

```
env::proxy::url: 'proxy.example.com'
env::proxy::port: 8080
env::proxy::exceptions:
  - 'localhost'
  - "%{::ipaddress}"
  - '.example.com'
```
