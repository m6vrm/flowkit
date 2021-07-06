enum TransferFlowState {
    case country(Country)
    case amount(Int, country: Country)
    case tariff(Tariff, amount: Int, country: Country)
    case transfer(Transfer)
}
