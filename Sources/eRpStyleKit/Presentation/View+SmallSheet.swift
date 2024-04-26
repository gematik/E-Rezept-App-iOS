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

import SwiftUI

extension View {
    /// Presents a sheet when a binding to a Boolean value that you provide is true. The size of the sheet is
    /// dynamically updated. If you use view component without intrinsic content size (such as `NavigationView` or
    /// `List`), you need to add a `.frame(height:)` modifier to your displayed content.
    public func smallSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(
            SmallSheetPresentationControllerModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        )
    }

    /// Presents a sheet when a binding to an item value that you provide is set. The size of the sheet is
    /// dynamically updated. If you use view component without intrinsic content size (such as `NavigationView` or
    /// `List`), you need to add a `.frame(height:)` modifier to your displayed content.
    public func smallSheet<Item, Content: View>(
        _ item: Binding<Item?>,
        @ViewBuilder content: (Item) -> Content
    ) -> some View {
        modifier(
            SmallSheetPresentationControllerModifier(
                isPresented: Binding(get: {
                    item.wrappedValue != nil
                }, set: { value in
                    if !value {
                        item.wrappedValue = nil
                    }
                }),
                onDismiss: {
                    item.wrappedValue = nil
                },
                content: {
                    if let item = item.wrappedValue {
                        content(item)
                    } else {
                        EmptyView()
                    }
                }
            )
        )
    }
}

struct SmallSheetPresentationControllerModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: SheetContent
    let onDismiss: () -> Void

    init(
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: () -> SheetContent
    ) {
        _isPresented = isPresented
        self.onDismiss = onDismiss
        sheetContent = content()
    }

    func body(content: Content) -> some View {
        content
            .background(
                SmallSheetPresentationController(isPresented: $isPresented, onDismiss: onDismiss) { sheetContent }
            )
    }
}

struct SmallSheet_Preview: PreviewProvider {
    private struct Preview: View {
        @State var visible = false
        var body: some View {
            VStack {
                Text("Must be in play mode to view interaction")

                Button {
                    visible.toggle()
                } label: {
                    Text("Show/Hide")
                }
            }
            .smallSheet(
                isPresented: $visible,
                onDismiss: {
                    // Do something on dimissal
                },
                content: {
                    VStack {
                        Text("SmallSheet, dismiss by pressing the button slide or flick downwards.")

                        Button(action: {
                            visible.toggle()
                        }, label: {
                            Text("Toggle")
                        })
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(Colors.systemBackground.ignoresSafeArea())
                }
            )
        }
    }

    static var previews: some View {
        Preview()
    }
}
