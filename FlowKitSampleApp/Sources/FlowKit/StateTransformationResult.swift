public enum StateTransformationResult<TransformedState, FlowResult> {
    case `continue`(TransformedState)
    case finish(FlowResult)
}
