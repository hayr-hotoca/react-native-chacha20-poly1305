package com.chacha20poly1305

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.WritableNativeMap
import com.google.crypto.tink.subtle.ChaCha20Poly1305
import org.spongycastle.util.encoders.Base64
import org.spongycastle.util.encoders.Hex

class Output(val nonce: String, val tag: String, val encrypted: String)
class Chacha20Poly1305Module(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  private fun encryptData(plainData: ByteArray, keyData: ByteArray, outputEncoding: String): Output {
    val cipher = ChaCha20Poly1305(keyData)
    val sealed = cipher.encrypt(plainData, null)
    val ivData = sealed.sliceArray(0..11)
    val iv = if (outputEncoding == "base64") Base64.toBase64String(ivData) else Hex.toHexString(ivData)
    val tagData = sealed.sliceArray(sealed.size-16..sealed.size-1)
    val tag = if (outputEncoding == "base64") Base64.toBase64String(tagData) else Hex.toHexString(tagData)
    val encryptedData = sealed.sliceArray(12..sealed.size-17)
    val encrypted = if (outputEncoding == "base64") Base64.toBase64String(encryptedData) else Hex.toHexString(encryptedData)

    return Output(iv, tag, encrypted)
  }

  private fun decryptData(cipherData: ByteArray, key: ByteArray): String {
    val cipher = ChaCha20Poly1305(key)
    val decrypted = cipher.decrypt(cipherData, null)

    return decrypted.toString(Charsets.UTF_8)
  }

  @ReactMethod
  fun encrypt(plainText: String,
              key: String,
              keyEncoding: String,
              outputEncoding: String,
              promise: Promise) {
    try {
      if (keyEncoding != "base64" && keyEncoding != "hex") return promise.reject("Input encoding eror", "Input key encoding should be in 'base64' or 'hex'")
      if (outputEncoding != "base64" && outputEncoding != "hex") return promise.reject("Output encoding eror", "Output encoding should be in 'base64' or 'hex'")

      val keyData = if (keyEncoding == "base64") Base64.decode(key) else  Hex.decode(key)
      val plainData = plainText.toByteArray()
      val encryptedData = encryptData(plainData, keyData, outputEncoding)

      val response = WritableNativeMap()
      response.putString("nonce", encryptedData.nonce)
      response.putString("tag", encryptedData.tag)
      response.putString("encrypted", encryptedData.encrypted)

      promise.resolve(response)
    } catch (e: Exception) {
      promise.reject("EncryptionError", "Failed to encrypt: " + e.localizedMessage, e)
    }
  }

  @ReactMethod
  fun decrypt(encrypted: String,
              key: String,
              nonce: String,
              tag: String,
              inputEncoding: String,
              promise: Promise) {
    try {
      if (inputEncoding != "base64" && inputEncoding != "hex") return promise.reject("Input encoding eror", "Input encoding should be in 'base64' or 'hex'")

      val keyData = if (inputEncoding == "base64") Base64.decode(key) else Hex.decode(key)
      val cipherData = if (inputEncoding == "base64")
        Base64.decode(nonce) + Base64.decode(encrypted) + Base64.decode(tag)
      else
        Hex.decode(nonce + encrypted + tag)
      val decryptedText = decryptData(cipherData, keyData)

      promise.resolve(decryptedText)
    } catch (e: Exception) {
      promise.reject("EncryptionError", "Failed to decrypt: " + e.localizedMessage, e)
    }
  }

  companion object {
    const val NAME = "Chacha20Poly1305"
  }
}
