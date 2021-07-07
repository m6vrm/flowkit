import FlowKit

final class TransferFlowStateReducer {
    private let transferRepository: TransferRepository

    init(transferRepository: TransferRepository) {
        self.transferRepository = transferRepository
    }
}

extension TransferFlowStateReducer: StateReducer {
    func reduce(state: TransferFlowState, with step: TransferFlowStep)
        -> Promise<ReducedState<TransferFlowState, Transfer>> {

        switch (step, state) {
        case (.amountComplete(let amount), .country(let country)):
            return .promise(.continue(.amount(amount, country: country)))
        case (.tariffsComplete(let tariff), .amount(let amount, let country)):
            return .promise(.continue(.tariff(tariff, amount: amount, country: country)))
        case (.confirmationComplete(result: .continue, let loadingPublisher),
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
