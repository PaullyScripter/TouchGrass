//
//  WeatherService.swift
//  Touch Grass
//
//  Created by Lily Bozeman on 3/1/26.
//

struct NOAAPointResponse: Codable {
    let properties: PointProperties
}

struct PointProperties: Codable {
    let forecast: String
    let relativeLocation: RelativeLocation
}

struct RelativeLocation: Codable {
    let properties: RelativeLocationProperties
}

struct RelativeLocationProperties: Codable {
    let city: String
    let state: String
}

struct LocationInfo {
    let city: String
    let state: String
    let forecastURL: String
}

struct NOAAForecastResponse: Codable {
    let properties: ForecastProperties
}

struct ForecastProperties: Codable {
    let periods: [ForecastPeriod]
}

struct ForecastPeriod: Codable {
    let number: Int
    let name: String
    let temperature: Int
    let temperatureUnit: String
    let shortForecast: String
    let detailedForecast: String
    let icon: String
}

import Foundation

func getLocationInfo() async -> LocationInfo? {
    // These are the coordinates of San Diego State University.
    
    let latitude = 32.774799;
    let longitude = -117.071869;
    
    // Once we get the request from api.weather.gov for our specific coordinates,
    // 1. We verify that the response was good (a 200 return type)
    // we have to parse the JSON return into data.
    
    let pointURLString = "https://api.weather.gov/points/\(latitude),\(longitude)"
    
    guard let pointURL = URL(string: pointURLString) else {
        print("Error. Could not create URL from string: \(pointURLString)")
        return nil
    }
    
    var pointRequest = URLRequest(url: pointURL)
    pointRequest.setValue("application/geo+json", forHTTPHeaderField: "Accept")
    pointRequest.setValue("TouchGrass, test@test.com", forHTTPHeaderField: "User-Agent")

    let pointData: Data
    let pointResponse: URLResponse
    
    do {
        (pointData, pointResponse) = try await URLSession.shared.data(for: pointRequest)
        print("Successfully retrieved weather data from: \(pointURL)")
    } catch {
        print ("Error during fetch.")
        return nil
    }
    
    if let httpResponse = pointResponse as? HTTPURLResponse {
        if httpResponse.statusCode != 200 {
            print("expected 200 but got \(httpResponse.statusCode)")
            return nil
        }
    }
    
    
    do {
        let pointResult = try JSONDecoder().decode(NOAAPointResponse.self, from: pointData)
        let pointResultProperties = pointResult.properties
        return LocationInfo(
            city: pointResultProperties.relativeLocation.properties.city,
            state: pointResultProperties.relativeLocation.properties.state,
            forecastURL: pointResultProperties.forecast)
    } catch {
        print("Decoding error for points response.")
        return nil
    }
}




func getDayForecast(forecastURLString: String) async -> ForecastPeriod? {
    // Convert the forecastURLString from string type to URL type.
    guard let forecastURL = URL(string: forecastURLString) else {
        print("Error: could not create URL from string: \(forecastURLString)")
        return nil
    }
    
    // Forecast request variables.
    var forecastRequest = URLRequest(url: forecastURL)
    let forecastData: Data
    let forecastResponse: URLResponse
    
    // Configurations on the forecast request.
    forecastRequest.setValue("application/geo+json", forHTTPHeaderField: "Accept")
    forecastRequest.setValue("TouchGrass, test@test.com", forHTTPHeaderField: "User-Agent")
    
   
    
    // Requesting the forecast.
    do {
        (forecastData, forecastResponse) = try await URLSession.shared.data(for: forecastRequest)
    } catch {
        print("Error: Could not request forecast.")
        return nil
    }
    
    // HTTP Status code 200 means the request is successful.
    // So we only want to accept HTTP status code 200.
    if let forecastHTTPResponse = forecastResponse as? HTTPURLResponse {
        if forecastHTTPResponse.statusCode != 200 {
            return nil
        }
    }
    
    // Return the forecast if it can be decoded.
    do {
        let forecastResult = try JSONDecoder().decode(NOAAForecastResponse.self, from: forecastData)
        return forecastResult.properties.periods[0]
    } catch {
        print("Decoding error for forecast.")
        return nil
    }
}
