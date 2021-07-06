public protocol FlowStateTransformer {
    associatedtype FlowState
    associatedtype FlowStep
    associatedtype FlowResult

    func transform(state: FlowState, for: FlowStep) -> FlowPromise<StateTransformationResult<FlowState, FlowResult>>
}
