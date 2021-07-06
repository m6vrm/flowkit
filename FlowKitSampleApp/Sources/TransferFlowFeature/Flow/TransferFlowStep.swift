import PromiseKit

enum TransferFlowStep {
    case amountRequired
    case amountComplete(amount: Int)

    case invalidAmountRequired

    case tariffsRequired
    case tariffsComplete(tariff: Tariff)

    case confirmationRequired
    case confirmationComplete(result: ConfirmationResult, loadingPublisher: Publisher<Bool>)

    case successRequired
    case successComplete
}
