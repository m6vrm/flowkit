import FlowKit

final class TransferFlowStateReducer {
    private let transferRepository: TransferRepository

    init(transferRepository: TransferRepository) {
        self.transferRepository = transferRepository
    }
}

extension TransferFlowStateReducer: StateReducer {
    func reduce(state: TransferFlowState, with stepResult: TransferFlowStepResult)
        -> Promise<ReducedState<TransferFlowState, Transfer>> {

        switch (stepResult, state) {
        case (.amount(let amount), .country(let country)):
            return .promise(.continue(.amount(amount, country: country)))
        case (.tariffs(let tariff), .amount(let amount, let country)):
            return .promise(.continue(.tariff(tariff, amount: amount, country: country)))
        case (.confirmation(result: .continue, let loadingPublisher),
              .tariff(let tariff, let amount, let country)):
            return .promise { completion in
                loadingPublisher.value = true
                self.transferRepository.createTransfer(country: country, amount: amount, tariff: tariff) {
                    completion(.continue(.transfer($0)))
                    loadingPublisher.value = false
                }
            }
        case (_, .transfer(let transfer)):
            return .promise(.finish(transfer))
        default:
            return .promise(.continue(state))
        }
    }
}
