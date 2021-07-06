import NavigationKit
import UIKit

protocol RouteNavigator {
    func forward(to route: Route)
    func back()
    func backToRoot()
}
