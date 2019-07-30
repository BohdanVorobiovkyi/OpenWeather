//
//  SearchController.swift
//  OpenWeatherApp
//
//  Created by Богдан Воробйовський on 7/30/19.
//  Copyright © 2019 Vorobiovskiy. All rights reserved.
//

import UIKit

protocol ChangeCityDelegate {
    func userEnteredANewCity(city: String)
}

class SearchViewController: UIViewController {
    @IBOutlet weak var getWeatherButton: UIButton!
    
    var delegate : ChangeCityDelegate?
    var params: [String: String] = [String: String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherButton.layer.cornerRadius = 5
        getWeatherButton.clipsToBounds = true
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        changeCityTextField.text = ""
    }
   
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var changeCityTextField: UITextField!
    
    @IBAction func getWeatherPressed(_ sender: Any) {
        guard let cityName = changeCityTextField.text else {return}
        params = ["q": String(cityName), "appid": APP_ID]
        sendDataToNextVC(entered: cityName)
        
    }
    
    func sendDataToNextVC(entered name: String) {
        guard let forecastVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "forecastVC") as? ForecastViewController else { return }
        forecastVC.params = params
        forecastVC.chosenCity = name
        print(params)
        forecastVC.modalPresentationStyle = UIModalPresentationStyle.popover
        
        self.present(forecastVC, animated: true, completion: nil)
    
    }
    
}
