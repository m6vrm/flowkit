import PromiseKit

enum Route {
    case amount(country: Country, completion: (Int) -> Void)
    case invalidAmount
    case tariffs(completion: (Tariff) -> Void)
    case confirmation(country: Country,
                      amount: Int,
                      tariff: Tariff,
                      completion: (ConfirmationResult) -> Void)
    case success(transfer: Transfer, completion: () -> Void)
}
