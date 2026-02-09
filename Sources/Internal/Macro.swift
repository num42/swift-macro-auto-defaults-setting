import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct AutoDefaultsSettingMacro: DeclarationMacro {
  public enum MacroDiagnostic: String, DiagnosticMessage {
    case requiresThreeArguments
    case keyMustBeStringLiteral
    case keyMustBePlainStringLiteral
    case keyCannotBeEmpty
    case keyMustBeValidIdentifier
    case typeMustBeMemberAccess
    case missingDefaultArgument

    public var message: String {
      switch self {
      case .requiresThreeArguments:
        return "AutoDefaultsSetting requires exactly 3 arguments (key, type, default)"
      case .keyMustBeStringLiteral:
        return "The 'key' argument must be a string literal"
      case .keyMustBePlainStringLiteral:
        return "The 'key' argument must be a non-interpolated string literal"
      case .keyCannotBeEmpty:
        return "The 'key' argument cannot be an empty string"
      case .keyMustBeValidIdentifier:
        return "The 'key' must be a valid identifier (alphanumeric and underscores only)"
      case .typeMustBeMemberAccess:
        return "The 'type' argument must be in the form 'TypeName.self'"
      case .missingDefaultArgument:
        return "The 'default' argument is required"
      }
    }

    public var diagnosticID: MessageID {
      MessageID(domain: "AutoDefaultsSettingMacro", id: rawValue)
    }

    public var severity: DiagnosticSeverity {
      .error
    }
  }

  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let arguments = Array(node.arguments)

    // Validate we have exactly 3 arguments
    guard arguments.count == 3 else {
      let diagnostic = Diagnostic(
        node: Syntax(node),
        message: MacroDiagnostic.requiresThreeArguments,
        highlights: [Syntax(node.arguments)]
      )
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    // Extract and validate the key argument
    guard let keyExpr = arguments[0].expression.as(StringLiteralExprSyntax.self) else {
      let diagnostic = Diagnostic(
        node: Syntax(arguments[0].expression),
        message: MacroDiagnostic.keyMustBeStringLiteral,
        highlights: [Syntax(arguments[0].expression)]
      )
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    guard
      keyExpr.segments.count == 1,
      let keySegment = keyExpr.segments.first?.as(StringSegmentSyntax.self)
    else {
      let diagnostic = Diagnostic(
        node: Syntax(keyExpr),
        message: MacroDiagnostic.keyMustBePlainStringLiteral,
        highlights: [Syntax(keyExpr)]
      )
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    let key = keySegment.content.text

    guard !key.isEmpty else {
      let diagnostic = Diagnostic(
        node: Syntax(keyExpr),
        message: MacroDiagnostic.keyCannotBeEmpty,
        highlights: [Syntax(keyExpr)]
      )
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    // Validate key contains only valid identifier characters
    let validKeyCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
    guard key.unicodeScalars.allSatisfy({ validKeyCharacters.contains($0) }) else {
      let diagnostic = Diagnostic(
        node: Syntax(keyExpr),
        message: MacroDiagnostic.keyMustBeValidIdentifier,
        highlights: [Syntax(keyExpr)]
      )
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    // Extract and validate the type argument
    guard let typeExpr = arguments[1].expression.as(MemberAccessExprSyntax.self),
      let typeBase = typeExpr.base
    else {
      let diagnostic = Diagnostic(
        node: Syntax(arguments[1].expression),
        message: MacroDiagnostic.typeMustBeMemberAccess,
        highlights: [Syntax(arguments[1].expression)]
      )
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    let typeString = typeBase.description.trimmingCharacters(in: .whitespaces)

    // Extract the default value argument
    guard arguments.count > 2 else {
      let diagnostic = Diagnostic(
        node: Syntax(node),
        message: MacroDiagnostic.missingDefaultArgument
      )
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    let defaultValue = arguments[2]
    let defaultValueString = defaultValue.expression.description.trimmingCharacters(
      in: .whitespaces
    )

    // Generate the struct name from the key
    let structName = generateStructName(from: key)

    let result: DeclSyntax = """
      public struct \(raw: structName): DefaultsSetting {
        public static var shared = Self()

        public let key = Key<\(raw: typeString)>(
          "\(raw: key)",
          default: \(raw: defaultValueString)
        )
      }
      """

    return [result]
  }

  private static func generateStructName(from key: String) -> String {
    // Capitalize the first letter and append "Setting"
    guard let firstChar = key.first else {
      return "Setting"
    }
    return firstChar.uppercased() + key.dropFirst() + "Setting"
  }
}
