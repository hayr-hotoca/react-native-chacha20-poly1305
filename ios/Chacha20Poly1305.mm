#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Chacha20Poly1305, NSObject)

RCT_EXTERN_METHOD(encrypt:(NSString)plainText
                  withKey:(NSString)key
                  keyEncoding:(NSString)keyEncoding
                  outputEncoding:(NSString)outputEncoding
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(decrypt:(NSString)encrypted
                  withKey:(NSString)key
                  nonce:(NSString)nonce
                  tag:(NSString)tag
                  inputEncoding:(NSString)inputEncoding
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
