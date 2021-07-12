public final class DefaultStepOverrider<Step, State> {
    public init() { }
}

extension DefaultStepOverrider: StepOverrider {
    public func override(step: Step, with state: State) -> Promise<Step> {
        return .promise(step)
    }
}
