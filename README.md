# ldap_passwd

![Build](https://github.com/liudonghua123/ldap_passwd/workflows/Build/badge.svg)

Simple password utility for ldap userPassword writing using dart, you can find some alternatives in other language world.

- Node: https://github.com/liudonghua123/ldap-passwd
- Python: https://github.com/peppelinux/pySSHA-slapd

## What is it

This is a simple lib and cli tool for generating or verifying the ldap userPassword.

It supports salted:

- md5
- sha1
- sha224
- sha256
- sha384
- sha512

## How to use it

### CLI usage

1. download the prebuild binary from the [release](https://github.com/liudonghua123/ldap_passwd/releases) page.
2. pub global activate ldap_passwd

### LIB usage

First add this dependence in your `pubspec.yaml` file, then import it in your app.

```yaml
dependencies:
  ldap_passwd: ^0.1.0
```

or

```yaml
dependencies:
  ldap_passwd:
    git: git://github.com/liudonghua123/ldap_passwd.git
```

```dart
import 'package:ldap_passwd/ldap_passwd.dart';
// ......
var ldapPasswd = LdapPasswd('<plain_password_here>');
var generated_hashed_password = generatePassword();
var isMatch = LdapPasswd.checkPassword(generated_hashed_password);
```

## License

MIT License

Copyright (c) 2020 liudonghua
