//
//  VACopyWithMacroError.swift
//  
//
//  Created by VAndrJ on 02.07.2024.
//

public enum VACopyWithMacroError: Error, CustomStringConvertible {
    case notStruct
    case multipleBindings

    public var description: String {
        switch self {
        case .notStruct: "Must be `struct` declaration"
        case .multipleBindings: "Use single variable"
        }
    }
}
