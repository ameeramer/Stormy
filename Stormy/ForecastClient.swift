//
//  ForecastClient.swift
//  Stormy
//
//  Created by Ameer Amer on 22/08/2016.
//  Copyright © 2016 Ameer Amer. All rights reserved.
//

import Foundation

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

enum Forecast: Endpoint {
    case Current(token: String, coordinatte: Coordinate)
    
    var baseURL: NSURL {
        return NSURL(string: "https://api.forecast.io")!
    }
    
    var path: String {
        switch self {
        case .Current(let token, let coordinatte):
            return "/forecast/\(token)/\(coordinatte.latitude),\(coordinatte.longitude)"
        }
    }
    
    var request: NSURLRequest {
        let url = NSURL(string: path, relativeToURL: baseURL)!
        return NSURLRequest(URL: url)
    }
}

final class ForecastAPIClient: APIClient {
    let configuration: NSURLSessionConfiguration
    lazy var session: NSURLSession = {
        return NSURLSession(configuration: self.configuration)
    }()
    private let token: String
    
    init(config: NSURLSessionConfiguration, APIKey: String) {
        self.configuration = config
        self.token = APIKey
    }
    
    convenience init(APIKey: String) {
        self.init(config: NSURLSessionConfiguration.defaultSessionConfiguration(), APIKey: APIKey)
    }

    func fetchCurrentWeather(coordinate: Coordinate, completion: APIResult<CurrentWeather> -> Void) {
        let request = Forecast.Current(token: self.token, coordinatte: coordinate).request
        fetch(request, parse: { json -> CurrentWeather? in
            // Parse from JSON response to CurrentWeather
            
            if let currentWeatherDictionary = json["currently"] as? [String: AnyObject] {
                return CurrentWeather(JSON: currentWeatherDictionary)
            } else {
                return nil
            }
            
        }, completion: completion)
    }
}