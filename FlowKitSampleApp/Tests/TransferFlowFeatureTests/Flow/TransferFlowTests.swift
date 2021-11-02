import XCTest

@testable import TransferFlowFeature
@testable import FlowKit
@testable import PromiseKit

final class TransferFlowTests: XCTestCase {
    private lazy var transferRepository = RandomTransferRepositoryMock()
    private lazy var transitionProvider = TransferFlowTransitionProvider()
    private lazy var stateReducer = TransferFlowStateReducer(transferRepository: transferRepository)

    func testTransferFlow() {
        let country: Country = .russia
        let amount = 100
        let comission = 50

        let transitionNavigator = makeTransitionNavigator { step, state in
            switch step {
            case .amount: return .amount(amount: amount)
            case .tariffs: return .tariffs(tariff: Tariff(comission: comission))
            case .confirmation: return .confirmation(result: .continue, loadingPublisher: Publisher())
            case .success: return .success
            case .finish: return .finish
            case .invalidAmount: return nil
            }
        }

        let flow = makeTransferFlow(transitionNavigator: transitionNavigator)
        let expectation = expectation(description: "waiting for flow")

        flow
            .start(from: .amount, with: .country(country))
            .complete { transfer in
                expectation.fulfill()

                XCTAssertEqual(transfer.country, country)
                XCTAssertEqual(transfer.amount, amount)
                XCTAssertEqual(transfer.tariff.comission, comission)
            }

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(transitionNavigator.steps, [
            .amount,
            .tariffs,
            .confirmation,
            .success,
            .finish,
        ])
    }

    func testTransferFlowWithInvalidAmount() {
        let country: Country = .russia
        let amount = 50
        let comission = 50

        let transitionNavigator = makeTransitionNavigator { step, state in
            switch step {
            case .amount: return .amount(amount: amount)
            case .tariffs: return .tariffs(tariff: Tariff(comission: comission))
            case .confirmation: return .confirmation(result: .continue, loadingPublisher: Publisher())
            case .success: return .success
            case .finish: return .finish
            case .invalidAmount: return nil
            }
        }

        let flow = makeTransferFlow(transitionNavigator: transitionNavigator)

        flow
            .start(from: .amount, with: .country(country))
            .complete()

        XCTAssertEqual(transitionNavigator.steps, [
            .amount,
            .invalidAmount,
        ])
    }

    func testTransferFlowWithBackToAmount() {
        let country: Country = .russia
        let amount = 100
        let comission = 50
        var editAmount = true

        let transitionNavigator = makeTransitionNavigator { step, state in
            switch step {
            case .amount: return .amount(amount: amount)
            case .tariffs: return .tariffs(tariff: Tariff(comission: comission))
            case .confirmation:
                defer { editAmount = false }
                return .confirmation(result: editAmount ? .editAmount : .continue,
                                     loadingPublisher: Publisher())
            default: return nil
            }
        }

        let flow = makeTransferFlow(transitionNavigator: transitionNavigator)

        flow
            .start(from: .amount, with: .country(country))
            .complete()

        XCTAssertEqual(transitionNavigator.steps, [
            .amount,
            .tariffs,
            .confirmation,
            .amount,
            .tariffs,
            .confirmation,
            .success,
        ])
    }

    func testTransferFlowWithBackToTariffs() {
        let country: Country = .russia
        let amount = 100
        let comission = 50
        var editTariff = true

        let transitionNavigator = makeTransitionNavigator { step, state in
            switch step {
            case .amount: return .amount(amount: amount)
            case .tariffs: return .tariffs(tariff: Tariff(comission: comission))
            case .confirmation:
                defer { editTariff = false }
                return .confirmation(result: editTariff ? .editTariff : .continue,
                                     loadingPublisher: Publisher())
            default: return nil
            }
        }

        let flow = makeTransferFlow(transitionNavigator: transitionNavigator)

        flow
            .start(from: .amount, with: .country(country))
            .complete()

        XCTAssertEqual(transitionNavigator.steps, [
            .amount,
            .tariffs,
            .confirmation,
            .tariffs,
            .confirmation,
            .success,
        ])
    }
}

private extension TransferFlowTests {
    func makeTransitionNavigator(navigator: @escaping (TransferFlowStep, TransferFlowState) -> TransferFlowStepResult?)
        -> RecordingTransitionNavigator<TransferFlowStep, TransferFlowState, TransferFlowStepResult> {

        return RecordingTransitionNavigator(navigator: navigator)
    }

    func makeTransferFlow(transitionNavigator: RecordingTransitionNavigator<TransferFlowStep,
                                                                TransferFlowState,
                                                                TransferFlowStepResult>)
        -> Flow<Transfer,
                RecordingTransitionNavigator<TransferFlowStep,
                                       TransferFlowState,
                                       TransferFlowStepResult>,
                TransferFlowStateReducer,
                TransferFlowTransitionProvider> {

        return Flow(transitionNavigator: transitionNavigator,
                    stateReducer: stateReducer,
                    transitionProvider: transitionProvider)
    }
}
