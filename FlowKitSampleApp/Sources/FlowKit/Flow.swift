public struct Flow<Result,
                   Navigator: FlowNavigator,
                   StepTransformer: FlowStepTransformer,
                   StateTransformer: FlowStateTransformer>

    where Navigator.Step == StepTransformer.Step,
          Navigator.State == StepTransformer.State,
          StateTransformer.Step == StepTransformer.Step,
          StateTransformer.State == StepTransformer.State,
          StateTransformer.Result == Result {

    private let navigator: Navigator
    private let stepTransformer: StepTransformer
    private let stateTransformer: StateTransformer

    public init(navigator: Navigator,
                stepTransformer: StepTransformer,
                stateTransformer: StateTransformer) {

        self.navigator = navigator
        self.stepTransformer = stepTransformer
        self.stateTransformer = stateTransformer
    }

    public func start(step: Navigator.Step, state: StateTransformer.State) -> FlowPromise<Result> {
        return FlowPromise { completion in
            zip(stateTransformer.transform(state: state, for: step),
                stepTransformer.transform(step: step, with: state))
                .complete {
                    let (stateTransformationResult, transformedStep) = $0

                    switch stateTransformationResult {
                    case .continue(let transformedState):
                        navigator.navigate(to: transformedStep, with: transformedState)
                            .then { start(step: $0, state: transformedState) }
                            .complete(using: completion)
                    case .finish(let result):
                        completion(result)
                    }
                }
        }
    }
}
