public protocol TransitionNavigator {
    associatedtype Step
    associatedtype State
    associatedtype StepResult

    func navigate(to: Step, with: State) -> Promise<StepResult>
}
