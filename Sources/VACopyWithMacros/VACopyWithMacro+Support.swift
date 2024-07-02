//
//  VACopyWithMacro+Support.swift
//  
//
//  Created by VAndrJ on 02.07.2024.
//

import SwiftSyntax

public extension VariableDeclSyntax {
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
              let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let type = binding.typeAnnotation?.type else {
            return nil
        }

        return (name, type)
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
