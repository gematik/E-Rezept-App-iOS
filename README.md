# eRezept App

## Introduction

Prescriptions for medicines that are only available in pharmacies can be issued as electronic prescriptions (e-prescriptions resp. E-Rezepte) for people with public health insurance from 1 July 2021. 
The official gematik E-Rezept App (electronic prescription app) is available to receive and redeem prescriptions digitally. Anyone can download the app for free: 

[![Download E-Rezept on the App Store](https://user-images.githubusercontent.com/52454541/126137060-cb8c7ceb-6a72-423d-9079-f3e1a98b2638.png)](https://apps.apple.com/de/app/das-e-rezept/id1511792179)[![Download E-Rezept on the PlayStore](https://user-images.githubusercontent.com/52454541/126138350-a52e1d84-1588-4e8a-86df-189ee4df8bc8.png)](https://play.google.com/store/apps/details?id=de.gematik.ti.erp.app)[![Download E-Rezept on the App Gallery](https://user-images.githubusercontent.com/52454541/126158983-15d73f12-36c6-41ce-8de5-29d10baaed04.png)](https://appgallery.huawei.com/#/app/C104463531)

and login with the health card of the public health insurance. In July 2021, the e-prescription will start with a test phase, initially in the focus region Berlin-Brandenburg. The nationwide rollout will follow three month later in the fourth quarter.

The e-prescriptions are stored in the telematics infrastructure, for which gematik is responsible.

Visit our [FAQ page](https://www.das-e-rezept-fuer-deutschland.de/fragen-antworten) for more information about the e-prescription.

### Support & Feedback

For endusers and insurant:

[![E-Rezept Webseite](https://img.shields.io/badge/web-E%20Rezept%20Webseite-green?logo=web.ru&style=flat-square&logoColor=white)](https://www.das-e-rezept-fuer-deutschland.de/)
[![eMail E-Rezept](https://img.shields.io/badge/email-E%20Rezept%20team-green?logo=mail.ru&style=flat-square&logoColor=white)](mailto:app-feedback@gematik.de)
[![E-Rezept Support Telephone](https://img.shields.io/badge/phone-E%20Rezept%20Service-green?logo=phone.ru&style=flat-square&logoColor=white)](tel:+498002773777)

Members of the health-industrie with functional questions

[![eMail E-Rezept Team](https://img.shields.io/badge/web-E%20Rezept%20Industrie-green?logo=web.ru&style=flat-square&logoColor=white)](https://www.gematik.de/hilfe-kontakt/hersteller/)

IT specialists

[![eMail E-Rezept Fachportal](https://img.shields.io/badge/web-E%20Rezept%20Fachportal-green?logo=web.ru&style=flat-square&logoColor=white)](https://fachportal.gematik.de/anwendungen/elektronisches-rezept)
[![eMail E-Rezept Team](https://img.shields.io/badge/email-E%20Rezept%20team-green?logo=mail.ru&style=flat-square&logoColor=white)](mailto:app-feedback@gematik.de)

### Data Privacy

You can find the privacy policy for the app at: [https://www.das-e-rezept-fuer-deutschland.de/app/datenschutz](https://www.das-e-rezept-fuer-deutschland.de/app/datenschutz)

### Licensing

Copyright 2021-2025 gematik GmbH

EUROPEAN UNION PUBLIC LICENCE v. 1.2

EUPL © the European Union 2007, 2016

See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License

### Additional Notes and Disclaimer from gematik GmbH

1. Copyright notice: Each published work result is accompanied by an explicit statement of the license conditions for use. These are regularly typical conditions in connection with open source or free software. Programs described/provided/linked here are free software, unless otherwise stated.
2. Permission notice: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    1. The copyright notice (Item 1) and the permission notice (Item 2) shall be included in all copies or substantial portions of the Software.
    2. The software is provided "as is" without warranty of any kind, either express or implied, including, but not limited to, the warranties of fitness for a particular purpose, merchantability, and/or non-infringement. The authors or copyright holders shall not be liable in any manner whatsoever for any damages or other claims arising from, out of or in connection with the software or the use or other dealings with the software, whether in an action of contract, tort, or otherwise.
    3. We take open source license compliance very seriously. We are always striving to achieve compliance at all times and to improve our processes. If you find any issues or have any suggestions or comments, or if you see any other ways in which we can improve, please reach out to: ospo@gematik.de
3. Please note: Parts of this code may have been generated using AI-supported technology. Please take this into account, especially when troubleshooting, for security analyses and possible adjustments.

## Development

### Getting started

run `$ make setup` to start developing locally. This will make sure all the dependencies are put in place and the Xcode-project will be generated and/or overwritten.

You'll need a running implementation of `IDP` and `FD`. A reference implementation for [`IDP`](https://github.com/gematik/ref-idp-server) and [`FD`](https://github.com/gematik/ref-eRp-FD-Server) is available.

Documentation for setting up the entire system will be available at a later date.

### Project setup

The Xcode-project is generated using `xcodegen`.
The more complex build configuration(s) is done with the help of Fastlane. See the `./fastlane` directory for full setup.

The App uses Apple's `Combine.framework` for operation scheduling. The UI-Layer is built with [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) ♥️ and `SwiftUI` ♥️.
Minimum platform requirements are: MacOS 11 and iOS 14.0

#### Modularization

The app is composed of several modules:

- `eRpApp` is the iOS front-end (consumer facing) eRezept App.
- `eRpKit` bundles all non platform specific business logic.
- `eRpLocalStorage` and `eRpRemoteStorage` serve as the FHIR communication module to send and request all the eRezept resources and store them locally.
- `Pharmacy` handles communication with the Pharmacy API.
- `FHIRClient` powers `eRpRemoteStorage` and `Pharmacy` by providing a generic FHIR interface (see [FHIR](http://hl7.org/fhir/) for more information about the FHIR standard).
- `HTTPClient` provides the interface for HTTP communication within the project.
- `IDP` is used for authentication against the eHealth network.
- `VAU` provides an encrypted communication channel with the eHealth network.
- `TrustStore` validates trust with a given trust anchor and handles ocsp responses.

You can find more documentation about each module [here](https://gematik.github.io/E-Rezept-App-iOS).

#### Generated Source

We use `sourcery` to generate some data structures. Run `$ sourcery` to update generated code. The compiler will tell you, if you need to update the generated code by running sourcery in most cases. As sourcery is used as a weak (generated code is checked in, CI is not executing sourcery) dependency, you have to install sourcery manually by running `$ brew install sourcery`.

### Build iOS app for release

Run `$ make build`

Note: make sure you've ran `$ make setup` before and have code-signing setup for your local (or ci-build) build.

### Functional Requirements

The underlying requirements can be found within the Gematik [Fachportal](https://fachportal.gematik.de). Search for "E-Rezept Frontend des Versicherten".

A mapping of these requirements can be found within the [documentation](https://gematik.github.io/E-Rezept-App-iOS). To generate the mapping from requirements to implementation run `bundle exec fastlane list_requirements`.

### Links Sourcecode

- [Android and Huawei implementation ![Android Robot](https://user-images.githubusercontent.com/52454541/126164998-befe06c0-d122-4e60-bf91-e2519072a5b4.png)](https://github.com/gematik/E-Rezept-App-Android)
- Reference implementation of the [IDP (**ID**entity **P**rovider)](https://github.com/gematik/ref-idp-server)
- Reference implementation of the [FD (**F**ach**D**ienst)](https://github.com/gematik/ref-eRp-FD-Server)

