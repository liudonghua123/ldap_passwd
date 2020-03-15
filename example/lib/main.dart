import 'dart:io';

import 'package:ldap_passwd/ldap_passwd.dart';
import 'package:args/args.dart';
import 'package:ansicolor/ansicolor.dart';

AnsiPen success = AnsiPen()..green();
AnsiPen info = AnsiPen()..blue();
AnsiPen warning = AnsiPen()..yellow();
AnsiPen error = AnsiPen()..red();

String commandUsage() {
  return '''
Usage: ldap_passwd <command> [options]

Commands:
  ldap-passwd.js check     Check the password and the hashed password is match
  ldap-passwd.js generate  Generate the hashed password from the plain password

  ''';
}

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addOption('password', abbr: 'p', help: 'plain password for checking');
  parser.addOption('hash', abbr: 'h', help: 'Hashed password for checking...');
  parser.addOption('encoder',
      abbr: 'e',
      help: 'The encoder for hash, like md5, sha1, sha256, ...',
      defaultsTo: 'sha1');
  parser.addFlag('suffixed',
      negatable: false,
      help: 'Wether the salt prefixed or suffixed',
      defaultsTo: true);
  parser.addOption('salt',
      abbr: 's',
      help: 'Salt, 8 bytes string or 12-length base64',
      defaultsTo: null);
  parser.addOption('salt_size',
      help: 'salt length in hex format, equals to 8 bytes or 12-length base64',
      defaultsTo: '16');
  parser.addFlag('help', negatable: false);

  var argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print(error(e.toString()));
    print(info(commandUsage()));
    print(info(parser.usage));
    exit(-1);
  }

  if (argResults['help']) {
    print(info(commandUsage()));
    print(info(parser.usage));
    exit(0);
  }

  if (argResults.rest.isEmpty) {
    print(warning('command should be specified as check or generate'));
    print(info(commandUsage()));
    print(info(parser.usage));
    exit(-1);
  }
  var command = argResults.rest[0];
  if (argResults.rest.length != 1 ||
      (command != 'check' && command != 'generate')) {
    print(warning('command need to be check or generate'));
    print(info(commandUsage()));
    print(info(parser.usage));
    exit(-1);
  }
  var ldapPasswd = LdapPasswd(argResults['password'],
      salt: argResults['salt'],
      saltSize: int.parse(argResults['salt_size']),
      encoder: argResults['encoder'],
      suffixed: argResults['suffixed']);
  switch (command) {
    case 'check':
      var result = ldapPasswd.checkPassword(argResults['hash']);
      if (result) {
        print(success('check result: ${result}'));
      } else {
        print(warning('check result: ${result}'));
      }
      break;
    case 'generate':
      var result = ldapPasswd.generatePassword();
      print(success('generate result: ${result}'));
      break;
  }
}
