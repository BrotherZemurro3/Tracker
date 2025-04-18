import UIKit

class TrackersViewController: UIViewController {
    // MARK: - Свойства
    private let trackersService: TrackersServiceProtocol
    private let viewModel: TrackersViewModel
    private let collectionView: TrackersCollectionView
    private let appearance = UINavigationBarAppearance()
    private let searchTrackersBar = UISearchBar()
    private let trackersLabel = UILabel()
    private let imageForEmptyStatisticList = UIImage(named: "EmptyStatistic")
    private let whatGoingToTrackLabel = UILabel()
    private let imageView: UIImageView
    private var currentDate = Date()
    // MARK: - Инициализация
    init(trackersService: TrackersServiceProtocol = TrackersService()) {
        self.trackersService = trackersService
        self.viewModel = TrackersViewModel(trackersService: trackersService)
        self.collectionView = TrackersCollectionView(viewModel: self.viewModel)
        self.imageView = UIImageView(image: imageForEmptyStatisticList)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        navigationTabBarAppearance()
        setupCollectionView()
        setupViewModelBindings()
        viewModel.loadTrackers(for: currentDate)
        updateEmptyStateVisibility()
        setupHideKeyboardOnTap()
    }
    // MARK: - Обновление состояния пустого списка
    private func updateEmptyStateVisibility() {
        let isEmpty = viewModel.trackers.isEmpty // Используем viewModel.trackers вместо trackersService.categories
        imageView.isHidden = !isEmpty
        whatGoingToTrackLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty // Добавляем скрытие коллекции при пустом состоянии
    }
    
    // MARK: - Настройка UI
    private func setupUI() {
        // Лейб Трекеры
        trackersLabel.text = "Трекеры"
        trackersLabel.tintColor = .black
        trackersLabel.font = .systemFont(ofSize: 34, weight: .bold)
        trackersLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersLabel)
        NSLayoutConstraint.activate([
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1)
        ])
        // Строка поиска трекеров
        searchTrackersBar.delegate = self
        searchTrackersBar.placeholder = "Поиск"
        searchTrackersBar.translatesAutoresizingMaskIntoConstraints = false
        searchTrackersBar.searchBarStyle = .minimal
        view.addSubview(searchTrackersBar)
        NSLayoutConstraint.activate([
            searchTrackersBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchTrackersBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            searchTrackersBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: -1),
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
        whatGoingToTrackLabel.font = .systemFont(ofSize: 12)
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
    private func navigationTabBarAppearance() {
        // Внешний вид навигационного бара
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear // Убираем фон
        appearance.shadowColor = .clear // Убираем тень
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // Кнопка с иконкой "плюс"
        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(named: "addTracker")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)), for: .normal)
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
    // MARK: - Обработчики событий
    @objc private func buttonTappedPlus() {
        let selectionVC = SelectionStateOfTrackerViewController()
        selectionVC.delegate = self
        let navController = UINavigationController(rootViewController: selectionVC)
        present(navController, animated: true)
    }
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        print("Выбрана дата: \(currentDate), день недели: \(weekday)")
        viewModel.loadTrackers(for: currentDate)
    }
    
    
    // MARK: - Настройка CollectionView
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTrackersBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -4),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 4),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    // MARK: - Связывание ViewModel
    private func setupViewModelBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                print("Обновление UI. Категорий: \(self?.viewModel.trackers.count ?? 0)")
                self?.collectionView.reloadData()
                self?.updateEmptyStateVisibility()
            }
        }
    }
}
// MARK: - Делегат создания трекера
extension TrackersViewController: TrackerCreationDelegate {
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String) {
        viewModel.addTracker(tracker, to: categoryTitle)
        updateEmptyStateVisibility()
        dismiss(animated: true)
    }
}
// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Скрываю клавиатуру при нажатии на кнопку "Search" или "Готово"
        searchBar.resignFirstResponder()
        
    }
    // Скрываю клавиатуру при начале скролла Test
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTrackersBar.resignFirstResponder()
    }
}
extension UIViewController {
    func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // Скрывает все текстовые поля и клавиатуру
    }
}
/*
 // Превью
 #if DEBUG
 import SwiftUI
 
 struct TrackersViewController_Preview: PreviewProvider {
 static var previews: some View {
 let viewController = TrackersViewController()
 return UINavigationController(rootViewController: viewController)
 .toPreview()
 .edgesIgnoringSafeArea(.all)
 }
 }
 extension UIViewController {
 func toPreview() -> some View {
 Preview(viewController: self)
 }
 
 private struct Preview: UIViewControllerRepresentable {
 let viewController: UIViewController
 
 func makeUIViewController(context: Context) -> some UIViewController {
 viewController
 }
 
 func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
 // Nothing to update
 }
 }
 }
 #endif
 */
