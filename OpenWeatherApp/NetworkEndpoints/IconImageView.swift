//
//  IconView.swift
//  OpenWeatherApp
//
//  Created by Богдан Воробйовський on 8/2/19.
//  Copyright © 2019 Vorobiovskiy. All rights reserved.
//

import UIKit
let imageCache = NSCache<AnyObject, UIImage>()


class IconView: UIImageView {

    var imageUrlString: String?
    
    func loadImageUsingUrlString(urlString: String) {
        
        imageUrlString = urlString
        
        guard let url = URL(string: urlString) else { return }
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async {
                guard let imageToCache = UIImage(data: data!) else { return }
                
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                    self.iconFadeIn()
                }
                
                imageCache.setObject(imageToCache, forKey: urlString as NSString)
            }
            
        }).resume()
    }
}
