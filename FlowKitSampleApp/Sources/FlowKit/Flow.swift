public struct Flow<Result,
                   Navigator: FlowNavigator,
                   StepTransformer: FlowStepTransformer,
                   StateReducer: FlowStateReducer>

    where Navigator.Step == StepTransformer.Step,
          Navigator.State == StepTransformer.State,
          StateReducer.Step == StepTransformer.Step,
          StateReducer.State == StepTransformer.State,
          StateReducer.Result == Result {

    private let navigator: Navigator
    private let stepTransformer: StepTransformer
    private let stateReducer: StateReducer

    public init(navigator: Navigator,
                stepTransformer: StepTransformer,
                stateReducer: StateReducer) {

        self.navigator = navigator
        self.stepTransformer = stepTransformer
        self.stateReducer = stateReducer
    }

    public func start(step: Navigator.Step, with state: StateReducer.State) -> FlowPromise<Result> {
        return FlowPromise { completion in
            stateReducer.reduce(state: state, with: step)
                .complete {
                    switch $0 {
                    case .continue(let reducedState):
                        stepTransformer.transform(step: step, with: state)
                            .then { navigator.navigate(to: $0, with: reducedState) }
                            .then { start(step: $0, with: reducedState) }
                            .complete(using: completion)
                    case .finish(let result):
                        completion(result)
                    }
                }
        }
    }
}
