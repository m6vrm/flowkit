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

        return navigate(using: .forwardTo(step), with: state)
    }

    public func `continue`(from step: ConcreteTransitionProvider.Step,
                           with stepResult: ConcreteTransitionNavigator.StepResult,
                           state: ConcreteStateReducer.State) -> Promise<Result> {

        return .promise { completion in
            stateReducer.reduce(state: state, with: stepResult)
                .complete {
                    switch $0 {
                    case .continue(let reducedState):
                        transitionProvider.transition(from: step, with: stepResult, state: reducedState)
                            .then { navigate(using: $0, with: reducedState) }
                            .complete(using: completion)
                    case .finish(let result):
                        completion(result)
                    }
                }
        }
    }
}

private extension Flow {
    func navigate(using transition: Transition<ConcreteTransitionNavigator.Step>,
                  with state: ConcreteStateReducer.State) -> Promise<Result> {

        return transitionNavigator.navigate(using: transition, with: state)
            .then {
                switch transition {
                case .forwardTo(let step):
                    return `continue`(from: step, with: $0, state: state)
                default:
                    return .nothing
                }
            }
    }
}
