public struct Flow<Result,
                   ConcreteStepOverrider: StepOverrider,
                   ConcreteStepNavigator: StepNavigator,
                   ConcreteStateReducer: StateReducer,
                   ConcreteNextStepProvider: NextStepProvider>

    where ConcreteStepOverrider.Step == ConcreteNextStepProvider.Step,
          ConcreteStepOverrider.State == ConcreteNextStepProvider.State,
          ConcreteStepNavigator.Step == ConcreteNextStepProvider.Step,
          ConcreteStepNavigator.State == ConcreteNextStepProvider.State,
          ConcreteStepNavigator.StepResult == ConcreteNextStepProvider.StepResult,
          ConcreteStateReducer.StepResult == ConcreteNextStepProvider.StepResult,
          ConcreteStateReducer.State == ConcreteNextStepProvider.State,
          ConcreteStateReducer.Result == Result {

    private let stepOverrider: ConcreteStepOverrider
    private let stepNavigator: ConcreteStepNavigator
    private let stateReducer: ConcreteStateReducer
    private let nextStepProvider: ConcreteNextStepProvider

    public init(stepOverrider: ConcreteStepOverrider,
                stepNavigator: ConcreteStepNavigator,
                stateReducer: ConcreteStateReducer,
                nextStepProvider: ConcreteNextStepProvider) {

        self.stepOverrider = stepOverrider
        self.stepNavigator = stepNavigator
        self.stateReducer = stateReducer
        self.nextStepProvider = nextStepProvider
    }

    public func start(from step: ConcreteStepNavigator.Step,
                      with state: ConcreteStateReducer.State) -> Promise<Result> {

        return stepOverrider.override(step: step, with: state)
            .then { stepNavigator.navigate(to: $0, with: state) }
            .then { `continue`(from: $0, with: state) }
    }

    public func `continue`(from stepResult: ConcreteStepNavigator.StepResult,
                           with state: ConcreteStateReducer.State) -> Promise<Result> {

        return .promise { completion in
            stateReducer.reduce(state: state, with: stepResult)
                .complete {
                    switch $0 {
                    case .continue(let reducedState):
                        nextStepProvider.next(for: stepResult, with: reducedState)
                            .then { start(from: $0, with: reducedState) }
                            .complete(using: completion)
                    case .finish(let result):
                        completion(result)
                    }
                }
        }
    }
}
