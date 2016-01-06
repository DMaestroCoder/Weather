//
//  WeatherDetailCell.swift
//  Weather
//
//  Copyright © 2016 dmitry. All rights reserved.
//

import UIKit

class СolumnView : UIView {
	@IBOutlet var timeLabel : UILabel!
	@IBOutlet var humidityLabel : UILabel!
	@IBOutlet var windLabel : UILabel!
	@IBOutlet var pressureLabel : UILabel!
	@IBOutlet var temperatureLabel : UILabel!
	@IBOutlet var iconImageView : UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.layer.cornerRadius = 5.0
		self.layer.masksToBounds = true
	}
}

class WeatherDetailCell : UITableViewCell {
	@IBOutlet var dateLabel : UILabel!
	@IBOutlet var weekLabel : UILabel!
	@IBOutlet var holderView : UIView!
	@IBOutlet var columnViewCollection: [СolumnView]!
	
	private static var timeFormatter : NSDateFormatter!
	private static var dateFormatter: NSDateFormatter!
	private static var weekFormatter: NSDateFormatter!
	
	override class func initialize () {
		timeFormatter = NSDateFormatter()
		timeFormatter.dateFormat = "HH:mm"
		
		dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd"
		
		weekFormatter = NSDateFormatter()
		weekFormatter.dateFormat = "EEEE"
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		holderView.layer.cornerRadius = 5.0
		holderView.layer.masksToBounds = true
	}
	
	func setWeatherHoldder(weatherHolder : DayWeatherHolder) {
		dateLabel.text = WeatherDetailCell.dateFormatter.stringFromDate(weatherHolder.dateTime)
		weekLabel.text = WeatherDetailCell.weekFormatter.stringFromDate(weatherHolder.dateTime)
		let weathers = weatherHolder.weathers
		
		for var i = 0; i < 8; i++ {
			let columnView = columnViewCollection[i]
			
			if i < weathers.count {
				let weather = weathers[i]
				let date = NSDate(timeIntervalSince1970: Double(weather.timeshtamp))
				
				columnView.timeLabel.text = WeatherDetailCell.timeFormatter.stringFromDate(date)
				columnView.humidityLabel.text = "\(weather.humidity)"
				columnView.windLabel.text = "\(weather.windSpeed)"
				columnView.pressureLabel.text = "\(Int(weather.pressure))"
				columnView.temperatureLabel.text = "\(weather.temp)"
				columnView.iconImageView!.image = UIImage(named: "\(weather.icon)")
			}
			
			columnView.hidden = i >= weathers.count
		}
	}
}
