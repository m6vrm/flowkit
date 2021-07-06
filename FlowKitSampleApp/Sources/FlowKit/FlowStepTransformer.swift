public protocol FlowStepTransformer {
    associatedtype FlowState
    associatedtype FlowStep

    func transform(step: FlowStep, with: FlowState) -> FlowPromise<FlowStep>
}
