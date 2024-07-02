//
//  VACopyWithTests+Properties.swift
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

    func test_struct_propertes_stored_empty() throws {
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

    func test_struct_propertes_computed_only() throws {
        assertMacroExpansion(
            """
            @CopyWith
            struct SomeStruct {
                var someVariable: Int { 1 }
                var someVariable1: Int {
                    get { 1 }
                    set {}
                }
            }
            """,
            expandedSource: """
            struct SomeStruct {
                var someVariable: Int { 1 }
                var someVariable1: Int {
                    get { 1 }
                    set {}
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_struct_propertes_multiple() throws {
        assertMacroExpansion(
            """
            @CopyWith
            struct SomeStruct {
                let (a, b): (Int, Int)
            }
            """,
            expandedSource: """
            struct SomeStruct {
                let (a, b): (Int, Int)
            }
            """,
            diagnostics: [DiagnosticSpec(message: VACopyWithMacroError.multipleBindings.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_struct_propertes_static() throws {
        assertMacroExpansion(
            """
            @CopyWith
            struct SomeStruct {
                static let someVariable = 1
                class let someVariable1 = false
            }
            """,
            expandedSource: """
            struct SomeStruct {
                static let someVariable = 1
                class let someVariable1 = false
            }
            """,
            macros: testMacros
        )
    }

    func test_struct_propertes_stored() throws {
        assertMacroExpansion(
            """
            @CopyWith
                @frozen  public struct SomeStruct {
                let someProperty: Int
                var someProperty1: Bool
            }
            """,
            expandedSource: """
                @frozen  public struct SomeStruct {
                let someProperty: Int
                var someProperty1: Bool
            }

            public extension SomeStruct {
                func copyWith(someProperty: Int? = nil, someProperty1: Bool? = nil) -> SomeStruct {
                    SomeStruct(
                        someProperty: someProperty ?? self.someProperty,
                        someProperty1: someProperty1 ?? self.someProperty1
                    )
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_struct_propertes_stored_optional() throws {
        assertMacroExpansion(
            """
            @CopyWith
            public struct SomeStruct {
                let someProperty: String?
                let someProperty1: Int
                let someProperty2: Bool?
            }
            """,
            expandedSource: """
            public struct SomeStruct {
                let someProperty: String?
                let someProperty1: Int
                let someProperty2: Bool?
            }

            public extension SomeStruct {
                public enum OR<T> {
                    case value(T)
                    case `nil`
                    case ignored
                }
                func copyWith(someProperty: OR<String> = .ignored, someProperty1: Int? = nil, someProperty2: OR<Bool> = .ignored) -> SomeStruct {
                    let someProperty: String? = switch someProperty {
                    case let .value(value):
                        value
                    case .nil:
                        nil
                    case .ignored:
                        self.someProperty
                    }
                    let someProperty2: Bool? = switch someProperty2 {
                    case let .value(value):
                        value
                    case .nil:
                        nil
                    case .ignored:
                        self.someProperty2
                    }
                    return SomeStruct(
                        someProperty: someProperty,
                        someProperty1: someProperty1 ?? self.someProperty1,
                        someProperty2: someProperty2
                    )
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_struct_propertes_stored_computed() throws {
        assertMacroExpansion(
            """
            @CopyWith
            internal struct SomeStruct {
                let someProperty: Int
                private(set) var someProperty1: Bool {
                    willSet { print(newValue) }
                    didSet { print(oldValue, someProperty1) }
                }
                var someProperty2: String { String(someProperty) }
                var someProperty3: Int {
                    get { someProperty1 ? 1 : 0 }
                    set { someProperty1 = newValue == 0 ? false : true }
                }
            }
            """,
            expandedSource: """
            internal struct SomeStruct {
                let someProperty: Int
                private(set) var someProperty1: Bool {
                    willSet { print(newValue) }
                    didSet { print(oldValue, someProperty1) }
                }
                var someProperty2: String { String(someProperty) }
                var someProperty3: Int {
                    get { someProperty1 ? 1 : 0 }
                    set { someProperty1 = newValue == 0 ? false : true }
                }
            }

            internal extension SomeStruct {
                func copyWith(someProperty: Int? = nil, someProperty1: Bool? = nil) -> SomeStruct {
                    SomeStruct(
                        someProperty: someProperty ?? self.someProperty,
                        someProperty1: someProperty1 ?? self.someProperty1
                    )
                }
            }
            """,
            macros: testMacros
        )
    }
}
#endif
