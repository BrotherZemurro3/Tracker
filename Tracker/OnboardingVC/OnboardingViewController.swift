import UIKit


final class OnboardingViewController: UIPageViewController {
    
   
    private lazy var fowardToTrackersButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Вот это технологии", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor(named: "black[day]")
        button.translatesAutoresizingMaskIntoConstraints = false
     //   button.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        return button
    }()
    
    lazy var pages: [UIViewController] = {
        let blueONB = BlueOnboardingViewController()
        let redONB = RedOnboardingViewController()
        return [blueONB,redONB]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        view.addSubview(fowardToTrackersButton)
        
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: fowardToTrackersButton.topAnchor, constant: -24),
            
            fowardToTrackersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            fowardToTrackersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fowardToTrackersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            fowardToTrackersButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        
    }
    
    
    @objc private func fowardToTrackersButtonTapped() {
        
        let tabBarController = TabBarController()
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = tabBarController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
}
