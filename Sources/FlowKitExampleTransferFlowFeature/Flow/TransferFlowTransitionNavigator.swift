import FlowKit
import FlowKitExampleNavigation
import FlowKitExamplePromises

final class TransferFlowTransitionNavigator {
    private let navigator: RouteNavigator

    init(navigator: RouteNavigator) {
        self.navigator = navigator
    }
}

extension TransferFlowTransitionNavigator: TransitionNavigator {
    func navigate(using transition: Transition<TransferFlowStep>,
                  with state: TransferFlowState) -> Promise<TransferFlowStepResult> {

        switch (transition, state) {
        case (.forwardTo(.amount), .country(let country)),
             (.forwardTo(.amount), .tariff(_, _, let country)):
            return .promise { completion in
                self.navigator.forward(to: .amount(country: country,
                                                   completion: { completion(.amount(amount: $0)) }))
            }
        case (.forwardTo(.invalidAmount), _):
            return .promise { _ in self.navigator.forward(to: .invalidAmount) }
        case (.forwardTo(.tariffs), _):
            return .promise { completion in
                self.navigator.forward(to: .tariffs(completion: { completion(.tariffs(tariff: $0)) }))
            }
        case (.forwardTo(.confirmation), .tariff(let tariff, let amount, let country)):
            return .promise { completion in
                let loadingPublisher = Publisher<Bool>()
                self.navigator.forward(to: .confirmation(loadingPublisher: loadingPublisher,
                                                         country: country,
                                                         amount: amount,
                                                         tariff: tariff,
                                                         completion: { completion(.confirmation(result: $0,
                                                                                                loadingPublisher: loadingPublisher)) }))
            }
        case (.forwardTo(.success), .transfer(let transfer)):
            return .promise { completion in
                self.navigator.forward(to: .success(transfer: transfer,
                                                    completion: { completion(.success) }))
            }
        case (.forwardTo(.finish), _):
            return .promise {
                self.navigator.backToRoot()
                $0(.finish)
            }
        case (.forwardTo(.alert), .error(let title)):
            return .promise { completion in
                self.navigator.present(.alert(title: title, retry: { completion(.retry) }))
            }
        case (.backTo(.amount), _):
            return .promise { _ in
                self.navigator.forward(to: .amount(country: .russia, completion: { _ in }))
            }
        case (.backTo(.tariffs), _):
            return .promise { _ in
                self.navigator.forward(to: .tariffs(completion: { _ in }))
            }
        case (.back, _):
            return .promise { _ in
                self.navigator.back()
            }
        default:
            return .nothing
        }
    }
}
