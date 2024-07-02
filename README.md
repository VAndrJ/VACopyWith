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
    func copyWith(a: Int? = nil, b: Bool? = nil) -> SomeStruct {
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
    func copyWith(a: OR<String> = .ignored, b: Int? = nil) -> SomeStruct {
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

// example

let exampleStruct = SomeStruct(a: "a", b: 0)
let exampleStructWithResetA = exampleStruct.copyWith(a: .nil)
let exampleStructWithNewA = exampleStruct.copyWith(a: .value("some string"))
```


Here an auxiliary enum is added to simplify working with optional properties and clear syntax.


## Author


Volodymyr Andriienko, vandrjios@gmail.com


## License


VACopyWith is available under the MIT license. See the LICENSE file for more info.
