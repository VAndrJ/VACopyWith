@attached(extension, names: arbitrary)
public macro CopyWith() = #externalMacro(module: "VACopyWithMacros", type: "VACopyWithMacro")
@attached(extension, names: arbitrary)
public macro MutableCopy() = #externalMacro(module: "VACopyWithMacros", type: "VAMutableCopyMacro")
