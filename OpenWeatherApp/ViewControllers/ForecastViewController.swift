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
 let reusable = "cellID"
let FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast"
let APP_ID = "b09b3fe9e81090dcceabb607f67ce310"

extension UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

class ForecastViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var items : [ForecastModel] = [ForecastModel]()
    var forecastData: WeatherData = WeatherData(){
        didSet{
            print(forecastData.weatherItems.count)
            DispatchQueue.main.async {
                self.forecastCollection.reloadData()
                self.chosenPlaceLabel.text = self.chosenCity
            }
        }
    }
    var params : [String: String] = [String: String]()
    var chosenCity: String = ""
    @IBOutlet weak var chosenPlaceLabel: UILabel!
    @IBOutlet weak var forecastCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forecastCollection.dataSource = self
        forecastCollection.delegate = self
        forecastCollection.register(UINib.init(nibName: ForecastCollectionViewCell.identifier, bundle: .none), forCellWithReuseIdentifier: reusable)
        getForecastData(url: FORECAST_URL , parametrs: params)
        
    }
    //
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil )
    }
    

        
        func getForecastData(url: String, parametrs: [String: String]) {
            Alamofire.request(url, method: .get, parameters: parametrs).responseJSON {
                response in
                if response.result.isSuccess {
                    print("Success", url)
//                    let forecastJSON : JSON = JSON(response.result.value!)
//                    self.updateForecastData(json: forecastJSON)
                    guard let data = response.data else {return}
                    self.parseJSONwithCodable(data: data)
                    //                guard let data = response.data else {return}
                    //                self.parseJSONwithCodable(data: data)
                }
                else {
                    print("Error\(String(describing: response.result.error))")
                    //Print to label about error
                }
            }
        }
    
    func parseJSONwithCodable(data: Data) {
        
        do {
            self.forecastData = try JSONDecoder().decode(WeatherData.self, from: data)
            print("--", self.forecastData.weatherItems)
        } catch let err as NSError {
            print(err.localizedDescription)
        }
    }
    

    

    func getWeatherData() {}

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return forecastData.weatherItems.count
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = forecastCollection.dequeueReusableCell(withReuseIdentifier: reusable, for: indexPath) as! ForecastCollectionViewCell
        cell.cellModel = forecastData.weatherItems[indexPath.row]
        // Configure the cell
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 3 - 8, height: UIScreen.main.bounds.height / 4.5)
    }
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}


//
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
//
//                }
//                else {
//                    //label.text - IS UNAVAIBLE
//
//                }
//
//            }
//            print(items.count)
//        }
