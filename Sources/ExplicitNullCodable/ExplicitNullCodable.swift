/// A macro that produces Encodable confirmance to a struct with explicit null coding strategy. For example,
///
///     @ExplicitNullEncodable
///     struct MyModel {
///         var name: String??
///     }
///
@attached(member, names: named(CodingKeys), named(encode(to:)))
@attached(extension, conformances: Encodable)
public macro ExplicitNullEncodable() = #externalMacro(module: "ExplicitNullCodableMacros", type: "ExplicitNullEncodableMacro")

/// A macro that produces Decodable confirmance to a struct with explicit null coding strategy. For example,
///
///     @ExplicitNullDecodable
///     struct MyModel {
///         var name: String??
///     }
///
@attached(member, names: named(CodingKeys), named(init(from:)))
@attached(extension, conformances: Encodable)
public macro ExplicitNullDecodable() = #externalMacro(module: "ExplicitNullCodableMacros", type: "ExplicitNullDecodableMacro")

/// A macro that produces Decodable confirmance to a struct with explicit null coding strategy. For example,
///
///     @ExplicitNullCodable
///     struct MyModel {
///         var name: String??
///     }
///
@attached(member, names: named(CodingKeys), named(init(from:)), named(encode(to:)))
@attached(extension, conformances: Encodable)
public macro ExplicitNullCodable() = #externalMacro(module: "ExplicitNullCodableMacros", type: "ExplicitNullCodableMacro")
