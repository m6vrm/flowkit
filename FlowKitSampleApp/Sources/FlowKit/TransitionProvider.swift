public protocol TransitionProvider {
    associatedtype Step
    associatedtype StepResult
    associatedtype State

    func transition(from: Step, with: StepResult, state: State) -> Promise<Step>
}
