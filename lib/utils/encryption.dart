
import 'configuration.dart';
//Encryption Class
class Cryptography
{

  static String encrypt(String data, String encryptionKey, {bool addFingerprint = true}) {

    String fullData = data;

    //add finger print to identify that the QR is generated by our app later
    if(addFingerprint) {
      fullData = Configuration.fingerprint + fullData;
    }

    var charCount = fullData.length;
    var encrypted = [];
    var kp = 0;
    var kl = encryptionKey.length - 1;

    for (var i = 0; i < charCount; i++) {
      var other = fullData[i].codeUnits[0] ^ encryptionKey[kp].codeUnits[0];
      encrypted.insert(i, other);
      kp = (kp < kl) ? (++kp) : (0);
    }
    String stringData = dataToString(encrypted);

    if(addFingerprint) {
      stringData = Configuration.fingerprint + stringData;
    }

    return stringData;
  }

  static String decrypt(data, String encryptionKey) {
    return encrypt(data, encryptionKey, addFingerprint: false);
  }

  static String dataToString(data) {
    var s = "";
    for (var i = 0; i < data.length; i++) {
      s += String.fromCharCode(data[i]);
    }
    return s;
  }
}