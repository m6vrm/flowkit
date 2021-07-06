import FlowKit

public final class TransferFlow {
    private let navigator: RouteNavigator
    private let transferRepository: TransferRepository

    private lazy var flowNavigator = TransferFlowNavigator(navigator: navigator)
    private lazy var flowStepTransformer = TransferFlowStepTransformer()
    private lazy var flowStateTransformer = TransferFlowStateTransformer(transferRepository: transferRepository)
    private lazy var flow = Flow(navigator: flowNavigator,
                                 stepTransformer: flowStepTransformer,
                                 stateTransformer: flowStateTransformer)

    init(navigator: RouteNavigator, transferRepository: TransferRepository) {
        self.navigator = navigator
        self.transferRepository = transferRepository
    }

    public func start(with country: Country) -> FlowPromise<Transfer> {
        return flow.start(step: .amountRequired, state: .country(country))
    }
}
