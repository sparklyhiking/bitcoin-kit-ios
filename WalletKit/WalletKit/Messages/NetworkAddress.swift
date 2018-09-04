//
//  NetworkAddress.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/11.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

/// When a network address is needed somewhere,
/// this structure is used. Network addresses are not prefixed with a timestamp in the version message.
struct NetworkAddress {
    let services: UInt64
    let address: String
    let port: UInt16

    init(services: UInt64, address: String, port: UInt16) {
        self.services = services
        self.address = address
        self.port = port
    }

    init(_ byteStream: ByteStream) {
        services = byteStream.read(UInt64.self)

        let addrData = byteStream.read(Data.self, count: 16)
        let addr = ipv6(from: addrData)
        if addr.hasPrefix("0000:0000:0000:0000:0000:ffff") {
            address = "0000:0000:0000:0000:0000:ffff:" + ipv4(from: addrData)
        } else {
            address = addr
        }


        port = byteStream.read(UInt16.self)
    }

    func serialized() -> Data {
        var data = Data()
        data += services.littleEndian
        data += pton(address)
        data += port.bigEndian
        return data
    }

}

extension NetworkAddress : CustomStringConvertible {
    var description: String {
        return "[\(address)]:\(port.bigEndian) \(ServiceFlags(rawValue: services))"
    }
}
