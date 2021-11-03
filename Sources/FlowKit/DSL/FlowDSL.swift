public struct FlowDSL<Step, Event, StepResult, State> {
    let definition: Declarations.Definition<Step, Event, StepResult, State>

    public init(@Builders.DefinitionBuilder definition: () -> Declarations.Definition<Step, Event, StepResult, State>) {
        self.definition = definition()
    }
}
