import VACopyWith

@CopyWith
struct SomeStruct: Equatable {
    let parameter1: Int
    let parameter2: Bool
}

let value = SomeStruct(parameter1: 1, parameter2: true)
assert(value.copyWith(parameter1: 2) == SomeStruct(parameter1: 2, parameter2: true))
assert(value.copyWith(parameter2: false) == SomeStruct(parameter1: 1, parameter2: false))
assert(value.copyWith(parameter1: 2, parameter2: false) == SomeStruct(parameter1: 2, parameter2: false))

@CopyWith
struct SomeStruct1: Equatable {
    let parameter1: Int
    let parameter2: Bool?
    let parameter3: String?
}

let value1 = SomeStruct1(parameter1: 1, parameter2: false, parameter3: "")
assert(value1.copyWith(parameter1: 2) == SomeStruct1(parameter1: 2, parameter2: false, parameter3: ""))
assert(value1.copyWith(parameter2: .nil) == SomeStruct1(parameter1: 1, parameter2: nil, parameter3: ""))
assert(value1.copyWith(parameter2: .value(true)) == SomeStruct1(parameter1: 1, parameter2: true, parameter3: ""))
assert(value1.copyWith(parameter3: .nil) == SomeStruct1(parameter1: 1, parameter2: false, parameter3: nil))
assert(value1.copyWith(parameter3: .value("1")) == SomeStruct1(parameter1: 1, parameter2: false, parameter3: "1"))
assert(value1.copyWith(parameter1: 10, parameter2: .nil, parameter3: .nil) == SomeStruct1(parameter1: 10, parameter2: nil, parameter3: nil))
assert(value1.copyWith(parameter1: 10, parameter2: .value(true), parameter3: .value("3")) == SomeStruct1(parameter1: 10, parameter2: true, parameter3: "3"))

@CopyWith
struct SomeStruct2: Equatable {
    let id = "const uuidstring ;)"
    var parameter1 = [1]
    var parameter2 = Optional("string")
}

let value2 = SomeStruct2()
assert(value2.copyWith(parameter1: [2, 3, 4]) == SomeStruct2(parameter1: [2, 3, 4]))
assert(value2.copyWith(parameter2: .value("new string")) == SomeStruct2(parameter2: "new string"))
assert(value2.copyWith(parameter2: .nil) == SomeStruct2(parameter2: nil))

@MutatedCopy
struct SomeStruct3: Equatable {
    let id = "const uuidstring ;)"
    var parameter1: Int
    var parameter2: Bool
}

let value3 = SomeStruct3(parameter1: 0, parameter2: false)
assert(value3.mutatedCopy {
    $0.parameter1 = 42
    $0.parameter2 = true
} == SomeStruct3(parameter1: 42, parameter2: true))

@MutatedCopy
public protocol SomeProtocol: Equatable {}

struct SomeStruct4: SomeProtocol {
    var parameter1: Int
    var parameter2: Bool
}

let value4 = SomeStruct4(parameter1: 0, parameter2: false)
assert(value4.mutatedCopy {
    $0.parameter1 = 42
    $0.parameter2 = true
} == SomeStruct4(parameter1: 42, parameter2: true))

@Mutating
class SomeClass {
    var parameter1 = 0
}

let example = SomeClass().mutating { $0.parameter1 = 42 }
assert(example.parameter1 == 42)
example.mutating { $0.parameter1 = 0 }
assert(example.parameter1 == 0)

@Mutating
public protocol SomeAnyObjectProtocol: AnyObject {}

class SomeClass1: SomeAnyObjectProtocol {
    var parameter1 = 0
}

let example1 = SomeClass1().mutating { $0.parameter1 = 42 }
assert(example1.parameter1 == 42)
example1.mutating { $0.parameter1 = 0 }
assert(example1.parameter1 == 0)
