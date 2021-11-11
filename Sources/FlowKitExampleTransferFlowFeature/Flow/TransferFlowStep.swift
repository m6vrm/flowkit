import FlowKitExamplePromises

enum TransferFlowStep {
    case amount
    case invalidAmount
    case tariffs
    case confirmation
    case success
    case finish

    case alert
}
