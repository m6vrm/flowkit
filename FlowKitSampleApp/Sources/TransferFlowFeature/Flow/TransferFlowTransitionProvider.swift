import FlowKit

final class TransferFlowTransitionProvider {
    enum Event {
        case invalidAmount
        case confirmationContinue
        case confirmationEditAmount
        case confirmationEditTariff
    }

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
    static func makeFlowDSL() -> FlowDSL.Flow<TransferFlowStep, Event, TransferFlowStepResult, TransferFlowState> {
        return FlowDSL.Flow {
            emit(using: emitter)
            step(.amount) {
                on(.invalidAmount) { forward(to: .invalidAmount) }
                next { forward(to: .tariffs) }
            }
            step(.tariffs) {
                next { forward(to: .confirmation) }
            }
            step(.confirmation) {
                on(.confirmationContinue) { forward(to: .success) }
                on(.confirmationEditAmount) { forward(to: .amount) }
                on(.confirmationEditTariff) { forward(to: .tariffs) }
            }
            step(.success) {
                next { forward(to: .finish) }
            }
        }
    }

    static func emitter(_ stepResult: TransferFlowStepResult, _ state: TransferFlowState) -> Event? {
        switch stepResult {
        case .amount(let amount) where amount < 100:
            return .invalidAmount
        case .confirmation(.continue, _):
            return .confirmationContinue
        case .confirmation(.editAmount, _):
            return .confirmationEditAmount
        case .confirmation(.editTariff, _):
            return .confirmationEditTariff
        default:
            return nil
        }
    }
}
