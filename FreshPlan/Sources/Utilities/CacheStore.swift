//
//  CacheStore.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-21.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit

/**
	* CacheStore class to store cached data to make it easier on requests
**/
public class CacheStore {
	private lazy var imageCache: NSCache<NSString, UIImage> = NSCache<NSString, UIImage>()
	
	public func setImage(key: NSString, image: UIImage) {
		imageCache.setObject(image, forKey: key)
	}
	
	public func getImage(key: NSString) -> UIImage? {
		return imageCache.object(forKey: key)
	}
}
