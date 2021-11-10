public enum Declarations {
    public struct On<Step, Event> {
        let event: Event?
        let transition: Transition<Step>
    }

    public struct Step<Step, Event> {
        let step: Step?
        let conditions: [On<Step, Event>]
    }

    public struct Definition<Step, Event, StepResult, State> {
        let emitter: (StepResult, State) -> Event?
        let steps: [Declarations.Step<Step, Event>]
    }
}
