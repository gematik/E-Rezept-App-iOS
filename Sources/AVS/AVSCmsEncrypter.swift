//
//  Copyright (c) 2023 gematik GmbH
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

import Foundation
import OpenSSL

protocol AVSCmsEncrypter {
    func cmsEncrypt(_ data: Data, recipients: [X509]) throws -> Data
}

class RsaOnlyAVSCmsEncrypter: AVSCmsEncrypter {
    func cmsEncrypt(_ data: Data, recipients: [X509]) throws -> Data {
        let cms = try CMSContentInfo.encryptPartial(data: data)
        try cms.addRecipientsRSAOnly(recipients)
        try cms.final(data: data)
        guard let bytes = cms.derBytes else {
            throw AVSError.InternalError.cmsContentCreation
        }
        return bytes
    }
}
