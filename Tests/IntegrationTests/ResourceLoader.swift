// swiftlint:disable:this file_name
//
//  Copyright (c) 2024 gematik GmbH
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

extension Bundle {
    /**
        Get the filePath for a resource in a bundle.

        - Parameters:
            - bundle: Name of the bundle packaged with this App/Framework Bundle
            - filename: The filename of the resource in the bundle

        - Returns: Absolute filePath to the Resources in the bundle
     */
    func resourceFilePath(in bundle: String, for filename: String) -> String {
        let bundlePath = self.bundlePath
        #if os(macOS)
        let resourceFilePath = "file://\(bundlePath)/Resources/\(bundle).bundle/\(filename)"
        #else
        let resourceFilePath = "file://\(bundlePath)/\(bundle).bundle/\(filename)"
        #endif
        return resourceFilePath
    }

    /**
        Get the filePath for a test resource in a bundle.

        - Parameters:
            - bundle: Name of the bundle packaged with this Test Bundle
            - filename: The filename of the resource in the bundle

        - Returns: Absolute filePath to the Resources in the bundle
     */
    func testResourceFilePath(in bundle: String, for filename: String) -> String {
        let bundlePath = self.bundlePath
        #if os(macOS)
        let resourceFilePath = "file://\(bundlePath)/Contents/Resources/\(bundle).bundle/\(filename)"
        #else
        let resourceFilePath = "file://\(bundlePath)/\(bundle).bundle/\(filename)"
        #endif
        return resourceFilePath
    }
}

extension URL {
    /**
        Convenience function for Data(contentsOf: URL)

        - Throws: An error in the Cocoa domain, if `url` cannot be read.

        - Returns: Data with contents of the (local) File
     */
    func readFileContents() throws -> Data {
        try Data(contentsOf: self)
    }
}

extension String {
    /// File reading/handling error cases
    enum FileReaderError: Error {
        /// Indicate the URL was not pointing to a valid Resource
        case invalidURL(String)
        /// Indicate there was no such file at specified path
        case noSuchFileAtPath(String)
    }

    /**
     Read the contents of a local file at path `self`.

        - Throws: FileReaderError when File not exists | An error in the Cocoa domain, if `url` cannot be read.

        - Returns: Data with contents of the File at path `self`
     */
    func readFileContents() throws -> Data {
        let mUrl: URL = asURL
        guard FileManager.default.fileExists(atPath: mUrl.path) else {
            throw FileReaderError.noSuchFileAtPath(self)
        }
        return try mUrl.readFileContents()
    }

    /// Returns path as URL
    var asURL: URL {
        if hasPrefix("/") {
            return URL(fileURLWithPath: self)
        }
        if let url = URL(string: self) {
            return url
        } else {
            return URL(fileURLWithPath: self)
        }
    }
}
