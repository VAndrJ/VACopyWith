//
//  VAMutatingMacro.swift
//  
//
//  Created by VAndrJ on 03.07.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct VAMutatingMacro: ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        if declaration is ClassDeclSyntax {
            let storedProperties = try declaration.storedProperties()
            guard storedProperties.contains(where: { $0.isVar }) else {
                return []
            }

            return [
                ExtensionDeclSyntax(modifiers: declaration.modifiers.accessModifier, extendedType: type) {
                """
                @discardableResult
                func mutating(configuring: (_ it: \(type)) throws -> Void) rethrows -> \(type) {
                    try configuring(self)

                    return self
                }
                """
                },
            ]
        } else if declaration is ProtocolDeclSyntax {
            if declaration.inheritanceClause?.inheritedTypes.contains(where: { $0.type.description.contains("AnyObject") }) == true {
                return [
                    ExtensionDeclSyntax(modifiers: declaration.modifiers.accessModifier, extendedType: type) {
                    """
                    @discardableResult
                    func mutating(configuring: (_ it: Self) throws -> Void) rethrows -> Self {
                        try configuring(self)

                        return self
                    }
                    """
                    },
                ]
            } else {
                throw VACopyWithMacroError.notAnyObject
            }
        }

        throw VACopyWithMacroError.notClassOrProtocol
    }
}
