# local_users

<!-- vim-markdown-toc GFM -->

* [Description](#description)
* [Setup](#setup)
  * [What local_users affects](#what-local_users-affects)
  * [Setup Requirements](#setup-requirements)
  * [Beginning with local_users](#beginning-with-local_users)
* [Usage](#usage)
  * [Adding SSH Keys](#adding-ssh-keys)
  * [Adding Users](#adding-users)
  * [Adding Groups](#adding-groups)
  * [Removing Users](#removing-users)
  * [Removing Groups](#removing-groups)
* [Reference](#reference)
  * [Adding SSH Keys](#adding-ssh-keys-1)
  * [Adding Users](#adding-users-1)
    * [Password expiry](#password-expiry)
  * [Adding Groups](#adding-groups-1)
  * [Removing Users](#removing-users-1)
  * [Removing Groups](#removing-groups-1)
* [Issues](#issues)

<!-- vim-markdown-toc -->

## Description
Puppet module to easily manage local users and their authorized keys.  It also manages local groups. It's an abstraction layer over the user and group resources to make it easier to add/remove users/groups across different systems using just hiera and calling this class.

Features:
  * maps keys into accounts according to the SSH key comment
  * sets the password aging for non expiring accounts
  * generates a series of accounts (e.g. for testing purposes)

It makes some assumptions to simplify the creation of local users:
  * the GID is the same as the UID unless it is explicitly specified
  * if GID is not specified, the system will choose one
  * the home directory location is the convention for the OS - it will be created if it doesn't exist

It will fail, if:
  * there is no user comment (GECOS) (unless the user is `root`)

It is designed to be driven by hiera, not so much through code.

## Setup

### What local_users affects

  * `/etc/passwd`, `/etc/shadow` and `/etc/group` mostly through the Puppet user and group resources, but does user `groupadd` command in certain circumstance
  * user home directories
  * users' authorized keys

### Setup Requirements
  * Nothing beyond Puppet and stdlib.

### Beginning with local_users

Include the class in your code:
```
  class { 'local_users': }
```

Create a list of SSH keys that will be references later (consumed) when setting up local users:

```
local_users::add::keys:
  -
    comment: 'jblogs@imac.local'
    type: ssh-rsa 
    key: 'AAAAB3NzaC1yc2EAAAABIwAAAQEArqFOapIoElAmJBlKq74MdlXQjPZ2xqOZ7xo2UZ4sRD4fRh+kgkfOP0+wius71pIJ2N2n7cgP1QWMP1i7xsvFJBnb+up9P0y93WTnf+wjKMNx3b9Xt43AffXAADegkWnaImIY+nVrqC1fOiq8xyDjT+kq5ItdE+QHaBNlsuP/FCSGQB8hhxOQyqwKsALdhedhZZ9MsCuVqf62Zti+V3CujyKwRuyeZa3f8zMLjjRFXXldxMVFMJv3/PbJNvMSGe38ikI6Dz/1ESJbNHJFcN+3sM6yzHWS1MROfW6jdxDEtvNgccirDDKUzmeA6wzGnHiDAqf/iJn/x4DUBdijROxE1Q=='
  -
    comment: 'root@prd009'
    type: ssh-rsa
    key: 'AAAAB3NzaC1yc2EAAAAdaqabaaabaqcHyTOwUqmD5evjpDdqyOaR7DISjHa4hu5vwIjg1IecduOZ9Mx00St6emeGwIjMWIapLwaWmTds3DnrON+lFCmMXYPhgIZJpJ4JrxJevMNFXZObS+TdSRwsCo9nuehA9Y1+NPMEPFdtcwdBRSjxDwCbuHzgTYo+hS2Wzwz4B2KjGFvFKx6IlK9qKx7B31n5O4bJMSJLsw+BPe/4xqzDUHjBpcXPPOP+4TWZzhXqZCdXalQZkhxLEC4jHTVycPvpyd3fHr3LOGThpc2ldnh8JAJz71sA01AquErQXa1/pFRl6dGbCZLRuHU8flMj8dA4ZZWCU06cboAkCgxYifTwB8Dd'
  -
    comment: 'bsmith@linux-9g92.site'
    type: ssh-rsa
    key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDFcGZD9nyS34Q4olunx2UgN3XKmZqQT2CeKNiuA2/KJkscty9tWP4cG4syEGY21ws3YL11KLYlI1oH4r2qiBk/AdyKhqpo10sCdCuOVAA+kXK7UQGyAjjwlkCLMYkofjEc5iauz1E6d9UOyrtSMnWZ+B59tq5Kd5zPMXAG1MrzWRO4bB2LwT82HaxXKdoon3VCB7jnXKMYQkj1o890HFp/RA1r4B+EBMDf6Op6iSsQsZGG4607Qvhrf8mfeJbSJiK3FezbO7i2hbIyqfzTNaDgzAexJNpsO/67nlytLs9w2Sx7npdp8faMECPQU0DW31e2UckXgDN43edYpYlNNV/N'
```

Define any groups that will be required for the users.  Also delete some unnecessary groups.

```
local_users::add::groups:
  admin: {}
  git:
    gid: 15002

local_users::remove::groups:
  - thesmiths
  - builders

```

Define some users, consuming both the SSH keys and groups previously specifed.  Also, delete some
redundant users.


```
local_users::add::users:
  jblogs:
    uid: 1000
    comment: Joe Blogs
    expiry: none
    auth_keys: 
      - 'jblogs@imac.local'
  bsmith:
    uid: 1051
    comment: Bill Smith
    expiry: none
    mode: '0700'
    auth_keys: 
      - 'bsmith@linux-9g92.site'
  bsmith0:
    uid: 1052
    comment: Bill Smith 0
    mode: '0700'
    generate: 10
  root:
    expiry: none
    auth_keys: 
      - 'jblogs@imac.local'
      - 'root@prd009'

local_users::remove::users:
  - jsmith
  - bob
```

## Usage

### Adding SSH Keys

Add an array of keys to hiera.  The comment field will be used to match against when being consumed by users.

```
local_users::add::keys:
  -
    comment: 'jblogs@imac.local'
    type: ssh-rsa 
    key: 'AAAAB3NzaC1yc2EAAAABIwAAAQEArqFOapIoElAmJBlKq74MdlXQjPZ2xqOZ7xo2UZ4sRD4fRh+kgkfOP0+wius71pIJ2N2n7cgP1QWMP1i7xsvFJBnb+up9P0y93WTnf+wjKMNx3b9Xt43AffXAADegkWnaImIY+nVrqC1fOiq8xyDjT+kq5ItdE+QHaBNlsuP/FCSGQB8hhxOQyqwKsALdhedhZZ9MsCuVqf62Zti+V3CujyKwRuyeZa3f8zMLjjRFXXldxMVFMJv3/PbJNvMSGe38ikI6Dz/1ESJbNHJFcN+3sM6yzHWS1MROfW6jdxDEtvNgccirDDKUzmeA6wzGnHiDAqf/iJn/x4DUBdijROxE1Q=='
```

### Adding Users

Add users by defining hashes/Data in the hiera data:

```
local_users::add::users:
  jblogs:
    uid: 1000
    comment: Joe Blogs
    expiry: none
    auth_keys: 
      - 'jblogs@imac.local'
```

### Adding Groups

Add groups by defining hashes/Data in the hiera data.  If the group hash is empty, then the system will decide the GID,
otherwise it can be specified.

```
local_users::add::groups:
  admin: {}
  git:
    gid: 15002
```

### Removing Users

Simply provide a list of groups to the hiera key:

```
local_users::remove::users: []
```

### Removing Groups

Simply provide a list of groups to the hiera key:

```
local_users::remove::groups: []
```

## Reference

### Adding SSH Keys

`local_users::add::keys`

Requires an array of hashses.  

Each hash must  have 3 fields:
 * `comment` - the name of the key, used to link entry to authorised_keys entries
 * `type` - the type of key, e.g. ssh-rsa 
 * `key` - the actual public key

### Adding Users

`local_users::add::users`

Requires a hash of user definition hashes.  

Each user definition hash must have a comment field (except root), otherwise system defaults will prevail.  
All Puppet user resource fields are supported, plus these additional ones:
  * `auth_keys` - a list of keys that will be added to the authorized_keys file, these must be defined with `local_users::add::keys` 
  * `mode` - the mode of the home directory
  * `base_dir` - the directory where the user's home directory with be created within
  * `generate` - the number of similar users to create.  I.e. 10 wil create 10 users.  Each user will be numbered sequentially and if the UID is specified, it will also be incremented.

If the GID of the user does not correspond to an existing group, a new one will be created named after the user.

#### Password expiry

Setting an account expiry to `none` will tune the `expiry` and `password_max_age` for each OS nuance to give expected 
behaviour.  This doesn't always work as expected out of the box with Puppet.

### Adding Groups

Groups behave the same as the Puppet group resource.

### Removing Users

All users specified for removal will be forcefully removed - i.e. all running processes belonging to that user will be killed
before the removal is attempted.

### Removing Groups
Groups being removed will simply be removed with the Puppet group resource.

## Issues
Only tested on UNIX/Linux type systems.  I don't always have access to AIX, so sometimes it breaks.

Since version 1.0.1 of this module duplicate GIDs will not be forced through.  This will create an issue if you have previously relied on this behaviour.

This module does not check for the existance of the users groups first - which might mean a duplicate is created rather than failing.

Since version 1.1.0 it requires Puppet 4 and above (hiera functions were replaced with lookup) and internal hiera was converted to version 5
