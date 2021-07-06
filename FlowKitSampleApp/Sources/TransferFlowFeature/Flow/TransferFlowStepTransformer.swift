import FlowKit

final class TransferFlowStepTransformer { }

extension TransferFlowStepTransformer: FlowStepTransformer {
    func transform(step: TransferFlowStep, with state: TransferFlowState) -> FlowPromise<TransferFlowStep> {
        switch step {
        case .amountComplete(let amount):
            if amount < 100 {
                return .promise(.invalidAmountRequired)
            } else {
                return .promise(.tariffsRequired)
            }
        case .tariffsComplete:
            return .promise(.confirmationRequired)
        case .confirmationComplete(.continue, _):
            return .promise(.successRequired)
        case .confirmationComplete(.editAmount, _):
            return .promise(.amountRequired)
        case .confirmationComplete(.editTariff, _):
            return .promise(.tariffsRequired)
        default:
            return .promise(step)
        }
    }
}
