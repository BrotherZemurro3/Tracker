//
//  ViewController.swift
//  Tracker
//
//  Created by Дионисий Коневиченко on 24.03.2025.
//

import UIKit

class TrackersViewController: UIViewController {


  // let tabBarController = TabBarController()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        // Настройка кнопки добавления трекера
        let addTrackerButton = UIButton()
        addTrackerButton.setImage(UIImage(named: "addTracker"), for: .normal)
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addTrackerButton)
        NSLayoutConstraint.activate([
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
        ])
        // Настройка даты
      let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor)
        ])
        // Лейб Трекеры
        let trackersLabel = UILabel()
        trackersLabel.text = "Трекеры"
        trackersLabel.tintColor = .black
        trackersLabel.font = .systemFont(ofSize: 32, weight: .bold)
        trackersLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersLabel)
        NSLayoutConstraint.activate([
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1)
        ])
        // Строка поиска трекеров
        let searchTrackersBar = UISearchBar()
        searchTrackersBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchTrackersBar)
        NSLayoutConstraint.activate([
            searchTrackersBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTrackersBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchTrackersBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7)
        
        ])
        // Картинка по центу "Что будем отслеживать"
        let imageForEmptyStatisticList = UIImage(named: "EmptyStatistic")
        let imageView = UIImageView(image: imageForEmptyStatisticList)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
        ])
        
        // "Что будем отслеживать"
        let whatGoingToTrackLabel = UILabel()
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
        // ypBold
    }
}

