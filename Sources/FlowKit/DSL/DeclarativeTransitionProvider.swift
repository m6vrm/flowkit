public final class DeclarativeTransitionProvider<Step: Equatable, Event: Equatable, StepResult, State> {
    private let flowDSL: FlowDSL<Step, Event, StepResult, State>

    public init(flowDSL: FlowDSL<Step, Event, StepResult, State>) {
        self.flowDSL = flowDSL
    }
}

extension DeclarativeTransitionProvider: TransitionProvider {
    public func transition(from step: Step, with stepResult: StepResult, state: State) -> Promise<Transition<Step>> {
        return transition(where: { $0 == nil }, stepResult: stepResult, state: state)   // handle "any" steps (*)
            ?? transition(where: { $0 == step }, stepResult: stepResult, state: state)  // handle exact steps
            ?? .nothing
    }
}

private extension DeclarativeTransitionProvider {
    func transition(where predicate: (Step?) -> Bool,
                    stepResult: StepResult,
                    state: State) -> Promise<Transition<Step>>? {

        let emitter = flowDSL.definition.emitter

        return flowDSL
            .definition
            .steps
            .first { predicate($0.step) }?
            .conditions
            .first { $0.event == emitter(stepResult, state) }
            .map { .promise($0.transition) }
    }
}
