//
//  File.swift
//  
//
//  Created by Malte on 04.06.21.
//

import Foundation

public extension Encodable {
  func encoded(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
    try encoder.encode(self)
  }
}

public extension Data {
  func decoded<T: Decodable>(decoder: JSONDecoder = JSONDecoder()) throws -> T {
    try decoder.decode(T.self, from: self)
  }
}

public extension JSONDecoder {
  convenience init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) {
    self.init()
    self.dateDecodingStrategy = dateDecodingStrategy
  }
}