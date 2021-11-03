import FlowKitExampleNavigation

public final class TransferFlowFactory {
    private let navigationDriver: NavigationDriver

    public init(navigatinDriver: NavigationDriver) {
        self.navigationDriver = navigatinDriver
    }

    public func makeTransferFlow() -> TransferFlow {
        let moduleBuilder = ModuleBuilder()
        let navigator = Navigator(driver: navigationDriver, builder: moduleBuilder)
        let transferRepository = RandomTransferRepository()
        return TransferFlow(navigator: navigator, transferRepository: transferRepository)
    }
}
