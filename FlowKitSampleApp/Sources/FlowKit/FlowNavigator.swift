public protocol FlowNavigator {
    associatedtype FlowStep
    associatedtype FlowState

    func navigate(to: FlowStep, with: FlowState) -> FlowPromise<FlowStep>
}
