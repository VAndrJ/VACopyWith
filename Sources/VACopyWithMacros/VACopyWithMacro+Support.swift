//
//  VACopyWithMacro+Support.swift
//  
//
//  Created by VAndrJ on 02.07.2024.
//

import SwiftSyntax

public extension VariableDeclSyntax {
    var isLet: Bool { bindingSpecifier.tokenKind == .keyword(.let) }
    var isVar: Bool { bindingSpecifier.tokenKind == .keyword(.var) }
    var isStatic: Bool { modifiers.contains { $0.name.tokenKind == .keyword(.static) } }
    var isClass: Bool { modifiers.contains { $0.name.tokenKind == .keyword(.class) } }
    var isInstance: Bool { !isClass && !isStatic }
    var isStored: Bool {
        get throws {
            guard isInstance else {
                return false
            }
            guard bindings.count == 1, let binding = bindings.first, binding.pattern.as(TuplePatternSyntax.self) == nil else {
                throw VACopyWithMacroError.multipleBindings
            }
            guard isLet && binding.initializer == nil || isVar else {
                return false
            }

            switch binding.accessorBlock?.accessors {
            case let .accessors(node):
                for accessor in node {
                    switch accessor.accessorSpecifier.tokenKind {
                    case .keyword(.willSet), .keyword(.didSet):
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
    var nameWithType: (name: String, type: TypeSyntax)? {
        guard let binding = bindings.first, bindings.count == 1,
              let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            return nil
        }
        
        if let type = binding.typeAnnotation?.type {
            return (name, type)
        } else if let initializer = binding.initializer?.value {
            if let type = initializer.literalOrExprType {
                return (name, type)
            } else if let member = initializer.as(ArrayExprSyntax.self)?.elements.first?.expression.literalOrExprType {
                return (name, TypeSyntax("[\(raw: member.description)]"))
            } else if let dict = initializer.as(DictionaryExprSyntax.self)?.content.as(DictionaryElementListSyntax.self)?.first, let key = dict.key.literalOrExprType, let value = dict.value.literalOrExprType {
                return (name, TypeSyntax("[\(raw: key.description): \(raw: value.description)]"))
            }
        }

        return nil
    }
}

public extension ExprSyntax {
    var literalOrExprType: TypeSyntax? {
        if self.as(StringLiteralExprSyntax.self) != nil {
            return TypeSyntax("String")
        } else if self.as(IntegerLiteralExprSyntax.self) != nil {
            return TypeSyntax("Int")
        } else if self.as(BooleanLiteralExprSyntax.self) != nil {
            return TypeSyntax("Bool")
        } else if self.as(FloatLiteralExprSyntax.self) != nil {
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
    var isOptional: Bool { self.as(OptionalTypeSyntax.self) != nil }
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
                case .public, .open: DeclModifierSyntax(name: .keyword(.public))
                case .fileprivate, .internal: declModifierSyntax
                default: nil
                }
            default: nil
            }
        })
    }
}
