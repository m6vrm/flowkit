protocol RouteNavigator {
    func forward(to: Route)
    func present(_: Route)
    func back()
    func backToRoot()
}
