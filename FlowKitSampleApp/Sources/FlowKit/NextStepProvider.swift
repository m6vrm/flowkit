public protocol NextStepProvider {
    associatedtype Step
    associatedtype StepResult
    associatedtype State

    func next(from: Step, for: StepResult, with: State) -> Promise<Step>
}
