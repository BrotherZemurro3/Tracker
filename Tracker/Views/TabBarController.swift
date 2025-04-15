import UIKit

final class TabBarController: UITabBarController {
    
    private enum TabBarItem: Int {
        case statistic
        case trackers
        
        var title: String {
            switch self {
            case .statistic: return "Статистика"
            case .trackers: return "Трекеры"
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .statistic: return UIImage(named: "statisticTabBarUnselected")
            case .trackers: return UIImage(named: "trackersTabBarUnselected")
            }
        }
        
        var selectedIcon: UIImage? {
            switch self {
            case .statistic: return UIImage(named: "statisticTabBarSelected")
            case .trackers: return UIImage(named: "trackersTabBarSelected")
            }
        }
    }
    
    private let unselectedTitleColor: UIColor = .gray
    private let selectedTitleColor: UIColor = .ypBlue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBar()
        self.delegate = self
        view.backgroundColor = .lightGray
    }
    
    private func setupTabBar() {
        var controllers: [UIViewController] = []
        
        tabBar.shadowImage = UIImage() // Убираем стандартную тень (если есть)
           tabBar.backgroundImage = UIImage() // Убираем фоновое изображение (если нужно)
           
           // Создаем изображение для разделителя (1px высотой)
           let separator = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5))
           separator.backgroundColor = UIColor.lightGray // Цвет разделителя
           separator.isUserInteractionEnabled = false
           
           // Добавляем разделитель
           tabBar.addSubview(separator)
           
           // Обновляем цвета элементов
           updateTabBarItemColors(selectedIndex: selectedIndex)
        
        
        for item in [TabBarItem.trackers, TabBarItem.statistic] {
            let controller = createController(for: item)
            controllers.append(controller)
        }
        
        self.viewControllers = controllers
        self.tabBar.tintColor = selectedTitleColor
        self.tabBar.unselectedItemTintColor = unselectedTitleColor
        
        updateTabBarItemColors(selectedIndex: selectedIndex)
    }
    
    private func createController(for item: TabBarItem) -> UIViewController {
        let controller: UIViewController
        
        switch item {
        case .trackers:
            controller = UINavigationController(rootViewController: TrackersViewController())
        case .statistic:
            controller = UINavigationController(rootViewController: StatisticsViewController())
        }
        
        let tabBarItem = UITabBarItem(
            title: item.title,
            image: item.icon,
            selectedImage: item.selectedIcon
        )
        
        controller.tabBarItem = tabBarItem
        controller.tabBarItem.tag = item.rawValue
        
        setTitleAttributes(for: controller.tabBarItem, selected: false)
        return controller
    }
    
    private func updateTabBarItemColors(selectedIndex: Int) {
        guard let items = tabBar.items else { return }
        
        for (index, item) in items.enumerated() {
            setTitleAttributes(for: item, selected: index == selectedIndex)
        }
    }
    
    private func setTitleAttributes(for item: UITabBarItem, selected: Bool) {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: selected ? selectedTitleColor : unselectedTitleColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        item.setTitleTextAttributes(attributes, for: .normal)
        item.setTitleTextAttributes(attributes, for: .selected)
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateTabBarItemColors(selectedIndex: tabBarController.selectedIndex)
    }
}
