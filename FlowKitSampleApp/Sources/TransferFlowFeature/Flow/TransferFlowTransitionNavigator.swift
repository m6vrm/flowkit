import FlowKit
import NavigationKit
import PromiseKit

final class TransferFlowTransitionNavigator {
    private let navigator: RouteNavigator

    init(navigator: RouteNavigator) {
        self.navigator = navigator
    }
}

extension TransferFlowTransitionNavigator: TransitionNavigator {
    func navigate(to step: TransferFlowStep, with state: TransferFlowState) -> Promise<TransferFlowStepResult> {
        switch (step, state) {
        case (.amount, .country(let country)),
             (.amount, .tariff(_, _, let country)):
            return .promise { completion in
                self.navigator.forward(to: .amount(country: country,
                                                   completion: { completion(.amount(amount: $0)) }))
            }
        case (.invalidAmount, _):
            return .promise { _ in self.navigator.forward(to: .invalidAmount) }
        case (.tariffs, _):
            return .promise { completion in
                self.navigator.forward(to: .tariffs(completion: { completion(.tariffs(tariff: $0)) }))
            }
        case (.confirmation, .tariff(let tariff, let amount, let country)):
            return .promise { completion in
                let loadingPublisher = Publisher<Bool>()
                self.navigator.forward(to: .confirmation(loadingPublisher: loadingPublisher,
                                                         country: country,
                                                         amount: amount,
                                                         tariff: tariff,
                                                         completion: { completion(.confirmation(result: $0,
                                                                                                        loadingPublisher: loadingPublisher)) }))
            }
        case (.success, .transfer(let transfer)):
            return .promise { completion in
                self.navigator.forward(to: .success(transfer: transfer,
                                                    completion: { completion(.success) }))
            }
        case (.finish, _):
            return .promise {
                self.navigator.backToRoot()
                $0(.finish)
            }
        default:
            return .nothing
        }
    }
}
