public protocol FlowStateTransformer {
    associatedtype State
    associatedtype Step
    associatedtype Result

    func transform(state: State, for: Step) -> FlowPromise<StateTransformationResult<State, Result>>
}
