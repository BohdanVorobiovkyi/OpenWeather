//
//  ForecastCollectionViewCell.swift
//  OpenWeatherApp
//
//  Created by Богдан Воробйовський on 7/30/19.
//  Copyright © 2019 Vorobiovskiy. All rights reserved.
//

import UIKit

extension ForecastCollectionViewCell {
    fileprivate func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "E, d MMMM"
        return  dateFormatter.string(from: date!)
    }
    
    fileprivate func convertTimeFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 10800) as TimeZone?
        dateFormatter.dateFormat = "HH:mm"
        return  dateFormatter.string(from: date!)
    }
}

class ForecastCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var imageView: IconView!
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
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupContentView()
    }
    
    fileprivate func setupContentView() {
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.layer.masksToBounds = true
    }
    
    fileprivate func roundedDoubleFromFarenheit(temp: Double) -> Double {
         let rounded = Double(round(10 * (temp - 273.15)) / 10)
        return rounded
    }
    
    fileprivate func setupUI(cellModel: WeatherItem) {
        
        let tempMax = cellModel.main.tempMax
        let tempMin = cellModel.main.tempMin
        
        if tempMax < 0 || tempMin < 0 {
            tempMaxLabel.text = "\(roundedDoubleFromFarenheit(temp:tempMax))C°"
            tempMinLabel.text = "\(roundedDoubleFromFarenheit(temp: tempMin))C°"
        }
        tempMaxLabel.text = "+\(roundedDoubleFromFarenheit(temp:tempMax ))C°"
        tempMinLabel.text = "+\(roundedDoubleFromFarenheit(temp: tempMin))C°"
        timeLabel.text = convertTimeFormater(cellModel.dateText)
        dateLabel.text = convertDateFormater(cellModel.dateText)
        humidityLabel.text = "humidity: \(cellModel.main.humidity)%"
        windLabel.text = "speed: \(cellModel.wind.speed)m/s"
        
         let iconId = cellModel.weather[0].icon
        let urlString = "\(NetworkEndpoints.iconsBaseURL)\(iconId)@2x.png"
        
        //:MARK - Image loader from the string, with Caching. Here we use custom IconView class, extension class for UIImageVIew
        print(urlString)
        imageView.loadImageUsingUrlString(urlString: urlString)
        
        //:MARK - For using local icons, try method below
        //        setImage(with: cellModel.weather[0].icon)
    
    }
    
   
    fileprivate func setImage(with imageCode: String){
        imageView.image = UIImage(named: imageCode)
    }
}
