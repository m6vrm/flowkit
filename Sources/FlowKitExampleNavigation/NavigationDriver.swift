import UIKit

public final class NavigationDriver {
    private let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func forward(to viewController: UIViewController) {
        if let index = navigationController
            .viewControllers
            .firstIndex(where: { type(of: $0) == type(of: viewController) }) {

            navigationController.popToViewController(navigationController.viewControllers[index], animated: true)
        } else {
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    func present(_ viewController: UIViewController) {
        navigationController.present(viewController, animated: true)
    }

    func back() {
        navigationController.popViewController(animated: true)
    }

    func backToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
