public struct Flow<FlowResult,
                   Navigator: FlowNavigator,
                   StepTransformer: FlowStepTransformer,
                   StateTransformer: FlowStateTransformer>

    where Navigator.FlowStep == StepTransformer.FlowStep,
          Navigator.FlowState == StepTransformer.FlowState,
          StateTransformer.FlowStep == StepTransformer.FlowStep,
          StateTransformer.FlowState == StepTransformer.FlowState,
          StateTransformer.FlowResult == FlowResult {

    private let navigator: Navigator
    private let stepTransformer: StepTransformer
    private let stateTransformer: StateTransformer

    public init(navigator: Navigator,
                stepTransformer: StepTransformer,
                stateTransformer: StateTransformer) {

        self.navigator = navigator
        self.stateTransformer = stateTransformer
        self.stepTransformer = stepTransformer
    }

    public func start(step: Navigator.FlowStep, state: StateTransformer.FlowState) -> FlowPromise<FlowResult> {
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
