internal import SwiftSyntaxMacrosGenericTestSupport
internal import Testing

#if canImport(AutoDefaultsSettingMacros)
  import AutoDefaultsSettingMacros

  @Suite
  struct AutoDefaultsSettingDiagnosticsTests {
    @Test func requiresThreeArguments() {
      assertMacroExpansion(
        """
        #AutoDefaultsSetting(key: "onlyKey", type: String.self)
        """,
        expandedSource: """
          #AutoDefaultsSetting(key: "onlyKey", type: String.self)
          """,
        diagnostics: [
          .init(
            message: AutoDefaultsSettingMacro.MacroDiagnostic.requiresThreeArguments.message,
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
        expandedSource: """
          #AutoDefaultsSetting(key: "launch\\(1)", type: Int.self, default: 0)
          """,
        diagnostics: [
          .init(
            message: AutoDefaultsSettingMacro.MacroDiagnostic.keyMustBePlainStringLiteral.message,
            line: 1,
            column: 27
          )
        ],
        macros: testMacros
      )
    }
  }
#endif
