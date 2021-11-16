public struct Flow<Result,
                   ConcreteTransitionNavigator: TransitionNavigator,
                   ConcreteStateReducer: StateReducer,
                   ConcreteTransitionProvider: TransitionProvider>

    where ConcreteTransitionNavigator.Step == ConcreteTransitionProvider.Step,
          ConcreteTransitionNavigator.State == ConcreteTransitionProvider.State,
          ConcreteTransitionNavigator.StepResult == ConcreteTransitionProvider.StepResult,
          ConcreteStateReducer.StepResult == ConcreteTransitionProvider.StepResult,
          ConcreteStateReducer.State == ConcreteTransitionProvider.State,
          ConcreteStateReducer.Result == Result {

    public typealias Step = ConcreteTransitionNavigator.Step
    public typealias State = ConcreteStateReducer.State
    public typealias StepResult = ConcreteTransitionProvider.StepResult

    private struct Snapshot {
        let step: Step
        let stepResult: StepResult
        let state: State
    }

    private let transitionNavigator: ConcreteTransitionNavigator
    private let stateReducer: ConcreteStateReducer
    private let transitionProvider: ConcreteTransitionProvider

    public init(transitionNavigator: ConcreteTransitionNavigator,
                stateReducer: ConcreteStateReducer,
                transitionProvider: ConcreteTransitionProvider) {

        self.transitionNavigator = transitionNavigator
        self.stateReducer = stateReducer
        self.transitionProvider = transitionProvider
    }

    public func start(from step: Step, with state: State) -> Promise<Result> {
        return navigate(using: .forwardTo(step), with: state, previousSnapshot: nil)
    }

    public func `continue`(from step: Step, with stepResult: StepResult, state: State) -> Promise<Result> {
        return `continue`(from: step, with: stepResult, state: state, previousSnapshot: nil)
    }
}

private extension Flow {
    private func `continue`(from step: Step,
                            with stepResult: StepResult,
                            state: State,
                            previousSnapshot: Snapshot?) -> Promise<Result> {

        return .promise { completion in
            stateReducer.reduce(state: state, with: stepResult)
                .complete {
                    switch $0 {
                    case .continue(let reducedState):
                        let snapshot = Snapshot(step: step, stepResult: stepResult, state: state)
                        transition(from: step, with: stepResult, state: reducedState, previousSnapshot: snapshot)
                            .complete(using: completion)
                    case .retry:
                        guard let previousSnapshot = previousSnapshot else { return }
                        retry(snapshot: previousSnapshot).complete(using: completion)
                    case .finish(let result):
                        completion(result)
                    }
                }
        }
    }

    private func navigate(using transition: Transition<Step>,
                          with state: State,
                          previousSnapshot: Snapshot?) -> Promise<Result> {

        return transitionNavigator.navigate(using: transition, with: state)
            .then {
                switch transition {
                case .forwardTo(let step):
                    return `continue`(from: step, with: $0, state: state, previousSnapshot: previousSnapshot)
                default:
                    return .nothing
                }
            }
    }

    private func transition(from step: Step,
                            with stepResult: StepResult,
                            state: State,
                            previousSnapshot: Snapshot) -> Promise<Result> {

        return transitionProvider.transition(from: step, with: stepResult, state: state)
            .then { navigate(using: $0, with: state, previousSnapshot: previousSnapshot) }
    }

    private func retry(snapshot: Snapshot) -> Promise<Result> {
        return `continue`(from: snapshot.step,
                          with: snapshot.stepResult,
                          state: snapshot.state,
                          previousSnapshot: nil)
    }
}
