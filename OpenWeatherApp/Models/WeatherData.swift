//
//  Weather.swift
//  OpenWeatherApp
//
//  Created by Богдан Воробйовський on 7/30/19.
//  Copyright © 2019 Vorobiovskiy. All rights reserved.
//

import Foundation


struct WeatherData: Decodable {
    
    let weatherItems: [WeatherItem]
    
    enum CodingKeys: String, CodingKey {
        case list = "list"
        case count = "cnt"
    }
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(weatherItems, forKey: .list)
//        //        try container.encode(weatherItems, forKey: .count)
//    }
    
    init() {
        weatherItems = [WeatherItem]()
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weatherItems = try container.decodeIfPresent(Array<WeatherItem>.self, forKey: .list) ?? [WeatherItem]()
        
    }
}


struct WeatherItem: Decodable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let dateText: String
    
    enum CodingKeys: String, CodingKey {
        case main = "main"
        case weather = "weather"
        case wind = "wind"
        case dateText = "dt_txt"
    }
    
    
//    func encode(to encoder: Encoder) throws {
//
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(main, forKey: .main)
//        try container.encode(weather, forKey: .weather)
//        try container.encode(wind, forKey: .wind)
//        try container.encode(dateText, forKey: .dateText)
//
//    }
    
    init() {
        self.dateText = ""
        main = Main()
        weather = [Weather]()
        wind = Wind()
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        main = try container.decodeIfPresent(Main.self, forKey: .main) ?? Main()
        weather = try container.decodeIfPresent([Weather].self, forKey: .weather) ?? [Weather]()
        
        wind = try container.decodeIfPresent(Wind.self, forKey: .wind) ?? Wind()
        dateText = try container.decodeIfPresent(String.self, forKey: .dateText) ?? ""
        
        
    }
    struct Weather: Decodable {
        let id: Int
        let icon: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case icon
        }
        init() {
            self.id = 0
            self.icon = ""
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            icon = try container.decode(String.self, forKey: .icon)
        }
//        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(id, forKey: .id)
//
//        }
    }
    
    
    struct Wind: Decodable {
        let speed: Double
        let degree: Double
        
        enum CodingKeys: String, CodingKey {
            case speed
            case deg
        }
        
        init(){
            self.speed = 0
            self.degree = 0
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            speed = try container.decode(Double.self, forKey: .speed)
            degree = try container.decode(Double.self, forKey: .deg)
        }
//        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(speed, forKey: .speed)
//            try container.encode(degree, forKey: .deg)
//
//        }
    }
    
    struct Main: Codable {
        let temp: Double
        let tempMin: Double
        let tempMax: Double
        let humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case humidity
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            
        }
        init() {
            self.temp = 0
            self.humidity = 0
            self.tempMin = 0
            self.tempMax = 0
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            temp = try container.decode(Double.self, forKey: .temp)
            tempMin = try container.decode(Double.self, forKey: .tempMin)
            tempMax = try container.decode(Double.self, forKey: .tempMax)
            humidity = try container.decode(Int.self, forKey: .humidity)
        }
//        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(temp, forKey: .temp)
//            try container.encode(humidity, forKey: .humidity)
//
//        }
    }
}

