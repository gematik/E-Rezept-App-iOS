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

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import SwiftUI

extension View {
    /// Presents a toast on the view.
    /// - Parameters:
    ///   - isPresented: Binding to the presentation state. Dependend on the kind of the toast, this will be called by
    ///   the toast to dismiss the toast.
    ///   - toast: The toast to show
    /// - Returns: The modified view.
    @ViewBuilder public func toast(isPresented: Binding<Bool>, toast: Toast?) -> some View {
        overlay {
            ToastContainerView(isPresented: isPresented.animation(.easeInOut), toast: toast)
        }
    }

    /// Presents a toast on the view.
    /// - Parameters:
    ///   - isPresented: Binding to the presentation state. Dependend on the kind of the toast, this will be called by
    ///   the toast to dismiss the toast.
    ///   - toast: The toast to show
    /// - Returns: The modified view.
    @ViewBuilder public func toast(toast: Binding<Toast?>) -> some View {
        overlay {
            ToastContainerView(
                isPresented: .init(
                    get: {
                        toast.wrappedValue != nil
                    },
                    set: { value in
                        if !value {
                            toast.wrappedValue = nil
                        }
                    }
                )
                .animation(.easeInOut),
                toast: toast.wrappedValue
            )
        }
    }
}

/// Structure describing a toast
public struct Toast {
    /// Initializes a toast with a given style.
    /// - Parameter uuid: A uuid for the toast for identification.
    /// - Parameter style: The style to use for the toast.
    public init(uuid: UUID = UUID(), style: Toast.Style) {
        self.uuid = uuid
        self.style = style
    }

    let uuid: UUID
    /// The style for the toast.
    public let style: Style

    /// Describes a toast style
    public enum Style {
        /// A simple toast style to display a simple message that will be dismissed after a given time.
        case simple(LocalizedStringKey, Int, Bundle)
        /// A more complex toast style to display a message and a description that will be dismissed after a given time.
        case twoLines(LocalizedStringKey, LocalizedStringKey, Int, Bundle)
        /// A action based toast that must be dismissed by user interaction.
        case action(LocalizedStringKey, Text, Bundle, () -> Void)

        var duration: Int? {
            switch self {
            case let .simple(_, duration, _),
                 let .twoLines(_, _, duration, _):
                return duration
            case .action:
                return nil
            }
        }
    }
}

public struct ToastContainerView: View {
    public init(isPresented: Binding<Bool>, toast: Toast? = nil) {
        _isPresented = isPresented
        self.toast = toast
    }

    @Binding var isPresented: Bool

    let toast: Toast?

    public var body: some View {
        VStack {
            Spacer()

            ZStack {
                if isPresented {
                    ZStack(alignment: .trailing) {
                        switch toast?.style {
                        case let .simple(text, _, bundle):
                            Text(text, bundle: bundle)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        case let .twoLines(upper, lower, _, bundle):
                            VStack {
                                Text(upper, bundle: bundle)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                Text(lower, bundle: bundle)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        case let .action(text, buttonTitle, bundle, action):
                            VStack(alignment: .trailing) {
                                Text(text, bundle: bundle)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Button {
                                    action()
                                } label: {
                                    buttonTitle
                                }
                            }
                        case .none:
                            EmptyView()
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity).animation(.bouncy))
                    .id(toast?.uuid)
                    .padding()
                    .background(Colors.systemGray3)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
                    .padding()
                    .colorScheme(.dark) // ??
                    .task(id: toast?.uuid) {
                        if let duration = toast?.style.duration {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        if toast?.style.duration == nil {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct Toast_PreviewProvider: PreviewProvider {
    struct Preview: View {
        @State var toast: Toast?

        var body: some View {
            VStack {
                Spacer()

                Button {
                    toast = Toast(style: .simple("5 seconds test", 5, .module))
                } label: {
                    Text("Show Simple")
                }
                Button {
                    toast = Toast(style: .twoLines("upper", "5 seconds test", 5, .module))
                } label: {
                    Text("Show Two Lines")
                }
                Button {
                    toast = Toast(style: .action("Toast with actions", Text("button title"), .module) {
                        self.toast = nil
                    })
                } label: {
                    Text("Show Buttons")
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                withAnimation(.easeInOut) {
                    toast = Toast(style: .simple("5 seconds test", 2, .module))
                }
            }
            .toast(
                isPresented: Binding<Bool>(
                    get: {
                        self.toast != nil
                    },
                    set: { newValue in
                        if !newValue {
                            toast = nil
                        }
                    }
                ),
                toast: toast
            )
        }
    }

    static var previews: some View {
        Preview()
    }
}
