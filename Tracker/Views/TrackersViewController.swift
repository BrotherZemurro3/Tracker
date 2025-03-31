import UIKit



class TrackersViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var collectionView = TrackersCollectionView()
    private let trackersService: TrackersServiceProtocol
    private let viewModel: TrackersViewModel
    let appearance = UINavigationBarAppearance()
    let searchTrackersBar = UISearchBar()
    let trackersLabel = UILabel()
    let imageForEmptyStatisticList = UIImage(named: "EmptyStatistic")
    let whatGoingToTrackLabel = UILabel()
    let imageView: UIImageView // Убираем инициализацию здесь

    init(trackersService: TrackersServiceProtocol = TrackersService()) {
        self.trackersService = trackersService
        self.viewModel = TrackersViewModel(trackersService: trackersService)
        self.collectionView = TrackersCollectionView(viewModel: viewModel) // Передаём ViewModel в коллекцию
        self.imageView = UIImageView(image: imageForEmptyStatisticList)
        super.init(nibName: nil, bundle: nil)
    }

    
    
    
    private var currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        // updateUI()
        navigationTabBarAppearance()
        setupCollectionView()
        updateEmptyStateVisibility()
    }
    
    private func setupUI() {
        // Лейб Трекеры
        trackersLabel.text = "Трекеры"
        trackersLabel.tintColor = .black
        trackersLabel.font = .systemFont(ofSize: 32, weight: .bold)
        trackersLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersLabel)
        NSLayoutConstraint.activate([
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1)
        ])
        // Строка поиска трекеров
        searchTrackersBar.translatesAutoresizingMaskIntoConstraints = false
        searchTrackersBar.searchBarStyle = .minimal
        view.addSubview(searchTrackersBar)
        NSLayoutConstraint.activate([
            searchTrackersBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTrackersBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchTrackersBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7)
            
        ])
        // Картинка по центу "Что будем отслеживать"
      
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
        ])
        
        // "Что будем отслеживать"
        whatGoingToTrackLabel.text = "Что будем отслеживать?"
        whatGoingToTrackLabel.tintColor = .black
        whatGoingToTrackLabel.font = UIFont(name: "YS Display-Medium", size: 16)
        whatGoingToTrackLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whatGoingToTrackLabel)
        NSLayoutConstraint.activate([
            whatGoingToTrackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Центр по X
            whatGoingToTrackLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            whatGoingToTrackLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            whatGoingToTrackLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
// MARK: - NavigationTabBar
    func navigationTabBarAppearance() {
        // Внешний вид навигационного бара
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear // Убираем фон
        appearance.shadowColor = .clear // Убираем тень
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // Кнопка с иконкой "плюс"
        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal)
        addButton.tintColor = .black
        addButton.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        addButton.addTarget(self, action: #selector(buttonTappedPlus), for: .touchUpInside)
        let addBarButton = UIBarButtonItem(customView: addButton)
        navigationItem.leftBarButtonItem = addBarButton
        
        // Настроим UIDatePicker на правой кнопке
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        // Создаем кнопку с UIDatePicker
        let dateBarButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = dateBarButton
    }
    
    @objc func buttonTappedPlus() {
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.delegate = self
        let navController = UINavigationController(rootViewController: createTrackerVC)
        present(navController, animated: true)
    }
    @objc func dateChanged(_ sender: UIDatePicker) {
        print("Выбрана дата: \(sender.date)")
    }
    
// MARK: - CollectionViewUISetUp
    
    func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTrackersBar.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func updateEmptyStateVisibility() {
        let isEmpty = trackersService.categories.isEmpty
        print("Проверка пустоты: \(isEmpty ? "пусто" : "есть данные")")
        imageView.isHidden = !isEmpty
        whatGoingToTrackLabel.isHidden = !isEmpty
    }
}

extension TrackersViewController: CreateTrackerDelegate {
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String) {
        viewModel.addTracker(tracker, to: categoryTitle) // Используем ViewModel
    }
}
