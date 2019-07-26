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

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "b09b3fe9e81090dcceabb607f67ce310"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    
    
    //Pre-linked IBOutlets

    let shapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        // let's start by drawing a circle somehow
        
        let center = view.center
        
        // create my track layer
        let trackLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(trackLayer)
        
        //        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
        
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
    
    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
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
    
    
   
 
//    @objc private func handleTap() {
//        print("Attempting to animate stroke")
//
//        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
//
//        basicAnimation.toValue = 1
//
//        basicAnimation.duration = 2
//
//        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
//        basicAnimation.isRemovedOnCompletion = true
//
//        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
//    }
   
    
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
                
//                self.updateWeatherData(json: weatherJSON)
//                                print(weatherJSON)
            }
            else {
                print("Error\(String(describing: response.result.error))")
                //Print to label about error
            }
        }
    }
    
    func loadImage() {
        Alamofire.request("http://ontheworldmap.com/world/world-political-map-with-countries.jpg").downloadProgress { (prog) in
            self.shapeLayer.strokeEnd = CGFloat(prog.fractionCompleted)
            print("---->", prog.fractionCompleted)
            }.responseData { (data) in
                print(data.result.value as Any)
        }
    }
    
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

