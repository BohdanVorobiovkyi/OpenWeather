//
//  ForecastModel.swift
//  OpenWeatherApp
//
//  Created by Богдан Воробйовський on 7/30/19.
//  Copyright © 2019 Vorobiovskiy. All rights reserved.
//

import Foundation
//:MARK - Model for Using SwiftyJSON parsing with ForecastViewController

class ForecastModel {
    let temp : Double
    let humidity : Double
    let id : Int
    let speed : Double
    let date : String
    
    
    init(temp: Double, humidity: Double, id: Int, speed: Double, date: String ) {
        self.temp = temp
        self.humidity = humidity
        self.id = id
        self.speed = speed
        self.date = date
    }
    var weatherIconName : String = " "
    
    //Method turns a condition code into the name of the weather condition image
    
    func updateWeatherIcon(condition: Int) -> String {
        
        switch (condition) {

        case 0...300 :
            return "tstorm1"
            
        case 301...500 :
            return "light_rain"
            
        case 501...600 :
            return "shower3"
            
        case 601...700 :
            return "snow4"
            
        case 701...771 :
            return "fog"
            
        case 772...799 :
            return "tstorm3"
            
        case 800 :
            return "sunny"
            
        case 801...804 :
            return "cloudy2"
            
        case 900...903, 905...1000  :
            return "tstorm3"
            
        case 903 :
            return "snow5"
            
        case 904 :
            return "sunny"
            
        default :
            return "dunno"
        }
}
}
