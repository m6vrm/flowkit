public enum ReducedState<ReducedState, FlowResult> {
    case `continue`(ReducedState)
    case finish(FlowResult)
}
