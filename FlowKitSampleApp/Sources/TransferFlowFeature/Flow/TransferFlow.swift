import FlowKit

public final class TransferFlow {
    private let navigator: RouteNavigator
    private let transferRepository: TransferRepository

    private lazy var flowNavigator = TransferFlowNavigator(navigator: navigator)
    private lazy var stepTransformer = TransferFlowStepTransformer()
    private lazy var stateReducer = TransferFlowStateReducer(transferRepository: transferRepository)
    private lazy var flow = Flow(navigator: flowNavigator,
                                 stepTransformer: stepTransformer,
                                 stateReducer: stateReducer)

    init(navigator: RouteNavigator, transferRepository: TransferRepository) {
        self.navigator = navigator
        self.transferRepository = transferRepository
    }

    public func start(with country: Country) -> FlowPromise<Transfer> {
        return flow.start(step: .amountRequired, with: .country(country))
    }
}
