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
}

import Foundation

func getDayForecast() async {
    // These are the coordinates of San Diego State University.
    let latitude = 32.774799;
    let longitude = -117.071869;
    
    let pointURLString = "https://api.weather.gov/points/\(latitude),\(longitude)"
    
    guard let pointURL = URL(string: pointURLString) else {
        print("Error. Could not create URL from string: \(pointURLString)")
        return
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
        return
    }
    
    if let httpResponse = pointResponse as? HTTPURLResponse {
        if httpResponse.statusCode != 200 {
            print("expected 200 but got \(httpResponse.statusCode)")
            return
        }
    }
    
    let pointResult: NOAAPointResponse
    do {
        pointResult = try JSONDecoder().decode(NOAAPointResponse.self, from: pointData)
    } catch {
        print("Decoding error")
        return
    }

}
