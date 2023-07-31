// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import AVS
import Combine
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import FHIRClient
import Foundation
import HTTPClient
import IDP
import ModelsR4
import OpenSSL
import Pharmacy
import TrustStore
import VAUClient
import ZXingObjC

extension AVSError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .network:
                return "i-54001"
            case .invalidAVSMessageInput:
                return "i-54002"
            case .invalidX509Input:
                return "i-54003"
            case .unspecified:
                return "i-54004"
            case .`internal`:
                return "i-54005"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .network(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .unspecified(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .unspecified:
                return [erpErrorCode]
            case let .`internal`(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension AVSError.InternalError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .cmsContentCreation:
                return "i-54101"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension AVSTransactionCoreDataStore.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .noMatchingEntity:
                return "i-5811"
            case .internalError:
                return "i-5812"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension AVScannerViewController.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .initalizationError:
                return "i-00201"
            case .other:
                return "i-00202"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .other(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .other:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension AppSecurityManagerError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .savePasswordFailed:
                return "i-00601"
            case .retrievePasswordFailed:
                return "i-00602"
            case .localAuthenticationContext:
                return "i-00603"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .localAuthenticationContext:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension AuthenticationChallengeProviderError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .cannotEvaluatePolicy:
                return "i-00301"
            case .failedEvaluatingPolicy:
                return "i-00302"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .cannotEvaluatePolicy:
                return [erpErrorCode]
            case .failedEvaluatingPolicy:
                return [erpErrorCode]
        }
    }
}

extension BiometricsSHA256Signer.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .sessionClosed:
                return "i-10201"
            case .signatureFailed:
                return "i-10202"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension CardWallExtAuthConfirmationDomain.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .idpError:
                return "i-01201"
            case .universalLinkFailed:
                return "i-01202"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .idpError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension CardWallReadCardDomain.State.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .idpError:
                return "i-01001"
            case .inputError:
                return "i-01002"
            case .signChallengeError:
                return "i-01003"
            case .biometrieError:
                return "i-01004"
            case .profileValidation:
                return "i-01005"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .idpError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .inputError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .signChallengeError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .biometrieError(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .biometrieError:
                return [erpErrorCode]
            case let .profileValidation(error):
                return [erpErrorCode] + error.erpErrorCodeList
        }
    }
}

extension CardWallReadCardDomain.State.Error.InputError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .missingPIN:
                return "i-01101"
            case .missingCAN:
                return "i-01102"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension ChargeItemDomainServiceAuthenticateResult.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .loginHandler:
                return "i-03101"
            case .unexpected:
                return "i-03102"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .loginHandler(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension ChargeItemDomainServiceDeleteResult.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .localStore:
                return "i-03401"
            case .loginHandler:
                return "i-03402"
            case .erxRepository:
                return "i-03403"
            case .unexpected:
                return "i-03404"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .localStore(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .loginHandler(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .erxRepository(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension ChargeItemDomainServiceFetchResult.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .localStore:
                return "i-03001"
            case .loginHandler:
                return "i-03002"
            case .erxRepository:
                return "i-03003"
            case .unexpected:
                return "i-03004"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .localStore(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .loginHandler(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .erxRepository(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension ChargeItemListDomainServiceGrantResult.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .localStore:
                return "i-03201"
            case .loginHandler:
                return "i-03202"
            case .erxRepository:
                return "i-03203"
            case .unexpectedGrantConsentResponse:
                return "i-03204"
            case .unexpected:
                return "i-03205"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .localStore(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .loginHandler(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .erxRepository(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension ChargeItemListDomainServiceRevokeResult.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .localStore:
                return "i-03301"
            case .loginHandler:
                return "i-03302"
            case .erxRepository:
                return "i-03303"
            case .unexpected:
                return "i-03304"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .localStore(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .loginHandler(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .erxRepository(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension ChargeItemPDFServiceError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .couldNotCreateDestinationURL:
                return "i-03501"
            case .couldNotCreatePDFStringForParsing:
                return "i-03502"
            case .parsingError:
                return "i-03503"
            case .failedToCreateAttachment:
                return "i-03504"
            case .dataMissingPatient:
                return "i-03505"
            case .dataMissingDoctor:
                return "i-03506"
            case .dataMissingPharmacy:
                return "i-03507"
            case .dataMissingInvoice:
                return "i-03508"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .parsingError:
                return [erpErrorCode]
            case .failedToCreateAttachment:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension ConversionError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .generic:
                return "i-10701"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .generic:
                return [erpErrorCode]
        }
    }
}

extension CoreDataController.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .initialization:
                return "i-50001"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .initialization(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .initialization:
                return [erpErrorCode]
        }
    }
}

extension DefaultDataMatrixStringEncoderError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .stringEncoding:
                return "i-20201"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .stringEncoding:
                return [erpErrorCode]
        }
    }
}

extension DemoError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .demo:
                return "i-01901"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension ErxConsent.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .unableToConstructConsentRequest:
                return "i-20601"
            case .invalidErxConsentInput:
                return "i-20602"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .invalidErxConsentInput:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension ErxRepositoryError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .local:
                return "i-20001"
            case .remote:
                return "i-20002"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .local(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .remote(error):
                return [erpErrorCode] + error.erpErrorCodeList
        }
    }
}

extension ErxTask.Status.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .decoding:
                return "i-20101"
            case .unknown:
                return "i-20102"
            case .missingStatus:
                return "i-20103"
            case .missingPatientReceiptReference:
                return "i-20104"
            case .missingPatientReceiptIdentifier:
                return "i-20105"
            case .missingPatientReceiptBundle:
                return "i-20106"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .decoding:
                return [erpErrorCode]
            case .unknown:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension ErxTaskOrder.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .unableToConstructCommunicationRequest:
                return "i-20601"
            case .invalidErxTaskOrderInput:
                return "i-20602"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .invalidErxTaskOrderInput:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension ExtAuthPendingDomain.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .idpError:
                return "i-01401"
            case .profileValidation:
                return "i-01402"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .idpError(error, _):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .profileValidation(error):
                return [erpErrorCode] + error.erpErrorCodeList
        }
    }
}

extension FHIRClient.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .internalError:
                return "i-52001"
            case .httpError:
                return "i-52002"
            case .operationOutcome:
                return "i-52003"
            case .inconsistentResponse:
                return "i-52004"
            case .decoding:
                return "i-52005"
            case .unknown:
                return "i-52006"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .internalError:
                return [erpErrorCode]
            case let .httpError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case .operationOutcome:
                return [erpErrorCode]
            case let .decoding(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .decoding:
                return [erpErrorCode]
            case let .unknown(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .unknown:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension FileManager.ExcludeFileError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .fileDoesNotExist:
                return "i-50301"
            case .error:
                return "i-50302"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .error:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension HTTPError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .internalError:
                return "i-53001"
            case .httpError:
                return "i-53002"
            case .networkError:
                return "i-53003"
            case .authentication:
                return "i-53004"
            case .vauError:
                return "i-53005"
            case .unknown:
                return "i-53006"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .internalError:
                return [erpErrorCode]
            case .httpError:
                return [erpErrorCode]
            case .networkError:
                return [erpErrorCode]
            case let .authentication(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .authentication:
                return [erpErrorCode]
            case let .vauError(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .vauError:
                return [erpErrorCode]
            case let .unknown(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .unknown:
                return [erpErrorCode]
        }
    }
}

extension IDPError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .network:
                return "i-10001"
            case .validation:
                return "i-10002"
            case .tokenUnavailable:
                return "i-10003"
            case .unspecified:
                return "i-10004"
            case .decoding:
                return "i-10005"
            case .noCertificateFound:
                return "i-10006"
            case .invalidDiscoveryDocument:
                return "i-10007"
            case .invalidStateParameter:
                return "i-10008"
            case .invalidNonce:
                return "i-10009"
            case .unsupported:
                return "i-10010"
            case .encryption:
                return "i-10011"
            case .decryption:
                return "i-10012"
            case .`internal`:
                return "i-10013"
            case .trustStore:
                return "i-10014"
            case .pairing:
                return "i-10015"
            case .invalidSignature:
                return "i-10016"
            case .serverError:
                return "i-10017"
            case .biometrics:
                return "i-10018"
            case .extAuthOriginalRequestMissing:
                return "i-10019"
            case .notAvailableInDemoMode:
                return "i-10020"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .network(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .validation(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .validation:
                return [erpErrorCode]
            case let .unspecified(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .unspecified:
                return [erpErrorCode]
            case let .decoding(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .decoding:
                return [erpErrorCode]
            case .unsupported:
                return [erpErrorCode]
            case let .`internal`(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .trustStore(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .pairing(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .pairing:
                return [erpErrorCode]
            case .invalidSignature:
                return [erpErrorCode]
            case .serverError:
                return [erpErrorCode]
            case let .biometrics(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension IDPError.InternalError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .loadDiscoveryDocumentUnexpectedNil:
                return "i-10101"
            case .requestChallengeUnexpectedNil:
                return "i-10102"
            case .constructingChallengeRequestUrl:
                return "i-10103"
            case .getAndValidateUnexpectedNil:
                return "i-10104"
            case .constructingRefreshWithSSOTokenRequest:
                return "i-10105"
            case .refreshResponseMissingHeaderValue:
                return "i-10106"
            case .challengeExpired:
                return "i-10107"
            case .verifyUnexpectedNil:
                return "i-10108"
            case .verifyResponseMissingHeaderValue:
                return "i-10109"
            case .verifierCodeCreation:
                return "i-10110"
            case .stateNonceCreation:
                return "i-10111"
            case .signedChallengeEncoded:
                return "i-10112"
            case .signedChallengeEncryption:
                return "i-10113"
            case .altVerifyResponseMissingHeaderValue:
                return "i-10114"
            case .encryptedSignedChallengeEncoding:
                return "i-10115"
            case .exchangeUnexpectedNil:
                return "i-10116"
            case .exchangeTokenUnexpectedNil:
                return "i-10117"
            case .ssoLoginAndExchangeUnexpectedNil:
                return "i-10118"
            case .registrationDataEncryption:
                return "i-10119"
            case .keyVerifierEncoding:
                return "i-10120"
            case .encryptedKeyVerifierEncoding:
                return "i-10121"
            case .keyVerifierJweHeaderEncryption:
                return "i-10122"
            case .keyVerifierJwePayloadEncryption:
                return "i-10123"
            case .nestJwtInJwePayloadEncryption:
                return "i-10124"
            case .invalidByteBuffer:
                return "i-10125"
            case .generatingSecureRandom:
                return "i-10126"
            case .registeredDeviceEncoding:
                return "i-10127"
            case .signedAuthenticationDataEncryption:
                return "i-10128"
            case .constructingExtAuthRequestUrl:
                return "i-10129"
            case .refreshTokenUnexpectedNil:
                return "i-10130"
            case .loadDirectoryKKAppsUnexpectedNil:
                return "i-10131"
            case .extAuthVerifyResponseMissingHeaderValue:
                return "i-10132"
            case .extAuthVerifierCodeCreation:
                return "i-10133"
            case .extAuthStateNonceCreation:
                return "i-10134"
            case .extAuthVerifyAndExchangeUnexpectedNil:
                return "i-10135"
            case .extAuthVerifyAndExchangeMissingQueryItem:
                return "i-10136"
            case .extAuthConstructingRedirectUri:
                return "i-10137"
            case .startExtAuthUnexpectedNil:
                return "i-10138"
            case .extAuthVerifyUnexpectedNil:
                return "i-10139"
            case .pairDeviceUnexpectedNil:
                return "i-10140"
            case .unregisterDeviceUnexpectedNil:
                return "i-10141"
            case .listDevicesUnexpectedNil:
                return "i-10142"
            case .altVerifyUnexpectedNil:
                return "i-10143"
            case .notImplemented:
                return "i-10144"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .generatingSecureRandom:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension IDTokenValidatorError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .profileNotFound:
                return "i-02101"
            case .profileNotMatchingInsuranceId:
                return "i-02102"
            case .profileWithInsuranceIdExists:
                return "i-02103"
            case .other:
                return "i-02104"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .profileNotMatchingInsuranceId:
                return [erpErrorCode]
            case .profileWithInsuranceIdExists:
                return [erpErrorCode]
            case let .other(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .other:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension JWE.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .invalidJWE:
                return "i-10301"
            case .encodingError:
                return "i-10302"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension JWT.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .malformedJWT:
                return "i-10401"
            case .noSignature:
                return "i-10402"
            case .encodingError:
                return "i-10403"
            case .invalidSignature:
                return "i-10404"
            case .invalidExpirationDate:
                return "i-10405"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension KeyVerifier.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .stringConversion:
                return "i-10501"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension KeychainAccessHelperError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .illegalArgument:
                return "i-02001"
            case .keyChainError:
                return "i-02002"
            case .decodingError:
                return "i-02003"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .keyChainError:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension LocalStorageBundleParsingError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .parseError:
                return "i-59001"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .parseError:
                return [erpErrorCode]
        }
    }
}

extension LocalStoreError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .notImplemented:
                return "i-20301"
            case .initialization:
                return "i-20302"
            case .write:
                return "i-20303"
            case .delete:
                return "i-20304"
            case .read:
                return "i-20305"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .initialization(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .initialization:
                return [erpErrorCode]
            case let .write(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .write:
                return [erpErrorCode]
            case let .delete(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .delete:
                return [erpErrorCode]
            case let .read(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .read:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension LoginHandlerError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .biometrieFailed:
                return "i-01301"
            case .biometrieFatal:
                return "i-01302"
            case .ssoFailed:
                return "i-01303"
            case .ssoExpired:
                return "i-01304"
            case .idpError:
                return "i-01305"
            case .network:
                return "i-01306"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .idpError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .network(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .network:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension MainDomain.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .localStoreError:
                return "i-01501"
            case .userSessionError:
                return "i-01502"
            case .importDuplicate:
                return "i-01503"
            case .repositoryError:
                return "i-01504"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .localStoreError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .userSessionError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .repositoryError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension MigrationError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .isLatestVersion:
                return "i-50101"
            case .missingProfile:
                return "i-50102"
            case .write:
                return "i-50103"
            case .read:
                return "i-50104"
            case .delete:
                return "i-50105"
            case .unspecified:
                return "i-50106"
            case .initialization:
                return "i-50107"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .write(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .write:
                return [erpErrorCode]
            case let .read(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .read:
                return [erpErrorCode]
            case let .delete(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .delete:
                return [erpErrorCode]
            case let .unspecified(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .unspecified:
                return [erpErrorCode]
            case let .initialization(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .initialization:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension NFCHealthCardPasswordControllerError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .cardError:
                return "i-02601"
            case .openSecureSession:
                return "i-02602"
            case .resetRetryCounter:
                return "i-02603"
            case .wrongCan:
                return "i-02604"
            case .changeReferenceData:
                return "i-02605"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .cardError:
                return [erpErrorCode]
            case let .openSecureSession(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .openSecureSession:
                return [erpErrorCode]
            case let .resetRetryCounter(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .resetRetryCounter:
                return [erpErrorCode]
            case let .changeReferenceData(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .changeReferenceData:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension NFCSignatureProviderError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .cardError:
                return "i-00401"
            case .wrongCAN:
                return "i-00403"
            case .cardConnectionError:
                return "i-00404"
            case .verifyCardError:
                return "i-00405"
            case .signingFailure:
                return "i-00406"
            case .genericError:
                return "i-00408"
            case .cardReadingError:
                return "i-00409"
            case .secureEnclaveError:
                return "i-00410"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .cardError:
                return [erpErrorCode]
            case let .wrongCAN(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .wrongCAN:
                return [erpErrorCode]
            case let .cardConnectionError(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .cardConnectionError:
                return [erpErrorCode]
            case let .verifyCardError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .signingFailure(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .genericError(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .genericError:
                return [erpErrorCode]
            case let .cardReadingError(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .cardReadingError:
                return [erpErrorCode]
            case let .secureEnclaveError(error):
                return [erpErrorCode] + error.erpErrorCodeList
        }
    }
}

extension NFCSignatureProviderError.SigningError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .unsupportedAlgorithm:
                return "i-00501"
            case .responseStatus:
                return "i-00502"
            case .certificate:
                return "i-00503"
            case .missingCertificate:
                return "i-00504"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .responseStatus:
                return [erpErrorCode]
            case let .certificate(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .certificate:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension NFCSignatureProviderError.VerifyPINError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .wrongSecretWarning:
                return "i-00601"
            case .securityStatusNotSatisfied:
                return "i-00602"
            case .memoryFailure:
                return "i-00603"
            case .passwordBlocked:
                return "i-00604"
            case .passwordNotUsable:
                return "i-00605"
            case .passwordNotFound:
                return "i-00606"
            case .unknownFailure:
                return "i-00607"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .wrongSecretWarning:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension PharmacyBundleParsingError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .parseError:
                return "i-51001"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .parseError:
                return [erpErrorCode]
        }
    }
}

extension PharmacyCoreDataStore.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .noMatchingEntity:
                return "i-50501"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension PharmacyFHIRDataSource.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .fhirClient:
                return "i-57001"
            case .notFound:
                return "i-57002"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .fhirClient(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension PharmacyRepositoryError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .local:
                return "i-57101"
            case .remote:
                return "i-57102"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .local(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .remote(error):
                return [erpErrorCode] + error.erpErrorCodeList
        }
    }
}

extension PrescriptionDetailDomain.LoadingImageError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .matrixCodeGenerationFailed:
                return "i-01601"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension PrescriptionRepositoryError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .loginHandler:
                return "i-02701"
            case .erxRepository:
                return "i-02702"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .loginHandler(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .erxRepository(error):
                return [erpErrorCode] + error.erpErrorCodeList
        }
    }
}

extension PrivateKeyContainer.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .keyNotFound:
                return "i-10801"
            case .unknownError:
                return "i-10802"
            case .retrievingPublicKeyFailed:
                return "i-10803"
            case .creationFromBiometrie:
                return "i-10804"
            case .creationWithoutBiometrie:
                return "i-10805"
            case .convertingKey:
                return "i-10806"
            case .signing:
                return "i-10807"
            case .canceledByUser:
                return "i-10808"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .keyNotFound:
                return [erpErrorCode]
            case .unknownError:
                return [erpErrorCode]
            case let .creationFromBiometrie(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .creationFromBiometrie:
                return [erpErrorCode]
            case let .creationWithoutBiometrie(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .creationWithoutBiometrie:
                return [erpErrorCode]
            case let .convertingKey(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .convertingKey:
                return [erpErrorCode]
            case let .signing(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .signing:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension ProfileCoreDataStore.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .noMatchingEntity:
                return "i-50201"
            case .initialization:
                return "i-50202"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .initialization(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .initialization:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension RedeemMatrixCodeDomain.LoadingImageError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .matrixCodeGenerationFailed:
                return "i-02301"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension RedeemServiceError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .eRxRepository:
                return "i-02401"
            case .avs:
                return "i-02402"
            case .internalError:
                return "i-02403"
            case .unspecified:
                return "i-02404"
            case .noTokenAvailable:
                return "i-02405"
            case .loginHandler:
                return "i-02406"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .eRxRepository(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .avs(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .internalError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .unspecified(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .unspecified:
                return [erpErrorCode]
            case let .loginHandler(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension RedeemServiceError.InternalError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .missingAVSEndpoint:
                return "i-02501"
            case .missingAVSCertificate:
                return "i-02502"
            case .missingTelematikId:
                return "i-02503"
            case .conversionVersionNumber:
                return "i-02504"
            case .idMissmatch:
                return "i-02505"
            case .noService:
                return "i-02506"
            case .unexpectedHTTPStatusCode:
                return "i-02507"
            case .localStoreError:
                return "i-02508"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .localStoreError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension RegisteredDevicesDomain.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .generic:
                return "i-01701"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .generic:
                return [erpErrorCode]
        }
    }
}

extension RegisteredDevicesServiceError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .missingAuthentication:
                return "i-01801"
            case .missingToken:
                return "i-01802"
            case .loginHandlerError:
                return "i-01803"
            case .idpError:
                return "i-01804"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .loginHandlerError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .idpError(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension RemoteStorageBundleParsingError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .parseError:
                return "i-58001"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .parseError:
                return [erpErrorCode]
        }
    }
}

extension RemoteStoreError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .fhirClientError:
                return "i-20401"
            case .notImplemented:
                return "i-20402"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .fhirClientError:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension ScannedErxTask.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .format:
                return "i-20501"
            case .invalidID:
                return "i-20502"
            case .invalidAccessCode:
                return "i-20503"
            case .invalidJSON:
                return "i-20504"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .invalidJSON(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .invalidJSON:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension ScannerDomain.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .duplicate:
                return "i-00101"
            case .empty:
                return "i-00102"
            case .invalid:
                return "i-00103"
            case .storeDuplicate:
                return "i-00104"
            case .scannedErxTask:
                return "i-00105"
            case .unknown:
                return "i-00106"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .scannedErxTask(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension SecureEnclaveSignatureProviderError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .fetchingPrivateKey:
                return "i-10901"
            case .signing:
                return "i-10902"
            case .packagingAuthCertificate:
                return "i-10903"
            case .packagingSeCertificate:
                return "i-10904"
            case .gatheringPairingData:
                return "i-10905"
            case .`internal`:
                return "i-10906"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .fetchingPrivateKey(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .fetchingPrivateKey:
                return [erpErrorCode]
            case let .signing(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .signing:
                return [erpErrorCode]
            case let .gatheringPairingData(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .gatheringPairingData:
                return [erpErrorCode]
            case .`internal`:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension SharedTask.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .missingSeparator:
                return "i-20701"
            case .failedDecodingEmptyString:
                return "i-20702"
            case .tooManyComponents:
                return "i-20703"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .missingSeparator:
                return [erpErrorCode]
            case .failedDecodingEmptyString:
                return [erpErrorCode]
            case .tooManyComponents:
                return [erpErrorCode]
        }
    }
}

extension ShipmentInfoCoreDataStore.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .noMatchingEntity:
                return "i-50401"
            case .internalError:
                return "i-50402"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension TokenPayload.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .dataEncoding:
                return "i-10601"
            case .stringConversion:
                return "i-10602"
            case .decryption:
                return "i-10603"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .decryption(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .decryption:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension TrustAnchor.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .invalidPEM:
                return "i-56201"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension TrustStoreError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .network:
                return "i-56001"
            case .noCertificateFound:
                return "i-56002"
            case .invalidOCSPResponse:
                return "i-56003"
            case .eeCertificateOCSPStatusVerification:
                return "i-56004"
            case .unspecified:
                return "i-56005"
            case .`internal`:
                return "i-56006"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .network(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .unspecified(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .unspecified:
                return [erpErrorCode]
            case let .`internal`(error):
                return [erpErrorCode] + error.erpErrorCodeList
            default:
                return [erpErrorCode]
        }
    }
}

extension TrustStoreError.InternalError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .loadOCSPCheckedTrustStoreUnexpectedNil:
                return "i-5611"
            case .loadCertListFromServerUnexpectedNil:
                return "i-5612"
            case .loadOCSPListFromServerUnexpectedNil:
                return "i-5613"
            case .trustStoreCertListUnexpectedNil:
                return "i-5614"
            case .loadOCSPResponsesUnexpectedNil:
                return "i-5615"
            case .missingSignerForEECertificate:
                return "i-5616"
            case .notImplemented:
                return "i-5617"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension UserProfileServiceError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .localStoreError:
                return "i-02201"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .localStoreError(error):
                return [erpErrorCode] + error.erpErrorCodeList
        }
    }
}

extension UserSessionError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .idpError:
                return "i-00801"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .idpError(error):
                return [erpErrorCode] + error.erpErrorCodeList
        }
    }
}

extension UserSessionProviderError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .unavailable:
                return "i-00701"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            default:
                return [erpErrorCode]
        }
    }
}

extension VAUError: CodedError {
    var erpErrorCode: String {
        switch self {
            case .network:
                return "i-55001"
            case .certificateDecoding:
                return "i-55002"
            case .internalCryptoError:
                return "i-55003"
            case .responseValidation:
                return "i-55004"
            case .unspecified:
                return "i-55005"
            case .internalError:
                return "i-55006"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case let .network(error):
                return [erpErrorCode] + error.erpErrorCodeList
            case let .unspecified(error as CodedError):
                return [erpErrorCode] + error.erpErrorCodeList
            case .unspecified:
                return [erpErrorCode]
            case .internalError:
                return [erpErrorCode]
            default:
                return [erpErrorCode]
        }
    }
}

extension ZXDataMatrixWriter.Error: CodedError {
    var erpErrorCode: String {
        switch self {
            case .cgImageConversion:
                return "i-00901"
        }
    }
    var erpErrorCodeList: [String] {
        switch self {
            case .cgImageConversion:
                return [erpErrorCode]
        }
    }
}
