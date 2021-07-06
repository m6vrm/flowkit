import FlowKit
import NavigationKit

final class TransferFlowNavigator {
    private let navigator: RouteNavigator

    init(navigator: RouteNavigator) {
        self.navigator = navigator
    }
}

extension TransferFlowNavigator: FlowNavigator {
    func navigate(to step: TransferFlowStep, with state: TransferFlowState) -> FlowPromise<TransferFlowStep> {
        switch (step, state) {
        case (.amountRequired, .country(let country)),
             (.amountRequired, .tariff(_, _, let country)):
            return .success { completion in
                self.navigator.forward(to: .amount(country: country,
                                                   completion: { completion(.amountComplete(amount: $0)) }))
            }
        case (.invalidAmountRequired, _):
            return .success { _ in self.navigator.forward(to: .invalidAmount) }
        case (.tariffsRequired, _):
            return .success { completion in
                self.navigator.forward(to: .tariffs(completion: { completion(.tariffsComplete(tariff: $0)) }))
            }
        case (.confirmationRequired, .tariff(let tariff, let amount, let country)):
            return .success { completion in
                self.navigator.forward(to: .confirmation(country: country,
                                                         amount: amount,
                                                         tariff: tariff,
                                                         completion: { completion(.confirmationComplete(result: $0)) }))
            }
        case (.successRequired, .transfer(let transfer)):
            return .success { completion in
                self.navigator.forward(to: .success(transfer: transfer,
                                                    completion: { completion(.successComplete) }))
            }
        default:
            return .nothing()
        }
    }
}
