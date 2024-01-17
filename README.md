# react-native-chacha20-poly1305



ChaCha20-Poly1305 encryption/decryption for React Native.\
Encrypt binary and text-like data with ease.\
Native implementations make sure it has the fastest performance.

# Requirements
iOS >= 13.0\
Android >= 26

## Installation

```sh
npm i --save react-native-chacha20-poly1305
```

## Usage

```js
import { decrypt, encrypt } from 'react-native-chacha20-poly1305';
import { generateSymmetricKey } from 'react-native-key-generator';

(async () => {
    const key = await generateSymmetricKey({ size: 256, outputEncoding: "base64" });
    // new unique key will be generated every time generateSymmetricKey is run
    // xyD2rJTETEBCBA538mAvCVG0AdF1lOm0kR7z1eRLdwQ=
    // hex encoding of key is c720f6ac94c44c4042040e77f2602f0951b401d17594e9b4911ef3d5e44b7704

    const encrypted = await encrypt({
        plainText: JSON.stringify({ x: 1, y: 2 }),
        key: "c720f6ac94c44c4042040e77f2602f0951b401d17594e9b4911ef3d5e44b7704",
        keyEncoding: "hex",
        outputEncoding: "base64"
    });
    console.log(encrypted);
    // Data in this object will be unique every time encrypt function is run
    // {
    //     "encrypted": "997U4wbic8FbEFeeEA==",
    //     "nonce": "ZGfMRlCFSGZMpUj2",
    //     "tag": "6MHP+gQh2hCFF6MFRCNeRQ=="
    // }

    // nonce: (or "initialization vector", "IV", "salt") is a unique non-secret sequence of data required by most cipher (encryption) algorithms, making the ciphertext (encrypted data) unique despite the same key

    // tag: authentication tag or MAC (message authentication code), the algorithm uses it to verify whether or not the ciphertext (encrypted data) and/or associated data have been modified.

    const decrypted = await decrypt({
        encrypted: "997U4wbic8FbEFeeEA==",
        key: "xyD2rJTETEBCBA538mAvCVG0AdF1lOm0kR7z1eRLdwQ=",
        nonce: "ZGfMRlCFSGZMpUj2",
        tag: "6MHP+gQh2hCFF6MFRCNeRQ==",
        inputEncoding: "base64",
    });
    console.log(decrypted); // '{"x":1,"y":2}'
})();
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## Author

Hayr Hotoca | [@1limxapp](https://twitter.com/1limxapp)\
This package is used in my cross-platform app called [1LimX](https://1limx.com/)
## License

MIT
