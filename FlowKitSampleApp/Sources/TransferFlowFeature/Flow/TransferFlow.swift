import FlowKit

public final class TransferFlow {
    private let navigator: RouteNavigator
    private let transferRepository: TransferRepository

    private lazy var stepNavigator = TransferFlowStepNavigator(navigator: navigator)
    private lazy var nextStepProvider = TransferFlowNextStepProvider()
    private lazy var stateReducer = TransferFlowStateReducer(transferRepository: transferRepository)

    private lazy var flow = Flow(stepNavigator: stepNavigator,
                                 nextStepProvider: nextStepProvider,
                                 stateReducer: stateReducer)

    init(navigator: RouteNavigator, transferRepository: TransferRepository) {
        self.navigator = navigator
        self.transferRepository = transferRepository
    }

    public func start(with country: Country) -> Promise<Transfer> {
        return flow.start(step: .amount, with: .country(country))
    }
}
