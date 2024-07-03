//
//  VACopyWithTests+MutatedCopy.swift
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

    func test_mutated_struct_extension() throws {
        assertMacroExpansion(
            """
            @MutatedCopy
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

    func test_mutated_struct_failure() throws {
        assertMacroExpansion(
            """
            @MutatedCopy
            class SomeStruct {
                let (a, b): (Int, Int)
            }
            """,
            expandedSource: """
            class SomeStruct {
                let (a, b): (Int, Int)
            }
            """,
            diagnostics: [DiagnosticSpec(message: VACopyWithMacroError.notStructOrProtocol.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_mutated_struct_let() throws {
        assertMacroExpansion(
            """
            @MutatedCopy
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

    func test_mutated_struct_var() throws {
        assertMacroExpansion(
            """
            @MutatedCopy
            struct SomeStruct {
                var a: Int
            }
            """,
            expandedSource: """
            struct SomeStruct {
                var a: Int
            }

            extension SomeStruct {
                func mutatedCopy(configuring: (_ it: inout SomeStruct) throws -> Void) rethrows -> SomeStruct {
                    var mutableCopy = self
                    try configuring(&mutableCopy)

                    return mutableCopy
                }
            }
            """,
            macros: testMacros
        )
    }    

    func test_mutated_protocol_var() throws {
        assertMacroExpansion(
            """
            @MutatedCopy
            protocol SomeProtocol {}
            """,
            expandedSource: """
            protocol SomeProtocol {}

            extension SomeProtocol {
                func mutatedCopy(configuring: (_ it: inout Self) throws -> Void) rethrows -> Self {
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
