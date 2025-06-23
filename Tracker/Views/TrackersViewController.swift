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
    private lazy var filtersButton = UIButton()
    private let colors = UIColors.shared
    private var selectedFilter: TrackerFilter = .all 
    // MARK: - Инициализация
    init(trackersService: TrackersServiceProtocol = TrackersService.shared) {
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
        view.backgroundColor = colors.viewBackgroundColor
        setupUI()
        navigationTabBarAppearance()
        setupCollectionView()
        setupViewModelBindings()
        viewModel.loadTrackers(for: currentDate)
        updateEmptyStateVisibility()
        setupHideKeyboardOnTap()
        setupFiltersButton()
    }
    // MARK: - Обновление состояния пустого списка
    private func updateEmptyStateVisibility() {
        let hasTrackersInStorage = !trackersService.categories.isEmpty
        let isEmptyAfterFilter = viewModel.trackers.isEmpty
        
        // Кнопка фильтра видна, если в хранилище есть трекеры (даже если после фильтрации список пуст)
        filtersButton.isHidden = !hasTrackersInStorage
        
        // Пустое состояние показываем только если после фильтрации ничего не найдено
        imageView.isHidden = !isEmptyAfterFilter
        whatGoingToTrackLabel.isHidden = !isEmptyAfterFilter
        collectionView.isHidden = isEmptyAfterFilter
        
        if let searchText = searchTrackersBar.text, !searchText.isEmpty {
            imageView.image = UIImage(named: "nothingToSearch")
            whatGoingToTrackLabel.text = "Ничего не найдено".localized
        } else {
            imageView.image = imageForEmptyStatisticList
            whatGoingToTrackLabel.text = "whatGoingToTrackLabel.title".localized
        }
    }
    // MARK: - Настройка UI
    private func setupUI() {
        // Лейб Трекеры
        trackersLabel.text = "trackers.title".localized
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
        searchTrackersBar.placeholder = "search.placeholder".localized
        searchTrackersBar.translatesAutoresizingMaskIntoConstraints = false
        searchTrackersBar.searchBarStyle = .minimal
       
        // RTL support
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            searchTrackersBar.semanticContentAttribute = .forceRightToLeft
            searchTrackersBar.searchTextField.semanticContentAttribute = .forceRightToLeft
            searchTrackersBar.searchTextField.textAlignment = .right
        } else {
            searchTrackersBar.searchTextField.textAlignment = .natural
        }
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
        whatGoingToTrackLabel.text = "whatGoingToTrackLabel.title".localized
        whatGoingToTrackLabel.tintColor = .black
        whatGoingToTrackLabel.font = .systemFont(ofSize: 12)
        whatGoingToTrackLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whatGoingToTrackLabel)
        NSLayoutConstraint.activate([
            whatGoingToTrackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Центр по X
            whatGoingToTrackLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            whatGoingToTrackLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            whatGoingToTrackLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupFiltersButton() {
        filtersButton.setTitle("filters.title".localized, for: .normal)
           filtersButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
           filtersButton.setTitleColor(.white, for: .normal)
           filtersButton.backgroundColor = .blue
           filtersButton.layer.cornerRadius = 16
        filtersButton.isHidden = true
           filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
           filtersButton.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(filtersButton)
           
           NSLayoutConstraint.activate([
               filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
               filtersButton.widthAnchor.constraint(equalToConstant: 114),
               filtersButton.heightAnchor.constraint(equalToConstant: 50)
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
        addButton.setImage(UIImage(named: "addTracker")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)) .withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.tintColor = .label
                addButton.addTarget(self, action: #selector(buttonTappedPlus), for: .touchUpInside)
                
        

        let addBarButton = UIBarButtonItem(customView: addButton)
        navigationItem.leftBarButtonItem = addBarButton
        
        //  UIDatePicker на правой кнопке
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
        datePicker.calendar = Calendar.current
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        // Создаем кнопку с UIDatePicker
        let dateBarButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = dateBarButton
    }
    // MARK: - Обработчики событий
    @objc private func buttonTappedPlus() {
        AnalyticsService.shared.report(event: "addTapped", screen: "main")
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
    @objc private func filtersButtonTapped() {
           let filterVC = TrackerFilterViewController(selectedFilter: selectedFilter)
           filterVC.delegate = self
           let navController = UINavigationController(rootViewController: filterVC)
           present(navController, animated: true)
       }
    
    // MARK: - Настройка CollectionView
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.deleteDelegate = self 
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
    func didUpdateTracker(_ tracker: Tracker, in categoryTitle: String, oldCategoryTitle: String?) {
          viewModel.didUpdateTracker(tracker, in: categoryTitle, oldCategoryTitle: oldCategoryTitle)
          updateEmptyStateVisibility()
          navigationController?.popViewController(animated: true)
      }
}
// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        viewModel.loadTrackers(for: currentDate, searchText: searchText.isEmpty ? nil : searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTrackersBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        viewModel.loadTrackers(for: currentDate)
    }
    // Скрываем кнопку "Отмена" при завершении поиска (если нужно)
      func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
          searchBar.setShowsCancelButton(false, animated: true)
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

extension TrackersViewController: TrackersCollectionViewDelegate {
    func didRequestPinTracker(_ trackerId: UUID, isPinned: Bool) {
          if isPinned {
              viewModel.pinTracker(id: trackerId)
          } else {
              viewModel.unpinTracker(id: trackerId)
          }
      }
    func didRequestDeleteTracker(_ trackerId: UUID) {
        let alert = UIAlertController(title: "",
                                  message: "Вы уверены, что хотите удалить этот трекер?",
                                  preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTracker(id: trackerId)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    func didRequestEditTracker(_ tracker: Tracker, categoryTitle: String, completedDays: Int) {
         let editVC = EditTrackerViewController(tracker: tracker, categoryTitle: categoryTitle, completedDays: completedDays)
         editVC.delegate = self
         let navController = UINavigationController(rootViewController: editVC)
         present(navController, animated: true)
     }
 }


extension TrackersViewController: TrackerFilterDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        selectedFilter = filter
        viewModel.setFilter(filter)
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
