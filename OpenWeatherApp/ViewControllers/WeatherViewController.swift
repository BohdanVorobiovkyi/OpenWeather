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

class WeatherViewController: UIViewController, InternetConnection {
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate let weatherDataModel = WeatherDataModel()
    fileprivate let shapeLayer = CAShapeLayer()
    fileprivate let trackLayer = CAShapeLayer()
    fileprivate let shapeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 20))
    fileprivate let forecastLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
    fileprivate let forecastView = UIView()
    
    fileprivate var params : [String: String] = [String: String]()

    var previousLocation: CLLocation?
    fileprivate let cornerRadius: CGFloat = 25.0
    fileprivate let shapeRadius: CGFloat = 40
    
    var chosenCity: String = ""
    
    //Pre-linked IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        addGuesture()
        shapeLayer.strokeEnd = 0
        
        tempView.alpha = 0
        tempView.layer.cornerRadius = cornerRadius
        
        containerView.alpha = 0
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        containerView.layer.shadowRadius = 25.0
        containerView.layer.shadowOpacity = 0.9
        
        locationLabel.clipsToBounds = true
        locationLabel.layer.cornerRadius = 15
        
        forecastView.backgroundColor = UIColor.white
        forecastView.layer.cornerRadius = 30
        view.addSubview(forecastView)
    
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        containerView.fadeOut()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let xForCenter = UIScreen.main.bounds.width
        let yForCenter = UIScreen.main.bounds.height - containerView.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - shapeRadius
        
        let center = CGPoint(x: xForCenter/2, y: yForCenter )
        
        createButtonWithProgressBar(center: center)
        forecastView.frame = CGRect(x: xForCenter/2 + 34 , y: yForCenter - 20, width: 60, height: 60)
        forecastLabel.center = forecastView.center
        
    }
    //MARK: - Shape layer with grey track layer and label in the center of the shape.
    func createButtonWithProgressBar(center: CGPoint) {
        
        let circularPath = UIBezierPath(arcCenter: center, radius: shapeRadius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 6
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 6
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(shapeLayer)
        
        shapeLabel.center = center
        shapeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        shapeLabel.textAlignment = .center
        shapeLabel.text = "CURRENT"
        view.addSubview(shapeLabel)
        
        
        forecastLabel.font = UIFont.boldSystemFont(ofSize: 10)
        forecastLabel.textAlignment = .center
        forecastLabel.text = "Forecast"
        view.addSubview(forecastLabel)
        
        
    }
    
    @IBAction func searchButton(_ sender: Any) {
        checkInternetConnection()
        if Reachability.isConnectedToNetwork() == true {
            goToSearchVC()
            print("SerachVC")
        }
    }
    fileprivate func goToSearchVC() {
        guard let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchVC") as? SearchViewController else { return }
        searchVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(searchVC, animated: true, completion: nil)
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    fileprivate func getWeatherData(url: String, parametrs: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parametrs).downloadProgress(closure: {
            (prog) in
            self.shapeLayer.strokeEnd = CGFloat(prog.fractionCompleted)
            self.fadeOutStrokeCompletion()
        }) .responseJSON {
            response in
            if response.result.isSuccess {
                print("Success", url)
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error\(String(describing: response.result.error))")
                //Print to label about error
            }
        }
        tempView.fadeIn()
        shapeLayer.strokeEnd = 0
    }
    
    //MARK: - JSON Parsing
    
    fileprivate func updateWeatherData(json: JSON) {
        if let temp = json["main"]["temp"].double {
            let city = json["name"].stringValue
            let condition = json["weather"][0]["id"].intValue
            let weatherIconName = weatherDataModel.updateWeatherIcon(condition: condition)
            
            weatherDataModel.temperature = Int(temp - 273.15)
            weatherDataModel.city = city
            weatherDataModel.condition = condition
            weatherDataModel.weatherIconName = weatherIconName
            
            self.updateUIWithWeatherData()
        }
        else {
            //label.text - IS UNAVAIBLE
            
        }
    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    fileprivate func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        params = ["lat": String(latitude), "lon": String(longitude), "appid": NetworkEndpoints.APP_ID]
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    func updateUIWithWeatherData() {
        temperatureLabel.text = "\(weatherDataModel.temperature) C°"
        weatherIconView.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    func addGuesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showWeekForecast))
        forecastView.addGestureRecognizer(tap)
    }
    
    @objc func showWeekForecast() {
        checkInternetConnection()
        if Reachability.isConnectedToNetwork() == true {
             sendDataToForecastVC()
            print("--->5 days")
        }
    }
    func sendDataToForecastVC() {
        guard let forecastVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "forecastVC") as? ForecastViewController else { return }
        forecastVC.params = params
        forecastVC.chosenCity = chosenCity
        print(params)
        forecastVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        self.present(forecastVC, animated: true, completion: nil)
    }
    
    fileprivate func fadeOutStrokeCompletion() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeColor")
        basicAnimation.fromValue = UIColor.red.cgColor
        basicAnimation.toValue = UIColor.clear.cgColor
        basicAnimation.duration = 1
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        self.shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    func beginDownloadingData() {
        shapeLayer.strokeEnd = 0
        checkInternetConnection()
        if Reachability.isConnectedToNetwork() == true {
        getWeatherData(url: NetworkEndpoints.WEATHER_URL, parametrs: params)
        }
    }
    
    // Check for touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let point = touch?.location(in: view) else { return }
        let layer = shapeLayer
        
        if let path = layer.path, path.contains(point) {
            beginDownloadingData()
        }
    }
}

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
                if Reachability.isConnectedToNetwork() == false {
                    self.containerView.fadeIn()
                    DispatchQueue.main.async {
                        self.locationLabel.text = "No Internet Connection"
                    }
                } else {
                    self.containerView.fadeOut()
                }
                return
            }
            let cityName = placemark.locality ?? ""
            let countryName = placemark.country ?? ""
            let administrativeArea = placemark.administrativeArea ?? ""
            let area = placemark.name ?? ""
           
            
            DispatchQueue.main.async {
                self.containerView.fadeIn()
                if !countryName.isEmpty && !cityName.isEmpty {
                    self.locationLabel.text = "\(countryName), \(cityName) "
                } else {
                    if administrativeArea != area && !administrativeArea.isEmpty {
                        self.locationLabel.text = "\(administrativeArea), \(area)"
                    } else {
                        self.locationLabel.text = " \(area)"
                    }
                }
                 self.chosenCity = self.locationLabel.text ?? ""
            }
        }
    }
}
extension WeatherViewController: CLLocationManagerDelegate {
    //    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    //        print(error)
    //    }
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        //Last location from the array
    //        let location = locations[locations.count - 1]
    //        if location.horizontalAccuracy > 0 {
    //            locationManager.stopUpdatingLocation()
    //            locationManager.delegate = nil
    //            print(location.coordinate.latitude, location.coordinate.longitude)
    //            let latitude = String(location.coordinate.latitude)
    //            let longitude = String(location.coordinate.longitude)
    //            params = ["lat": latitude, "lon": longitude, "appid": NetworkEndpoints.APP_ID]
    //        }
    //    }
    //    func getWeatherForLocation(for location: CLLocation) {
    //        let latitude = String(location.coordinate.latitude)
    //        let longitude = String(location.coordinate.longitude)
    //        params = ["lat": latitude, "lon": longitude, "appid": NetworkEndpoints.APP_ID]
    //    }

}


