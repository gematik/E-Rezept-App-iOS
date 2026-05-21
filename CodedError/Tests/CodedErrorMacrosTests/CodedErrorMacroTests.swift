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
// swiftlint:disable type_body_length function_body_length file_length

import MacroTesting
import SwiftSyntaxMacros
import XCTest

#if canImport(CodedErrorMacros)
import CodedErrorMacros
#endif

final class CodedErrorMacroTests: XCTestCase {
    override func invokeTest() {
        #if canImport(CodedErrorMacros)
        withMacroTesting(
            record: .failed,
            macros: [CodedErrorMacro.self]
        ) {
            super.invokeTest()
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroFixItFunctionality() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                // sourcery: errorCode = "01"
                case someError
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                // sourcery: errorCode = "01"
                case someError
                ┬─────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "01"' with '@ErrorCode("01")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
            }
            """
        } fixes: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")

                // sourcery: errorCode = "01"
                case someError
            }
            """
        } expansion: {
            """
            enum TestError: Swift.Error {
                @ErrorCode("01")

                // sourcery: errorCode = "01"
                case someError
            }

            extension TestError: CodedError {
                internal var erpErrorCode: String {
                    switch self {
                        case .someError:
                        return "i-02901"
                    }
                }

                internal var erpErrorCodeList: [String] {
                    switch self {
                                    default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroBasic() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                // sourcery: errorCode = "01"
                case someError
                // sourcery: errorCode = "02"
                case anotherError
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                // sourcery: errorCode = "01"
                case someError
                ┬─────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "01"' with '@ErrorCode("01")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
                // sourcery: errorCode = "02"
                case anotherError
                ┬────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "02"' with '@ErrorCode("02")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
            }
            """
        } fixes: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")

                // sourcery: errorCode = "01"
                case someError
                @ErrorCode("02")

                // sourcery: errorCode = "02"
                case anotherError
            }
            """
        } expansion: {
            """
            enum TestError: Swift.Error {
                @ErrorCode("01")

                // sourcery: errorCode = "01"
                case someError
                @ErrorCode("02")

                // sourcery: errorCode = "02"
                case anotherError
            }

            extension TestError: CodedError {
                internal var erpErrorCode: String {
                    switch self {
                        case .someError:
                        return "i-02901"
                        case .anotherError:
                        return "i-02902"
                    }
                }

                internal var erpErrorCodeList: [String] {
                    switch self {
                                    default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroWithAssociatedValues() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                // sourcery: errorCode = "01"
                case simpleError
                // sourcery: errorCode = "02"
                case idpError(IDPError)
                // sourcery: errorCode = "03"
                case dataError(Data)
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                // sourcery: errorCode = "01"
                case simpleError
                ┬───────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "01"' with '@ErrorCode("01")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
                // sourcery: errorCode = "02"
                case idpError(IDPError)
                ┬──────────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "02"' with '@ErrorCode("02")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
                // sourcery: errorCode = "03"
                case dataError(Data)
                ┬───────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "03"' with '@ErrorCode("03")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
            }
            """
        } fixes: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")

                // sourcery: errorCode = "01"
                case simpleError
                @ErrorCode("02")

                // sourcery: errorCode = "02"
                case idpError(IDPError)
                @ErrorCode("03")

                // sourcery: errorCode = "03"
                case dataError(Data)
            }
            """
        } expansion: {
            """
            enum TestError: Swift.Error {
                @ErrorCode("01")

                // sourcery: errorCode = "01"
                case simpleError
                @ErrorCode("02")

                // sourcery: errorCode = "02"
                case idpError(IDPError)
                @ErrorCode("03")

                // sourcery: errorCode = "03"
                case dataError(Data)
            }

            extension TestError: CodedError {
                internal var erpErrorCode: String {
                    switch self {
                        case .simpleError:
                        return "i-02901"
                        case .idpError:
                        return "i-02902"
                        case .dataError:
                        return "i-02903"
                    }
                }

                internal var erpErrorCodeList: [String] {
                    switch self {
                                    case let .idpError(error as CodedError):
                        return [erpErrorCode] + error.erpErrorCodeList
                        default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroWithPublicEnum() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("500")
            public enum PublicError: Swift.Error {
                // sourcery: errorCode = "10"
                case networkError
            }
            """
        } diagnostics: {
            """
            @CodedError("500")
            public enum PublicError: Swift.Error {
                // sourcery: errorCode = "10"
                case networkError
                ┬────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "10"' with '@ErrorCode("10")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
            }
            """
        } fixes: {
            """
            @CodedError("500")
            public enum PublicError: Swift.Error {
                @ErrorCode("10")

                // sourcery: errorCode = "10"
                case networkError
            }
            """
        } expansion: {
            """
            public enum PublicError: Swift.Error {
                @ErrorCode("10")

                // sourcery: errorCode = "10"
                case networkError
            }

            extension PublicError: CodedError {
                public var erpErrorCode: String {
                    switch self {
                        case .networkError:
                        return "i-50010"
                    }
                }

                public var erpErrorCodeList: [String] {
                    switch self {
                                    default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroMissingErrorCodes() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("100")
            enum TestError: Swift.Error {
                case missingCodeError
                // sourcery: errorCode = "01"
                case hasCodeError
            }
            """
        } diagnostics: {
            """
            @CodedError("100")
            enum TestError: Swift.Error {
                case missingCodeError
                // sourcery: errorCode = "01"
                case hasCodeError
                ┬────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "01"' with '@ErrorCode("01")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
            }
            """
        } fixes: {
            """
            @CodedError("100")
            enum TestError: Swift.Error {
                case missingCodeError
                @ErrorCode("01")

                // sourcery: errorCode = "01"
                case hasCodeError
            }
            """
        } expansion: {
            """
            enum TestError: Swift.Error {
                case missingCodeError
                @ErrorCode("01")

                // sourcery: errorCode = "01"
                case hasCodeError
            }

            extension TestError: CodedError {
                internal var erpErrorCode: String {
                    switch self {
                        case .missingCodeError:
                        return "i-10000"
                        case .hasCodeError:
                        return "i-10001"
                    }
                }

                internal var erpErrorCodeList: [String] {
                    switch self {
                                    default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroOriginalExample() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum Error: Swift.Error, Equatable, LocalizedError {
                // sourcery: errorCode = "01"
                case idpError(IDPError)
                // sourcery: errorCode = "02"
                case universalLinkFailed
                // sourcery: errorCode = "03"
                case kkNotFound
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum Error: Swift.Error, Equatable, LocalizedError {
                // sourcery: errorCode = "01"
                case idpError(IDPError)
                ┬──────────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "01"' with '@ErrorCode("01")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
                // sourcery: errorCode = "02"
                case universalLinkFailed
                ┬───────────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "02"' with '@ErrorCode("02")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
                // sourcery: errorCode = "03"
                case kkNotFound
                ┬──────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "03"' with '@ErrorCode("03")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
            }
            """
        } fixes: {
            """
            @CodedError("029")
            enum Error: Swift.Error, Equatable, LocalizedError {
                @ErrorCode("01")

                // sourcery: errorCode = "01"
                case idpError(IDPError)
                @ErrorCode("02")

                // sourcery: errorCode = "02"
                case universalLinkFailed
                @ErrorCode("03")

                // sourcery: errorCode = "03"
                case kkNotFound
            }
            """
        } expansion: {
            """
            enum Error: Swift.Error, Equatable, LocalizedError {
                @ErrorCode("01")

                // sourcery: errorCode = "01"
                case idpError(IDPError)
                @ErrorCode("02")

                // sourcery: errorCode = "02"
                case universalLinkFailed
                @ErrorCode("03")

                // sourcery: errorCode = "03"
                case kkNotFound
            }

            extension Error: CodedError {
                internal var erpErrorCode: String {
                    switch self {
                        case .idpError:
                        return "i-02901"
                        case .universalLinkFailed:
                        return "i-02902"
                        case .kkNotFound:
                        return "i-02903"
                    }
                }

                internal var erpErrorCodeList: [String] {
                    switch self {
                                    case let .idpError(error as CodedError):
                        return [erpErrorCode] + error.erpErrorCodeList
                        default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroWithErrorCodeAnnotations() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
                @ErrorCode("02")
                case anotherError
            }
            """
        } expansion: {
            """
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
                @ErrorCode("02")
                case anotherError
            }

            extension TestError: CodedError {
                internal var erpErrorCode: String {
                    switch self {
                        case .someError:
                        return "i-02901"
                        case .anotherError:
                        return "i-02902"
                    }
                }

                internal var erpErrorCodeList: [String] {
                    switch self {
                                    default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroMixedAnnotationAndComments() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case annotatedError
                // sourcery: errorCode = "02"
                case commentError
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case annotatedError
                // sourcery: errorCode = "02"
                case commentError
                ┬────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "02"' with '@ErrorCode("02")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
            }
            """
        } fixes: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case annotatedError
                @ErrorCode("02")

                // sourcery: errorCode = "02"
                case commentError
            }
            """
        } expansion: {
            """
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case annotatedError
                @ErrorCode("02")

                // sourcery: errorCode = "02"
                case commentError
            }

            extension TestError: CodedError {
                internal var erpErrorCode: String {
                    switch self {
                        case .annotatedError:
                        return "i-02901"
                        case .commentError:
                        return "i-02902"
                    }
                }

                internal var erpErrorCodeList: [String] {
                    switch self {
                                    default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroValidation_InvalidBaseErrorCode() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("12")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
            }
            """
        } diagnostics: {
            """
            @CodedError("12")
            ┬────────────────
            ╰─ 🛑 Base error code '12' must be exactly 3 digits (000-999)
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroValidation_InvalidBaseErrorCodeTooLong() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("1234")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
            }
            """
        } diagnostics: {
            """
            @CodedError("1234")
            ┬──────────────────
            ╰─ 🛑 Base error code '1234' must be exactly 3 digits (000-999)
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroValidation_InvalidBaseErrorCodeNonDigits() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("abc")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
            }
            """
        } diagnostics: {
            """
            @CodedError("abc")
            ┬─────────────────
            ╰─ 🛑 Base error code 'abc' must be exactly 3 digits (000-999)
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroValidation_InvalidCaseErrorCode() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("1")
                case someError
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("1")
                ╰─ 🛑 Error code '1' for case 'someError' must be exactly 2 digits (00-99)
                case someError
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroValidation_InvalidCaseErrorCodeTooLong() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("123")
                case someError
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("123")
                ╰─ 🛑 Error code '123' for case 'someError' must be exactly 2 digits (00-99)
                case someError
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroValidation_InvalidCaseErrorCodeNonDigits() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("ab")
                case someError
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("ab")
                ╰─ 🛑 Error code 'ab' for case 'someError' must be exactly 2 digits (00-99)
                case someError
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroValidation_InvalidCommentBasedErrorCode() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                // sourcery: errorCode = "1"
                case someError
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                // sourcery: errorCode = "1"
                case someError
                ┬─────────────
                ├─ 🛑 Error code '1' for case 'someError' must be exactly 2 digits (00-99)
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "1"' with '@ErrorCode("1")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodedErrorMacroValidation_ValidErrorCodes() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
                @ErrorCode("99")
                case anotherError
                // sourcery: errorCode = "00"
                case legacyError
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
                @ErrorCode("99")
                case anotherError
                // sourcery: errorCode = "00"
                case legacyError
                ┬───────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "00"' with '@ErrorCode("00")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
            }
            """
        } fixes: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
                @ErrorCode("99")
                case anotherError
                @ErrorCode("00")

                // sourcery: errorCode = "00"
                case legacyError
            }
            """
        } expansion: {
            """
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
                @ErrorCode("99")
                case anotherError
                @ErrorCode("00")

                // sourcery: errorCode = "00"
                case legacyError
            }

            extension TestError: CodedError {
                internal var erpErrorCode: String {
                    switch self {
                        case .someError:
                        return "i-02901"
                        case .anotherError:
                        return "i-02999"
                        case .legacyError:
                        return "i-02900"
                    }
                }

                internal var erpErrorCodeList: [String] {
                    switch self {
                                    default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    /// Test to verify that modern @ErrorCode syntax doesn't produce warnings
    func testCodedErrorMacroModernSyntaxNoWarnings() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
                @ErrorCode("02")
                case anotherError
            }
            """
        } expansion: {
            """
            enum TestError: Swift.Error {
                @ErrorCode("01")
                case someError
                @ErrorCode("02")
                case anotherError
            }

            extension TestError: CodedError {
                internal var erpErrorCode: String {
                    switch self {
                        case .someError:
                        return "i-02901"
                        case .anotherError:
                        return "i-02902"
                    }
                }

                internal var erpErrorCodeList: [String] {
                    switch self {
                                    default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    /// Test for comment syntax modernization suggestion with various comment formats
    func testCodedErrorMacroCommentSyntaxVariations() throws {
        #if canImport(CodedErrorMacros)
        assertMacro {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                //sourcery: errorCode = "01"
                case noSpaceComment
                //  sourcery: errorCode = "02"
                case spacedComment
                // sourcery:errorCode="03"
                case noSpacesAroundEquals
            }
            """
        } diagnostics: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                //sourcery: errorCode = "01"
                case noSpaceComment
                ┬──────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "01"' with '@ErrorCode("01")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
                //  sourcery: errorCode = "02"
                case spacedComment
                ┬─────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "02"' with '@ErrorCode("02")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
                // sourcery:errorCode="03"
                case noSpacesAroundEquals
                ┬────────────────────────
                ╰─ ⚠️ Replace comment '// sourcery: errorCode = "03"' with '@ErrorCode("03")' annotation
                   ✏️ Replace comment with @ErrorCode annotation
            }
            """
        } fixes: {
            """
            @CodedError("029")
            enum TestError: Swift.Error {
                @ErrorCode("01")

                //sourcery: errorCode = "01"
                case noSpaceComment
                @ErrorCode("02")

                //  sourcery: errorCode = "02"
                case spacedComment
                // sourcery:errorCode="03"
                @ErrorCode("03")

                // sourcery:errorCode="03"
                case noSpacesAroundEquals
            }
            """
        } expansion: {
            """
            enum TestError: Swift.Error {
                @ErrorCode("01")

                //sourcery: errorCode = "01"
                case noSpaceComment
                @ErrorCode("02")

                //  sourcery: errorCode = "02"
                case spacedComment
                // sourcery:errorCode="03"
                @ErrorCode("03")

                // sourcery:errorCode="03"
                case noSpacesAroundEquals
            }

            extension TestError: CodedError {
                internal var erpErrorCode: String {
                    switch self {
                        case .noSpaceComment:
                        return "i-02901"
                        case .spacedComment:
                        return "i-02902"
                        case .noSpacesAroundEquals:
                        return "i-02903"
                    }
                }

                internal var erpErrorCodeList: [String] {
                    switch self {
                                    default:
                        return [erpErrorCode]
                    }
                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

// swiftlint:enable function_body_length file_length type_body_length
