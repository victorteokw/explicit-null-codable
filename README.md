# Explicit Null Codable

Codable which handles null explicitly in Swift.

## Strategy

1. For single optional, always do not produce `null` in the generated json data.
2. For double optional, `nil` produces absent, `Optional(Optional(nil))` produces `null`.
3. For double optional, `null` is decoded as `Optional(Optional(nil))`, while absent value is decoded as `nil`.

This strategy is quite similar to some programming language like Rust, which makes null values explicit.

## Usage

Use like this. Available decorators are `@ExplicitNullCodable`, `@ExplicitNullEncodable` and `@ExplicitNullDecodable`.
Choose the one which is sufficient for your struct.

```swift
@ExplicitNullCodable
struct MyCodable {
    var name: String??
}
```

## Installation

Install with Swift Package Manager.

```
https://github.com/victorteokw/explicit-null-codable.git
```

## License

MIT License
