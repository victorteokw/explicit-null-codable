import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

func extension_(type: some TypeSyntaxProtocol, protocol_: String) -> ExtensionDeclSyntax? {
    DeclSyntax(stringLiteral: """
        extension \(type.trimmed): \(protocol_) { }        
    """).as(ExtensionDeclSyntax.self)
}

func requireStruct(declaration: some DeclGroupSyntax, context: some MacroExpansionContext) -> [DeclSyntax] {
    let message = ExplicitNullCodableDiagnosticMessage("ExplicitNullCodable: declaration is not struct")
    let diagnostic = Diagnostic(node: declaration, position: declaration.memberBlock.position, message: message)
    context.diagnose(diagnostic)
    return []
}

enum OptionalLevel {
    case none
    case single(TypeSyntax)
    case double(OptionalTypeSyntax)

    static func match(_ typeSyntax: TypeSyntax) -> Self {
        if let optionalSyntax = typeSyntax.as(OptionalTypeSyntax.self) {
            if let innerOptionalSyntax = optionalSyntax.wrappedType.as(OptionalTypeSyntax.self) {
                .double(innerOptionalSyntax.trimmed)
            } else {
                .single(optionalSyntax.wrappedType.trimmed)
            }
        } else {
            .none
        }
    }
}

func fields(decl: StructDeclSyntax) -> [(TokenSyntax, TypeSyntax)] {
    decl.memberBlock.members.compactMap { member in
        if let variableDecl = member.decl.as(VariableDeclSyntax.self),
           let binding = variableDecl.bindings.first,
           let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self),
           let typeAnnotation = binding.typeAnnotation,
           binding.accessorBlock == nil {
            (identifierPattern.identifier.trimmed, typeAnnotation.type.trimmed)
        } else {
            nil
        }
    }
}

func codingKeys(from fields: [(TokenSyntax, TypeSyntax)]) -> DeclSyntax {
    let cases = fields.map { "case \($0.0)" }.joined(separator: "\n")
    return DeclSyntax(stringLiteral: """
        enum CodingKeys: CodingKey {
            \(cases)
        }
    """)
}

func encodeTo(from fields: [(TokenSyntax, TypeSyntax)]) -> DeclSyntax {
    let encodes = fields.map { (name, type) in
        switch OptionalLevel.match(type) {
        case .none: "try container.encode(self.\(name), forKey: .\(name))"
        case .single: "try container.encodeIfPresent(self.\(name), forKey: .\(name))"
        case .double: """
        if let \(name) {
            try container.encode(\(name), forKey: .\(name))
        }
        """
        }
    }.joined(separator: "\n")
    return DeclSyntax(stringLiteral: """
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            \(encodes)
        }    
    """)
}

func initFrom(from fields: [(TokenSyntax, TypeSyntax)]) -> DeclSyntax {
    let decodes = fields.map { (name, type) in
        switch OptionalLevel.match(type) {
        case .none: "self.\(name) = try container.decode(\(type).self, forKey: .\(name))"
        case .single(let innerType): "self.\(name) = try container.decodeIfPresent(\(innerType).self, forKey: .\(name))"
        case .double(let innerType): """
        if container.contains(.\(name)) {
            self.\(name) = Optional(try container.decode(\(innerType).self, forKey: .\(name)))
        }
        """
        }
    }.joined(separator: "\n")
    return DeclSyntax(stringLiteral: """
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            \(decodes)
        }
    """)
}

struct ExplicitNullCodableDiagnosticMessage: DiagnosticMessage {

    let message: String

    init(_ message: String) {
        self.message = message
    }

    var description: String {
        message
    }

    var diagnosticID: MessageID {
        MessageID(domain: "ExplicitNullCodable", id: "\(self)")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

public struct ExplicitNullEncodableMacro: MemberMacro, ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return requireStruct(declaration: declaration, context: context)
        }
        let fields = fields(decl: structDecl)
        let codingKeys = codingKeys(from: fields)
        let encodeTo = encodeTo(from: fields)
        return [codingKeys, encodeTo]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard !protocols.isEmpty,
              let ext = extension_(type: type, protocol_: "Encodable") else { return [] }
        return [ext]
    }
}

public struct ExplicitNullDecodableMacro: MemberMacro, ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return requireStruct(declaration: declaration, context: context)
        }
        let fields = fields(decl: structDecl)
        let codingKeys = codingKeys(from: fields)
        let initFrom = initFrom(from: fields)
        return [codingKeys, initFrom]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard !protocols.isEmpty,
              let ext = extension_(type: type, protocol_: "Decodable") else { return [] }
        return [ext]
    }
}

public struct ExplicitNullCodableMacro: MemberMacro, ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return requireStruct(declaration: declaration, context: context)
        }
        let fields = fields(decl: structDecl)
        let codingKeys = codingKeys(from: fields)
        let encodeTo = encodeTo(from: fields)
        let initFrom = initFrom(from: fields)
        return [codingKeys, encodeTo, initFrom]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard !protocols.isEmpty,
              let ext0 = extension_(type: type, protocol_: "Encodable"),
              let ext1 = extension_(type: type, protocol_: "Decodable") else { return [] }
        return [ext0, ext1]
    }
}

@main
struct ExplicitNullCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ExplicitNullEncodableMacro.self,
        ExplicitNullDecodableMacro.self,
        ExplicitNullCodableMacro.self,
    ]
}
