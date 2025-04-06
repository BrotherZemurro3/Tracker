import UIKit

final class TrackersCollectionView: UICollectionView {
    private var viewModel: TrackersViewModel
    private var currentDate: Date = Date()
    
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        
        configureCollectionView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Кофигурация ячейки
    private func configureCollectionView() {
        delegate = self
        dataSource = self
        register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        register(TrackersSupplementaryView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: "Header")
    }
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.reloadData()
            }
        }
    }
    // MARK: - Обновление даты
    func update(date: Date) {
        currentDate = date
        viewModel.loadTrackers(for: date)
    }
}
// MARK: - UICollectionViewDataSource

extension TrackersCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.trackers[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackersCollectionViewCell
        
        let tracker = viewModel.trackers[indexPath.section].trackers[indexPath.row]
        let completedDays = viewModel.getCompletedDaysCount(for: tracker.id)
        let isCompletedToday = viewModel.isTrackerCompletedToday(tracker.id)
        
        cell.configure(
            with: tracker,
            completedDays: viewModel.getCompletedDaysCount(for: tracker.id),
            isCompletedToday: viewModel.isTrackerCompletedToday(tracker.id),
            currentDate: viewModel.currentDate
        )
        
        cell.onActionButtonTapped = { [weak self] trackerId, isCompleted in
            if isCompleted {
                self?.viewModel.completeTracker(id: trackerId, date: Date())
            } else {
                self?.viewModel.uncompleteTracker(id: trackerId, date: Date())
            }
        }
        
        return cell
    }
    
    
    private func findIndexPath(for trackerId: UUID) -> IndexPath? {
        for (section, category) in viewModel.trackers.enumerated() {
            if let row = category.trackers.firstIndex(where: { $0.id == trackerId }) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 16 * 3) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "Header",
            for: indexPath) as! TrackersSupplementaryView
        
        header.titleLabel.text = viewModel.trackers[indexPath.section].title
        return header
    }
}
