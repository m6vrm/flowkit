import FlowKit

public final class TransferFlow {
    private let navigator: RouteNavigator
    private let transferRepository: TransferRepository
    private let analytics: TransferFlowAnalyticsTracker

    private lazy var transitionNavigator = TransferFlowTransitionNavigator(navigator: navigator)
    private lazy var transitionProvider = TransferFlowTransitionProvider()
    private lazy var stateReducer = TransferFlowStateReducer(transferRepository: transferRepository,
                                                             analytics: analytics)

    private lazy var flow = Flow(transitionNavigator: transitionNavigator,
                                 stateReducer: stateReducer,
                                 transitionProvider: transitionProvider)

    init(navigator: RouteNavigator,
         transferRepository: TransferRepository,
         analytics: TransferFlowAnalyticsTracker) {

        self.navigator = navigator
        self.transferRepository = transferRepository
        self.analytics = analytics
    }

    public func start(with country: Country) -> Promise<Transfer> {
        return flow.start(from: .amount, with: .country(country))
    }
}
