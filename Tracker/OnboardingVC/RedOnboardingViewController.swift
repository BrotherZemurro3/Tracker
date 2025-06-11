import UIKit

final class RedOnboardingViewController: UIViewController {
    
    
    private let colors = UIColors.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupLabel()
}
    func setupBackground() {
        let redBackgroundImage = UIImageView(image: UIImage(named: "redOnboardingBack"))
        redBackgroundImage.contentMode = .scaleAspectFit
        redBackgroundImage.frame = view.bounds
        view.addSubview(redBackgroundImage)
        view.sendSubviewToBack(redBackgroundImage)
    }
    
    func setupLabel() {
        let redOnboardingLabel = UILabel()
        redOnboardingLabel.text = "redOnboardingLabel.title".localized
        redOnboardingLabel.textColor = UIColors.shared.adaptiveButtonText
        redOnboardingLabel.font = .systemFont(ofSize: 32, weight: .bold)
        redOnboardingLabel.numberOfLines = 0
        redOnboardingLabel.textAlignment = .center
        redOnboardingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(redOnboardingLabel)
        
        NSLayoutConstraint.activate([
            redOnboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            redOnboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            redOnboardingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -287),
        ])
    }
}

