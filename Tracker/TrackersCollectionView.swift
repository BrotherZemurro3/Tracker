import UIKit



class TrackersCollectionView: UICollectionView {
    private var viewModel: TrackersService
    
    init(viewModel: TrackersService) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        //Размер ячеек
        layout.itemSize = CGSize(width: 167, height: 90)
        layout.minimumInteritemSpacing = 0
        
        // Настройка хедеров и футеров
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
                layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        super.init(frame: .zero, collectionViewLayout: layout)
        // Настройка ячеек для переиспользования
        register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier:  TrackersCollectionViewCell.reuseIdentifier)
        // Регистрация хедеров и футеров для секций
        register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        // delegate && datasource
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: TrackersService) {
        self.viewModel = viewModel
    }
    

    @objc private func trackerButtonTapped(_ sender: UIButton) {
         guard let indexPath = indexPathForItem(at: sender.convert(CGPoint.zero, to: self)) else { return }
         let tracker = viewModel.categories[indexPath.section].trackers[indexPath.item]
         let currentDate = Date() // Или используйте выбранную дату
         
         if viewModel.completedTrackers.contains(where: { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }) {
             viewModel.uncompleteTracker(id: tracker.id, date: currentDate)
         } else {
             viewModel.completeTracker(id: tracker.id, date: currentDate)
         }
         
         reloadItems(at: [indexPath])
     }
}

extension TrackersCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier, for: indexPath) as! TrackersCollectionViewCell
        let category = viewModel.categories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        let completedDays = viewModel.completedTrackers.filter { $0.id == tracker.id}.count
        let isCompleted = viewModel.completedTrackers.contains {$0.id == tracker.id}
        
        cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompleted)
        cell.actionButton.tag = indexPath.item
        cell.actionButton.addTarget(self, action: #selector(trackerButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    // Количество ячеек
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories[section].trackers.count
    }
  
   // Хедер и футер
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
        view.titleLabel.text = "Supplementary view"
        return view
    }

    
    
}
extension TrackersCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let label = UILabel()
        label.text = "Тут SupplementaryView 1"
        label.sizeToFit()
        return CGSize(width: collectionView.frame.width, height: label.frame.height + 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let label = UILabel()
        label.text = "Тут SupplementaryView 2"
        label.sizeToFit()
        return CGSize(width: collectionView.frame.width, height: label.frame.height + 50)
    }
    // Задаём размеры ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2, height: 50)
    }
    // Минимальный отступ между ячейками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
          return 0
      }
    }

