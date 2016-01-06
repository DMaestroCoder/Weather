//
//  WeatherTableViewController.swift
//  Weather
//
//  Copyright © 2016 dmitry. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherTableViewController : UITableViewController {
	
	private var cities : [CityItem]?
	private let openWeather = OpenWeather(apiKey: "a4ff05d556d26a5cbd5ed3725ef08e46", language: "ua", temperatureFormat: .Celsius)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadWeather()
	}
	
	private func loadWeather() {
		let navigationController = self.navigationController as! BaseNavigationController
		navigationController.startLoading()
		
		openWeather.severalWeather(CLLocationCoordinate2D(latitude: 49.98679, longitude: 36.2343), citiesCount: 10){ (error : NSError?, cityItems : [CityItem]?) -> Void in
			if let error = error {
				print(error.description)
			}
			else {
				self.cities = cityItems
				self.tableView.reloadData()
			}
			
			navigationController.stopLoading()
		}
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cities != nil ? cities!.count : 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("weatherCellIdentifier") as! WeatherCell
		let city = cities![indexPath.row]
		
		cell.weatherImageView!.image = UIImage(named: "\(city.weather.icon)")
		cell.cityNameLabel!.text = city.name
		cell.temperatureLabel!.text = "\(city.weather.temp) °C"
		
		return cell;
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let selectedCell = sender as! UITableViewCell
		let indexPath = self.tableView.indexPathForCell(selectedCell)!
		let city = cities![indexPath.row]
		
		let detailViewController = segue.destinationViewController as! WeatherDetailViewController
		detailViewController.cityItem = city
	}
	
}
