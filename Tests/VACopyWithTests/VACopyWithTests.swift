import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(VACopyWithMacros)
import VACopyWithMacros

let testMacros: [String: Macro.Type] = [
    "CopyWith": VACopyWithMacro.self,
]
#endif

final class VACopyWithTests: XCTestCase {}