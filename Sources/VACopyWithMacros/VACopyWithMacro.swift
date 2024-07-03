import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct VACopyWithMacro: ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let decl = declaration.as(StructDeclSyntax.self) else {
            throw VACopyWithMacroError.notStruct
        }
        
        let storedProperties = try decl.storedProperties()
        let properties = storedProperties.compactMap(\.nameWithType)
        guard !properties.isEmpty else {
            return []
        }

        let isContainsOptional = properties.contains { $0.type.isOptional }
        
        return [
            ExtensionDeclSyntax(modifiers: decl.modifiers.accessModifier, extendedType: type) {
                if isContainsOptional {
                    EnumDeclSyntax(
                        modifiers: decl.modifiers.accessModifier, 
                        name: "OR",
                        genericParameterClause: GenericParameterClauseSyntax(parameters: GenericParameterListSyntax(arrayLiteral: GenericParameterSyntax(name: "T"))),
                        memberBlock: MemberBlockSyntax(members: MemberBlockItemListSyntax(itemsBuilder: {
                            """
                            case value(T)
                            case `nil`
                            case ignored
                            """
                        }))
                    )
                }
                FunctionDeclSyntax(
                    name: "copyWith",
                    signature: FunctionSignatureSyntax(
                        parameterClause: FunctionParameterClauseSyntax(
                            rightParen: .rightParenToken(leadingTrivia: .newline),
                            parametersBuilder: {
                                for property in properties {
                                    FunctionParameterSyntax(
                                        leadingTrivia: .newline,
                                        firstName: TokenSyntax("\(raw: property.name)"),
                                        type: (property.type.isOptional ? TypeSyntax("OR<\(property.type.nonOptional)>") : TypeSyntax(OptionalTypeSyntax(wrappedType: property.type.trimmed))),
                                        defaultValue: InitializerClauseSyntax(value: property.type.isOptional ? ExprSyntax(".ignored") : ExprSyntax("nil"))
                                    )
                                }
                            }
                        ),
                        returnClause: ReturnClauseSyntax(type: type)
                    ),
                    body: CodeBlockSyntax {
                        for property in properties where property.type.isOptional {
                                """
                                let \(raw: property.name): \(property.type.trimmed) = switch \(raw: property.name) {
                                case let .value(value):
                                    value
                                case .nil:
                                    nil
                                case .ignored:
                                    self.\(raw: property.name)
                                }
                                """
                        }
                        """
                        \(raw: isContainsOptional ? "return " : "")\(FunctionCallExprSyntax(
                            calledExpression: DeclReferenceExprSyntax(baseName: .identifier(type.description)),
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax {
                                for (i, property) in properties.enumerated() {
                                    LabeledExprSyntax(
                                        leadingTrivia: .newline,
                                        label: .identifier(property.name),
                                        colon: .colonToken(),
                                        expression: property.type.isOptional ? ExprSyntax("\(raw: property.name)") : ExprSyntax("\(raw: property.name) ?? self.\(raw: property.name)"),
                                        trailingComma: i == properties.indices.last ? nil : .commaToken()
                                    )
                                }
                            },
                            rightParen: .rightParenToken(leadingTrivia: .newline)
                        ))
                        """
                    }
                )
            },
        ]
    }
}
@main
struct VACopyWithPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        VACopyWithMacro.self,
        VAMutatedCopyMacro.self,
        VAMutatingMacro.self,
    ]
}
