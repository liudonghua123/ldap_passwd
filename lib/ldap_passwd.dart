import 'dart:convert';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

String _randomValueHex(int length) {
  var random = Random.secure();
  return hex
      .encode(List<int>.generate(length ~/ 2, (i) => random.nextInt(256)));
}

class LdapPasswd {
  String password;
  int saltSize;
  bool suffixed;
  String encoder;
  String salt;
  LdapPasswd(this.password,
      {this.saltSize = 16,
      this.suffixed = true,
      this.encoder = 'SHA1',
      this.salt});

  bool checkPassword(String hashedPassowrd) {
    var hashedPassowrdSplitted = hashedPassowrd.split('}');
    // get and set the encoder of the hashed password
    encoder = hashedPassowrdSplitted[0].substring(1);
    var cleanedHashedPassowrd = hashedPassowrdSplitted[1];
    Map result = _sshaSplit(cleanedHashedPassowrd);
    // get and set the salt of the hashed password
    salt ??= result['salt'];
    var generatedHashedPassword = generatePassword();
    return generatedHashedPassword == hashedPassowrd;
  }

  String generatePassword() {
    Map result = _sshaEncoder();
    var digest = result['digest'];
    var salt = result['salt'];
    var digestBuffer;
    if (saltSize != 0) {
      if (suffixed) {
        digestBuffer = hex.decode(digest) + hex.decode(salt);
      } else {
        digestBuffer = hex.decode(salt) + hex.decode(digest);
      }
    } else {
      digestBuffer = hex.decode(digest);
    }
    var hashType = '{${encoder.toUpperCase()}}';
    return '${hashType}${base64.encode(digestBuffer)}';
  }

  Hash _getEncoder(String encoderName) {
    var fixedEncoderName =
        encoderName.startsWith('SS') ? encoderName.substring(1) : encoderName;
    if (fixedEncoderName == 'SHA') {
      fixedEncoderName = 'SHA1';
    }
    fixedEncoderName = fixedEncoderName.toLowerCase();
    dynamic encoder;
    switch (fixedEncoderName) {
      case 'md5':
        encoder = md5;
        break;
      case 'sha1':
        encoder = sha1;
        break;
      case 'sha224':
        encoder = sha224;
        break;
      case 'sha256':
        encoder = sha256;
        break;
      case 'sha384':
        encoder = sha384;
        break;
      case 'sha512':
        encoder = sha512;
        break;
      default:
        encoder = sha1;
    }
    return encoder;
  }

  Map<String, String> _sshaSplit(String hashedPassowrd) {
    var payload, salt, hashType;
    var hexedPassword = hex.encode(base64.decode(hashedPassowrd));
    if (saltSize != 0) {
      if (suffixed) {
        payload = hexedPassword.substring(0, hexedPassword.length - saltSize);
        salt = hexedPassword.substring(hexedPassword.length - saltSize);
      } else {
        salt = hexedPassword.substring(0, saltSize);
        payload = hexedPassword.substring(hexedPassword.length - saltSize);
      }
      hashType = '{${encoder.toUpperCase()}}';
    } else {
      salt = '';
      payload = hexedPassword;
    }
    return {
      'salt': salt,
      'payload': payload,
      'hashType': hashType,
      'hashedPassowrd': hashedPassowrd,
    };
  }

  Map<String, String> _sshaEncoder() {
    salt ??= _randomValueHex(saltSize);
    var hash = _getEncoder(encoder);
    String digest;
    if (suffixed) {
      digest = hex
          .encode(hash.convert(utf8.encode(password) + hex.decode(salt)).bytes);
    } else {
      digest = hex
          .encode(hash.convert(hex.decode(salt) + utf8.encode(password)).bytes);
    }
    return {'salt': salt, 'digest': digest, 'password': password};
  }
}
