import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { decrypt, encrypt } from 'react-native-chacha20-poly1305';

export default function App() {
  const [result, setResult] = React.useState<number | undefined>();

  React.useEffect(() => {
    encrypt({
      plainText: JSON.stringify({ x: 1, y: 2 }),
      key: "c720f6ac94c44c4042040e77f2602f0951b401d17594e9b4911ef3d5e44b7704",
      keyEncoding: "hex",
      outputEncoding: "base64"
    }).then(res => console.log(res))
      .catch(e => console.log(e));

    decrypt({
      encrypted: "oWq1CfIY8GGcGQ8ODlgk7svc3sE=",
      key: "LAnIp48R+r525MH9kme671+2Z2sta+yRGGmA783KBl8=",
      nonce: "kCZNwhqK1AZO+Hm1",
      tag: "Lhnw8wlIqzD7z94NIKJx3Q==",
      inputEncoding: "base64",
    }).then(res => console.log(res))
      .catch(e => console.log(e));
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
