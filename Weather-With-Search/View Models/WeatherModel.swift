//
//  CurrentWeatherModel.swift
//  Weather
//
//  Created by Yumeng Liu on 7/7/24.
//

import Foundation


let weatherCodeIconMapping = [
    "0": ["day": ["description": "Sunny", "image": "01d@2x.png"], "night": ["description": "Clear", "image": "01n@2x.png"]], "1": ["day": ["description": "Mainly Sunny", "image": "01d@2x.png"], "night": ["description": "Mainly Clear", "image": "01n@2x.png"]], "2": ["day": ["description": "Partly Cloudy", "image": "02d@2x.png"], "night": ["description": "Partly Cloudy", "image": "02n@2x.png"]], "3": ["day": ["description": "Cloudy", "image": "03d@2x.png"], "night": ["description": "Cloudy", "image": "03n@2x.png"]], "45": ["day": ["description": "Foggy", "image": "50d@2x.png"], "night": ["description": "Foggy", "image": "50n@2x.png"]], "48": ["day": ["description": "Rime Fog", "image": "50d@2x.png"], "night": ["description": "Rime Fog", "image": "50n@2x.png"]], "51": ["day": ["description": "Light Drizzle", "image": "09d@2x.png"], "night": ["description": "Light Drizzle", "image": "09n@2x.png"]], "53": ["day": ["description": "Drizzle", "image": "09d@2x.png"], "night": ["description": "Drizzle", "image": "09n@2x.png"]], "55": ["day": ["description": "Heavy Drizzle", "image": "09d@2x.png"], "night": ["description": "Heavy Drizzle", "image": "09n@2x.png"]], "56": ["day": ["description": "Light Freezing Drizzle", "image": "09d@2x.png"], "night": ["description": "Light Freezing Drizzle", "image": "09n@2x.png"]], "57": ["day": ["description": "Freezing Drizzle", "image": "09d@2x.png"], "night": ["description": "Freezing Drizzle", "image": "09n@2x.png"]], "61": ["day": ["description": "Light Rain", "image": "10d@2x.png"], "night": ["description": "Light Rain", "image": "10n@2x.png"]], "63": ["day": ["description": "Rain", "image": "10d@2x.png"], "night": ["description": "Rain", "image": "10n@2x.png"]], "65": ["day": ["description": "Heavy Rain", "image": "10d@2x.png"], "night": ["description": "Heavy Rain", "image": "10n@2x.png"]], "66": ["day": ["description": "Light Freezing Rain", "image": "10d@2x.png"], "night": ["description": "Light Freezing Rain", "image": "10n@2x.png"]], "67": ["day": ["description": "Freezing Rain", "image": "10d@2x.png"], "night": ["description": "Freezing Rain", "image": "10n@2x.png"]], "71": ["day": ["description": "Light Snow", "image": "13d@2x.png"], "night": ["description": "Light Snow", "image": "13n@2x.png"]], "73": ["day": ["description": "Snow", "image": "13d@2x.png"], "night": ["description": "Snow", "image": "13n@2x.png"]], "75": ["day": ["description": "Heavy Snow", "image": "13d@2x.png"], "night": ["description": "Heavy Snow", "image": "13n@2x.png"]], "77": ["day": ["description": "Snow Grains", "image": "13d@2x.png"], "night": ["description": "Snow Grains", "image": "13n@2x.png"]], "80": ["day": ["description": "Light Showers", "image": "09d@2x.png"], "night": ["description": "Light Showers", "image": "09n@2x.png"]], "81": ["day": ["description": "Showers", "image": "09d@2x.png"], "night": ["description": "Showers", "image": "09n@2x.png"]], "82": ["day": ["description": "Heavy Showers", "image": "09d@2x.png"], "night": ["description": "Heavy Showers", "image": "09n@2x.png"]], "85": ["day": ["description": "Light Snow Showers", "image": "13d@2x.png"], "night": ["description": "Light Snow Showers", "image": "13n@2x.png"]], "86": ["day": ["description": "Snow Showers", "image": "13d@2x.png"], "night": ["description": "Snow Showers", "image": "13n@2x.png"]], "95": ["day": ["description": "Thunderstorm", "image": "11d@2x.png"], "night": ["description": "Thunderstorm", "image": "11n@2x.png"]], "96": ["day": ["description": "Light Thunderstorms With Hail", "image": "11d@2x.png"], "night": ["description": "Light Thunderstorms With Hail", "image": "11n@2x.png"]], "99": ["day": ["description": "Thunderstorm With Hail", "image": "11d@2x.png"], "night": ["description": "Thunderstorm With Hail", "image": "11n@2x.png"]]]


// Model of the response body we get from calling the API

struct WeatherData: Codable {
    let latitude: Double
    let longitude: Double
    let generationtime_ms: Double
    let utc_offset_seconds: Int
    let timezone: String
    let timezone_abbreviation: String
    let elevation: Int
    let current_units: CurrentUnits
    let current: Current
    let hourly_units: HourlyUnits
    let hourly: Hourly
    let daily_units: DailyUnits
    let daily: Daily

    struct CurrentUnits: Codable {
        let time: String
        let interval: String
        let temperature_2m: String
        let is_day: String
        let weather_code: String
    }

    struct Current: Codable {
        let time: Date
        let interval: Int
        let temperature_2m: Float
        let is_day: Int
        let weather_code: Int
    }

    struct HourlyUnits: Codable {
        let time: String
        let temperature_2m: String
        let weather_code: String
    }

    struct Hourly: Codable {
        let time: [Date]
        let temperature_2m: [Float]
        let weather_code: [Int]
    }

    struct DailyUnits: Codable {
        let time: String
        let weather_code: String
        let temperature_2m_max: String
        let temperature_2m_min: String
    }

    struct Daily: Codable {
        let time: [Date]
        let weather_code: [Int]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
        let sunset: [Date]
        let sunrise: [Date]
    }
}


struct CurrentWeather {
    let dayName: String
    let date: String
    let temperature: Float
    let temperatureUnit: String
    let weatherName: String
    let weatherIconName: String
    let timeZone: String
    
    func presentTemperature() -> String {
        return "\(temperature)°"
    }
}

struct HourWeatherItem : Identifiable {
    let id: UUID = UUID()
    let hour: String
    let weatherIconName: String
    let temperature: Float
    let temperatureUnit: String
    
    func presentTemperature() -> String {
        return "\(temperature)°"
    }
    
}

struct DayWeatherItem: Identifiable {
    let id: UUID = UUID()
    let dayName: String
    let maxTemperature: Double
    let minTemperature: Double
    let temperatureUnit: String
    let weatherIconName: String
    
}
