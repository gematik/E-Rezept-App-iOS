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

import SwiftUI

/// ``SectionContainer`` variation with a single element. This exists due to generic conformance deciding between
/// `Tuple` and any other `View` implementation.
public struct SingleElementSectionContainer<Header: View, Content: View, Footer: View>: View {
    var content: Content
    var header: () -> Header?
    var footer: () -> Footer?

    public init<SingleElementContent: View>(@ViewBuilder header: @escaping () -> Header? = { nil },
                                            @ViewBuilder footer: @escaping () -> Footer? = { nil },
                                            @ViewBuilder content: @escaping () -> SingleElementContent)
        where Content == ModifiedContent<SingleElementContent, SectionContainerCellModifier> {
        self.header = header
        self.content = content().modifier(SectionContainerCellModifier(last: true))
        self.footer = footer
    }

    public var body: some View {
        SectionContainer(header: header, footer: footer) {
            content
        }
    }
}

extension SingleElementSectionContainer {
    /// ``SectionContainer`` variation with a single element. This exists due to generic conformance deciding between
    /// `Tuple` and any other `View` implementation.
    public init<SingleElement: View>(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping () -> SingleElement
    )
        where Content == ModifiedContent<SingleElement, SectionContainerCellModifier>, Header == EmptyView {
        self.init(header: { nil as EmptyView? }, footer: footer, content: content)
    }

    /// ``SectionContainer`` variation with a single element. This exists due to generic conformance deciding between
    /// `Tuple` and any other `View` implementation.
    public init<SingleElement: View>(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> SingleElement
    )
        where Content == ModifiedContent<SingleElement, SectionContainerCellModifier>, Footer == EmptyView {
        self.init(header: header, footer: { nil as EmptyView? }, content: content)
    }

    /// ``SectionContainer`` variation with a single element. This exists due to generic conformance deciding between
    /// `Tuple` and any other `View` implementation.
    public init<SingleElement: View>(
        @ViewBuilder content: @escaping () -> SingleElement
    )
        where Content == ModifiedContent<SingleElement, SectionContainerCellModifier>, Header == EmptyView,
        Footer == EmptyView {
        self.init(header: { nil as EmptyView? },
                  footer: { nil as EmptyView? },
                  content: content)
    }
}
