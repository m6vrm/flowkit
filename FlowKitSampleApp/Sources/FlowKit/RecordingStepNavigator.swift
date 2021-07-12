public final class RecordingStepNavigator<Step, State, StepResult> {
    public private(set) var steps: [Step] = []

    private let navigator: (Step, State) -> StepResult?

    public init(navigator: @escaping (Step, State) -> StepResult?) {
        self.navigator = navigator
    }
}

extension RecordingStepNavigator: StepNavigator {
    public func navigate(to step: Step, with state: State) -> Promise<StepResult> {
        steps.append(step)
        return navigator(step, state).map { .promise($0) } ?? .nothing
    }
}
