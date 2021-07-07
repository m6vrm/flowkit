import PromiseKit

enum TransferFlowStep {
    case amount
    case invalidAmount
    case tariffs
    case confirmation
    case success
    case finish
}
