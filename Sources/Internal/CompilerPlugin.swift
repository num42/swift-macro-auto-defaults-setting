import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AutoDefaultsSettingPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    AutoDefaultsSettingMacro.self
  ]
}
