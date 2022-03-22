//
//  Copyright (c) 2022 gematik GmbH
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
// swiftlint:disable large_tuple missing_docs operator_usage_whitespace file_length no_extension_access_modifier

import SwiftUI

public
extension SectionContainer where Header == EmptyView {
    init<Content0: View, Content1: View>(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: footer, content: content)
    }

    init<Content0: View, Content1: View, Content2: View>(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: footer, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View>(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: footer, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View>(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: footer, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View, Content5: View>(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: footer, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View, Content5: View,
        Content6: View>(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: footer, content: content)
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View
    >(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: footer, content: content)
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View
    >(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>,
            ModifiedContent<Content8, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: footer, content: content)
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View,
        Content9: View
    >(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8,
                          Content9)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>,
            ModifiedContent<Content8, SectionContainerCellModifier>,
            ModifiedContent<Content9, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: footer, content: content)
    }
}

public
extension SectionContainer where Footer == EmptyView {
    init<Content0: View, Content1: View>(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>
        )> {
        self.init(header: header, footer: { nil as EmptyView? }, content: content)
    }

    init<Content0: View, Content1: View, Content2: View>(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>
        )> {
        self.init(header: header, footer: { nil as EmptyView? }, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View>(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>
        )> {
        self.init(header: header, footer: { nil as EmptyView? }, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View>(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>
        )> {
        self.init(header: header, footer: { nil as EmptyView? }, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View, Content5: View>(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>
        )> {
        self.init(header: header, footer: { nil as EmptyView? }, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View, Content5: View,
        Content6: View>(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>
        )> {
        self.init(header: header, footer: { nil as EmptyView? }, content: content)
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View
    >(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>
        )> {
        self.init(header: header, footer: { nil as EmptyView? }, content: content)
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View
    >(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>,
            ModifiedContent<Content8, SectionContainerCellModifier>
        )> {
        self.init(header: header, footer: { nil as EmptyView? }, content: content)
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View,
        Content9: View
    >(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8,
                          Content9)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>,
            ModifiedContent<Content8, SectionContainerCellModifier>,
            ModifiedContent<Content9, SectionContainerCellModifier>
        )> {
        self.init(header: header, footer: { nil as EmptyView? }, content: content)
    }
}

public
extension SectionContainer where Header == EmptyView, Footer == EmptyView {
    init<Content0: View, Content1: View>(
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: { nil as EmptyView? }, content: content)
    }

    init<Content0: View, Content1: View, Content2: View>(
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: { nil as EmptyView? }, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View>(
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: { nil as EmptyView? }, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View>(
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: { nil as EmptyView? }, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View, Content5: View>(
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: { nil as EmptyView? }, content: content)
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View, Content5: View,
        Content6: View>(
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: { nil as EmptyView? }, content: content)
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View
    >(
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: { nil as EmptyView? }, content: content)
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View
    >(
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>,
            ModifiedContent<Content8, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: { nil as EmptyView? }, content: content)
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View,
        Content9: View
    >(
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8,
                          Content9)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>,
            ModifiedContent<Content8, SectionContainerCellModifier>,
            ModifiedContent<Content9, SectionContainerCellModifier>
        )> {
        self.init(header: { nil as EmptyView? }, footer: { nil as EmptyView? }, content: content)
    }
}
