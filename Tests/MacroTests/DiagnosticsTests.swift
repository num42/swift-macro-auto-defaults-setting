import MacroTester
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(AutoDefaultsSettingMacros)
  import AutoDefaultsSettingMacros

  @Suite struct AutoDefaultsSettingDiagnosticsTests {
    let testMacros: [String: Macro.Type] = [
      "AutoDefaultsSetting": AutoDefaultsSettingMacro.self
    ]

    @Test func requiresThreeArguments() {
      assertMacroExpansion(
        """
        #AutoDefaultsSetting(key: "onlyKey", type: String.self)
        """,
        expandedSource: "",
        diagnostics: [
          .init(
            message: MacroDiagnostic.requiresThreeArguments.message,
            line: 1,
            column: 1
          )
        ],
        macros: testMacros
      )
    }

    @Test func interpolatedKeyThrowsError() {
      assertMacroExpansion(
        """
        #AutoDefaultsSetting(key: "launch\\(1)", type: Int.self, default: 0)
        """,
        expandedSource: "",
        diagnostics: [
          .init(
            message: MacroDiagnostic.keyMustBePlainStringLiteral.message,
            line: 1,
            column: 1
          )
        ],
        macros: testMacros
      )
    }
  }
#endif
