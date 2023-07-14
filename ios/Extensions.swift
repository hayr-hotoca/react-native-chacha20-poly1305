//
//  Extensions.swift
//  react-native-chacha20-poly1305
//
//  Created by hayr-hotoca on 16/07/2023.
//

import Foundation

public extension Data {
    private static let regex = try! NSRegularExpression(pattern: "([0-9a-fA-F]{2})", options: [])
    init?(hexString: String) {
        guard hexString.count.isMultiple(of: 2) else {
            return nil
        }
        
        let chars = hexString.map { $0 }
        let bytes = stride(from: 0, to: chars.count, by: 2)
            .map { String(chars[$0]) + String(chars[$0 + 1]) }
            .compactMap { UInt8($0, radix: 16) }
        
        guard hexString.count / bytes.count == 2 else { return nil }
        self.init(bytes)
    }

    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        let charA: UInt8 = 0x61
        let char0: UInt8 = 0x30
        func byteToChar(_ b: UInt8) -> Character {
            Character(UnicodeScalar(b > 9 ? charA + b - 10 : char0 + b))
        }
        let hexChars = flatMap {[
            byteToChar(($0 >> 4) & 0xF),
            byteToChar($0 & 0xF)
        ]}
        return String(hexChars)
    }
}

public extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

