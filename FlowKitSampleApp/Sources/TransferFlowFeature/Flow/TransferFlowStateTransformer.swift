import FlowKit

final class TransferFlowStateTransformer {
    private let transferRepository: TransferRepository

    init(transferRepository: TransferRepository) {
        self.transferRepository = transferRepository
    }
}

extension TransferFlowStateTransformer: FlowStateTransformer {
    func transform(state: TransferFlowState, for step: TransferFlowStep)
        -> FlowPromise<StateTransformationResult<TransferFlowState, Transfer>> {

        switch (step, state) {
        case (.amountComplete(let amount), .country(let country)):
            return .success(.continue(.amount(amount, country: country)))
        case (.tariffsComplete(let tariff), .amount(let amount, let country)):
            return .success(.continue(.tariff(tariff, amount: amount, country: country)))
        case (.confirmationComplete(result: .continue), .tariff(let tariff, let amount, let country)):
            return .success { completion in
                self.transferRepository.createTransfer(country: country, amount: amount, tariff: tariff) {
                    completion(.continue(.transfer($0)))
                }
            }
        case (_, .transfer(let transfer)):
            return .success(.finish(transfer))
        default:
            return .success(.continue(state))
        }
    }
}
