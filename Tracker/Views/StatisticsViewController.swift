import UIKit

final class StatisticsViewController: UIViewController {
    private let trackersService: TrackersServiceProtocol
    private let statisticsService: StatisticsServiceProtocol
    
    private let placeholderView = StatisticsPlaceholderView()
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    
    private var statisticsItems: [StatisticsItem] = []
    
    init(
        trackersService: TrackersServiceProtocol = TrackersService(),
        statisticsService: StatisticsServiceProtocol = StatisticsService()
    ) {
        self.trackersService = trackersService
        self.statisticsService = statisticsService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatistics()
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerCompleted),
            name: NSNotification.Name("TrackerCompletedNotification"),
            object: nil
        )
    }
    
    @objc private func handleTrackerCompleted() {
        updateStatistics()
    }
    
    private func updateStatistics() {
        let allTrackers = trackersService.categories.flatMap { $0.trackers }
        let completedTrackers = trackersService.completedTrackers
        
        let statistics = statisticsService.calculateStatistics(
            completedTrackers: completedTrackers,
            allTrackers: allTrackers
        )
        
        statisticsItems = [
            StatisticsItem(title: "Лучший период", value: statistics.bestPeriod),
            StatisticsItem(title: "Идеальные дни", value: statistics.perfectDays),
            StatisticsItem(title: "Трекеров завершено", value: statistics.trackersCompleted),
            StatisticsItem(title: "Среднее значение", value: Int(statistics.averageValue.rounded()))
        ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updatePlaceholderVisibility()
        }
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = statisticsItems.allSatisfy { $0.value == 0 }
        placeholderView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func setupUI() {
        view.backgroundColor = UIColors.shared.viewBackgroundColor
        
        // Настройка placeholder
        placeholderView.configure(
            image: UIImage(named: "nothingToAnalize"),
            text: "Анализировать пока нечего"
        )
        
        // Настройка таблицы
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        
        // Настройка titleLabel
        titleLabel.text = "Статистика"
        titleLabel.font = .boldSystemFont(ofSize: 34)
        titleLabel.textColor = .label // Используем цвет из вашей системы
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false // Добавлено
        titleLabel.numberOfLines = 1 // Добавлено
        
        // Добавление на view
        view.addSubview(titleLabel)
        view.addSubview(placeholderView)
        view.addSubview(tableView)
        
        // Констрейнты
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Title Label constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 41), // Добавлено
            
            // Placeholder constraints
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Table View constraints
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        updatePlaceholderVisibility()
    }}

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statisticsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsCell.reuseIdentifier,
            for: indexPath
        ) as? StatisticsCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: statisticsItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
