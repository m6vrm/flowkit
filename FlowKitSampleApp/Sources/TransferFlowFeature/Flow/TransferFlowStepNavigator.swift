import FlowKit
import NavigationKit
import PromiseKit

final class TransferFlowStepNavigator {
    private let navigator: RouteNavigator

    init(navigator: RouteNavigator) {
        self.navigator = navigator
    }
}

extension TransferFlowStepNavigator: StepNavigator {
    func navigate(to step: TransferFlowStep, with state: TransferFlowState) -> Promise<TransferFlowStep> {
        switch (step, state) {
        case (.amountRequired, .country(let country)),
             (.amountRequired, .tariff(_, _, let country)):
            return .promise { completion in
                self.navigator.forward(to: .amount(country: country,
                                                   completion: { completion(.amountComplete(amount: $0)) }))
            }
        case (.invalidAmountRequired, _):
            return .promise { _ in self.navigator.forward(to: .invalidAmount) }
        case (.tariffsRequired, _):
            return .promise { completion in
                self.navigator.forward(to: .tariffs(completion: { completion(.tariffsComplete(tariff: $0)) }))
            }
        case (.confirmationRequired, .tariff(let tariff, let amount, let country)):
            return .promise { completion in
                let loadingPublisher = Publisher<Bool>()
                self.navigator.forward(to: .confirmation(loadingPublisher: loadingPublisher,
                                                         country: country,
                                                         amount: amount,
                                                         tariff: tariff,
                                                         completion: { completion(.confirmationComplete(result: $0,
                                                                                                        loadingPublisher: loadingPublisher)) }))
            }
        case (.successRequired, .transfer(let transfer)):
            return .promise { completion in
                self.navigator.forward(to: .success(transfer: transfer,
                                                    completion: { completion(.successComplete) }))
            }
        default:
            return .nothing()
        }
    }
}
