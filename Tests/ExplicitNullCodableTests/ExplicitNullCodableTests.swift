import Testing
import Foundation
@testable import ExplicitNullCodable

struct TestingError: Error {
    var message: String
}

@ExplicitNullCodable
struct MyCodable: Codable {
    var name: String??
    var age: Int??
    var isBlocked: Bool??
    var singlePresent: Bool?
    var singleAbsent: Bool?
    var none: Bool

    init(name: String??, age: Int??, isBlocked: Bool??, singlePresent: Bool?, singleAbsent: Bool?, none: Bool) {
        self.name = name
        self.age = age
        self.isBlocked = isBlocked
        self.singlePresent = singlePresent
        self.singleAbsent = singleAbsent
        self.none = none
    }
}

@Test func codableEncode() throws {
    let myCodable = MyCodable(name: Optional(Optional(nil)), age: nil, isBlocked: false, singlePresent: true, singleAbsent: nil, none: false)
    let encoder = JSONEncoder()
    let data = try encoder.encode(myCodable)
    let string = String(data: data, encoding: .utf8)!
    #expect(string.count == 65)
    #expect(string.contains("\"name\":null"))
    #expect(string.contains("\"isBlocked\":false"))
    #expect(string.contains("\"none\":false"))
    #expect(string.contains("\"singlePresent\":true"))
}

@Test func codableDecode() throws {
    let string = "{\"name\":null,\"isBlocked\":false,\"singlePresent\":true,\"none\":false}"
    let data = string.data(using: .utf8)!
    let decoder = JSONDecoder()
    let myCodable = try decoder.decode(MyCodable.self, from: data)
    if myCodable.age != nil {
        throw TestingError(message: "age is not nil")
    }
    if let name = myCodable.name {
        #expect(name == nil)
    } else {
        throw TestingError(message: "name is not Optional(Optional(nil))")
    }
    #expect(myCodable.isBlocked == false)
    #expect(myCodable.singleAbsent == nil)
    #expect(myCodable.singlePresent == true)
}

@ExplicitNullEncodable
struct MyEncodable: Codable {
    var name: String??
    var age: Int??
    var isBlocked: Bool??
    var singlePresent: Bool?
    var singleAbsent: Bool?
    var none: Bool

    init(name: String??, age: Int??, isBlocked: Bool??, singlePresent: Bool?, singleAbsent: Bool?, none: Bool) {
        self.name = name
        self.age = age
        self.isBlocked = isBlocked
        self.singlePresent = singlePresent
        self.singleAbsent = singleAbsent
        self.none = none
    }
}

@Test func encodableEncode() throws {
    let myCodable = MyEncodable(name: Optional(Optional(nil)), age: nil, isBlocked: false, singlePresent: true, singleAbsent: nil, none: false)
    let encoder = JSONEncoder()
    let data = try encoder.encode(myCodable)
    let string = String(data: data, encoding: .utf8)!
    #expect(string.count == 65)
    #expect(string.contains("\"name\":null"))
    #expect(string.contains("\"isBlocked\":false"))
    #expect(string.contains("\"none\":false"))
    #expect(string.contains("\"singlePresent\":true"))
}

@ExplicitNullDecodable
struct MyDecodable: Codable {
    var name: String??
    var age: Int??
    var isBlocked: Bool??
    var singlePresent: Bool?
    var singleAbsent: Bool?
    var none: Bool

    init(name: String??, age: Int??, isBlocked: Bool??, singlePresent: Bool?, singleAbsent: Bool?, none: Bool) {
        self.name = name
        self.age = age
        self.isBlocked = isBlocked
        self.singlePresent = singlePresent
        self.singleAbsent = singleAbsent
        self.none = none
    }
}

@Test func decodableDecode() throws {
    let string = "{\"name\":null,\"isBlocked\":false,\"singlePresent\":true,\"none\":false}"
    let data = string.data(using: .utf8)!
    let decoder = JSONDecoder()
    let myCodable = try decoder.decode(MyDecodable.self, from: data)
    if myCodable.age != nil {
        throw TestingError(message: "age is not nil")
    }
    if let name = myCodable.name {
        #expect(name == nil)
    } else {
        throw TestingError(message: "name is not Optional(Optional(nil))")
    }
    #expect(myCodable.isBlocked == false)
    #expect(myCodable.singleAbsent == nil)
    #expect(myCodable.singlePresent == true)
}
