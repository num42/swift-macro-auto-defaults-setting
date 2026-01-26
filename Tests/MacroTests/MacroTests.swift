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

    @Test func enumType() {
      MacroTester.testMacro(macros: testMacros)
    }
      
      @Test func booleanDefault() {
        MacroTester.testMacro(macros: testMacros)
      }

      @Test func integerDefault() {
        MacroTester.testMacro(macros: testMacros)
      }

      @Test func doubleDefault() {
        MacroTester.testMacro(macros: testMacros)
      }

      @Test func arrayDefault() {
        MacroTester.testMacro(macros: testMacros)
      }

      @Test func dictionaryDefault() {
        MacroTester.testMacro(macros: testMacros)
      }

      @Test func optionalDefault() {
        MacroTester.testMacro(macros: testMacros)
      }

      @Test func multiWordKey() {
        MacroTester.testMacro(macros: testMacros)
      }

      @Test func urlDefault() {
        MacroTester.testMacro(macros: testMacros)
      }

      @Test func dataDefault() {
        MacroTester.testMacro(macros: testMacros)
      }

      @Test func dateDefault() {
        MacroTester.testMacro(macros: testMacros)
      }
  }
#endif
