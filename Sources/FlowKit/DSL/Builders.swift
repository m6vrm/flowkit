public enum Builders {
    @resultBuilder
    public struct TransitionBuilder {
        public static func buildBlock<Step>(_ component: Transition<Step>) -> Transition<Step> {
            return component
        }
    }

    @resultBuilder
    public struct ConditionBuilder {
        public static func buildBlock<Step, Event>(_ components: Declarations.On<Step, Event>...)
            -> [Declarations.On<Step, Event>] {

            return components
        }
    }

    @resultBuilder
    public struct DefinitionBuilder {
        public static func buildBlock<Step, Event, StepResult, State>(
            _ emitter: @escaping (StepResult, State) -> Event?,
            _ steps: Declarations.Step<Step, Event>...) -> Declarations.Definition<Step, Event, StepResult, State> {

            return Declarations.Definition(emitter: emitter, steps: steps)
        }
    }
}
