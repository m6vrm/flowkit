import UIKit

public final class Navigator<Route, Builder: ModuleBuilder> where Builder.Route == Route {
    private let driver: NavigationDriver
    private let builder: Builder

    public init(driver: NavigationDriver, builder: Builder) {
        self.driver = driver
        self.builder = builder
    }

    public func forward(to route: Route) {
        let viewController = builder.build(by: route)
        driver.forward(to: viewController)
    }

    public func present(_ route: Route) {
        let viewController = builder.build(by: route)
        driver.present(viewController)
    }

    public func back() {
        driver.back()
    }

    public func backToRoot() {
        driver.backToRoot()
    }
}
