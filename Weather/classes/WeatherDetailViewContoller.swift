//
//  WeatherDetailViewContoller.swift
//  Weather
//
//  Copyright © 2016 dmitry. All rights reserved.
//

import UIKit

extension NSDate {
	
	func isSameDay(date : NSDate) -> Bool {
		let calendar = NSCalendar.currentCalendar()
		let comps1 = calendar.components([NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Day], fromDate:date)
		let comps2 = calendar.components([NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Day], fromDate:self)
		
		return (comps1.day == comps2.day) && (comps1.month == comps2.month) && (comps1.year == comps2.year)
	}
	
}

class DayWeatherHolder {
	var dateTime : NSDate
	var weathers : [WeatherItem] = []
	
	init(_ dateTime : NSDate) {
		self.dateTime = dateTime
	}
}

class WeatherDetailViewController : UIViewController, UITableViewDelegate {
	@IBOutlet var cityNameLabel : UILabel!
	@IBOutlet var tableView : UITableView!
	
	@IBOutlet var humidityLabel : UILabel!
	@IBOutlet var windLabel : UILabel!
	@IBOutlet var pressureLabel : UILabel!
	@IBOutlet var temperatureLabel : UILabel!
	@IBOutlet var iconImageView : UIImageView!
	
	private let openWeather = OpenWeather(apiKey: "a4ff05d556d26a5cbd5ed3725ef08e46", language: "ua", temperatureFormat: .Celsius)
	private var weatherDays : [DayWeatherHolder] = []
	
	var cityItem : CityItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		humidityLabel.text = "\(cityItem.weather.humidity) %"
		windLabel.text = "\(cityItem.weather.windSpeed) m/s"
		pressureLabel.text = "\(cityItem.weather.pressure) hpa"
		temperatureLabel.text = "\(cityItem.weather.temp) °C"
		iconImageView!.image = UIImage(named: "\(cityItem.weather.icon)")
		
		loadWeather()
	}
	
	private func coollectWeatherDays(cityItem : CityItem) {
		var currentWeatherHolder : DayWeatherHolder! = nil
		for weather in cityItem.weatherItems {
			let date = NSDate(timeIntervalSince1970: Double(weather.timeshtamp))
			
			if currentWeatherHolder == nil || !currentWeatherHolder.dateTime.isSameDay(date) {
				currentWeatherHolder = DayWeatherHolder(date)
				currentWeatherHolder.weathers.append(weather)
				weatherDays.append(currentWeatherHolder)
			}
			else {
				currentWeatherHolder.weathers.append(weather)
			}
		}
	}
	
	private func loadWeather() {
		let navigationController = self.navigationController as! BaseNavigationController
		navigationController.startLoading()
		
		openWeather.forecastWeather(cityItem.id){ (error : NSError?, cityItem : CityItem?) -> Void in
			if let error = error {
				print(error.description)
			}
			else {
				self.cityNameLabel.text = cityItem!.name
				self.coollectWeatherDays(cityItem!)
				self.tableView.reloadData()
			}
			
			navigationController.stopLoading()
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return weatherDays.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("weatherDetailCellIdentifier") as! WeatherDetailCell
		let weatherHolder = weatherDays[indexPath.row]
		cell.setWeatherHoldder(weatherHolder)
		return cell;
	}
	
}