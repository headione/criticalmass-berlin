//
//  CriticalMaps

import CoreLocation
import UIKit

protocol MapInfoPresenter {
    func onViewLoaded()
}

final class MapInfoViewController: UIViewController, IBConstructable {
    typealias CompletionHandler = () -> Void
    @IBOutlet private var infoViewContainer: UIView! {
        didSet {
            let swipeUpGesture = UISwipeGestureRecognizer(
                target: self,
                action: #selector(onSwipeUpGestureRecognizer)
            )
            swipeUpGesture.direction = .up
            infoViewContainer.addGestureRecognizer(swipeUpGesture)
        }
    }

    @IBOutlet private var locationUpdateErrorViewContainer: UIView! {
        didSet {
            locationUpdateErrorViewContainer.isHidden = true
        }
    }

    private var showServerError = false
    private var errorView = MapInfoView.fromNib()

    private let animationDuration: TimeInterval = 0.2

    private var infoView = MapInfoView.fromNib()
    private var visibleBottomConstraint: NSLayoutConstraint!
    private var infoViewContainerTopConstraint: NSLayoutConstraint {
        infoViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        errorView.translatesAutoresizingMaskIntoConstraints = false
        locationUpdateErrorViewContainer.addSubview(errorView)
        errorView.addLayoutsSameSizeAndOrigin(in: locationUpdateErrorViewContainer)

        infoViewContainer.addSubview(infoView)
        infoView.addLayoutsSameSizeAndOrigin(in: infoViewContainer)

        visibleBottomConstraint = infoViewContainerTopConstraint
        visibleBottomConstraint.priority = .required
        view.addConstraints([visibleBottomConstraint])

        visibleBottomConstraint.isActive = false
        infoViewContainer.isHidden = true

        infoView.closeButtonHandler = {
            self.dismissMapInfo()
        }

        subscribeForNotififications()
    }

    private func subscribeForNotififications() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(didReceiveLocationsUpdate),
                name: .locationAndMessagesReceived,
                object: nil
            )
    }

    /// Called when the mapInfoViewContainer is swiped up
    @objc private func onSwipeUpGestureRecognizer() {
        dismissMapInfo()
    }

    public func configureAndPresentMapInfoView(
        title: String,
        style: MapInfoView.Configuration.Style,
        _ completion: CompletionHandler? = nil,
        tapHandler: @escaping MapInfoView.TapHandler
    ) {
        func animateIn() {
            infoView.configure(with: MapInfoView.Configuration(title: title, style: style))
            infoViewContainer.isHidden = false

            let animator = UIViewPropertyAnimator(
                duration: animationDuration,
                timingParameters: UICubicTimingParameters.linearOutSlow
            )
            animator.addAnimations {
                self.visibleBottomConstraint.isActive = true
                self.view.layoutIfNeeded()
            }
            animator.addCompletion { _ in
                completion?()
                UIAccessibility.post(notification: .layoutChanged, argument: self.view)
            }
            animator.startAnimation()
        }
        infoView.tapHandler = tapHandler

        if !visibleBottomConstraint.isActive {
            animateIn()
        } else {
            dismissMapInfo(animated: false) {
                animateIn()
            }
        }
    }

    public func dismissMapInfo(animated: Bool = true, _ completion: CompletionHandler? = nil) {
        let finishBlock: () -> Void = {
            UIAccessibility.post(notification: .layoutChanged, argument: self.view)
            completion?()
        }
        if !animated {
            visibleBottomConstraint.isActive = false
            infoViewContainer.isHidden = true
            finishBlock()
        } else {
            let animator = UIViewPropertyAnimator(
                duration: animationDuration,
                timingParameters: UICubicTimingParameters.fastOutLiner
            )
            animator.addAnimations {
                self.visibleBottomConstraint.isActive = false
                self.view.layoutIfNeeded()
            }
            animator.addCompletion { _ in
                self.infoViewContainer.isHidden = true
                finishBlock()
            }
            animator.startAnimation()
        }
    }

    @objc private func didReceiveLocationsUpdate(notification: Notification) {
        guard
            let result = notification.object as? ApiResponseResult,
            result.failed != showServerError
        else {
            return
        }
        let errorMessage = L10n.Map.Layer.Info.errorMessage
        errorView.configure(
            with: .init(
                title: errorMessage,
                style: .alert
            )
        )
        showServerError = result.failed
        UIAccessibility.post(notification: .announcement, argument: L10n.Map.Layer.Info.errorMessage)
        showServerError ? locationUpdateErrorViewContainer.fadeIn() : locationUpdateErrorViewContainer.fadeOut()
    }
}

// https://material.io/design/motion/speed.html#easing
private extension UICubicTimingParameters {
    static var linearOutSlow: UITimingCurveProvider {
        UICubicTimingParameters(controlPoint1: .init(x: 0.0, y: 0.0), controlPoint2: .init(x: 0.2, y: 1.0))
    }

    static var fastOutLiner: UITimingCurveProvider {
        UICubicTimingParameters(controlPoint1: .init(x: 0.4, y: 0.0), controlPoint2: .init(x: 1.0, y: 1.0))
    }
}
