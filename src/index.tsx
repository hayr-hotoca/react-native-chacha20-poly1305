import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-chacha20-poly1305' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const Chacha20Poly1305 = NativeModules.Chacha20Poly1305
  ? NativeModules.Chacha20Poly1305
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export type EncryptedOutput = {
  nonce: string;
  tag: string;
  encryptedText: string;
};

type EncryptInput = {
  plainText: string;
  key: string;
  keyEncoding: string;
  outputEncoding: string;
}

type DecryptInput = {
  encrypted: string;
  key: string;
  nonce: string;
  tag: string;
  inputEncoding: string;
}

export function encrypt(encryptInput: EncryptInput): Promise<EncryptedOutput> {
  const { plainText, key, keyEncoding, outputEncoding } = encryptInput;
  return Chacha20Poly1305.encrypt(plainText, key, keyEncoding, outputEncoding);
}

export function decrypt(decryptInput: DecryptInput): Promise<string> {
  const { encrypted, key, nonce, tag, inputEncoding } = decryptInput;
  return Chacha20Poly1305.decrypt(encrypted, key, nonce, tag, inputEncoding);
}
