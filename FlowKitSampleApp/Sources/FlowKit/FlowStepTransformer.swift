public protocol FlowStepTransformer {
    associatedtype State
    associatedtype Step

    func transform(step: Step, with: State) -> FlowPromise<Step>
}
