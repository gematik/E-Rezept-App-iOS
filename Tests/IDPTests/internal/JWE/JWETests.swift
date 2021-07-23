//
//  Copyright (c) 2021 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import Combine
import DataKit
import Foundation
@testable import IDP
import Nimble
import OpenSSL
import XCTest

import CryptoKit

class JWETests: XCTestCase {
    private let publicKey = try! BrainpoolP256r1.KeyExchange.PublicKey(x962: Data(
        hex: "049650AC6D4D5B1201DE4CFFE99DB3A2396426A377BC95D9DC466727A2574D7C39643159E578F05A6B607E89AFDD5395EEACC8E72714489CAC3160C4BB79AA45C6" // swiftlint:disable:this line_length
    ))

    func testHeaderEncoding() throws {
        let ephemeralPublic = try BrainpoolP256r1.KeyExchange
            .PublicKey(
                x962: Data(
                    hex: "044178088a425736b88f3a6ab2b7f7e6238c34b1a52c56ce41f53aa61b5f4d98e134bfa20462a67538b5aa530e717f615d0993cfc44ea79619f5d118110edf9241"
                )
            )

        let jwk = try! JWK.from(brainpoolP256r1: ephemeralPublic)
        let encryptioContext = JWE.EncryptionContext(symmetricKey: SymmetricKey(data: Data()), ephemeralPublicKey: jwk)
        let header = JWE.Header(encryptionContext: encryptioContext,
                                alg: "ECDH-ES",
                                encryption: JWE.Encryption.a256gcm,
                                contentType: "JWT")

        let encodedHeader = try JSONEncoder().encode(header)
        let encodedHeaderBase64 = encodedHeader.base64EncodedData().utf8string!

        let expectedHeaderBase64 =
            "eyJlbmMiOiJBMjU2R0NNIiwiZXBrIjp7InkiOiJOTC1pQkdLbWRUaTFxbE1PY1g5aFhRbVR6OFJPcDVZWjlkRVlFUTdma2tFIiwieCI6IlFYZ0lpa0pYTnJpUE9tcXl0X2ZtSTR3MHNhVXNWczVCOVRxbUcxOU5tT0UiLCJrdHkiOiJFQyIsImNydiI6IkJQLTI1NiJ9LCJjdHkiOiJKV1QiLCJhbGciOiJFQ0RILUVTIn0="

        XCTAssertEqual(encodedHeaderBase64, expectedHeaderBase64)
    }

    func testPremadeJWE() throws {
        let publicKey = try! BrainpoolP256r1.KeyExchange.PublicKey(x962: Data(
            hex: "0440ba49fcba45c7eeb2261b1be0ebc7c14d6484b9ef8a23b060ebe67f97252bbc987ba49df364a0c9926f2b6de1baf46068a13a2c5c9812b2f3451f48b75719ee" // swiftlint:disable:this line_length
        ))

        let ephemeralPrivate = try BrainpoolP256r1.KeyExchange
            .PrivateKey(raw: Data(hex: "a1746e2e69305e90bce385965f82069be49ac9afe190e69f951cb214a8cb9475"))
        let ephemeralPublic = try BrainpoolP256r1.KeyExchange
            .PublicKey(
                x962: Data(
                    hex: "044178088a425736b88f3a6ab2b7f7e6238c34b1a52c56ce41f53aa61b5f4d98e134bfa20462a67538b5aa530e717f615d0993cfc44ea79619f5d118110edf9241"
                )
            )

        let iv = try "OX_3DCbccZztqyLd".decodeBase64URLEncoded()

        let payload =
            "eyJhbGciOiJCUDI1NlIxIiwidHlwIjoiSldUIiwiY3R5IjoiTkpXVCIsIng1YyI6WyJNSUlDK2pDQ0FxQ2dBd0lCQWdJSEF3QVRhbGRmVlRBS0JnZ3Foa2pPUFFRREFqQ0JsakVMTUFrR0ExVUVCaE1DUkVVeEh6QWRCZ05WQkFvTUZtZGxiV0YwYVdzZ1IyMWlTQ0JPVDFRdFZrRk1TVVF4UlRCREJnTlZCQXNNUEVWc1pXdDBjbTl1YVhOamFHVWdSMlZ6ZFc1a2FHVnBkSE5yWVhKMFpTMURRU0JrWlhJZ1ZHVnNaVzFoZEdscmFXNW1jbUZ6ZEhKMWEzUjFjakVmTUIwR0ExVUVBd3dXUjBWTkxrVkhTeTFEUVRFd0lGUkZVMVF0VDA1TVdUQWVGdzB4T1RBME1EZ3lNakF3TURCYUZ3MHlOREEwTURneU1UVTVOVGxhTUgweEN6QUpCZ05WQkFZVEFrUkZNUkV3RHdZRFZRUUtEQWhCVDBzZ1VHeDFjekVTTUJBR0ExVUVDd3dKTVRBNU5UQXdPVFk1TVJNd0VRWURWUVFMREFwWU1URTBOREk0TlRNd01RNHdEQVlEVlFRRURBVkdkV05vY3pFTk1Bc0dBMVVFS2d3RVNuVnVZVEVUTUJFR0ExVUVBd3dLU25WdVlTQkdkV05vY3pCYU1CUUdCeXFHU000OUFnRUdDU3NrQXdNQ0NBRUJCd05DQUFSMU5kcnJJOG9LTWl2MHh0VVhGNW9zUzd6YkZJS3hHdC9Cd2lzdWtXb0VLNUdzSjFjQ3lHRXBDSDBzczhKdkQ0T0FISlM4SU1tMS9yTTU5amxpUysxT280SHZNSUhzTUIwR0ExVWREZ1FXQkJTY0VaNUgxVXhTTWhQc09jV1poRzhaUWVXaHZUQU1CZ05WSFJNQkFmOEVBakFBTURBR0JTc2tDQU1EQkNjd0pUQWpNQ0V3SHpBZE1CQU1EbFpsY25OcFkyaGxjblJsTHkxeU1Ba0dCeXFDRkFCTUJERXdId1lEVlIwakJCZ3dGb0FVUkxGTUFWaFVIdHpaTjc3a3NqOHFicVJjaVIwd0lBWURWUjBnQkJrd0Z6QUtCZ2dxZ2hRQVRBU0JJekFKQmdjcWdoUUFUQVJHTUE0R0ExVWREd0VCL3dRRUF3SUhnREE0QmdnckJnRUZCUWNCQVFRc01Db3dLQVlJS3dZQkJRVUhNQUdHSEdoMGRIQTZMeTlsYUdOaExtZGxiV0YwYVdzdVpHVXZiMk56Y0M4d0NnWUlLb1pJemowRUF3SURTQUF3UlFJaEFJUEljYkdqSlF4dVVHYkptQlVpbVd2YlVpN20rU3VYWUJjUkdGeVowaklKQWlBbTFJV0lmdi9nTmMvV213NFpPKzczMFE5QzVkY2NGbk1qbXZiSmU3aTc1Zz09Il19.eyJuand0IjoiZXlKaGJHY2lPaUpDVURJMU5sSXhJaXdpZEhsd0lqb2lTbGRVSWl3aWEybGtJam9pY0hWclgybGtjRjl6YVdjaWZRLmV5SnBjM01pT2lKb2RIUndjem92TDJsa2NDNTZaVzUwY21Gc0xtbGtjQzV6Y0d4cGRHUnVjeTUwYVMxa2FXVnVjM1JsTG1SbElpd2ljbVZ6Y0c5dWMyVmZkSGx3WlNJNkltTnZaR1VpTENKemJtTWlPaUp4UTFSbWJVb3dOWGhSU1RWVWMzWnJVV3RKVkV3eFpsSnlVVVJoZG5oQ1ZsUjNWVzFPTUhCQ1FYUjNJaXdpWTI5a1pWOWphR0ZzYkdWdVoyVmZiV1YwYUc5a0lqb2lVekkxTmlJc0luUnZhMlZ1WDNSNWNHVWlPaUpqYUdGc2JHVnVaMlVpTENKdWIyNWpaU0k2SW1sbFFtczRhMUJsVEdad01tSTJjMEZaVGxKaklpd2lZMnhwWlc1MFgybGtJam9pWlZKbGVtVndkRUZ3Y0NJc0luTmpiM0JsSWpvaWIzQmxibWxrSUdVdGNtVjZaWEIwSWl3aWMzUmhkR1VpT2lKbVNVbDJlbW8zZVZadlpGb3diekZNWVRVeFZDSXNJbkpsWkdseVpXTjBYM1Z5YVNJNkltaDBkSEE2THk5eVpXUnBjbVZqZEM1blpXMWhkR2xyTG1SbEwyVnlaWHBsY0hRaUxDSmxlSEFpT2pFMk1UWTBNVFkzTmpZc0ltbGhkQ0k2TVRZeE5qUXhOalU0Tml3aVkyOWtaVjlqYUdGc2JHVnVaMlVpT2lJeU9HUkhNWFJKVG13eU1GaERjWGxMYkhWRGVWSmxlWGRMWVVRd09UVnBlRjlEWWpCSFQzZDVlbVpqSWl3aWFuUnBJam9pWXpVeU5UYzNOMlkyWmpkaE16UTBNeUo5LmpaUzc2V09NeEIwT0swd29QelFNcWp3Zm9FWk1FcEY1MVBhelFscFhpa0NuZW9kUHZKQVNmdkQ4ODhYRkhuVVY3bVFFQkZrZ056N25NMjhkQ0NYeHdBIn0.IbbCIWFrKpE0L25c8Q-X7h2cr_njnNNKSY_RBSbw9k536p0GE2dDwIDdaNHpduX-T_TXy40DeaewLHtnaTTChg"
            .data(using: .utf8)!

        let expectedJWE =
            "eyJlbmMiOiJBMjU2R0NNIiwiZXBrIjp7InkiOiJOTC1pQkdLbWRUaTFxbE1PY1g5aFhRbVR6OFJPcDVZWjlkRVlFUTdma2tFIiwieCI6IlFYZ0lpa0pYTnJpUE9tcXl0X2ZtSTR3MHNhVXNWczVCOVRxbUcxOU5tT0UiLCJrdHkiOiJFQyIsImNydiI6IkJQLTI1NiJ9LCJjdHkiOiJKV1QiLCJhbGciOiJFQ0RILUVTIn0..OX_3DCbccZztqyLd.f9nzQOA6JmZTAN-bRmuHCs_9zdcpmqfPXyJcNWEaFryFwFFhMdEt1Wwkftcy_H6HmxIQUFdYZbJjvSZwo-7umibRKBKcWVfYhnVMEZkz_a__amaQAfsZnNXcU-8FBBZwJe2q83jSofBSTF53zWc6d03INbINZ8lqpfdbu-V6dzAUIUvd7eLT8_n3QtmZX430Rma8PAYJ_qy_UCz9ifXpch7x8Lbq3nYksigUhM2dFXnQxUagvvWpP11pR1Fn2fmcikAgEf3UMji8a0fCRpn4diHFGwko2uty3UDnnG6Ljl37WKYWVyOZmoM5TC5NzupaAkA78V0GarjwsEWlQSWWkYZ2J0H0y-LcQAQwGW57d2liD92w25tc1_IxcO3gxofDrCRqAnj-xuGU8-TjAESBPSofthGFx3w4uWU4bkXB64aId223EmUUHHz2FEuZZ2QMkitZTumhDEGJY0Y_-uhTXR8uxQf26VPTYITqU2zszJd48U6qib9zPdbKDAbYRo-Pfj-Id8awDEj0uvHtBaDlSXQKP6COdGJucX3SdimRuilf30GgFT7Zr6Up7Kac1l8Hg8se7qniZ1M0e890Fc3cZpf3dhv5Qz3DULrsiKrYn6EUo-fPIUXr7NQ1rVuUmhegQNmmBl6kBg1xMDi4p1iuIvYfeWtATCaKuD1IU3OhyvVgvKod8nA6OUh8IDSc1KQh_eJDWkGW2GHzX2zb9Wmi_HJrg9dSHCO2fm_LNchHABHF0DfnufFeKqxShNlQp7hbTutcsMGGWVIcM9ns7iyV07VP20LKQ18X-mFUSGO3om3w0WByghFH6UBlNAsBy9fCboSCUdTTlBiCD3BIa5ZGEr3dHVbcn55yziwkL_4Og6UrDACOM23RMAZr-qz4W8zYr3qGE892i2WJXJMz2-TAd4jOAs_9A2oS8qitLsd3zTYheXSCI_aZrbfsfy5bpiNKSC-wijICe7mgPvDbbwHlnXH6Av1FrdKzn9EkAaYaxWWkl1DStUI5QIUTO6CzjCRTnk5YklkUwHzj_7dO-jcn84Wsr8GCXoU4WaXlMHRTNqYtHbIfhDgRyW7v5zzQKTOgKbCU16gY1sX9bgVgVCIvWxDOpLmhOWnvGy0Pa9gBI7aYSnE9uVoCy3nO3be8FAAph86oKhULzCqBh7-FwzX1NcXCCcqRLdowJGnyuQlf55imkb7eVCvphvMjhAYNJqiVHJ6zfGhaCkq7FD_pLwmKKFSsnWy_0FtA6Nn4op1IBg9UJ6JHAbJQmZsvDfFO7jrOmeCDHfToHb3OCYBBv02Hyz6JOPdYH0AbfqB6JlU8NAo8k0CxK385iZCf8vuTuhv8gLa6Ry-koSG4dWNl-zkxdcdWGg59c9-QPY7EOqDPHNSmNPMDUPlx0bIxWjk_utuFRE7E4c0QnuDIc-9TfC3eySYHTa6CrFkcIj4dvEUi2BxAvJunqNa2sxDWUt62jIHR5CeIuSdOltUNsndo9GKKuqq5sA3lEqrZP6LOnHQxW6qCEVNtDtYBL01mxScEGLEQFklliPSIPODO5EtL7Lf-B-q7XQUUeMY4Ot4Ukq3UhmYxaU1qDwLob8bmT0zjPiCqUtZDOf_IZOLVmwcu_HGA9jV7dkVwNPk4DRMFWakMKNTgqA5HeAZ_jaFHwHbxrqsqcfrmDFTFHtv_zFrA17S5NGOL4b8ge06P4h5Xx-VAwu6Jtn_Uo80bz_5ffwcGfosUJqOSyL1td_xoqGz9l4HJxByaxRBBUBirNgbBnvpaL6KGZICzvFx1CLKy2_aCWFfm29cB8BmLzD1jZe2QPIuCE6KG6XpugYiLyHqcaLxBmbCzi5w_xiKbSzSZ0BJ7XROBTzIvaliAdA_aKymH6DlaL6rVfoHQ2_bMksOX1CLyWDtl6Q9cw6muTnkbMNQoE5hAXuc9cetdVUsxpjAe2TTDJS_pJ3jD9SaQLu-km0mWleB_W_Q9wtfFx114gD6tNTLZzSNsudD-s9hAoDZUQygDhv7DY7ajHgKQmQnmVsXLvsMO3X11rZOiWAI775f0YGQqWlQpBTrJDxLgHcgPR6hFZ8hBwjRZ9mkiP9oHW5OwvCunE4FWrZ10qt6KBZREY9TFewrrOH3YXv3uD8uvecUZysOGZHOoJIX8MS5Fu9OuIN6oUk-GH-JaHC0KznK9UqMhLC2cq2DjHy1abrKds8Km7TxrK9hprjDtJBTgq9TCPWkshh-npsEVKgapSLC-MeObpfjpeP5yNlmHe9c39hRCRSC_bUJuqB34G3Ouf18Eioo5tW9IsWcR4Uh6_9uNFogmPG4jR_rGNkpFVaJPx2hHuMJ2GDTO3NeqfUMSPJ_uOewn8u8ZaE6xvmubt5Wa5s80IpZj-BxXnvoDj4TKW9Ba-H52cPdV_ciWDsLsS0k59cVQNQ0lkvpxRjcSgRgq4MHMJF0vpc5qEg3lZikCmIUZBmcehJjFjB0Uzmi6cVD9IRJuu7ZYbQVMhjr-l8UwXv2u2WrURtJEYnBEwNmOwoMc4j1N8NIb7WSZkOE33Fw9zrBSEFFeW7Rj_-x76nbbaCqZAPB6RBf3jC_J2Bveq0MBx3OdVwY-vvsKu7iQrdLRfLB-YhXtOFbx9oWHSBl1QC1X-6Z0pvt2BBOUnqldTlf-0Ro8SaZAyxJ0iYe577R14esQAP6W2fP_M6awKJAVUCNU8WxEfkbH2OLfbYRxjwewSToTzvVZIKLR_B3gLuDfFc2I0-ONVEq63JIbKlwWIye7hGe3HWUZ-802GFAx3GtThA_5Pe3AoIXaIoVzJA4ozJ5HQ7i4lBXNyCwdx-DmMh2e2t2pa6mV5YeTr7mh5DUw_kB4okp0rwvQ33aN69An83QQFTzcmon13fRiVVBvmKceO6TyikVfZkYuT4gB3l45CWzLKSElPtwg3uIRkEq7ujqT0NbbEnWVZ544BCaANyLN-8gTeE8ZDiiQAU9dsCx54vpFoSQatHVZfS2cZv4Hiy7reR-Ub7x-dJ5mLIx1GHBAByxYJxlEcx-dpg24AaJsbD-qeFd5Pytf8V3lG0e2oby-73jCocoY-SdL_z5KBeZdqUTsZJkY3Q9RSuFnvYkSGGZup5tDG1_o_P1QNKzH_HKsV0YOkEOiaitnHUAKW-VC0BWsR8eaml_tecYXOfu94h_uR0ghEDkcazUb8y0Ci1mblvIZKRR6VuE9bSX9iUMa4-LpQ70WAG5sgTeR1m5uhz6msgO2UuQWaNUf_Ko05RoHXZbil7JaMD8s3X0IL9hNEQJHMp2bFOqzkHwtgk6jmjAXJORduex4fFvzZh4sIhmCdsCcC5JOWxAfEkAfapbs0MCba1-hvl5IdrK9oW-Gx-Rn4a8-uXkZc25xO_GUebEqMjnryY_Z5sfa-9YXCwj_QClauF-wk2dGQ2xA4DLLiLNeMQMh9RcbuEIln8JNQlO8DfEhfqlgNSGAuA.XlbwIN6EJUheoQgxuiMHUQ"

        // passt der public key zum private key?
        XCTAssert(ephemeralPublic.rawValue == ephemeralPrivate.publicKey.rawValue)

        let header = try! JWE.Header(algorithm: JWE.Algorithm
                                        .ecdh_es(.bpp256r1(publicKey,
                                                           keyPairGenerator: { ephemeralPrivate })),
                                     encryption: .a256gcm,
                                     contentType: "JWT")

        let sut = try JWE(header: header, payload: payload, nonceGenerator: { iv })

        let completeJWE = sut.encoded().utf8string!

        XCTAssertEqual(completeJWE, expectedJWE)
    }

    func testAESDecryption() throws {
        let symmetricKeyData = try "QnJVVzdQb0hKR1NhTnlEZG5PcThVQzRkZTMwRmtNcUg".decodeBase64URLEncoded()
        let symmetricKey = SymmetricKey(data: symmetricKeyData)

        let rawJwe =
            "eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIiwiZXhwIjoxNjE1OTk1NDA4LCJjdHkiOiJKV1QifQ..tt0I7Bu86fI31FEr.Wfu9akmOSjeWnHGcsM_IonufXa0B1_3DupDl1TKqXU4uMhnnkf5OwWd6gx0sxaWF66fiA39qawSQfx2eERSbGIJo9QtKw9O0EfrnZ9Yx3oI-iFeg4QBWm13ZJjKn2DP7wxaea4sxcdiS-7e6ueHF5H5mnwXynOH5d8qkhrDw5xTu6w-EwOBbF0de_z--X4XteJnCJ4dK_MACWkyUT80MACXCDWFpbo_yY2pAlbR2UpcpKFVxrGolJGF81pKxIjs1K8Jf6S_t3RX7-0uGuz-V1hOx-aWzaibSmZcXWA8gERqHpb0fvyVkDBRodJ1l3944ZgOtoF_2ukpFi0q8-MHmGc5Ae5vcXMFmsZV8c3302WxbPKkZnMaWgdmmkgfEjnU3Ctgqv7FJAR5HrWNDFdijQS0BWUQNQXhTbn6ybJWMvYpMIpDE-MXwkiKwVw0NluL-nji405wXc9JAz3rklQN2DXh0MljxWt28QdwmYGCfU5-ojlyyXG8Di8ezwX7iYFFPgd6RDvhdFVzhN_t3sRrwVd6jXMzCnwOA8IXWFQqhR5Nskd9Gu6VhPjbhY3z9_u6OburIOCNfefAhJFJ-bKzgF03FPogPfXkWjbIlmvHxv8vnd0oYBQEqR7R3UP3A_6S0_yQoBEvYYXAWfqb84UTXxAjrYUOKp8G19h1hWZ8GEo39XvLlw44IVYmxwLvNiVHKwW60Q0IjgqDwfAWsOa-Rb6w_RyOZ_H7HnqZroI8fLVfjrqEVsHKyxgtCggGo4tsToJcJLXiENmRCs8v_RGbzITtzDEF3ZQAqKhfYfoci3wpIjxX6yPt_JsUCACJRAvQBauYoCYRVWTN3J64CWfTgzYHUOGma25bSkO9yXBo-o35niWWA8H6sdbsGpGihnk0c0ze8vquoms2WFPZwnfH9Q4XyeKz_SZr2aVZoxAmxtWLMewlOZYTn0MvitHqdkdgM5R9aiIqWs6Y1JRxxenQdGdOn-d7Vx6IZOwyB5kqxgLFTj85sYe3Q7Fc8YzGXFQA1JknMrQqGRiUoOWN9kz3YQaPa-vFEXhuXtQPPA-LnU42ZlF0bGnFlM9RO9G5QjvEH-zw27qrjCtZsC_cRzCl2xX5oA97mmw.f7UVreVx4R-biuFJpfhnoQ"
            .data(using: .utf8)!

        let jwe = try JWE.from(rawJwe, with: .plain(symmetricKey))

        let expectedNJWT =
            "eyJhbGciOiJCUDI1NlIxIiwidHlwIjoiYXQrSldUIiwia2lkIjoiaWRwU2lnIn0.eyJzdWIiOiJQTXFYTHR0RGV3bWVGU0Qybkhndm9iNGVXYWhtZl9FTFE3bGJZTWF6eEE4IiwicHJvZmVzc2lvbk9JRCI6IjEuMi4yNzYuMC43Ni40LjQ5Iiwib3JnYW5pemF0aW9uTmFtZSI6ImdlbWF0aWsgTXVzdGVya2Fzc2UxR0tWTk9ULVZBTElEIiwiaWROdW1tZXIiOiJYNTEwNTU0MjUxIiwiYW1yIjpbIm1mYSIsInNjIiwicGluIl0sImlzcyI6Imh0dHBzOi8vaWRwLnplbnRyYWwuaWRwLnNwbGl0ZG5zLnRpLWRpZW5zdGUuZGUiLCJnaXZlbl9uYW1lIjoiTWFpa2UiLCJjbGllbnRfaWQiOiJlUmV6ZXB0QXBwIiwiYXVkIjoiaHR0cHM6Ly9lcnAudGVsZW1hdGlrLmRlL2xvZ2luIiwiYWNyIjoiZ2VtYXRpay1laGVhbHRoLWxvYS1oaWdoIiwiYXpwIjoiZVJlemVwdEFwcCIsInNjb3BlIjoicGFpcmluZyBvcGVuaWQiLCJhdXRoX3RpbWUiOjE2MTU5OTUxMDgsImV4cCI6MTYxNTk5NTQwOCwiZmFtaWx5X25hbWUiOiJMYXVzw6luIiwiaWF0IjoxNjE1OTk1MTA4LCJqdGkiOiJiOGI1M2UyNDI1OWQ1NzcwIn0.QtA3HmSNs2qgkh1FOo1PaVjJjfWm2lMWF9f0pKHZxUyij2gXTjiGYh7-6bdXKGiWc2N39atRy5SWeGowLDAzAg"
            .data(using: .utf8)!

        XCTAssertEqual(jwe.payload, expectedNJWT)
    }
}
