public enum FlowDSL {
    @resultBuilder
    public struct TransitionBuilder {
        public static func buildBlock<Step>(_ component: Transition<Step>) -> Transition<Step> {
            return component
        }
    }

    public struct On<Step, Event> {
        let event: Event?
        let transition: Transition<Step>
    }

    @resultBuilder
    public struct ConditionBuilder {
        public static func buildBlock<Step, Event>(_ components: On<Step, Event>...)
            -> [On<Step, Event>] {

            return components
        }
    }

    public struct Step<Step, Event> {
        let step: Step
        let conditions: [On<Step, Event>]
    }

    public struct Definition<Step, Event, StepResult, State> {
        let emitter: (StepResult, State) -> Event?
        let steps: [FlowDSL.Step<Step, Event>]
    }

    @resultBuilder
    public struct DefinitionBuilder {
        public static func buildBlock<Step, Event, StepResult, State>(
            _ emitter: @escaping (StepResult, State) -> Event?,
            _ steps: FlowDSL.Step<Step, Event>...) -> Definition<Step, Event, StepResult, State> {

            return Definition(emitter: emitter, steps: steps)
        }
    }

    public struct Flow<Step, Event, StepResult, State> {
        let definition: Definition<Step, Event, StepResult, State>

        public init(@DefinitionBuilder definition: () -> Definition<Step, Event, StepResult, State>) {
            self.definition = definition()
        }
    }
}
