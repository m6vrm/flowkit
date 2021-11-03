public enum Transition<Step> {
    case forwardTo(Step)
    case backTo(Step)
    case back
}
