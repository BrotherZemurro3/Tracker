import UIKit

final class BlueOnboardingViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupLabel()
    
    }
    
 private func setupBackground() {
        let blueBackgroundImage = UIImageView(image: UIImage(named: "blueOnboardingBack"))
        blueBackgroundImage.contentMode = .scaleAspectFit
        blueBackgroundImage.frame = view.bounds
        view?.addSubview(blueBackgroundImage)
        view?.sendSubviewToBack(blueBackgroundImage)
    }
    
    private func setupLabel() {
        let blueOnboardinglabel = UILabel()
        blueOnboardinglabel.text = "blueOnboardinglabel.title".localized
        blueOnboardinglabel.textColor = UIColor(named: "black[day]")
        blueOnboardinglabel.font = .systemFont(ofSize: 32, weight: .bold)
        blueOnboardinglabel.numberOfLines = 0
        blueOnboardinglabel.textAlignment = .center
        blueOnboardinglabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blueOnboardinglabel)
        
        NSLayoutConstraint.activate([
            blueOnboardinglabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blueOnboardinglabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blueOnboardinglabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -287),
        ])
    }
}
