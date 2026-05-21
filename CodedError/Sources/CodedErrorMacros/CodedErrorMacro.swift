//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//
// swiftlint:disable type_body_length

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Diagnostic messages for CodedError macro
public struct CodedErrorDiagnostic: DiagnosticMessage {
    public let message: String
    public let diagnosticID: MessageID
    public let severity: DiagnosticSeverity

    init(message: String, diagnosticID: String, severity: DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = MessageID(domain: "CodedError", id: diagnosticID)
        self.severity = severity
    }

    static func invalidBaseErrorCode(_ code: String) -> CodedErrorDiagnostic {
        CodedErrorDiagnostic(
            message: "Base error code '\(code)' must be exactly 3 digits (000-999)",
            diagnosticID: "invalid-base-error-code"
        )
    }

    static func invalidCaseErrorCode(_ code: String, caseName: String) -> CodedErrorDiagnostic {
        CodedErrorDiagnostic(
            message: "Error code '\(code)' for case '\(caseName)' must be exactly 2 digits (00-99)",
            diagnosticID: "invalid-case-error-code"
        )
    }

    static func useModernAnnotationSyntax(_ code: String, caseName _: String) -> CodedErrorDiagnostic {
        CodedErrorDiagnostic(
            message: "Replace comment '// sourcery: errorCode = \"\(code)\"' with '@ErrorCode(\"\(code)\")' annotation",
            diagnosticID: "use-modern-annotation-syntax",
            severity: .warning
        )
    }
}

/// FixIt message for replacing comment syntax with @ErrorCode annotation
struct ReplaceCommentWithAttributeMessage: FixItMessage {
    let message: String = "Replace comment with @ErrorCode annotation"
    let fixItID = MessageID(domain: "CodedError", id: "replace-comment-with-attribute")
}

/// Implementation of the `CodedError` macro that generates CodedError conformance
/// for enums with error code annotations in comments.
public struct CodedErrorMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw CodedErrorError.onlyApplicableToEnum
        }

        // Extract base error code from macro argument
        guard let baseErrorCode = extractBaseErrorCode(from: node) else {
            throw CodedErrorError.missingBaseErrorCode
        }

        // Validate base error code format (must be 3 digits)
        validateBaseErrorCode(baseErrorCode, node: node, context: context)

        // Parse enum cases and their error codes from comments
        let caseInfos = try parseEnumCases(enumDecl, context: context)

        // Generate the extension
        let extensionDecl = try generateCodedErrorExtension(
            for: type,
            baseErrorCode: baseErrorCode,
            cases: caseInfos,
            enumDecl: enumDecl
        )

        return [extensionDecl]
    }

    private static func extractBaseErrorCode(from node: AttributeSyntax) -> String? {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let firstArg = arguments.first,
              let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
              let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) else {
            return nil
        }
        return segment.content.text
    }

    private static func parseEnumCases(_ enumDecl: EnumDeclSyntax,
                                       context: some MacroExpansionContext) throws -> [CaseInfo] {
        var caseInfos: [CaseInfo] = []

        for member in enumDecl.memberBlock.members {
            if let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) {
                for element in caseDecl.elements {
                    let caseName = element.name.text

                    // First try to extract error code from @ErrorCode annotation
                    var errorCode = extractErrorCodeFromAttributes(caseDecl.attributes)
                    var usedCommentSyntax = false

                    // Fall back to extracting from comments (for backward compatibility)
                    if errorCode == nil {
                        errorCode = extractErrorCodeFromTrivia(caseDecl.leadingTrivia)
                        if errorCode != nil {
                            usedCommentSyntax = true
                        }
                    }

                    // Validate error code format if present (must be 2 digits)
                    if let code = errorCode {
                        validateCaseErrorCode(code, caseName: caseName, caseDecl: caseDecl, context: context)

                        // Suggest modern annotation syntax if comment syntax was used
                        if usedCommentSyntax {
                            suggestModernAnnotationSyntax(
                                code: code,
                                caseName: caseName,
                                caseDecl: caseDecl,
                                leadingTrivia: caseDecl.leadingTrivia,
                                context: context
                            )
                        }
                    }

                    // Check if case has associated values
                    let associatedValues = element.parameterClause?.parameters.map { param in
                        AssociatedValue(
                            label: param.firstName?.text,
                            type: param.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    } ?? []

                    caseInfos.append(CaseInfo(
                        name: caseName,
                        errorCode: errorCode,
                        associatedValues: associatedValues
                    ))
                }
            }
        }

        return caseInfos
    }

    private static func extractErrorCodeFromAttributes(_ attributes: AttributeListSyntax) -> String? {
        for attribute in attributes {
            if case let .attribute(attr) = attribute,
               let attributeName = attr.attributeName.as(IdentifierTypeSyntax.self),
               attributeName.name.text == "ErrorCode" {
                // Extract the error code from @ErrorCode("xx")
                if let arguments = attr.arguments?.as(LabeledExprListSyntax.self),
                   let firstArg = arguments.first,
                   let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
                   let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                    return segment.content.text
                }
            }
        }
        return nil
    }

    private static func extractErrorCodeFromTrivia(_ trivia: Trivia) -> String? {
        for piece in trivia {
            if case let .lineComment(comment) = piece {
                let content = comment.trimmingCharacters(in: .whitespacesAndNewlines)
                if content.contains("sourcery:"), content.contains("errorCode") {
                    // Extract error code from comment like "// sourcery: errorCode = "01""
                    // Handle various formats: errorCode = "01", errorCode="01", etc.
                    let pattern = #"errorCode\s*=\s*"([^"]+)""#
                    if let regex = try? NSRegularExpression(pattern: pattern),
                       let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
                       let range = Range(match.range(at: 1), in: content) {
                        return String(content[range])
                    }
                }
            }
        }
        return nil
    }

    private static func generateCodedErrorExtension(
        for type: some TypeSyntaxProtocol,
        baseErrorCode: String,
        cases: [CaseInfo],
        enumDecl: EnumDeclSyntax
    ) throws -> ExtensionDeclSyntax {
        let accessLevel = extractAccessLevel(from: enumDecl)

        // Generate erpErrorCode switch cases
        let errorCodeCases = cases
            .map { caseInfo in
                let fullErrorCode = "i-\(baseErrorCode)\(caseInfo.errorCode ?? "00")"
                return "case .\(caseInfo.name): return \"\(fullErrorCode)\""
            }
            .joined(separator: "\n            ")

        // Generate erpErrorCodeList switch cases
        let errorCodeListCases = generateErrorCodeListCases(cases: cases)

        let extensionCode = """
        extension \(type): CodedError {
            \(accessLevel) var erpErrorCode: String {
                switch self {
                    \(errorCodeCases)
                }
            }

            \(accessLevel) var erpErrorCodeList: [String] {
                switch self {
                    \(errorCodeListCases)
                }
            }
        }
        """

        let sourceFile = Parser.parse(source: extensionCode)
        guard let extensionDecl = sourceFile.statements.first?.item.as(ExtensionDeclSyntax.self) else {
            throw CodedErrorError.failedToGenerateExtension
        }

        return extensionDecl
    }

    private static func validateBaseErrorCode(
        _ code: String,
        node: AttributeSyntax,
        context: some MacroExpansionContext
    ) {
        // Base error code must be exactly 3 digits
        guard code.count == 3, code.allSatisfy(\.isNumber) else {
            let diagnostic = Diagnostic(
                node: node,
                message: CodedErrorDiagnostic.invalidBaseErrorCode(code)
            )
            context.diagnose(diagnostic)
            return // Don't throw, just return after emitting diagnostic
        }
    }

    private static func validateCaseErrorCode(
        _ code: String,
        caseName: String,
        caseDecl: EnumCaseDeclSyntax,
        context: some MacroExpansionContext
    ) {
        // Case error code must be exactly 2 digits
        guard code.count == 2, code.allSatisfy(\.isNumber) else {
            let diagnostic = Diagnostic(
                node: caseDecl,
                message: CodedErrorDiagnostic.invalidCaseErrorCode(code, caseName: caseName)
            )
            context.diagnose(diagnostic)
            return // Don't throw, just return after emitting diagnostic
        }
    }

    private static func suggestModernAnnotationSyntax(
        code: String,
        caseName: String,
        caseDecl: EnumCaseDeclSyntax,
        leadingTrivia: Trivia,
        context: some MacroExpansionContext
    ) {
        // Create a FixIt that adds @ErrorCode annotation and removes the comment
        let newCaseDecl = createFixedCaseDecl(caseDecl: caseDecl, errorCode: code, leadingTrivia: leadingTrivia)

        let fixIt = FixIt(
            message: ReplaceCommentWithAttributeMessage(),
            changes: [
                .replace(
                    oldNode: Syntax(caseDecl),
                    newNode: Syntax(newCaseDecl)
                ),
            ]
        )

        let diagnostic = Diagnostic(
            node: caseDecl,
            message: CodedErrorDiagnostic.useModernAnnotationSyntax(code, caseName: caseName),
            fixIts: [fixIt]
        )

        context.diagnose(diagnostic)
    }

    private static func createFixedCaseDecl(caseDecl: EnumCaseDeclSyntax, errorCode: String,
                                            leadingTrivia: Trivia) -> EnumCaseDeclSyntax {
        // Create the @ErrorCode attribute
        let errorCodeAttribute = AttributeSyntax(
            attributeName: IdentifierTypeSyntax(name: .identifier("ErrorCode")),
            leftParen: .leftParenToken(),
            arguments: .argumentList(LabeledExprListSyntax([
                LabeledExprSyntax(expression: StringLiteralExprSyntax(content: errorCode)),
            ])),
            rightParen: .rightParenToken()
        )

        // Remove the sourcery comment from leading trivia
        let cleanTrivia = removeSourceryComment(from: leadingTrivia)

        // Add the @ErrorCode attribute to the case declaration with proper formatting
        var newAttributes = Array(caseDecl.attributes)
        newAttributes.append(.attribute(errorCodeAttribute.with(\.trailingTrivia, .newline)))

        return caseDecl
            .with(\.attributes, AttributeListSyntax(newAttributes))
            .with(\.leadingTrivia, cleanTrivia)
    }

    private static func removeSourceryComment(from trivia: Trivia) -> Trivia {
        var newTrivia: [TriviaPiece] = []
        var index = 0
        let pieces = Array(trivia)

        while index < pieces.count {
            let piece = pieces[index]
            switch piece {
            case let .lineComment(comment):
                if comment.contains("sourcery: errorCode") {
                    // Skip this comment and any immediately following newlines/spaces
                    index += 1
                    while index < pieces.count {
                        switch pieces[index] {
                        case .newlines, .spaces, .tabs:
                            index += 1
                        default:
                            break
                        }
                    }
                    continue
                } else {
                    newTrivia.append(piece)
                }
            default:
                newTrivia.append(piece)
            }
            index += 1
        }

        return Trivia(pieces: newTrivia)
    }

    private static func generateErrorCodeListCases(cases: [CaseInfo]) -> String {
        let casesWithAssociatedValues = cases.filter { !$0.associatedValues.isEmpty }

        var result: [String] = []

        // Handle cases with associated values
        for caseInfo in casesWithAssociatedValues where caseInfo.associatedValues.count == 1 {
            let associatedValue = caseInfo.associatedValues[0]
            if associatedValue.type.contains("Error") || associatedValue.type == "IDPError" {
                // Try to cast to CodedError, fallback handled by default case
                let casePattern = "case let .\(caseInfo.name)(error as CodedError):"
                let returnStatement = "return [erpErrorCode] + error.erpErrorCodeList"
                result.append("\(casePattern) \(returnStatement)")
            }
        }

        // Default case handles all other cases (including fallbacks for non-CodedError associated types)
        result.append("default: return [erpErrorCode]")

        return result.map { "            \($0)" }.joined(separator: "\n")
    }

    private static func extractAccessLevel(from enumDecl: EnumDeclSyntax) -> String {
        for modifier in enumDecl.modifiers {
            switch modifier.name.text {
            case "public": return "public"
            case "internal": return "internal"
            case "private": return "private"
            case "fileprivate": return "fileprivate"
            default: continue
            }
        }
        return "internal"
    }
}

struct CaseInfo {
    let name: String
    let errorCode: String?
    let associatedValues: [AssociatedValue]
}

struct AssociatedValue {
    let label: String?
    let type: String
}

public enum CodedErrorError: CustomStringConvertible, Error {
    case onlyApplicableToEnum
    case missingBaseErrorCode
    case failedToGenerateExtension
    case invalidBaseErrorCode(String)
    case invalidCaseErrorCode(String, caseName: String)

    public var description: String {
        switch self {
        case .onlyApplicableToEnum:
            return "@CodedError can only be applied to an enum"
        case .missingBaseErrorCode:
            return "@CodedError requires a base error code as argument"
        case .failedToGenerateExtension:
            return "Failed to generate CodedError extension"
        case let .invalidBaseErrorCode(code):
            return "Base error code '\(code)' must be exactly 3 digits (000-999)"
        case let .invalidCaseErrorCode(code, caseName):
            return "Error code '\(code)' for case '\(caseName)' must be exactly 2 digits (00-99)"
        }
    }
}

// swiftlint:enable type_body_length
