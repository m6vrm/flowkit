import FlowKitExamplePromises

enum Route {
    case amount(country: Country, completion: (Int) -> Void)
    case invalidAmount
    case tariffs(completion: (Tariff) -> Void)
    case confirmation(loadingPublisher: Publisher<Bool>,
                      country: Country,
                      amount: Int,
                      tariff: Tariff,
                      completion: (ConfirmationResult) -> Void)
    case success(transfer: Transfer, completion: () -> Void)

    case alert(title: String, retry: () -> Void)
}
