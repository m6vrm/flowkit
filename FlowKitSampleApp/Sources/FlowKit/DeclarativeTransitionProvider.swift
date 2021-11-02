public final class DeclarativeTransitionProvider<Step: Equatable, StepResult, State> {
    private let flowDSL: FlowDSL.Flow<Step, StepResult, State>

    public init(flowDSL: FlowDSL.Flow<Step, StepResult, State>) {
        self.flowDSL = flowDSL
    }
}

extension DeclarativeTransitionProvider: TransitionProvider {
    public func next(from step: Step, for stepResult: StepResult, with state: State) -> Promise<Step> {
        return flowDSL
            .steps
            .first { $0.step == step }?
            .conditions
            .first { $0.predicate(stepResult, state) }
            .map { .promise($0.transition.step) } ?? .nothing
    }
}
