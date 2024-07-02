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
