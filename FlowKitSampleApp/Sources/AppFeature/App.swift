import UIKit
import NavigationKit
import TransferFlowFeature

public final class App {
    private lazy var window = UIWindow()

    public init() { }

    public func launch() {
        let firstViewController = FirstViewController()
        let navigationController = UINavigationController(rootViewController: firstViewController)

        window.backgroundColor = .white
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        let navigationDriver = NavigationDriver(navigationController: navigationController)
        let transferFlowFactory = TransferFlowFactory(navigatinDriver: navigationDriver)

        let transferFlow = transferFlowFactory.makeTransferFlow()

        let completion: (Transfer) -> Void = { transfer in
            let alert = UIAlertController(title: "Success!",
                                          message: "Created Transfer ID: \(transfer.identifier)",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            firstViewController.present(alert, animated: true)
        }

        firstViewController.tapRussiaButtonHandler =
            { transferFlow.start(with: .russia).complete(using: completion) }
        firstViewController.tapGermanyButtonHandler =
            { transferFlow.start(with: .germany).complete(using: completion) }
        firstViewController.tapFranceButtonHandler =
            { transferFlow.start(with: .france).complete(using: completion) }
    }
}
