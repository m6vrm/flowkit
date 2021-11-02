public protocol FlowDSLBuilder {
    associatedtype Step
    associatedtype StepResult
    associatedtype State

    typealias Step_ = FlowDSL.Step<Step, StepResult, State>
    typealias On = FlowDSL.On<Step, StepResult, State>
    typealias Transition = FlowDSL.Transition<Step>
}

extension FlowDSLBuilder {
    public static func step(_ step: Step,
                            @FlowDSL.ConditionBuilder conditions: () -> [On]) -> Step_ {

        return FlowDSL.Step(step: step, conditions: conditions())
    }

    public static func on(_ predicate: @escaping (StepResult, State) -> Bool,
                          @FlowDSL.TransitionBuilder transition: () -> Transition) -> On {

        return FlowDSL.On(predicate: predicate, transition: transition())
    }

    public static func next(@FlowDSL.TransitionBuilder transition: () -> Transition) -> On {
        return FlowDSL.On(predicate: { _, _ in true }, transition: transition())
    }

    public static func transition(_ step: Step) -> Transition {
        return FlowDSL.Transition(step: step)
    }
}

extension FlowDSLBuilder where StepResult: Equatable {
    public static func on(_ expectedStepResult: StepResult,
                          @FlowDSL.TransitionBuilder transition: () -> Transition) -> On {

        return FlowDSL.On(predicate: { stepResult, _ in stepResult == expectedStepResult }, transition: transition())
    }

    public static func on(_ expectedStepResult: StepResult,
                          _ expectedState: State,
                          @FlowDSL.TransitionBuilder transition: () -> Transition)
        -> On where State: Equatable {

        return FlowDSL.On(predicate: { $0 == expectedStepResult && $1 == expectedState },
                          transition: transition())
    }
}
