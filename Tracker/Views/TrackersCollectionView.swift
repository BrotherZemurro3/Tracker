import UIKit

final class TrackersCollectionView: UICollectionView {
    // MARK: - Properties
    private var viewModel: TrackersViewModel?
    private var trackers: [TrackerCategory] = []
    
    // MARK: - Init
    init(viewModel: TrackersViewModel? = nil) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        
        configureCollectionView()
        setupBindings()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func configureCollectionView() {
        delegate = self
        dataSource = self
        register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
    }
    
    private func setupBindings() {
        viewModel?.onDataUpdated = { [weak self] in
            self?.trackers = self?.viewModel?.trackers ?? []
            DispatchQueue.main.async {
                self?.reloadData()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension TrackersCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackers[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackersCollectionViewCell else {
            return UICollectionViewCell()
        }
        let tracker = trackers[indexPath.section].trackers[indexPath.row]
        cell.configure(with: tracker)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 32) / 2, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
