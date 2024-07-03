# VACopyWith


[![StandWithUkraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)
[![Support Ukraine](https://img.shields.io/badge/Support-Ukraine-FFD500?style=flat&labelColor=005BBB)](https://opensource.fb.com/support-ukraine)


[![Language](https://img.shields.io/badge/language-Swift%205.9-orangered.svg?style=flat)](https://www.swift.org)
[![SPM](https://img.shields.io/badge/SPM-compatible-limegreen.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20macOS%20%7C%20macCatalyst-lightgray.svg?style=flat)](https://developer.apple.com/discover)


### @CopyWith 

Adds an extension with the `copyWith` function. Works with the default initializer and has some other limitations. For example, the following syntax is not supported:


```swift
struct SomeStruct {
    let (a, b): (Int, Int)
}
```


Example 1:


```swift
            
@CopyWith
struct SomeStruct {
    let a: Int
    let b: Bool
}

// expands to

struct SomeStruct {
    let a: Int
    let b: Bool
}

extension SomeStruct {
    func copyWith(
        a: Int? = nil, 
        b: Bool? = nil
    ) -> SomeStruct {
        SomeStruct(
            a: a ?? self.a,
            b: b ?? self.b
        )
    }
}

// usage

let exampleStruct = SomeStruct(a: 1, b: false)
let exampleStructWith10 = exampleStruct.copyWith(a: 10)
let exampleStructWithTrue = exampleStruct.copyWith(b: true)
```


Example 2:


```swift
@CopyWith
public struct SomeStruct {
    let a: String?
    let b: Int
}

// expands to

public struct SomeStruct {
    let a: String?
    let b: Int
}

public extension SomeStruct {
    public enum OR<T> {
        case value(T)
        case `nil`
        case ignored
    }
    func copyWith(
        a: OR<String> = .ignored, 
        b: Int? = nil
    ) -> SomeStruct {
        let a: String? = switch a {
        case let .value(value):
            value
        case .nil:
            nil
        case .ignored:
            self.a
        }
        return SomeStruct(
            a: a,
            b: b ?? self.b
        )
    }
}

// usage

let exampleStruct = SomeStruct(a: "a", b: 0)
let exampleStructWithResetA = exampleStruct.copyWith(a: .nil)
let exampleStructWithNewA = exampleStruct.copyWith(a: .value("some string"))
```


Here an auxiliary enum is added to simplify working with optional properties and clear syntax.


Example 3:


```swift
@CopyWith
struct SomeStruct {
    let id = "const uuidstring ;)"
    let constantProperty = false
    var boolValue = true
    var intValue = 1
    var doubleValue = 1.0
    var stringValue = "a"
    var customValue = MyCustomType(property: 1)
}

// expands to

struct SomeStruct {
    let id = "const uuidstring ;)"
    let constantProperty = false
    var boolValue = true
    var intValue = 1
    var doubleValue = 1.0
    var stringValue = "a"
    var customValue = MyCustomType(property: 1)
}

extension SomeStruct {
    func copyWith(
        boolValue: Bool? = nil,
        intValue: Int? = nil,
        doubleValue: Double? = nil,
        stringValue: String? = nil,
        customValue: MyCustomType? = nil
    ) -> SomeStruct {
        SomeStruct(
            boolValue: boolValue ?? self.boolValue,
            intValue: intValue ?? self.intValue,
            doubleValue: doubleValue ?? self.doubleValue,
            stringValue: stringValue ?? self.stringValue,
            customValue: customValue ?? self.customValue
        )
    }
}

// usage

let exampleStruct = SomeStruct()
let exampleStructWithFalse = exampleStruct.copyWith(boolValue: false)
```


### @MutatedCopy


Adds an extension to a `struct` with a `mutatedCopy` function if `var` fields are present.


Example 1:


```swift
@MutatedCopy
struct SomeStruct: Equatable {
    let id = "const uuidstring ;)"
    var intValue: Int
    var boolValue: Bool
}

// expands to

struct SomeStruct: Equatable {
    let id = "const uuidstring ;)"
    var intValue: Int
    var boolValue: Bool
}

extension SomeStruct {
    func mutatedCopy(configuring: (_ it: inout SomeStruct) throws -> Void) rethrows -> SomeStruct {
        var mutableCopy = self
        try configuring(&mutableCopy)

        return mutableCopy
    }
}

Example 2:


```swift
@MutatedCopy
protocol SomeProtocol: Equatable {}

struct SomeStruct: SomeProtocol {
    let id = "const uuidstring ;)"
    var intValue: Int
    var boolValue: Bool
}

// expands to

protocol SomeProtocol: Equatable {}

extension SomeProtocol {
    func mutatedCopy(configuring: (_ it: inout Self) throws -> Void) rethrows -> Self {
        var mutableCopy = self
        try configuring(&mutableCopy)

        return mutableCopy
    }
}

struct SomeStruct: SomeProtocol {
    let id = "const uuidstring ;)"
    var intValue: Int
    var boolValue: Bool
}

// usage

let exampleStruct = SomeStruct(parameter1: 0, parameter2: false)
let exampleStructModified = exampleStruct.mutatedCopy {
    $0.intValue = 42
    $0.boolValue = true
}
```

// usage

let exampleStruct = SomeStruct(parameter1: 0, parameter2: false)
let exampleStructModified = exampleStruct.mutatedCopy {
    $0.intValue = 42
    $0.boolValue = true
}
```


### @Mutating


Adds an extension to a `class` with a `mutating` function if `var` fields are present, or to `protocol` without fields check.


Example 1:


```swift
@Mutating
class SomeClass {
    var intValue: Int = 0
    var boolValue: Bool = false
}

// expands to

class SomeClass {
    var intValue: Int = 0
    var boolValue: Bool = false
}

extension SomeClass {
    @discardableResult
    func mutating(configuring: (_ it: SomeClass) throws -> Void) rethrows -> SomeClass {
        try configuring(&self)

        return self
    }
}

// usage

let exampleClass = SomeClass().mutating {
    $0.intValue = 42
    $0.boolValue = true
}
```


Example 2:


```swift
@Mutating
protocol SomeProtocol: AnyObject {}

class SomeClass: SomeProtocol {
    var intValue: Int = 0
    var boolValue: Bool = false
}

// expands to
protocol SomeProtocol: AnyObject {}

extension SomeProtocol {
    @discardableResult
    func mutating(configuring: (_ it: Self) throws -> Void) rethrows -> Self {
        try configuring(&self)

        return self
    }
}

class SomeClass: SomeProtocol {
    var intValue: Int = 0
    var boolValue: Bool = false
}

// usage

let exampleClass = SomeClass().mutating {
    $0.intValue = 42
    $0.boolValue = true
}
```


## Author


Volodymyr Andriienko, vandrjios@gmail.com


## License


VACopyWith is available under the MIT license. See the LICENSE file for more info.
