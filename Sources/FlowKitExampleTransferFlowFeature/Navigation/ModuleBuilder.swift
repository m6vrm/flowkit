import UIKit
import FlowKitExampleNavigation

struct ModuleBuilder { }

extension ModuleBuilder: FlowKitExampleNavigation.ModuleBuilder {
    func build(by route: Route) -> UIViewController {
        switch route {
        case .amount(let country, let completion):
            return AmountViewController(country: country, completion: completion)
        case .tariffs(let completion):
            return TariffsViewController(completion: completion)
        case .confirmation(let loadingPublisher, let country, let amount, let tariff, let completion):
            return ConfirmationViewController(loadingPublisher: loadingPublisher,
                                              country: country,
                                              amount: amount,
                                              tariff: tariff,
                                              completion: completion)
        case .success(let transfer, let completion):
            return SuccessViewController(transfer: transfer, completion: completion)
        case .invalidAmount:
            return InvalidAmountViewController()
        }
    }
}
