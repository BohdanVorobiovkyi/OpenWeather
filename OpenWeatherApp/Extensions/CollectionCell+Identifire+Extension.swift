//
//  CollectionCell+Identifire+Extension.swift
//  OpenWeatherApp
//
//  Created by Богдан Воробйовський on 7/31/19.
//  Copyright © 2019 Vorobiovskiy. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
