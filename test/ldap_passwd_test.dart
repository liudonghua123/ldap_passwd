import 'package:ldap_passwd/ldap_passwd.dart';
import 'package:test/test.dart';

void main() {
  var encoders = [
    'md5',
    'sha1',
    'sha256',
    'sha224',
    'sha256',
    'sha384',
    'sha512'
  ];
  for (var encoder in encoders) {
    test('check ${encoder} encoder', () {
      var ldapPasswd = LdapPasswd('123456', encoder: encoder);
      var generatedPassword = ldapPasswd.generatePassword();
      print('checking generatedPassword: ${generatedPassword}');
      expect(ldapPasswd.checkPassword(generatedPassword), true);
    });
  }
}
