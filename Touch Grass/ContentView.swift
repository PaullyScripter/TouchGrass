//
//  ContentView.swift
//  Touch Grass
//
//  Created by Lily Bozeman on 2/17/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ForecastView()
    }
}

struct ForecastView: View {
    @State private var forecast: ForecastPeriod? = nil
    @State private var location: LocationInfo? = nil
    
    var body: some View {
        VStack {
            if let location = location {
                Text("\(location.city), \(location.state)")
            }
            
            
            
            if let forecast = forecast {
                Text(forecast.name)
                    .font(.largeTitle)
                Text("High: \(forecast.temperature)°\(forecast.temperatureUnit)")
                Text(forecast.shortForecast)
                
                
                
                
                AsyncImage (url: URL(string: forecast.icon)) {
                    image in image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }.frame(width: 100, height: 100)
                
            }
        } .task {
            // Get the location.
            location = await getLocationInfo()
            
            // If the forecastURL has been loaded, then request the forecast.
            if let forecastURL = location?.forecastURL {
                forecast = await getDayForecast(forecastURLString: forecastURL)
            }
            
        }
    }
}

#Preview {
    ContentView()
}
