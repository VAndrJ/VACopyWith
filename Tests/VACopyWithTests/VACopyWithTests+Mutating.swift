//
//  VACopyWithTests+Mutating.swift
//
//
//  Created by VAndrJ on 03.07.2024.
//

#if canImport(VACopyWithMacros)
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import VACopyWithMacros

extension VACopyWithTests {

    func test_mutating_class_extension() throws {
        assertMacroExpansion(
            """
            @Mutating
            class SomeClass {
            }
            """,
            expandedSource: """
            class SomeClass {
            }
            """,
            macros: testMacros
        )
    }

    func test_mutating_class_failure() throws {
        assertMacroExpansion(
            """
            @Mutating
            struct SomeClass {
                let (a, b): (Int, Int)
            }
            """,
            expandedSource: """
            struct SomeClass {
                let (a, b): (Int, Int)
            }
            """,
            diagnostics: [DiagnosticSpec(message: VACopyWithMacroError.notClassOrProtocol.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_mutating_class_let() throws {
        assertMacroExpansion(
            """
            @Mutating
            class SomeClass {
                let a: Int
            }
            """,
            expandedSource: """
            class SomeClass {
                let a: Int
            }
            """,
            macros: testMacros
        )
    }

    func test_mutating_class_var() throws {
        assertMacroExpansion(
            """
            @Mutating
            class SomeClass {
                var a: Int
            }
            """,
            expandedSource: """
            class SomeClass {
                var a: Int
            }

            extension SomeClass {
                @discardableResult
                func mutating(configuring: (_ it: SomeClass) throws -> Void) rethrows -> SomeClass {
                    try configuring(self)

                    return self
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_mutating_protocol() throws {
        assertMacroExpansion(
            """
            @Mutating
            protocol SomeProtocol: AnyObject {}
            """,
            expandedSource: """
            protocol SomeProtocol: AnyObject {}

            extension SomeProtocol {
                @discardableResult
                func mutating(configuring: (_ it: Self) throws -> Void) rethrows -> Self {
                    try configuring(self)

                    return self
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_mutating_protocol_failure() throws {
        assertMacroExpansion(
            """
            @Mutating
            protocol SomeProtocol {}
            """,
            expandedSource: """
            protocol SomeProtocol {}
            """,
            diagnostics: [DiagnosticSpec(message: VACopyWithMacroError.notAnyObject.description, line: 1, column: 1)],
            macros: testMacros
        )
    }
}
#endif
