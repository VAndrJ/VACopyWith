@attached(extension, names: arbitrary)
public macro CopyWith() = #externalMacro(module: "VACopyWithMacros", type: "VACopyWithMacro")
@attached(extension, names: arbitrary)
public macro MutatedCopy() = #externalMacro(module: "VACopyWithMacros", type: "VAMutatedCopyMacro")
