import UIKit

final class RedOnboardingViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let redBackgroundImage = UIImageView(image: UIImage(named: "redOnboardingBack"))
        redBackgroundImage.contentMode = .scaleAspectFit
        redBackgroundImage.frame = view.bounds
        view?.addSubview(redBackgroundImage)
        view?.sendSubviewToBack(redBackgroundImage)
        
        let redOnboardinglabel = UILabel()
        redOnboardinglabel.text = "Даже если это не литры воды и йога"
        redOnboardinglabel.textColor = UIColor(named: "black[day]")
        redOnboardinglabel.font = .systemFont(ofSize: 32, weight: .bold)
        redOnboardinglabel.numberOfLines = 0
        redOnboardinglabel.textAlignment = .center
        redOnboardinglabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(redOnboardinglabel)
        
        NSLayoutConstraint.activate([
            redOnboardinglabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            redOnboardinglabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            redOnboardinglabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -304),
        ])
    }
}

