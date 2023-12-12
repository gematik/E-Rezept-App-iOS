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

import SwiftUI
import UIKit

struct SmallSheetPresentationController<Content: View>: UIViewRepresentable {
    typealias UIViewType = UIView

    @Binding var isPresented: Bool
    let content: Content
    let onDismiss: () -> Void

    init(
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        _isPresented = isPresented
        self.onDismiss = onDismiss
        self.content = content()
    }

    func makeUIView(context _: Context) -> UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard context.coordinator.presented != isPresented else {
            return
        }
        context.coordinator.presented = isPresented

        if isPresented {
            // Embed content SwiftUI.View
            let hostingController = HeightCalculatingHostingController(rootView: content)

            // Create the UIViewController that will be presented by the UIButton
            let viewController = SmallSheetContainerViewController(
                dismissBackgroundTap: {
                    self.isPresented = false
                    onDismiss()
                },
                contentVC: hostingController
            )

            // Mandatory to apply custom animation
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = context.coordinator

            // Present the viewController
            uiView.window?.rootViewController?.erp_leafPresentedViewController().present(viewController, animated: true)
        } else {
            // Dismiss the viewController
            uiView.window?.rootViewController?.erp_leafPresentedViewController().dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate, UIViewControllerTransitioningDelegate {
        var presented = false

        func animationController(
            forPresented _: UIViewController,
            presenting _: UIViewController,
            source _: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            ShowAnimationController()
        }

        func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            HideAnimationController()
        }
    }

    private class HeightCalculatingHostingController<T: View>: UIHostingController<T> {
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            preferredContentSize = view.intrinsicContentSize
        }
    }

    class HideAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
            0.5
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let view = transitionContext.view(forKey: .from) else { return }
            view.frame = transitionContext.containerView.bounds

            let contextVC = transitionContext.viewController(forKey: .from) as? SmallSheetContainerViewController

            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseInOut]
            ) {
                if let contextVC = contextVC,
                   let height = contextVC.contentSize?.height {
                    view.frame = transitionContext.containerView.bounds.offsetBy(dx: 0, dy: height)
                }
            } completion: { _ in
                transitionContext.completeTransition(true)
            }
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.curveEaseInOut]
            ) {
                transitionContext.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            } completion: { _ in
            }
        }
    }

    class ShowAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
            0.5
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let view = transitionContext.view(forKey: .to) else { return }
            transitionContext.containerView.addSubview(view)

            if let contextVC = transitionContext.viewController(forKey: .to) as? SmallSheetContainerViewController,
               let height = contextVC.contentSize?.height {
                view.frame = transitionContext.containerView.bounds.offsetBy(dx: 0, dy: height)
            }

            transitionContext.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            transitionContext.containerView.isOpaque = false

            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseInOut]
            ) {
                view.frame = transitionContext.containerView.bounds
            } completion: { _ in
                transitionContext.completeTransition(true)
            }

            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.curveEaseInOut]
            ) {
                transitionContext.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            } completion: { _ in
            }
        }
    }
}

extension UIViewController {
    func erp_leafPresentedViewController() -> UIViewController {
        guard let presentedViewController = presentedViewController else {
            return self
        }
        return presentedViewController
    }
}
