//
//  VACopyWithMacroError.swift
//  
//
//  Created by VAndrJ on 02.07.2024.
//

public enum VACopyWithMacroError: Error, CustomStringConvertible {
    case notStruct
    case tupleBindings
    case notClassOrProtocol
    case notStructOrProtocol
    case notAnyObject

    public var description: String {
        switch self {
        case .notStruct: "Must be `struct` declaration"
        case .notStructOrProtocol: "Must be `struct` or `protocol` declaration"
        case .notAnyObject: "Must inherit `AnyOject`"
        case .notClassOrProtocol: "Must be `class` or `protocol` declaration"
        case .tupleBindings: "Use single variable"
        }
    }
}
