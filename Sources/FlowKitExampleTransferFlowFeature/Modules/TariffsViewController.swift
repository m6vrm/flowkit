import UIKit
import FlowKitExamplePromises

final class TariffsViewController: UIViewController {
    private let completion: (Tariff) -> Void

    init(completion: @escaping (Tariff) -> Void) {
        self.completion = completion

        super.init(nibName: nil, bundle: nil)

        title = "Tariffs"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16

        let commissionLabel = UILabel()

        let commission10Button = UIButton(type: .system)
        commission10Button.setTitle("Commission 10%", for: .normal)
        commission10Button.addTarget(self, action: #selector(didTapTariffCommission10Button), for: .touchUpInside)

        let commission20Button = UIButton(type: .system)
        commission20Button.setTitle("Commission 20%", for: .normal)
        commission20Button.addTarget(self, action: #selector(didTapTariffCommission20Button), for: .touchUpInside)

        let commission30Button = UIButton(type: .system)
        commission30Button.setTitle("Commission 30%", for: .normal)
        commission30Button.addTarget(self, action: #selector(didTapTariffCommission30Button), for: .touchUpInside)

        view.addSubview(stackView)
        stackView.addArrangedSubview(commissionLabel)
        stackView.addArrangedSubview(commission10Button)
        stackView.addArrangedSubview(commission20Button)
        stackView.addArrangedSubview(commission30Button)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
        ])
    }
}

private extension TariffsViewController {
    @objc
    func didTapTariffCommission10Button() {
        completion(Tariff(commission: 10))
    }

    @objc
    func didTapTariffCommission20Button() {
        completion(Tariff(commission: 20))
    }

    @objc
    func didTapTariffCommission30Button() {
        completion(Tariff(commission: 30))
    }
}
