//
//  WeatherManager.swift
//  Clima
//
//  Created by Maximiliano Ituarte on 06/01/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather (_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let weatherURl =
    "https://api.openweathermap.org/data/2.5/weather?appid=7ed1e21cd8a306daa06f5afcfcd62a26&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather (cityName: String) {
        
        let urlString = "\(weatherURl)&q=\(cityName)"
        
        performRequest(with: urlString)
    }
    
    func fetchWeather (latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let urlString = "\(weatherURl)&lat=\(latitude)&lon=\(longitude)"
        
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        
            // En esta funcion se realiza el networking, que es el paso de la query de la app hacia el servidor a cambio de los datos de la API. Podemos dividirlo en 4 pasos
        
            // 1. Crear la URL
        
            if let url = URL(string: urlString){
            // 2. Crear la sesion de la URL
            let session = URLSession(configuration: .default)
            // 3. Darle a la sesion una tarea | En este caso, se aplica una Closure
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather =  self.parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // 4. Empezar la tarea
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
    let decoder = JSONDecoder()
    do{
        let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
        
        let id = decodedData.weather[0].id
        let temp = decodedData.main.temp
        let name = decodedData.name
        
        let weather = WeatherModel(conditionId: id, cityname: name, temperature: temp)
        return weather
       
        
    } catch {
        delegate?.didFailWithError(error: error)
        return nil
    }
}
   
}
