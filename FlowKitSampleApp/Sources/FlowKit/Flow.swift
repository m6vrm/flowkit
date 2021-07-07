public struct Flow<Result,
                   ConcreteStepNavigator: StepNavigator,
                   ConcreteNextStepProvider: NextStepProvider,
                   ConcreteStateReducer: StateReducer>

    where ConcreteStepNavigator.Step == ConcreteNextStepProvider.Step,
          ConcreteStepNavigator.State == ConcreteNextStepProvider.State,
          ConcreteStepNavigator.StepResult == ConcreteNextStepProvider.StepResult,
          ConcreteStateReducer.StepResult == ConcreteNextStepProvider.StepResult,
          ConcreteStateReducer.State == ConcreteNextStepProvider.State,
          ConcreteStateReducer.Result == Result {

    private let stepNavigator: ConcreteStepNavigator
    private let nextStepProvider: ConcreteNextStepProvider
    private let stateReducer: ConcreteStateReducer

    public init(stepNavigator: ConcreteStepNavigator,
                nextStepProvider: ConcreteNextStepProvider,
                stateReducer: ConcreteStateReducer) {

        self.stepNavigator = stepNavigator
        self.nextStepProvider = nextStepProvider
        self.stateReducer = stateReducer
    }

    public func start(step: ConcreteStepNavigator.Step,
                      with state: ConcreteStateReducer.State) -> Promise<Result> {

        return Promise { completion in
            stepNavigator.navigate(to: step, with: state)
                .complete { stepResult in
                    stateReducer.reduce(state: state, with: stepResult)
                        .complete {
                            switch $0 {
                            case .continue(let reducedState):
                                nextStepProvider.next(for: stepResult, with: reducedState)
                                    .then { start(step: $0, with: reducedState) }
                                    .complete(using: completion)
                            case .finish(let result):
                                completion(result)
                            }
                        }
                }
        }
    }
}
