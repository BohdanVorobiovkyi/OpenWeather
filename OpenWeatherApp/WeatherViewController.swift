//
//  ViewController.swift
//  OpenWeatherApp
//
//  Created by Богдан Воробйовський on 7/25/19.
//  Copyright © 2019 Vorobiovskiy. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import MapKit

extension WeatherViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapView.setRegion(region, animated: true)
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        
        let geocoder = CLGeocoder()
        
        guard  let previousLocation = self.previousLocation else {return}
        
        guard center.distance(from: previousLocation) > 50 else {return}
        
        self.previousLocation = center
        geocoder.reverseGeocodeLocation(center) { [weak self] (placemarks, err) in
            guard let self = self else {return}
            if let _ = err {
                
            }
            
            guard let placemark = placemarks?.first else {
                
                return
            }
            let cityName = placemark.locality ?? ""
            let countryName = placemark.country ?? ""
            let administrativeArea = placemark.administrativeArea ?? ""
            let area = placemark.name ?? ""
            
            DispatchQueue.main.async {
                if !countryName.isEmpty && !cityName.isEmpty {
                    self.locationLabel.text = "\(countryName) \(administrativeArea) "
                } else {
                    if administrativeArea != area {
                        self.locationLabel.text = "\(administrativeArea) \(area)"
                    } else {
                        self.locationLabel.text = " \(area)"
                    }
                }
            }
            print(countryName, cityName)
        }
    }
}

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "b09b3fe9e81090dcceabb607f67ce310"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    var previousLocation: CLLocation?
    let cornerRadius: CGFloat = 25.0
    //Pre-linked IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    let shapeLayer = CAShapeLayer()
    
    let initialLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height  - containerView.frame.height - CGFloat(100) )
        print(UIScreen.main.bounds.height - containerView.frame.height - CGFloat(70) , UIScreen.main.bounds.height)
        
       
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.delegate = self
       
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        containerView.layer.shadowRadius = 25.0
        containerView.layer.shadowOpacity = 0.9
       
        locationLabel.clipsToBounds = true
        locationLabel.layer.cornerRadius = 15
        
//        view.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        // let's start by drawing a circle somehow
//        let buttonLocation = CGPoint(x: mapView.frame.width/2, y: UIScreen.main.bounds.height - containerView.frame.height - CGFloat(130))
        
        // create my track layer
        let trackLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 40, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 6
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
//        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(trackLayer)
        
        //        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 6
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 20))
        label.center = center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = "Forecast"
        view.addSubview(label)
        
        
//        view.addSubview(initialLabel)
//        initialLabel.center = center
//        initialLabel.frame = CGRect(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height  - containerView.frame.height - CGFloat(100), width: 70 , height: 70)
////        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    func getWeatherData(url: String, parametrs: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parametrs).downloadProgress(closure: {
            
            (prog) in
            self.shapeLayer.strokeEnd = CGFloat(prog.fractionCompleted)
            print("---->", prog.fractionCompleted)
            
        }) .responseJSON {
            response in
            if response.result.isSuccess {
                print("Success", url)
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                                self.updateWeatherData(json: weatherJSON)
                
//                print(weatherJSON)
            }
            else {
                print("Error\(String(describing: response.result.error))")
                //Print to label about error
            }
        }
    }
    
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON) {
        if let temp = json["main"]["temp"].double {
            let city = json["name"].stringValue
            let condition = json["weather"][0]["id"].intValue
            let humidity = json["main"]["humidity"].intValue
            let windSpeed = json["wind"]["speed"].doubleValue
            let weatherIconName = weatherDataModel.updateWeatherIcon(condition: condition)
            
            weatherDataModel.temperature = Int(temp - 273.15)
            weatherDataModel.city = city
            weatherDataModel.condition = condition
            weatherDataModel.humidity = humidity
            weatherDataModel.windSpeed = Int(windSpeed)
            weatherDataModel.weatherIconName = weatherIconName
            print(city, temp, humidity, windSpeed, weatherIconName)
            
//            updateUIWithWeatherData()
        }
        else {
            //label.text - IS UNAVAIBLE
            
        }
    }

    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        params = ["lat": String(latitude), "lon": String(longitude), "appid": APP_ID]
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getWeatherForLocation(for location: CLLocation) {
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        params = ["lat": latitude, "lon": longitude, "appid": APP_ID]
    }
    
    //Write the didUpdateLocations method here:
    var params : [String: String] = [String: String]()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Last location from the array
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print(location.coordinate.latitude, location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            params = ["lat": latitude, "lon": longitude, "appid": APP_ID]
//            let params : [String : String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
           
        }
    }
    
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    
    
    //Write the PrepareForSegue Method here
    
    
    
    
    func beginDownloadingData() {
        shapeLayer.strokeEnd = 0
        getWeatherData(url: WEATHER_URL, parametrs: params)
    }
    
    // Check for touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let point = touch?.location(in: view) else { return }
        let layer = shapeLayer
        
        if let path = layer.path, path.contains(point) {
            print(layer)
            
            beginDownloadingData()
            
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            
            basicAnimation.toValue = 1
            
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = true
            
            shapeLayer.add(basicAnimation, forKey: "urSoBasic")
        }
    }
}

