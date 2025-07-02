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

import Combine
@testable import eRpFeatures
@testable import IDP
import Nimble
import TestUtils
import XCTest

final class KeychainStorageTests: XCTestCase {
    // swiftlint:disable line_length
    let jwt =
        "eyJhbGciOiJCUDI1NlIxIiwia2lkIjoiZGlzY1NpZyIsIng1YyI6WyJNSUlDc1RDQ0FsaWdBd0lCQWdJSEFic3NxUWhxT3pBS0JnZ3Foa2pPUFFRREFqQ0JoREVMTUFrR0ExVUVCaE1DUkVVeEh6QWRCZ05WQkFvTUZtZGxiV0YwYVdzZ1IyMWlTQ0JPVDFRdFZrRk1TVVF4TWpBd0JnTlZCQXNNS1V0dmJYQnZibVZ1ZEdWdUxVTkJJR1JsY2lCVVpXeGxiV0YwYVd0cGJtWnlZWE4wY25WcmRIVnlNU0F3SGdZRFZRUUREQmRIUlUwdVMwOU5VQzFEUVRFd0lGUkZVMVF0VDA1TVdUQWVGdzB5TVRBeE1UVXdNREF3TURCYUZ3MHlOakF4TVRVeU16VTVOVGxhTUVreEN6QUpCZ05WQkFZVEFrUkZNU1l3SkFZRFZRUUtEQjFuWlcxaGRHbHJJRlJGVTFRdFQwNU1XU0F0SUU1UFZDMVdRVXhKUkRFU01CQUdBMVVFQXd3SlNVUlFJRk5wWnlBek1Gb3dGQVlIS29aSXpqMENBUVlKS3lRREF3SUlBUUVIQTBJQUJJWVpud2lHQW41UVlPeDQzWjhNd2FaTEQzci9iejZCVGNRTzVwYmV1bTZxUXpZRDVkRENjcml3L1ZOUFBaQ1F6WFFQZzRTdFd5eTVPT3E5VG9nQkVtT2pnZTB3Z2Vvd0RnWURWUjBQQVFIL0JBUURBZ2VBTUMwR0JTc2tDQU1EQkNRd0lqQWdNQjR3SERBYU1Bd01Da2xFVUMxRWFXVnVjM1F3Q2dZSUtvSVVBRXdFZ2dRd0lRWURWUjBnQkJvd0dEQUtCZ2dxZ2hRQVRBU0JTekFLQmdncWdoUUFUQVNCSXpBZkJnTlZIU01FR0RBV2dCUW84UGptcWNoM3pFTkYyNXF1MXpxRHJBNFBxREE0QmdnckJnRUZCUWNCQVFRc01Db3dLQVlJS3dZQkJRVUhNQUdHSEdoMGRIQTZMeTlsYUdOaExtZGxiV0YwYVdzdVpHVXZiMk56Y0M4d0hRWURWUjBPQkJZRUZDOTRNOUxnVzQ0bE5nb0Fia1Bhb21uTGpTOC9NQXdHQTFVZEV3RUIvd1FDTUFBd0NnWUlLb1pJemowRUF3SURSd0F3UkFJZ0NnNHlaRFdteUJpcmd4emF3ei9TOERKblJGS3RZVS9ZR05sUmM3K2tCSGNDSUJ1emJhM0dzcHFTbW9QMVZ3TWVOTktOYUxzZ1Y4dk1iREpiMzBhcWFpWDEiXX0K.eyJhdXRob3JpemF0aW9uX2VuZHBvaW50IjoiaHR0cDovL2xvY2FsaG9zdDo4ODg4L3NpZ25fcmVzcG9uc2UiLCJhdXRoX3BhaXJfZW5kcG9pbnQiOiJodHRwOi8vbG9jYWxob3N0Ojg4ODgvYWx0X3Jlc3BvbnNlIiwic3NvX2VuZHBvaW50IjoiaHR0cDovL2xvY2FsaG9zdDo4ODg4L3Nzb19yZXNwb25zZSIsInVyaV9wYWlyIjoiaHR0cDovL2xvY2FsaG9zdDo4ODg4L3BhaXJpbmdzIiwidG9rZW5fZW5kcG9pbnQiOiJodHRwOi8vbG9jYWxob3N0Ojg4ODgvdG9rZW4iLCJ1cmlfZGlzYyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODg4OC9kaXNjb3ZlcnlEb2N1bWVudCIsImlzc3VlciI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODg4OCIsImp3a3NfdXJpIjoiaHR0cDovL2xvY2FsaG9zdDo4ODg4L2p3a3MiLCJleHAiOjE2MTYxNDM4NzYsImlhdCI6MTYxNjA1NzQ3NiwidXJpX3B1a19pZHBfZW5jIjoiaHR0cDovL2xvY2FsaG9zdDo4ODg4L2lkcEVuYy9qd2suanNvbiIsInVyaV9wdWtfaWRwX3NpZyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODg4OC9pcGRTaWcvandrLmpzb24iLCJra19hcHBfbGlzdF91cmkiOiJodHRwOi8vbG9jYWxob3N0Ojg4ODgvYXBwTGlzdCIsInRoaXJkX3BhcnR5X2F1dGhvcml6YXRpb25fZW5kcG9pbnQiOiJodHRwOi8vbG9jYWxob3N0Ojg4ODgvdGhpcmRQYXJ0eUF1dGgiLCJzdWJqZWN0X3R5cGVzX3N1cHBvcnRlZCI6WyJwYWlyd2lzZSJdLCJpZF90b2tlbl9zaWduaW5nX2FsZ192YWx1ZXNfc3VwcG9ydGVkIjpbIkJQMjU2UjEiXSwicmVzcG9uc2VfdHlwZXNfc3VwcG9ydGVkIjpbImNvZGUiXSwic2NvcGVzX3N1cHBvcnRlZCI6WyJvcGVuaWQiLCJlLXJlemVwdCJdLCJyZXNwb25zZV9tb2Rlc19zdXBwb3J0ZWQiOlsicXVlcnkiXSwiZ3JhbnRfdHlwZXNfc3VwcG9ydGVkIjpbImF1dGhvcml6YXRpb25fY29kZSJdLCJhY3JfdmFsdWVzX3N1cHBvcnRlZCI6WyJnZW1hdGlrLWVoZWFsdGgtbG9hLWhpZ2giXSwidG9rZW5fZW5kcG9pbnRfYXV0aF9tZXRob2RzX3N1cHBvcnRlZCI6WyJub25lIl0sImNvZGVfY2hhbGxlbmdlX21ldGhvZHNfc3VwcG9ydGVkIjpbIlMyNTYiXX0K.kzREKDmjMY7eBWnyjJegij4srFcIOzHyeQs_CAz4A4pzobMlTDC9QNN0S1y-b4ETx6OChyp_OuFCC_4g4clobQ"
    let serialized = Data(
        base64Encoded: "YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICVRyb290gAGsCwwbHB0eHyAhIiYsVSRudWxs0w0ODxAVGldOUy5rZXlzWk5TLm9iamVjdHNWJGNsYXNzpBESExSAAoADgASABaQWFxgZgAaAB4AIgAmAC1lwdWtfdG9rZW5XcGF5bG9hZF8QE2VuY3J5cHRpb25QdWJsaWNLZXlZY3JlYXRlZE9uTxECtTCCArEwggJYoAMCAQICBwOtSOQAlI0wCgYIKoZIzj0EAwIwgYQxCzAJBgNVBAYTAkRFMR8wHQYDVQQKDBZnZW1hdGlrIEdtYkggTk9ULVZBTElEMTIwMAYDVQQLDClLb21wb25lbnRlbi1DQSBkZXIgVGVsZW1hdGlraW5mcmFzdHJ1a3R1cjEgMB4GA1UEAwwXR0VNLktPTVAtQ0ExMCBURVNULU9OTFkwHhcNMjAwODA0MDAwMDAwWhcNMjUwODA0MjM1OTU5WjBJMQswCQYDVQQGEwJERTEmMCQGA1UECgwdZ2VtYXRpayBURVNULU9OTFkgLSBOT1QtVkFMSUQxEjAQBgNVBAMMCUlEUCBTaWcgMTBaMBQGByqGSM49AgEGCSskAwMCCAEBBwNCAASWUKxtTVsSAd5M/+mds6I5ZCajd7yV2dxGZyeiV018OWQxWeV48FprYH6Jr91Tle6syOcnFEicrDFgxLt5qkXGo4HtMIHqMB0GA1UdDgQWBBSfA1SwGVk/gZaI0w+DE/zWvhEvGDA4BggrBgEFBQcBAQQsMCowKAYIKwYBBQUHMAGGHGh0dHA6Ly9laGNhLmdlbWF0aWsuZGUvb2NzcC8wDAYDVR0TAQH/BAIwADAhBgNVHSAEGjAYMAoGCCqCFABMBIFLMAoGCCqCFABMBIEjMB8GA1UdIwQYMBaAFCjw+OapyHfMQ0Xbmq7XOoOsDg+oMC0GBSskCAMDBCQwIjAgMB4wHDAaMAwMCklEUC1EaWVuc3QwCgYIKoIUAEwEggQwDgYDVR0PAQH/BAQDAgeAMAoGCCqGSM49BAMCA0cAMEQCIFQT4QMMl/BwFR9DtG9/lWs6QQFpEDY5BFUZL/hGF9XvAiBXZ+Dvp4rzPl1YvcYiiuHVtUezA99+DqTj0xY3hISFVV8RCvBleUpoYkdjaU9pSkNVREkxTmxJeElpd2lhMmxrSWpvaVpHbHpZMU5wWnlJc0luZzFZeUk2V3lKTlNVbERjMVJEUTBGc2FXZEJkMGxDUVdkSlNFRmljM054VVdoeFQzcEJTMEpuWjNGb2EycFBVRkZSUkVGcVEwSm9SRVZNVFVGclIwRXhWVVZDYUUxRFVrVlZlRWg2UVdSQ1owNVdRa0Z2VFVadFpHeGlWMFl3WVZkeloxSXlNV2xUUTBKUFZERlJkRlpyUmsxVFZWRjRUV3BCZDBKblRsWkNRWE5OUzFWMGRtSllRblppYlZaMVpFZFdkVXhWVGtKSlIxSnNZMmxDVlZwWGVHeGlWMFl3WVZkMGNHSnRXbmxaV0U0d1kyNVdjbVJJVm5sTlUwRjNTR2RaUkZaUlVVUkVRbVJJVWxVd2RWTXdPVTVWUXpGRVVWUkZkMGxHVWtaVk1WRjBWREExVFZkVVFXVkdkekI1VFZSQmVFMVVWWGROUkVGM1RVUkNZVVozTUhsT2FrRjRUVlJWZVUxNlZUVk9WR3hoVFVWcmVFTjZRVXBDWjA1V1FrRlpWRUZyVWtaTlUxbDNTa0ZaUkZaUlVVdEVRakZ1V2xjeGFHUkhiSEpKUmxKR1ZURlJkRlF3TlUxWFUwRjBTVVUxVUZaRE1WZFJWWGhLVWtSRlUwMUNRVWRCTVZWRlFYZDNTbE5WVWxGSlJrNXdXbmxCZWsxR2IzZEdRVmxJUzI5YVNYcHFNRU5CVVZsS1MzbFJSRUYzU1VsQlVVVklRVEJKUVVKSldWcHVkMmxIUVc0MVVWbFBlRFF6V2poTmQyRmFURVF6Y2k5aWVqWkNWR05SVHpWd1ltVjFiVFp4VVhwWlJEVmtSRU5qY21sM0wxWk9VRkJhUTFGNldGRlFaelJUZEZkNWVUVlBUM0U1Vkc5blFrVnRUMnBuWlRCM1oyVnZkMFJuV1VSV1VqQlFRVkZJTDBKQlVVUkJaMlZCVFVNd1IwSlRjMnREUVUxRVFrTlJkMGxxUVdkTlFqUjNTRVJCWVUxQmQwMURhMnhGVlVNeFJXRlhWblZqTTFGM1EyZFpTVXR2U1ZWQlJYZEZaMmRSZDBsUldVUldVakJuUWtKdmQwZEVRVXRDWjJkeFoyaFJRVlJCVTBKVGVrRkxRbWRuY1dkb1VVRlVRVk5DU1hwQlprSm5UbFpJVTAxRlIwUkJWMmRDVVc4NFVHcHRjV05vTTNwRlRrWXlOWEYxTVhweFJISkJORkJ4UkVFMFFtZG5ja0puUlVaQ1VXTkNRVkZSYzAxRGIzZExRVmxKUzNkWlFrSlJWVWhOUVVkSFNFZG9NR1JJUVRaTWVUbHNZVWRPYUV4dFpHeGlWMFl3WVZkemRWcEhWWFppTWs1NlkwTTRkMGhSV1VSV1VqQlBRa0paUlVaRE9UUk5PVXhuVnpRMGJFNW5iMEZpYTFCaGIyMXVUR3BUT0M5TlFYZEhRVEZWWkVWM1JVSXZkMUZEVFVGQmQwTm5XVWxMYjFwSmVtb3dSVUYzU1VSU2QwRjNVa0ZKWjBObk5IbGFSRmR0ZVVKcGNtZDRlbUYzZWk5VE9FUktibEpHUzNSWlZTOVpSMDVzVW1NM0sydENTR05EU1VKMWVtSmhNMGR6Y0hGVGJXOVFNVlozVFdWT1RrdE9ZVXh6WjFZNGRrMWlSRXBpTXpCaGNXRnBXREVpWFgwSy5leUpoZFhSb2IzSnBlbUYwYVc5dVgyVnVaSEJ2YVc1MElqb2lhSFIwY0RvdkwyeHZZMkZzYUc5emREbzRPRGc0TDNOcFoyNWZjbVZ6Y0c5dWMyVWlMQ0poZFhSb1gzQmhhWEpmWlc1a2NHOXBiblFpT2lKb2RIUndPaTh2Ykc5allXeG9iM04wT2pnNE9EZ3ZZV3gwWDNKbGMzQnZibk5sSWl3aWMzTnZYMlZ1WkhCdmFXNTBJam9pYUhSMGNEb3ZMMnh2WTJGc2FHOXpkRG80T0RnNEwzTnpiMTl5WlhOd2IyNXpaU0lzSW5WeWFWOXdZV2x5SWpvaWFIUjBjRG92TDJ4dlkyRnNhRzl6ZERvNE9EZzRMM0JoYVhKcGJtZHpJaXdpZEc5clpXNWZaVzVrY0c5cGJuUWlPaUpvZEhSd09pOHZiRzlqWVd4b2IzTjBPamc0T0RndmRHOXJaVzRpTENKMWNtbGZaR2x6WXlJNkltaDBkSEE2THk5c2IyTmhiR2h2YzNRNk9EZzRPQzlrYVhOamIzWmxjbmxFYjJOMWJXVnVkQ0lzSW1semMzVmxjaUk2SW1oMGRIQTZMeTlzYjJOaGJHaHZjM1E2T0RnNE9DSXNJbXAzYTNOZmRYSnBJam9pYUhSMGNEb3ZMMnh2WTJGc2FHOXpkRG80T0RnNEwycDNhM01pTENKbGVIQWlPakUyTVRZeE5ETTROellzSW1saGRDSTZNVFl4TmpBMU56UTNOaXdpZFhKcFgzQjFhMTlwWkhCZlpXNWpJam9pYUhSMGNEb3ZMMnh2WTJGc2FHOXpkRG80T0RnNEwybGtjRVZ1WXk5cWQyc3Vhbk52YmlJc0luVnlhVjl3ZFd0ZmFXUndYM05wWnlJNkltaDBkSEE2THk5c2IyTmhiR2h2YzNRNk9EZzRPQzlwY0dSVGFXY3ZhbmRyTG1wemIyNGlMQ0pyYTE5aGNIQmZiR2x6ZEY5MWNta2lPaUpvZEhSd09pOHZiRzlqWVd4b2IzTjBPamc0T0RndllYQndUR2x6ZENJc0luUm9hWEprWDNCaGNuUjVYMkYxZEdodmNtbDZZWFJwYjI1ZlpXNWtjRzlwYm5RaU9pSm9kSFJ3T2k4dmJHOWpZV3hvYjNOME9qZzRPRGd2ZEdocGNtUlFZWEowZVVGMWRHZ2lMQ0p6ZFdKcVpXTjBYM1I1Y0dWelgzTjFjSEJ2Y25SbFpDSTZXeUp3WVdseWQybHpaU0pkTENKcFpGOTBiMnRsYmw5emFXZHVhVzVuWDJGc1oxOTJZV3gxWlhOZmMzVndjRzl5ZEdWa0lqcGJJa0pRTWpVMlVqRWlYU3dpY21WemNHOXVjMlZmZEhsd1pYTmZjM1Z3Y0c5eWRHVmtJanBiSW1OdlpHVWlYU3dpYzJOdmNHVnpYM04xY0hCdmNuUmxaQ0k2V3lKdmNHVnVhV1FpTENKbExYSmxlbVZ3ZENKZExDSnlaWE53YjI1elpWOXRiMlJsYzE5emRYQndiM0owWldRaU9sc2ljWFZsY25raVhTd2laM0poYm5SZmRIbHdaWE5mYzNWd2NHOXlkR1ZrSWpwYkltRjFkR2h2Y21sNllYUnBiMjVmWTI5a1pTSmRMQ0poWTNKZmRtRnNkV1Z6WDNOMWNIQnZjblJsWkNJNld5Sm5aVzFoZEdsckxXVm9aV0ZzZEdndGJHOWhMV2hwWjJnaVhTd2lkRzlyWlc1ZlpXNWtjRzlwYm5SZllYVjBhRjl0WlhSb2IyUnpYM04xY0hCdmNuUmxaQ0k2V3lKdWIyNWxJbDBzSW1OdlpHVmZZMmhoYkd4bGJtZGxYMjFsZEdodlpITmZjM1Z3Y0c5eWRHVmtJanBiSWxNeU5UWWlYWDBLLmt6UkVLRG1qTVk3ZUJXbnlqSmVnaWo0c3JGY0lPekh5ZVFzX0NBejRBNHB6b2JNbFREQzlRTk4wUzF5LWI0RVR4Nk9DaHlwX091RkNDXzRnNGNsb2JRTxBBBJZQrG1NWxIB3kz/6Z2zojlkJqN3vJXZ3EZnJ6JXTXw5ZDFZ5XjwWmtgfomv3VOV7qzI5ycUSJysMWDEu3mqRcbSIw8kJVdOUy50aW1lI0HChyPAAAAAgArSJygpKlokY2xhc3NuYW1lWCRjbGFzc2VzVk5TRGF0ZaIpK1hOU09iamVjdNInKC0uXxATTlNNdXRhYmxlRGljdGlvbmFyeaMvMCtfEBNOU011dGFibGVEaWN0aW9uYXJ5XE5TRGljdGlvbmFyeQAIABEAGgAkACkAMgA3AEkATABRAFMAYABmAG0AdQCAAIcAjACOAJAAkgCUAJkAmwCdAJ8AoQCjAK0AtQDLANUDjg6CDsYOyw7TDtwO3g7jDu4O9w7+DwEPCg8PDyUPKQ8/AAAAAAAAAgEAAAAAAAAAMQAAAAAAAAAAAAAAAAAAD0w="
    )!

    var jwk: JWK {
        let jwkData = Data(
            base64Encoded: "ewogICAgIng1YyI6IFsKICAgICAgICAiTUlJQ3NUQ0NBbGlnQXdJQkFnSUhBNjFJNUFDVWpUQUtCZ2dxaGtqT1BRUURBakNCaERFTE1Ba0dBMVVFQmhNQ1JFVXhIekFkQmdOVkJBb01GbWRsYldGMGFXc2dSMjFpU0NCT1QxUXRWa0ZNU1VReE1qQXdCZ05WQkFzTUtVdHZiWEJ2Ym1WdWRHVnVMVU5CSUdSbGNpQlVaV3hsYldGMGFXdHBibVp5WVhOMGNuVnJkSFZ5TVNBd0hnWURWUVFEREJkSFJVMHVTMDlOVUMxRFFURXdJRlJGVTFRdFQwNU1XVEFlRncweU1EQTRNRFF3TURBd01EQmFGdzB5TlRBNE1EUXlNelU1TlRsYU1Fa3hDekFKQmdOVkJBWVRBa1JGTVNZd0pBWURWUVFLREIxblpXMWhkR2xySUZSRlUxUXRUMDVNV1NBdElFNVBWQzFXUVV4SlJERVNNQkFHQTFVRUF3d0pTVVJRSUZOcFp5QXhNRm93RkFZSEtvWkl6ajBDQVFZSkt5UURBd0lJQVFFSEEwSUFCSlpRckcxTld4SUIza3ovNloyem9qbGtKcU4zdkpYWjNFWm5KNkpYVFh3NVpERlo1WGp3V210Z2ZvbXYzVk9WN3F6STV5Y1VTSnlzTVdERXUzbXFSY2FqZ2Uwd2dlb3dIUVlEVlIwT0JCWUVGSjhEVkxBWldUK0Jsb2pURDRNVC9OYStFUzhZTURnR0NDc0dBUVVGQndFQkJDd3dLakFvQmdnckJnRUZCUWN3QVlZY2FIUjBjRG92TDJWb1kyRXVaMlZ0WVhScGF5NWtaUzl2WTNOd0x6QU1CZ05WSFJNQkFmOEVBakFBTUNFR0ExVWRJQVFhTUJnd0NnWUlLb0lVQUV3RWdVc3dDZ1lJS29JVUFFd0VnU013SHdZRFZSMGpCQmd3Rm9BVUtQRDQ1cW5JZDh4RFJkdWFydGM2ZzZ3T0Q2Z3dMUVlGS3lRSUF3TUVKREFpTUNBd0hqQWNNQm93REF3S1NVUlFMVVJwWlc1emREQUtCZ2dxZ2hRQVRBU0NCREFPQmdOVkhROEJBZjhFQkFNQ0I0QXdDZ1lJS29aSXpqMEVBd0lEUndBd1JBSWdWQlBoQXd5WDhIQVZIME8wYjMrVmF6cEJBV2tRTmprRVZSa3YrRVlYMWU4Q0lGZG40TytuaXZNK1hWaTl4aUtLNGRXMVI3TUQzMzRPcE9QVEZqZUVoSVZWIgogICAgXSwKICAgICJraWQiOiAiaWRwU2lnIiwKICAgICJrdHkiOiAiRUMiLAogICAgImNydiI6ICJCUC0yNTYiLAogICAgIngiOiAiQUpaUXJHMU5XeElCM2t6LzZaMnpvamxrSnFOM3ZKWFozRVpuSjZKWFRYdzUiLAogICAgInkiOiAiWkRGWjVYandXbXRnZm9tdjNWT1Y3cXpJNXljVVNKeXNNV0RFdTNtcVJjWT0iCn0="
        )!
        return try! JSONDecoder().decode(JWK.self, from: jwkData)
    }

    // swiftlint:enable line_length
    lazy var testDocument: DiscoveryDocument = {
        try! DiscoveryDocument(
            jwt: JWT(from: jwt),
            encryptPuks: jwk,
            signingPuks: jwk,
            createdOn: Date(timeIntervalSince1970: 1_600_000_000)
        )
    }()

    func testDiscoveryDocumentStorage() throws {
        let keychainHelperMock = MockKeychainAccessHelper()
        keychainHelperMock.setGenericPasswordForServiceReturnValue = true
        let sut = KeychainStorage(profileId: UUID())
        sut.keychainHelper = keychainHelperMock

        sut.set(discovery: testDocument)

        expect(keychainHelperMock.setGenericPasswordForServiceCalled).to(beTrue())
        guard let (password, _, _) = keychainHelperMock.setGenericPasswordForServiceReceivedArguments else {
            fail()
            return
        }

        expect(password) == serialized
    }

    func testRetrieveDiscoveryDocumentStorage() throws {
        let keychainHelperMock = MockKeychainAccessHelper()
        let sut = KeychainStorage(profileId: UUID())
        sut.keychainHelper = keychainHelperMock

        keychainHelperMock.genericPasswordForOfServiceReturnValue = serialized

        sut.discoveryDocument.first().test(expectations: { receivedDocument in
            // swiftlint:disable:previous trailing_closure
            expect(receivedDocument) == self.testDocument
        })
    }

    func testCANStorage() {
        let keychainHelperMock = MockKeychainAccessHelper()
        keychainHelperMock.setGenericPasswordForServiceReturnValue = true
        let sut = KeychainStorage(profileId: UUID())
        sut.keychainHelper = keychainHelperMock

        sut.set(can: "123456")

        expect(keychainHelperMock.setGenericPasswordForServiceCalled).to(beTrue())
        guard let (password, _, _) = keychainHelperMock.setGenericPasswordForServiceReceivedArguments else {
            fail()
            return
        }

        expect(String(data: password, encoding: .utf8)).to(equal("123456"))
    }

    func testCANRetrieval() {
        let keychainHelperMock = MockKeychainAccessHelper()
        let sut = KeychainStorage(profileId: UUID())
        sut.keychainHelper = keychainHelperMock

        keychainHelperMock.genericPasswordForOfServiceReturnValue = "123456".data(using: .utf8)

        sut.can.first().test(expectations: { can in
            // swiftlint:disable:previous trailing_closure
            expect(can).to(equal("123456"))
        })
    }

    func testCANRetrievalOnAnotherSet() {
        let keychainHelperMock = MockKeychainAccessHelper()
        let sut = KeychainStorage(profileId: UUID())
        sut.keychainHelper = keychainHelperMock
        keychainHelperMock.setGenericPasswordForServiceReturnValue = true

        keychainHelperMock.genericPasswordForOfServiceReturnValue = "123456".data(using: .utf8)

        var firedEvents = 0

        let expectation = XCTestExpectation(description: "lala")

        let cancellable = sut.can.sink { can in
            firedEvents += 1
            expect(can).to(equal("123456"))

            if firedEvents == 2 {
                expectation.fulfill()
            }
        }
        expect(firedEvents).to(equal(1))

        sut.set(can: "123456")

        expect(firedEvents).to(equal(2))

        wait(for: [expectation], timeout: 5)

        cancellable.cancel()
    }

    func testTokenRetrievalOnAnotherSet() throws {
        let keychainHelperMock = MockKeychainAccessHelper()
        keychainHelperMock.setGenericPasswordForServiceReturnValue = true
        let sut = KeychainStorage(profileId: UUID())
        sut.keychainHelper = keychainHelperMock

        var receivedTokens: [IDPToken?] = []
        let cancellable = sut.token.sink { idpToken in
            receivedTokens.append(idpToken)
        }

        let inputToken = IDPToken(accessToken: "accessToken", expires: Date(), idToken: "idToken", redirect: "redirect")
        let tokenData = try JSONEncoder().encode(inputToken)
        keychainHelperMock.genericPasswordForOfServiceReturnValue = tokenData

        expect(keychainHelperMock.setGenericPasswordForServiceCalled) == false
        sut.set(token: inputToken)
        expect(keychainHelperMock.setGenericPasswordForServiceCalled) == true

        expect(receivedTokens.count).toEventually(equal(2), timeout: .seconds(5))
        expect(receivedTokens[0]).to(beNil())
        expect(receivedTokens[1]).to(equal(inputToken))

        cancellable.cancel()
    }

    func testKeyIdentifierRetrievalOnAnotherSet() throws {
        let keychainHelperMock = MockKeychainAccessHelper()
        keychainHelperMock.setGenericPasswordForServiceReturnValue = true
        let sut = KeychainStorage(profileId: UUID())
        sut.keychainHelper = keychainHelperMock

        var receivedKeys: [Data?] = []
        let cancellable = sut.keyIdentifier.sink { keyIdentifier in
            receivedKeys.append(keyIdentifier)
        }

        let expected = "123456".data(using: .utf8)
        keychainHelperMock.genericPasswordForOfServiceReturnValue = expected

        expect(keychainHelperMock.setGenericPasswordForServiceCalled) == false
        sut.set(keyIdentifier: expected)
        expect(keychainHelperMock.setGenericPasswordForServiceCalled) == true

        expect(receivedKeys.count).toEventually(equal(2), timeout: .seconds(5))
        expect(receivedKeys[0]).to(beNil())
        expect(receivedKeys[1]).to(equal(expected))

        cancellable.cancel()
    }
}
