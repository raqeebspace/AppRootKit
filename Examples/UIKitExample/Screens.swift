import UIKit
import AppRootUIKit

extension UIViewController {
    /// The root navigation controller this screen lives in.
    var appRoot: AppRootNavigationController? {
        navigationController as? AppRootNavigationController
    }
}

final class OnboardingViewController: ActionViewController {
    init() {
        super.init(title: "Welcome", color: .systemIndigo,
                   message: "The first root. Shown until onboarding is finished.")
        addAction("Get started") { [weak self] in
            Session.didFinishOnboarding = true
            self?.appRoot?.setRoot(AppFlow.login)
        }
    }
}

final class LoginViewController: ActionViewController {
    init() {
        super.init(title: "Log in", color: .systemTeal,
                   message: "Switching here uses the default push from the right.")
        addAction("Log in") { [weak self] in
            Session.isLoggedIn = true
            self?.appRoot?.setRoot(AppFlow.home) // home fades in
        }
    }
}

final class HomeViewController: ActionViewController {
    init() {
        super.init(title: "Home", color: .systemGreen,
                   message: "Push a few screens, then log out: the whole stack is replaced.")
        addAction("Push details") { [weak self] in
            self?.navigationController?.pushViewController(DetailViewController(depth: 1), animated: true)
        }
        addAction("Log out") {
            Session.isLoggedIn = false
            // Every AppRootNavigationController in the app switches (all windows).
            AppRootNavigationController.setRootInAllWindows(AppFlow.login)
        }
        addAction("Reset onboarding") { [weak self] in
            Session.didFinishOnboarding = false
            Session.isLoggedIn = false
            self?.appRoot?.setRoot(AppFlow.onboarding) // slides in from the left
        }
    }
}

/// A plain pushed screen: ordinary UINavigationController navigation keeps working.
final class DetailViewController: ActionViewController {
    init(depth: Int) {
        super.init(title: "Details \(depth)", color: .systemOrange,
                   message: "A pushed screen on top of home.")
        addAction("Push another") { [weak self] in
            self?.navigationController?.pushViewController(DetailViewController(depth: depth + 1), animated: true)
        }
        addAction("Log out from here") { [weak self] in
            Session.isLoggedIn = false
            self?.appRoot?.setRoot(AppFlow.login)
        }
    }
}

/// A screen with a title, a message and a column of buttons.
class ActionViewController: UIViewController {
    private let stack = UIStackView()

    init(title: String, color: UIColor, message: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        view.backgroundColor = color.withAlphaComponent(0.15)

        let label = UILabel()
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)

        stack.axis = .vertical
        stack.spacing = 12
        stack.addArrangedSubview(label)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func addAction(_ title: String, handler: @escaping () -> Void) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .large
        stack.addArrangedSubview(UIButton(configuration: configuration, primaryAction: UIAction { _ in handler() }))
    }
}
