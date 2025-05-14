import UIKit


final class OnboardingViewController: UIPageViewController {
    
    lazy var pages: [UIViewController] = {
        let blueONB = BlueOnboardingViewController()
        let redONB = RedOnboardingViewController()
    }()
    
}
