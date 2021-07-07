public protocol FlowStateReducer {
    associatedtype State
    associatedtype Step
    associatedtype Result

    func reduce(state: State, with: Step) -> FlowPromise<ReducedState<State, Result>>
}
