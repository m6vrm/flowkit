public protocol StateReducer {
    associatedtype State
    associatedtype StepResult
    associatedtype Result

    func reduce(state: State, with: StepResult) -> Promise<ReducedState<State, Result>>
}
