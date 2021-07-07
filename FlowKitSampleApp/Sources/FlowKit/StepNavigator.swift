public protocol StepNavigator {
    associatedtype Step
    associatedtype State
    associatedtype StepResult

    func navigate(to: Step, with: State) -> Promise<StepResult>
}
