public protocol NextStepProvider {
    associatedtype StepResult
    associatedtype State
    associatedtype Step

    func next(for: StepResult, with: State) -> Promise<Step>
}
