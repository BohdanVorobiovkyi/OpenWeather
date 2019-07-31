//
//  ForecastViewController.swift
//  OpenWeatherApp
//
//  Created by Богдан Воробйовський on 7/30/19.
//  Copyright © 2019 Vorobiovskiy. All rights reserved.
//

import UIKit
import Alamofire
//import SwiftyJSON

private let reuseIdentifier = "forecastCell"

class ForecastViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var params : [String: String] = [String: String]()
    var chosenCity: String = ""
    fileprivate var itemsHeight: CGFloat = 0
    fileprivate var itemsWidth: CGFloat = 0
    
    @IBOutlet weak var chosenPlaceLabel: UILabel!
    @IBOutlet weak var forecastCollection: UICollectionView!
    @IBOutlet weak var progressView: UIProgressView!
    
    fileprivate var forecastData: ForecastWeatherData = ForecastWeatherData(){
        didSet{
            print(forecastData.weatherItems.count)
            DispatchQueue.main.async {
                self.forecastCollection.reloadData()
                self.forecastCollection.fadeInForCollection()
                self.chosenPlaceLabel.text = self.chosenCity
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        getForecastData(url: NetworkEndpoints.FORECAST_URL , parametrs: params)
        
    }
    
    fileprivate func setupCollectionView() {
        forecastCollection.dataSource = self
        forecastCollection.delegate = self
        forecastCollection.alpha = 0
        forecastCollection.register(UINib.init(nibName: ForecastCollectionViewCell.identifier, bundle: .none), forCellWithReuseIdentifier: reuseIdentifier)
    }
    //:MARK - Item's sizes for orientations
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIApplication.shared.statusBarOrientation.isLandscape {
            // activate landscape changes
            self.itemsHeight = (UIScreen.main.bounds.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 100) - CGFloat(4)
            if self.itemsHeight < 140 {
                self.itemsHeight = 200
            }
            self.itemsWidth = UIScreen.main.bounds.width / 3 - 24 - self.view.safeAreaInsets.right - self.view.safeAreaInsets.left
        } else {
            // activate portrait changes
            self.itemsHeight = (UIScreen.main.bounds.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 100)/3 - CGFloat(4)
            self.itemsWidth = UIScreen.main.bounds.width / 3 - 8 - self.view.safeAreaInsets.right - self.view.safeAreaInsets.left
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil )
    }
    
    fileprivate func getForecastData(url: String, parametrs: [String: String]) {
        progressView.progress = 0
        Alamofire.request(url, method: .get, parameters: parametrs).downloadProgress(closure: {
            (prog) in
            self.progressView.progress = Float(prog.fractionCompleted)
        }).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success", url)
                guard let data = response.data else {return}
                self.parseJSONwithCodable(data: data)
            }
            else {
                self.chosenPlaceLabel.text = String(describing: response.result.error)
                print("Error\(String(describing: response.result.error))")
            }
        }
    }
    
    fileprivate func parseJSONwithCodable(data: Data) {
        do {
            self.forecastData = try JSONDecoder().decode(ForecastWeatherData.self, from: data)
            if self.forecastData.weatherItems.count == 0 {
                self.chosenCity = "Locality is not found. \n Try another one."
            }
        } catch let err as NSError {
            print(err.localizedDescription)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecastData.weatherItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = forecastCollection.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ForecastCollectionViewCell
        cell.cellModel = forecastData.weatherItems[indexPath.row]
        // Configure the cell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemsWidth , height:  itemsHeight)
    }
}


// MARK: - SwiftyJSON parsing method

//        func updateForecastData(json: JSON) {
//            guard let count: Int = json["cnt"].int else {return}
//            for item in 0...count {
//                if let temp = json["list"][item]["main"]["temp"].double {
//                    guard let humidity = json["list"][item]["main"]["humidity"].double else { return }
//                    guard let id = json["list"][item]["weather"][0]["id"].int else { return }
//                    guard let speed = json["list"][item]["wind"]["speed"].double else { return  }
//                    guard let date = json["list"][item]["dt_txt"].string else { return  }
//                    //
//                    items.append(ForecastModel(temp: Double(temp - 273.15), humidity: humidity, id: id, speed: speed, date: date))
//                }
//                else {
//                    //label.text - IS UNAVAIBLE
//                }
//            }
//            print(items.count)
//        }
