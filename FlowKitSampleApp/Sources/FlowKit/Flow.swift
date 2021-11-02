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

    public func start(from step: ConcreteTransitionNavigator.Step,
                      with state: ConcreteStateReducer.State) -> Promise<Result> {

        return transitionNavigator.navigate(to: step, with: state)
            .then { `continue`(from: step, for: $0, with: state) }
    }

    public func `continue`(from step: ConcreteTransitionProvider.Step,
                           for stepResult: ConcreteTransitionNavigator.StepResult,
                           with state: ConcreteStateReducer.State) -> Promise<Result> {

        return .promise { completion in
            stateReducer.reduce(state: state, with: stepResult)
                .complete {
                    switch $0 {
                    case .continue(let reducedState):
                        transitionProvider.transition(from: step, with: stepResult, state: reducedState)
                            .then { start(from: $0, with: reducedState) }
                            .complete(using: completion)
                    case .finish(let result):
                        completion(result)
                    }
                }
        }
    }
}
