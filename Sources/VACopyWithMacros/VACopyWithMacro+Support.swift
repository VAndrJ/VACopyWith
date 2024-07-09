//
//  VACopyWithMacro+Support.swift
//  
//
//  Created by VAndrJ on 02.07.2024.
//

import SwiftSyntax

private let staticKeyword: TokenKind = .keyword(.static)
private let classKeyword: TokenKind = .keyword(.class)
private let varKeyword: TokenKind = .keyword(.var)
private let letKeyword: TokenKind = .keyword(.let)
private let willSetKeyword: TokenKind = .keyword(.willSet)
private let didSetKeyword: TokenKind = .keyword(.didSet)

public extension VariableDeclSyntax {
    var isLet: Bool { bindingSpecifier.tokenKind == letKeyword }
    var isVar: Bool { bindingSpecifier.tokenKind == varKeyword }
    var isStatic: Bool { modifiers.contains { $0.name.tokenKind == staticKeyword } }
    var isClass: Bool { modifiers.contains { $0.name.tokenKind == classKeyword } }
    var isInstance: Bool { !(isClass || isStatic) }
    var isStored: Bool {
        get throws {
            guard isInstance else {
                return false
            }
            guard let binding = bindings.first, !binding.pattern.is(TuplePatternSyntax.self) else {
                throw VACopyWithMacroError.tupleBindings
            }
            guard isVar || isLet && binding.initializer == nil else {
                return false
            }

            switch binding.accessorBlock?.accessors {
            case let .accessors(node):
                for accessor in node {
                    switch accessor.accessorSpecifier.tokenKind {
                    case willSetKeyword, didSetKeyword:
                        continue
                    default:
                        return false
                    }
                }

                return true
            case .getter:
                return false
            case .none:
                return true
            }
        }
    }
    var nameWithType: [(name: String, type: TypeSyntax)] {
        var names: [String] = []
        var possibleType: TypeSyntax?

        for binding in bindings {
            if let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                names.append(name)
                if let type = binding.typeAnnotation?.type {
                    possibleType = type
                } else if let initializer = binding.initializer?.value {
                    if let type = initializer.literalOrExprType {
                        possibleType = type
                    } else if let member = initializer.as(ArrayExprSyntax.self)?.elements.first?.expression.literalOrExprType {
                        possibleType = TypeSyntax("[\(raw: member.description)]")
                    } else if let dict = initializer.as(DictionaryExprSyntax.self)?.content.as(DictionaryElementListSyntax.self)?.first, let key = dict.key.literalOrExprType, let value = dict.value.literalOrExprType {
                        possibleType = TypeSyntax("[\(raw: key.description): \(raw: value.description)]")
                    }
                }
            }
        }

        if let possibleType {
            return names.map { ($0, possibleType) }
        } else {
            return []
        }
    }
}

public extension ExprSyntax {
    var literalOrExprType: TypeSyntax? {
        if self.is(StringLiteralExprSyntax.self) {
            return TypeSyntax("String")
        } else if self.is(IntegerLiteralExprSyntax.self) {
            return TypeSyntax("Int")
        } else if self.is(BooleanLiteralExprSyntax.self) {
            return TypeSyntax("Bool")
        } else if self.is(FloatLiteralExprSyntax.self) {
            return TypeSyntax("Double")
        } else if let member = self.as(MemberAccessExprSyntax.self)?.base?.description {
            return TypeSyntax("\(raw: member)")
        } else if let expr = self.as(FunctionCallExprSyntax.self), let member = expr.calledExpression.as(MemberAccessExprSyntax.self)?.base?.description ?? expr.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
            if member == "Optional" {
                if let argumentType = expr.arguments.first?.expression.literalOrExprType {
                    return TypeSyntax("\(raw: argumentType)?")
                }
            } else {
                return TypeSyntax("\(raw: member)")
            }
        }

        return nil
    }
}

public extension TypeSyntax {
    var isOptional: Bool { self.is(OptionalTypeSyntax.self) }
    var nonOptional: TypeSyntax { self.as(OptionalTypeSyntax.self)?.wrappedType.trimmed ?? self.trimmed }
}

public extension DeclGroupSyntax {

    func storedProperties() throws -> [VariableDeclSyntax] {
        try memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self), try variable.isStored else {
                return nil
            }

            return variable
        }
    }
}

public extension DeclModifierListSyntax {
    var accessModifier: DeclModifierListSyntax {
        DeclModifierListSyntax(compactMap { declModifierSyntax in
            switch declModifierSyntax.name.tokenKind {
            case let .keyword(keyword):
                switch keyword {
                case .open: DeclModifierSyntax(name: .keyword(.public))
                case .public, .fileprivate, .internal: declModifierSyntax
                default: nil
                }
            default: nil
            }
        })
    }
}
