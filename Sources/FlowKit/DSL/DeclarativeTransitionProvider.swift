public final class DeclarativeTransitionProvider<Step: Equatable, Event: Equatable, StepResult, State> {
    private let flowDSL: FlowDSL<Step, Event, StepResult, State>

    public init(flowDSL: FlowDSL<Step, Event, StepResult, State>) {
        self.flowDSL = flowDSL
    }
}

extension DeclarativeTransitionProvider: TransitionProvider {
    public func transition(from step: Step, with stepResult: StepResult, state: State) -> Promise<Transition<Step>> {
        let emitter = flowDSL.definition.emitter

        return flowDSL
            .definition
            .steps
            .first { $0.step == step }?
            .conditions
            .first { $0.event == nil || $0.event == emitter(stepResult, state) }
            .map { .promise($0.transition) } ?? .nothing
    }
}
