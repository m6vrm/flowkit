import FlowKit

final class TransferFlowTransitionProvider {
    private lazy var declarativeTransitionProvider = DeclarativeTransitionProvider(flowDSL: Self.makeFlowDSL())
}

extension TransferFlowTransitionProvider: TransitionProvider, FlowDSLBuilder {
    func next(from step: TransferFlowStep,
              for stepResult: TransferFlowStepResult,
              with state: TransferFlowState) -> Promise<TransferFlowStep> {

        return declarativeTransitionProvider.next(from: step, for: stepResult, with: state)
    }
}

extension TransferFlowTransitionProvider {
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
