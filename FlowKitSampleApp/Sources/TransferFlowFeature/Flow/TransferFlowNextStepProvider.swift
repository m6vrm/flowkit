import FlowKit

final class TransferFlowNextStepProvider {
    private lazy var declarativeNextStepProvider = DeclarativeNextStepProvider(flowDSL: Self.makeFlowDSL())
}

extension TransferFlowNextStepProvider: NextStepProvider, FlowDSLBuilder {
    func next(from step: TransferFlowStep,
              for stepResult: TransferFlowStepResult,
              with state: TransferFlowState) -> Promise<TransferFlowStep> {

        return declarativeNextStepProvider.next(from: step, for: stepResult, with: state)
    }
}

extension TransferFlowNextStepProvider {
    static func makeFlowDSL() -> FlowDSL.Flow<TransferFlowStep, TransferFlowStepResult, TransferFlowState> {
        return FlowDSL.Flow {
            step(.amount) {
                on(invalidAmount) { transition(.invalidAmount) }
                next { transition(.tariffs) }
            }
            step(.tariffs) {
                next { transition(.confirmation) }
            }
            step(.confirmation) {
                on(confirmationContinue) { transition(.success) }
                on(confirmationEditAmount) { transition(.amount) }
                on(confirmationEditTariff) { transition(.tariffs) }
            }
            step(.success) {
                next { transition(.finish) }
            }
        }
    }

    // bullshit...
    static func invalidAmount(_ stepResult: TransferFlowStepResult, _ state: TransferFlowState) -> Bool {
        if case .amount(let amount) = stepResult { return amount < 100 } else { return false }
    }

    static func confirmationContinue(_ stepResult: TransferFlowStepResult, _ state: TransferFlowState) -> Bool {
        if case .confirmation(.continue, _) = stepResult { return true } else { return false }
    }

    static func confirmationEditAmount(_ stepResult: TransferFlowStepResult, _ state: TransferFlowState) -> Bool {
        if case .confirmation(.editAmount, _) = stepResult { return true } else { return false }
    }

    static func confirmationEditTariff(_ stepResult: TransferFlowStepResult, _ state: TransferFlowState) -> Bool {
        if case .confirmation(.editTariff, _) = stepResult { return true } else { return false }
    }
}
