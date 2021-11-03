public protocol FlowDSLBuilder {
    associatedtype Step
    associatedtype Event
    associatedtype StepResult
    associatedtype State

    typealias Step_ = Declarations.Step<Step, Event>
    typealias On = Declarations.On<Step, Event>
}

extension FlowDSLBuilder {
    public static func step(_ step: Step,
                            @Builders.ConditionBuilder conditions: () -> [On]) -> Step_ {

        return Step_(step: step, conditions: conditions())
    }

    public static func emit(using emitter: @escaping (StepResult, State) -> Event?) -> (StepResult, State) -> Event? {
        return emitter
    }

    public static func on(_ event: Event,
                          @Builders.TransitionBuilder transition: () -> Transition<Step>) -> On {

        return On(event: event, transition: transition())
    }

    public static func next(@Builders.TransitionBuilder transition: () -> Transition<Step>) -> On {
        return On(event: nil, transition: transition())
    }

    public static func forward(to step: Step) -> Transition<Step> {
        return .forwardTo(step)
    }

    public static func back(to step: Step) -> Transition<Step> {
        return .backTo(step)
    }

    public static func back() -> Transition<Step> {
        return .back
    }
}
