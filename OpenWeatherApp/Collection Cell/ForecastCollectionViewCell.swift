//
//  ForecastCollectionViewCell.swift
//  OpenWeatherApp
//
//  Created by Богдан Воробйовський on 7/30/19.
//  Copyright © 2019 Vorobiovskiy. All rights reserved.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
   
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    
    
    var cellModel: WeatherItem? {
        didSet {
            guard let cellModel = cellModel else { return }
            setupUI(cellModel: cellModel)
            print("OK HERE3")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.layer.masksToBounds = true
        
       
        // Initialization code
    }
    
////    private func dateFormatter(_ dateIn: String) -> String {
////        guard let unixDate = Double(dateIn) else { return "" }
////        let date = Date(timeIntervalSince1970: unixDate/1000.0 )
////        let dateFormatter = DateFormatter()
////        dateFormatter.dateFormat = "dd/MM/YYYY"
////
////        let newDate = dateFormatter.string(from: date)
////        return newDate
////    }
//////    func getDayOfWeek(_ today:String) -> Int? {
////        let formatter  = DateFormatter()
////        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.s"
////        guard let todayDate = formatter.date(from: today) else { return nil }
////        let myCalendar = Calendar(identifier: .gregorian)
////        let weekDay = myCalendar.component(.weekday, from: todayDate)
////        return weekDay
////    }
//
////    func getDayOfWeek(_ inDate: String) -> Int {
////        let date = Date()
////
////        let format = DateFormatter()
////         let iDate = format.date(from: inDate)
////        format.dateFormat = "yyyy-MM-dd"
////        let formattedDate = format.string(from: iDate!)
////        print(formattedDate)
////        let calendar = Calendar.current
////        let weekday = calendar.component(.weekday, from: date)
////        print(weekday)
////        return we
////    }
//
//    func getDateFromString(_ inDate: String) -> String {
//        let stringDate = inDate
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
//        guard let date = dateFormatter.date(from: stringDate) else {return Date() }
//        return date
//    }
//    func getDayOfWeek(_ inDate: Date) -> Int {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
//        let calendar = Calendar(identifier: .gregorian)
//        let weekday = calendar.component(.weekday, from: inDate)
//        return weekday
//    }
    
    
    func getDateFromString(_ inDate: String) -> Date {
        let inputDate = inDate
        print(inDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: inputDate) else {return Date()}
        return date
    }
    func convertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "E, d MMMM"
        return  dateFormatter.string(from: date!)
        
    }
    func convertTimeFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 10800) as TimeZone?
        dateFormatter.dateFormat = "HH:mm"
        print("String From Date : \(dateFormatter.string(from: date!))")
        return  dateFormatter.string(from: date!)
        
    }
    
    func roundedDouble(temp: Double) -> Double {
         let rounded = Double(round(10 * (temp - 273.15)) / 10)
        return rounded
    }
    
    func setupUI(cellModel: WeatherItem) {
       
     print(convertTimeFormater(cellModel.dateText))
        let tempMax = cellModel.main.tempMax
        let tempMin = cellModel.main.tempMin
        if tempMax < 0 || tempMin < 0 {
            tempMaxLabel.text = "\(roundedDouble(temp:tempMax))C°"
            tempMinLabel.text = "\(roundedDouble(temp: tempMin))C°"
        }
        tempMaxLabel.text = "+\(roundedDouble(temp:tempMax ))C°"
        tempMinLabel.text = "+\(roundedDouble(temp: tempMin))C°"
        timeLabel.text = convertTimeFormater(cellModel.dateText)
        dateLabel.text = convertDateFormater(cellModel.dateText)
        humidityLabel.text = "humidity: \(cellModel.main.humidity)%"
        windLabel.text = "speed: \(cellModel.wind.speed)m/s"
        setImage(with: cellModel.weather[0].icon)
        
        //        guard let previewImageURL = URL.init(string: cellModel.homeScreenMostViewedPreviewImageURLString) else {
        //            return
        //        }
    }
    
    func setImage(with imageCode: String){
        imageView.image = UIImage(named: imageCode)
    }
}
