public struct Flow<Result,
                   ConcreteStepNavigator: StepNavigator,
                   ConcreteStateReducer: StateReducer,
                   ConcreteTransitionProvider: TransitionProvider>

    where ConcreteStepNavigator.Step == ConcreteTransitionProvider.Step,
          ConcreteStepNavigator.State == ConcreteTransitionProvider.State,
          ConcreteStepNavigator.StepResult == ConcreteTransitionProvider.StepResult,
          ConcreteStateReducer.StepResult == ConcreteTransitionProvider.StepResult,
          ConcreteStateReducer.State == ConcreteTransitionProvider.State,
          ConcreteStateReducer.Result == Result {

    private let stepNavigator: ConcreteStepNavigator
    private let stateReducer: ConcreteStateReducer
    private let transitionProvider: ConcreteTransitionProvider

    public init(stepNavigator: ConcreteStepNavigator,
                stateReducer: ConcreteStateReducer,
                transitionProvider: ConcreteTransitionProvider) {

        self.stepNavigator = stepNavigator
        self.stateReducer = stateReducer
        self.transitionProvider = transitionProvider
    }

    public func start(from step: ConcreteStepNavigator.Step,
                      with state: ConcreteStateReducer.State) -> Promise<Result> {

        return stepNavigator.navigate(to: step, with: state)
            .then { `continue`(from: step, for: $0, with: state) }
    }

    public func `continue`(from step: ConcreteTransitionProvider.Step,
                           for stepResult: ConcreteStepNavigator.StepResult,
                           with state: ConcreteStateReducer.State) -> Promise<Result> {

        return .promise { completion in
            stateReducer.reduce(state: state, with: stepResult)
                .complete {
                    switch $0 {
                    case .continue(let reducedState):
                        transitionProvider.next(from: step, for: stepResult, with: reducedState)
                            .then { start(from: $0, with: reducedState) }
                            .complete(using: completion)
                    case .finish(let result):
                        completion(result)
                    }
                }
        }
    }
}
