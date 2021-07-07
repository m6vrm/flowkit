public struct Flow<Result,
                   ConcreteStepNavigator: StepNavigator,
                   ConcreteStepResultTransformer: StepResultTransformer,
                   ConcreteStateReducer: StateReducer>

    where ConcreteStepNavigator.Step == ConcreteStepResultTransformer.Step,
          ConcreteStepNavigator.State == ConcreteStepResultTransformer.State,
          ConcreteStepNavigator.StepResult == ConcreteStepResultTransformer.StepResult,
          ConcreteStateReducer.StepResult == ConcreteStepResultTransformer.StepResult,
          ConcreteStateReducer.State == ConcreteStepResultTransformer.State,
          ConcreteStateReducer.Result == Result {

    private let stepNavigator: ConcreteStepNavigator
    private let stepResultTransformer: ConcreteStepResultTransformer
    private let stateReducer: ConcreteStateReducer

    public init(stepNavigator: ConcreteStepNavigator,
                stepResultTransformer: ConcreteStepResultTransformer,
                stateReducer: ConcreteStateReducer) {

        self.stepNavigator = stepNavigator
        self.stepResultTransformer = stepResultTransformer
        self.stateReducer = stateReducer
    }

    public func start(step: ConcreteStepNavigator.Step, with state: ConcreteStateReducer.State) -> Promise<Result> {
        return Promise { completion in
            stepNavigator.navigate(to: step, with: state)
                .complete { stepResult in
                    stateReducer.reduce(state: state, with: stepResult)
                        .complete {
                            switch $0 {
                            case .continue(let reducedState):
                                stepResultTransformer.transform(stepResult: stepResult, with: state)
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
