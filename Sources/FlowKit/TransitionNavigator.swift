public protocol TransitionNavigator {
    associatedtype Step
    associatedtype State
    associatedtype StepResult

    func navigate(using: Transition<Step>, with: State) -> Promise<StepResult>
}
