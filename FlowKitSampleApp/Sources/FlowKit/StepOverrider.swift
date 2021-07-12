public protocol StepOverrider {
    associatedtype Step
    associatedtype State

    func override(step: Step, with: State) -> Promise<Step>
}
