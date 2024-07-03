//
//  VAMutatedCopyMacro.swift
//  
//
//  Created by VAndrJ on 03.07.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct VAMutatedCopyMacro: ExtensionMacro {

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
        guard storedProperties.contains(where: { $0.isVar }) else {
            return []
        }

        return [
            ExtensionDeclSyntax(modifiers: decl.modifiers.accessModifier, extendedType: type) {
                """
                func mutatedCopy(configuring: (_ it: inout \(type)) throws -> Void) rethrows -> \(type) {
                    var mutableCopy = self
                    try configuring(&mutableCopy)

                    return mutableCopy
                }
                """
            },
        ]
    }
}
