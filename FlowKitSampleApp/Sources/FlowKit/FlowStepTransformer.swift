public protocol FlowStepTransformer {
    associatedtype Step
    associatedtype State

    func transform(step: Step, with: State) -> FlowPromise<Step>
}
