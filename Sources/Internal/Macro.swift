import SwiftSyntax
import SwiftSyntaxMacros

public struct AutoDefaultsSettingMacro: DeclarationMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let key = node.arguments
      .first!
      .expression.as(StringLiteralExprSyntax.self)!
      .segments
      .first!.as(StringSegmentSyntax.self)!
      .content
      .text

    let typeString = node.arguments
      .dropFirst()
      .first!
      .expression.as(MemberAccessExprSyntax.self)!
      .base!
      .description

    let defaultValue = node.arguments
      .dropFirst(2)
      .first!

    let result: DeclSyntax = """
        public struct \(raw: key.prefix(1).uppercased() + key.dropFirst())Setting: DefaultsSetting {
        public static var shared = Self()

        public let key = Key<\(raw: typeString)>(
          "\(raw: key)",
          \(raw: defaultValue.description.drop(while: { $0.isWhitespace }))
        )
      }
      """

    return [result]
  }
}
