//
//  VACopyWithTests+MutableCopy.swift
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

    func test_mutableCopy_struct_extension() throws {
        assertMacroExpansion(
            """
            @MutableCopy
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

    func test_mutableCopy_struct_failure() throws {
        assertMacroExpansion(
            """
            @MutableCopy
            class SomeStruct {
                let (a, b): (Int, Int)
            }
            """,
            expandedSource: """
            class SomeStruct {
                let (a, b): (Int, Int)
            }
            """,
            diagnostics: [DiagnosticSpec(message: VACopyWithMacroError.notStruct.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_mutableCopy_struct_let() throws {
        assertMacroExpansion(
            """
            @MutableCopy
            struct SomeStruct {
                let a: Int
            }
            """,
            expandedSource: """
            struct SomeStruct {
                let a: Int
            }
            """,
            macros: testMacros
        )
    }

    func test_mutableCopy_struct_var() throws {
        assertMacroExpansion(
            """
            @MutableCopy
            struct SomeStruct {
                var a: Int
            }
            """,
            expandedSource: """
            struct SomeStruct {
                var a: Int
            }

            extension SomeStruct {
                func mutableCopy(configuring: (inout SomeStruct) throws -> Void) rethrows -> SomeStruct {
                    var mutableCopy = self
                    try configuring(&mutableCopy)

                    return mutableCopy
                }
            }
            """,
            macros: testMacros
        )
    }
}
#endif
