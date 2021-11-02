public enum FlowDSL {
    public struct Transition<Step> {
        let step: Step
    }

    @resultBuilder
    public struct TransitionBuilder {
        public static func buildBlock<Step>(_ component: Transition<Step>) -> Transition<Step> {
            return component
        }
    }

    public struct On<Step, StepResult, State> {
        let predicate: (StepResult, State) -> Bool
        let transition: Transition<Step>
    }

    @resultBuilder
    public struct ConditionBuilder {
        public static func buildBlock<Step, StepResult, State>(_ components: On<Step, StepResult, State>...)
            -> [On<Step, StepResult, State>] {

            return components
        }
    }

    public struct Step<Step, StepResult, State> {
        let step: Step
        let conditions: [On<Step, StepResult, State>]
    }

    @resultBuilder
    public struct StepBuilder {
        public static func buildBlock<Step, StepResult, State>(_ components: FlowDSL.Step<Step, StepResult, State>...)
            -> [FlowDSL.Step<Step, StepResult, State>] {

            return components
        }
    }

    public struct Flow<Step, StepResult, State> {
        let steps: [FlowDSL.Step<Step, StepResult, State>]

        public init(@StepBuilder steps: () -> [FlowDSL.Step<Step, StepResult, State>]) {
            self.steps = steps()
        }
    }
}
