import FlowKit

final class TransferFlowTransitionProvider {
    private lazy var declarativeTransitionProvider = DeclarativeTransitionProvider(flowDSL: Self.makeFlowDSL())
}

extension TransferFlowTransitionProvider: TransitionProvider {
    func transition(from step: TransferFlowStep,
                    with stepResult: TransferFlowStepResult,
                    state: TransferFlowState) -> Promise<Transition<TransferFlowStep>> {

        return declarativeTransitionProvider.transition(from: step, with: stepResult, state: state)
    }
}

extension TransferFlowTransitionProvider: FlowDSLBuilder {
    enum Event {
        case invalidAmount
        case confirmationContinue
        case confirmationEditAmount
        case confirmationEditTariff

        case error
    }
}

private extension TransferFlowTransitionProvider {
    static func makeFlowDSL() -> FlowDSL<TransferFlowStep, Event, TransferFlowStepResult, TransferFlowState> {
        let dsl = FlowDSL {
            emit(using: emitter)
            step {
                on(.error) { forward(to: .alert) }
            }
            step(.amount) {
                on(.invalidAmount) { forward(to: .invalidAmount) }
                next { forward(to: .tariffs) }
            }
            step(.tariffs) {
                next { forward(to: .confirmation) }
            }
            step(.confirmation) {
                on(.confirmationContinue) { forward(to: .success) }
                on(.confirmationEditAmount) { back(to: .amount) }
                on(.confirmationEditTariff) { back(to: .tariffs) }
            }
            step(.success) {
                next { forward(to: .finish) }
            }
        }

        let dot = DOTBuilder()
        dot.dsl(dsl)
        print(dot.build())

        return dsl
    }

    static func emitter(_ stepResult: TransferFlowStepResult, _ state: TransferFlowState) -> Event? {
        switch (stepResult, state) {
        case (_, .error):
            return .error
        case (.amount(let amount), _) where amount < 100:
            return .invalidAmount
        case (.confirmation(.continue, _), _):
            return .confirmationContinue
        case (.confirmation(.editAmount, _), _):
            return .confirmationEditAmount
        case (.confirmation(.editTariff, _), _):
            return .confirmationEditTariff
        default:
            return nil
        }
    }
}
