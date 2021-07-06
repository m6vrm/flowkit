public protocol FlowNavigator {
    associatedtype Step
    associatedtype State

    func navigate(to: Step, with: State) -> FlowPromise<Step>
}
