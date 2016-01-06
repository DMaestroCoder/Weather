//
//  Openweathermap.swift
//  Weather
//
//  Copyright © 2016 dmitry. All rights reserved.
//

import Foundation
import CoreLocation

let kServerUrlBase = "http://openweathermap.org/data"
let kApiVersion = "2.5"

struct WeatherItem {
	let mainDescription : String
	let detailDescription : String
	let icon : String
	
	let temp : Double
	let tempMin : Double
	let tempMax : Double
	let pressure : Double
	let humidity : Double
	
	let windSpeed : Double
	let windDegree : Double
	
	let timeshtamp : UInt32
	
	let clouds : Int
	
	private init(dictionary : NSDictionary) {
		self.timeshtamp = dictionary["dt"]!.unsignedIntValue
		
		let mainDict = dictionary["main"] as! NSDictionary
		self.temp = mainDict["temp"]!.doubleValue
		self.tempMin = mainDict["temp_min"]!.doubleValue
		self.tempMax = mainDict["temp_max"]!.doubleValue
		self.pressure = mainDict["pressure"]!.doubleValue
		self.humidity = mainDict["humidity"]!.doubleValue
		
		let weatherDict = (dictionary["weather"] as! NSArray)[0] as! NSDictionary
		self.mainDescription = weatherDict["main"] as! String
		self.detailDescription = weatherDict["description"] as! String
		self.icon = weatherDict["icon"] as! String
		
		let windDict = dictionary["wind"] as! NSDictionary
		self.windSpeed = windDict["speed"]!.doubleValue
		self.windDegree = windDict["deg"]!.doubleValue
		
		let cloudDict = dictionary["clouds"] as! NSDictionary
		self.clouds = cloudDict["all"]!.integerValue
	}
}

struct CityItem {
	let name : String
	let id : Int
	
	let coordLongityde : Double
	let coordLatitude : Double
	
	let forecast : Bool
	
	var weatherItems : [WeatherItem] = []
	
	var weather : WeatherItem {
		get {
			return weatherItems[0]
		}
	}
	
	private init(dictionary : NSDictionary, forecast : Bool) {
		let cityDict = forecast ? dictionary["city"] as! NSDictionary : dictionary
		self.name = cityDict["name"] as! String
		self.id = cityDict["id"]!.integerValue
		
		let coordDict = cityDict["coord"] as! NSDictionary
		self.coordLongityde = coordDict["lon"]!.doubleValue
		self.coordLatitude = coordDict["lat"]!.doubleValue
		
		self.forecast = forecast
		
		if forecast {
			for itemDict in dictionary["list"] as! NSArray {
				let weatherItem = WeatherItem(dictionary: itemDict as! NSDictionary)
				self.weatherItems.append(weatherItem)
			}
		}
		else {
			let weatherItem = WeatherItem(dictionary: dictionary)
			self.weatherItems.append(weatherItem)
		}
	}
}

class OpenWeather {
	typealias cityComplitionHandler = (NSError?, CityItem?) -> Void
	typealias citiesComplitionHandler = (NSError?, [CityItem]?) -> Void
	
	enum TemperatureFormat : String {
		case Fahrenheit = "imperal"
		case Celsius = "metric"
		case Kelvin = ""
	}
	
	enum Result {
		case Success(NSDictionary!)
		case Error(NSError!)
	}
	
	private let requestQueue : NSOperationQueue
	
	var apiKey : String
	var language : String
	var temperatureFormat : TemperatureFormat
	
	init(apiKey : String, language : String, temperatureFormat : TemperatureFormat) {
		self.apiKey = apiKey
		self.language = language
		self.temperatureFormat = temperatureFormat
		requestQueue = NSOperationQueue()
	}
	
	private func performRequest(method : String, complitionHandler : (Result) -> Void) {
		var urlPath = kServerUrlBase + "/" + kApiVersion + "/" + method
		urlPath += buildParam("APPID", value: apiKey)
		urlPath += buildParam("lang", value: language)
		urlPath += buildParam("units", value: temperatureFormat.rawValue)
		let currentQueue = NSOperationQueue.currentQueue()!
		
		let request = NSURLRequest(URL: NSURL(string: urlPath)!)
		
		NSURLConnection.sendAsynchronousRequest(request, queue: requestQueue) { (response : NSURLResponse?, data : NSData?, error : NSError?) -> Void in
			var error : NSError? = error
			var dictionary : NSDictionary?
			
			if let data = data {
				do {
					dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
				}
				catch let exError as NSError {
					error = exError
				}
			}
			
			currentQueue.addOperationWithBlock {
				let result = error != nil ? Result.Error(error) : Result.Success(dictionary)
				complitionHandler(result)
			}
		}
	}
	
	private func requestWithCityResponse(method : String, complitionHandler : cityComplitionHandler, forecast : Bool) {
		performRequest(method) { (result : Result) -> Void in
			switch(result) {
			case .Success(let dictionary) :
				let cityItem = CityItem(dictionary: dictionary, forecast: forecast)
				complitionHandler(nil, cityItem)
				
			case .Error(let error) :
				complitionHandler(error, nil)
			}
		}
	}
	
	private func requestWithCitiesResponse(method : String, complitionHandler : citiesComplitionHandler) {
		performRequest(method) { (result : Result) -> Void in
			switch(result) {
			case .Success(let dictionary) :
				let dictList = dictionary["list"] as! NSArray
				var cities : [CityItem] = []
				for cityDict in dictList {
					let cityItem = CityItem(dictionary: cityDict as! NSDictionary, forecast: false)
					cities.append(cityItem)
				}
				
				complitionHandler(nil, cities)
				
			case .Error(let error) :
				complitionHandler(error, nil)
			}
		}
	}
	
	private func buildParam(key : String, value : String) -> String! {
		return "&" + key + "=" + value
	}
	
	func currentWeather(cityName : String, complitionHandler : cityComplitionHandler) {
		var method = "weather?"
		method += buildParam("q", value: cityName)
		requestWithCityResponse(method, complitionHandler: complitionHandler, forecast: false)
	}
	
	func currentWeather(cityId : Int, complitionHandler : cityComplitionHandler) {
		var method = "weather?"
		method += buildParam("id", value: "\(cityId)")
		requestWithCityResponse(method, complitionHandler: complitionHandler, forecast: false)
	}
	
	func currentWeather(coordinate: CLLocationCoordinate2D, complitionHandler : cityComplitionHandler) {
		var method = "weather?"
		method += buildParam("lat", value: "\(coordinate.latitude)")
		method += buildParam("lon", value: "\(coordinate.longitude)")
		requestWithCityResponse(method, complitionHandler: complitionHandler, forecast: false)
	}
	
	func severalWeather(coordinate: CLLocationCoordinate2D, citiesCount : Int, complitionHandler : citiesComplitionHandler) {
		var method = "find?"
		method += buildParam("lat", value: "\(coordinate.latitude)")
		method += buildParam("lon", value: "\(coordinate.longitude)")
		method += buildParam("cnt", value: "\(citiesCount)")
		requestWithCitiesResponse(method, complitionHandler: complitionHandler)
	}
	
	func forecastWeather(cityName : String, complitionHandler : cityComplitionHandler) {
		var method = "forecast?"
		method += buildParam("q", value: cityName)
		requestWithCityResponse(method, complitionHandler: complitionHandler, forecast: true)
	}
	
	func forecastWeather(cityId : Int, complitionHandler : cityComplitionHandler) {
		var method = "forecast?"
		method += buildParam("id", value: "\(cityId)")
		requestWithCityResponse(method, complitionHandler: complitionHandler, forecast: true)
	}
	
	func forecastWeather(coordinate: CLLocationCoordinate2D, complitionHandler : cityComplitionHandler) {
		var method = "forecast?"
		method += buildParam("lat", value: "\(coordinate.latitude)")
		method += buildParam("lon", value: "\(coordinate.longitude)")
		requestWithCityResponse(method, complitionHandler: complitionHandler, forecast: true)
	}
	
}
