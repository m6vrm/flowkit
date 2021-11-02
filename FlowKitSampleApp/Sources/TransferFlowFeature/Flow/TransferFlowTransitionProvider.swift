import FlowKit

final class TransferFlowTransitionProvider {
    private lazy var declarativeTransitionProvider = DeclarativeTransitionProvider(flowDSL: Self.makeFlowDSL())
}

extension TransferFlowTransitionProvider: TransitionProvider, FlowDSLBuilder {
    func transition(from step: TransferFlowStep,
                    with stepResult: TransferFlowStepResult,
                    state: TransferFlowState) -> Promise<Transition<TransferFlowStep>> {

        return declarativeTransitionProvider.transition(from: step, with: stepResult, state: state)
    }
}

private extension TransferFlowTransitionProvider {
    static func makeFlowDSL() -> FlowDSL.Flow<TransferFlowStep, TransferFlowStepResult, TransferFlowState> {
        return FlowDSL.Flow {
            step(.amount) {
                on(invalidAmount) { forward(to: .invalidAmount) }
                next { forward(to: .tariffs) }
            }
            step(.tariffs) {
                next { forward(to: .confirmation) }
            }
            step(.confirmation) {
                on(confirmationContinue) { forward(to: .success) }
                on(confirmationEditAmount) { forward(to: .amount) }
                on(confirmationEditTariff) { forward(to: .tariffs) }
            }
            step(.success) {
                next { forward(to: .finish) }
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
