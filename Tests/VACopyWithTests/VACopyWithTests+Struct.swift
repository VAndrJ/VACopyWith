//
//  VACopyWithTests+Struct.swift
//  
//
//  Created by VAndrJ on 02.07.2024.
//

#if canImport(VACopyWithMacros)
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import VACopyWithMacros

extension VACopyWithTests {
    
    func test_struct_extension() throws {
        assertMacroExpansion(
            """
            @CopyWith
            struct SomeStruct {
            }
            """,
            expandedSource: """
            struct SomeStruct {
            }
            """,
            macros: testMacros
        )
    }

    func test_struct_extension_modifier() throws {
        assertMacroExpansion(
            """
            @CopyWith
            public struct SomeStruct {
            }
            @CopyWith
            open struct SomeStruct1 {
            }
            @CopyWith
            fileprivate struct SomeStruct2 {
            }
            @CopyWith
            internal struct SomeStruct3 {
            }
            """,
            expandedSource: """
            public struct SomeStruct {
            }
            open struct SomeStruct1 {
            }
            fileprivate struct SomeStruct2 {
            }
            internal struct SomeStruct3 {
            }
            """,
            macros: testMacros
        )
    }

    func test_struct_extension_failure_class_notStruct() throws {
        assertMacroExpansion(
            """
            @CopyWith
            class SomeStruct {
            }
            """,
            expandedSource: """
            class SomeStruct {
            }
            """,
            diagnostics: [DiagnosticSpec(message: VACopyWithMacroError.notStruct.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_struct_extension_failure_enum_notStruct() throws {
        assertMacroExpansion(
            """
            @CopyWith
            enum SomeStruct {
            }
            """,
            expandedSource: """
            enum SomeStruct {
            }
            """,
            diagnostics: [DiagnosticSpec(message: VACopyWithMacroError.notStruct.description, line: 1, column: 1)],
            macros: testMacros
        )
    }
}
#endif
