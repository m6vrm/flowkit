import FlowKit

final class TransferFlowStepTransformer { }

extension TransferFlowStepTransformer: FlowStepTransformer {
    func transform(step: TransferFlowStep, with state: TransferFlowState) -> FlowPromise<TransferFlowStep> {
        switch step {
        case .amountComplete(let amount):
            if amount < 100 {
                return .success(.invalidAmountRequired)
            } else {
                return .success(.tariffsRequired)
            }
        case .tariffsComplete:
            return .success(.confirmationRequired)
        case .confirmationComplete(.continue):
            return .success(.successRequired)
        case .confirmationComplete(.editAmount):
            return .success(.amountRequired)
        case .confirmationComplete(.editTariff):
            return .success(.tariffsRequired)
        default:
            return .success(step)
        }
    }
}
