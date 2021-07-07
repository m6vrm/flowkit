import PromiseKit

enum TransferFlowStepResult {
    case amount(amount: Int)
    case tariffs(tariff: Tariff)
    case confirmation(result: ConfirmationResult, loadingPublisher: Publisher<Bool>)
    case success
    case finish
}
