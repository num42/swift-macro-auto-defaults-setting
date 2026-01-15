import MacroTester
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(AutoDefaultsSettingMacros)
  import AutoDefaultsSettingMacros

  let testMacros: [String: Macro.Type] = [
    "AutoDefaultsSetting": AutoDefaultsSettingMacro.self
  ]

  @Suite
  struct AutoDefaultsSettingMacroTests {
    @Test func standardType() {
      MacroTester.testMacro(macros: testMacros)
    }
  }
#endif
