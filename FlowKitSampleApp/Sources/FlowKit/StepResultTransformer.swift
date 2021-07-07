public protocol StepResultTransformer {
    associatedtype StepResult
    associatedtype State
    associatedtype Step

    func transform(stepResult: StepResult, with: State) -> Promise<Step>
}
