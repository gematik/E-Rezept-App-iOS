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

import UIKit

class SmallSheetContainerViewController: UIViewController {
    let dismiss: () -> Void
    weak var bottomAnchor: NSLayoutConstraint?
    weak var heightAnchor: NSLayoutConstraint?

    // Retained by ViewController hierarchy
    weak var contentViewController: UIViewController?

    init(dismissBackgroundTap: @escaping () -> Void, contentVC: UIViewController) {
        dismiss = dismissBackgroundTap
        contentViewController = contentVC

        super.init(nibName: nil, bundle: nil)

        addChild(contentVC)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        dismiss = {}

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    private static let upwardsDragDampening = 0.8
    private static let dismissVelocityThreshold = CGFloat(100)

    @objc
    func panGesture(_ gesture: UIPanGestureRecognizer) {
        guard let bottomAnchor = bottomAnchor else {
            return
        }

        let translation = gesture.translation(in: view).y

        switch gesture.state {
        case .began:
            animateLayoutChanges = false
        case .changed:
            let translation: CGFloat = {
                if translation < 0 {
                    return -pow(abs(translation), Self.upwardsDragDampening)
                } else {
                    return translation + (view.window?.safeAreaInsets.bottom ?? 0)
                }
            }()
            bottomAnchor
                .constant = -keyboardHeight + translation - (view.window?.safeAreaInsets.bottom ?? 0)
        case .ended:
            animateLayoutChanges = true
            // Flick downwards
            if gesture.velocity(in: view).y > Self.dismissVelocityThreshold {
                dismiss()
                // Slow pan downwards more than half
            } else if let height = heightAnchor?.constant,
                      translation > abs(height) * 0.5 {
                dismiss()
            } else {
                resetPan()
            }
        case .cancelled, .failed:
            animateLayoutChanges = true
        case .possible:
            break
        @unknown default:
            break
        }
    }

    private func resetPan() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.beginFromCurrentState, .curveEaseOut],
                       animations: {
                           self.bottomAnchor?.constant = -self.keyboardHeight
                           self.view.layoutIfNeeded()
                       }, completion: { _ in
                       })
    }

    var fillingFooter = UIView()

    override func loadView() {
        // Use UIControl to enable background tap for dismissal
        let view = UIControl()
        view.addTarget(self, action: #selector(Self.backgroundTapped), for: .touchUpInside)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGestureRecognizer)

        if let contentViewController = contentViewController {
            view.addSubview(fillingFooter)
            view.addSubview(contentViewController.view)

            contentViewController.view.layer.cornerRadius = 16
            contentViewController.view.layer.cornerCurve = .continuous
            contentViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            contentViewController.view.clipsToBounds = true
            contentViewController.view.backgroundColor = UIColor.clear

            // Set constraints
            contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
            contentViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            contentViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

            // Without this height anchor the HostingController is a bit too big
            heightAnchor = contentViewController.view.heightAnchor
                .constraint(equalToConstant: contentViewController.preferredContentSize.height)
            heightAnchor?.isActive = true

            // remember the bottom anchor to adjust for keyboard safe area insets
            bottomAnchor = contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            bottomAnchor?.isActive = true

            fillingFooter.translatesAutoresizingMaskIntoConstraints = false
            fillingFooter.backgroundColor = contentViewController.view.subviews.first?
                .backgroundColor ?? .systemBackground
            contentViewController.view.bottomAnchor.constraint(equalTo: fillingFooter.topAnchor).isActive = true
            contentViewController.view.widthAnchor.constraint(equalTo: fillingFooter.widthAnchor).isActive = true
            fillingFooter.heightAnchor.constraint(equalToConstant: 500).isActive = true
            contentViewController.view.leadingAnchor.constraint(equalTo: fillingFooter.leadingAnchor).isActive = true

            contentViewController.didMove(toParent: self)
        }

        self.view = view
    }

    @objc
    func backgroundTapped() {
        dismiss()
    }

    // Calculate content size
    var contentSize: CGSize? {
        var size = contentViewController?.view.sizeThatFits(CGSize(width: view.bounds.width, height: 0))

        // Account for safe area insets so content looks nice without visible keyboard
        size?.height += view.window?.safeAreaInsets.bottom ?? 0
        return size
    }

    // MARK: - keyboard safe area insets handling

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(keyBoardWillShow(notification:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyBoardWillHide(notification:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)

        animateLayoutChanges = true
    }

    var animateLayoutChanges = false

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        if animateLayoutChanges {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseOut]
            ) {
                if let height = self.contentViewController?.preferredContentSize.height {
                    self.heightAnchor?.constant = height
                }
                self.fillingFooter.backgroundColor = self.contentViewController?.view.subviews.first?
                    .backgroundColor ?? .systemBackground

                self.view.layoutIfNeeded()
            } completion: { _ in
            }
        } else {
            if let height = contentViewController?.preferredContentSize.height {
                heightAnchor?.constant = height
            }
            fillingFooter.backgroundColor = contentViewController?.view.subviews.first?
                .backgroundColor ?? .systemBackground
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var keyboardHeight: CGFloat = 0

    @objc
    func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            if let window = view.window {
                let heightInwindow = window.convert(keyboardSize.cgRectValue, to: view)
                keyboardHeight = max(0, view.frame.maxY - heightInwindow.minY)
            } else {
                keyboardHeight = keyboardSize.cgRectValue.height
            }
        }

        let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSValue)?
            .value(of: TimeInterval.self) ?? 2.0
        let animationCurve: UIView
            .AnimationOptions = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSValue)?
            .value(of: UIView.AnimationOptions.self) ?? .curveEaseInOut
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: animationCurve,
                       animations: {
                           self.bottomAnchor?.constant = -self.keyboardHeight
                           self.view.layoutIfNeeded()
                       }, completion: { _ in
                       })
    }

    @objc
    func keyBoardWillHide(notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            if let window = view.window {
                let heightInwindow = window.convert(keyboardSize.cgRectValue, to: view)
                keyboardHeight = max(0, view.frame.maxY - heightInwindow.minY)
            } else {
                keyboardHeight = keyboardSize.cgRectValue.height
            }
        }

        let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSValue)?
            .value(of: TimeInterval.self) ?? 2.0
        let animationCurve: UIView
            .AnimationOptions = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSValue)?
            .value(of: UIView.AnimationOptions.self) ?? .curveEaseInOut
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: animationCurve,
                       animations: {
                           self.bottomAnchor?.constant = -self.keyboardHeight
                           self.view.layoutIfNeeded()
                       }, completion: { _ in
                       })
    }
}
