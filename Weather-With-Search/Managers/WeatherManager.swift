import Foundation
import CoreLocation


class WeatherManager {
    // HTTP request to get the current weather depending on the coordinates we got from LocationManager
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, unit: String, timeZone: String) async throws -> WeatherData {
        let localTimeZoneIdentifier: String = timeZone
        guard let encodedTimeZone = localTimeZoneIdentifier.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,is_day,weather_code&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,sunset,sunrise&timeformat=unixtime&temperature_unit=\(unit)&timezone=\(encodedTimeZone)&format=json") else {
                    fatalError("Missing or invalid URL")
                }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw networkingError.responseError
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(WeatherData.self, from: data)
        } catch {
            throw networkingError.dataError
        }
    
    }

}



enum networkingError : Error {
    case responseError, dataError
}

func getFormattedTime(from date: Date, with format: String, for timeZone: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone(identifier: timeZone)
    return dateFormatter.string(from: date)
}


func getWeatherIconName(code: Int, isDay: Int) -> String {
    let timeOfDay = (isDay == 1) ? "day" : "night"
        return weatherCodeIconMapping[String(code)]?[timeOfDay]?["image"].flatMap { "https://openweathermap.org/img/wn/" + $0 } ?? "None"
}

func getWeatherName(code: Int, isDay: Int) -> String {
    let timeOfDay = (isDay == 1) ? "day" : "night"
        return weatherCodeIconMapping[String(code)]?[timeOfDay]?["description"].flatMap { $0 } ?? "None"
}


func isSameDateAndHour(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    
    let components1 = calendar.dateComponents([.year, .month, .day, .hour], from: date1)
    let components2 = calendar.dateComponents([.year, .month, .day, .hour], from: date2)
    
    return components1.year == components2.year &&
           components1.month == components2.month &&
           components1.day == components2.day &&
           components1.hour == components2.hour
}

func isSameDate(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    
    let components1 = calendar.dateComponents([.year, .month, .day, .hour], from: date1)
    let components2 = calendar.dateComponents([.year, .month, .day, .hour], from: date2)
    
    return components1.year == components2.year &&
           components1.month == components2.month &&
           components1.day == components2.day
}

func isDayTime(date: Date, response: WeatherData) -> Int {
    var sunriseTime: Date?
    var sunsetTime: Date?
    for i in 0...6 {
        if isSameDate(date1: date, date2: response.daily.sunrise[i]) {
            sunriseTime = response.daily.sunrise[i]
        }
        if isSameDate(date1: date, date2: response.daily.sunset[i]) {
            sunsetTime = response.daily.sunset[i]
        }
    }
    
    if let sunsetTime = sunsetTime, let sunriseTime = sunriseTime{
        if sunriseTime <= date && date < sunsetTime {
            return 1
        }
        else {
            return 0
        }
    }
    return 1
}

func loadCurrentWeather(_ response: WeatherData) -> CurrentWeather {
    let isDay = response.current.is_day
    let timeZone = response.timezone
    return CurrentWeather(
        dayName: getFormattedTime(from: response.current.time, with: "EEE", for: timeZone),
        date: getFormattedTime(from: response.current.time, with: "MMM d", for: timeZone),
        temperature: response.current.temperature_2m,
        temperatureUnit: response.current_units.temperature_2m,
        weatherName: getWeatherName(code: response.current.weather_code, isDay: isDay),
        weatherIconName: getWeatherIconName(code: response.current.weather_code, isDay: isDay), timeZone: response.timezone)
        
}

func loadHourWeather(_ response: WeatherData) -> [HourWeatherItem] {
    var hourArray: [HourWeatherItem] = []
    let currentTime = Date()
    let timeZone = response.timezone
    var hourStartIndex = 0
    
    while !isSameDateAndHour(date1: currentTime, date2: response.hourly.time[hourStartIndex]) {
        hourStartIndex += 1
    }
    let hourlyData = response.hourly
    
    for i in 0...23 {
        hourArray.append(HourWeatherItem(
            hour: getFormattedTime(from: hourlyData.time[i + hourStartIndex], with: "h a", for: timeZone),
            weatherIconName: getWeatherIconName(code: hourlyData.weather_code[i + hourStartIndex], isDay: isDayTime(date: hourlyData.time[i + hourStartIndex], response: response)),
            temperature: hourlyData.temperature_2m[i + hourStartIndex],
            temperatureUnit: response.hourly_units.temperature_2m
        ))
    }
    return hourArray
    
}

func loadDailyWeather(_ response: WeatherData) -> [DayWeatherItem] {
    var dayArray: [DayWeatherItem] = []
    let dailyData = response.daily
    let timeZone = response.timezone
    
    for i in 0..<dailyData.time.count {
        dayArray.append(DayWeatherItem(
            dayName: (i == 0) ? "Today" : getFormattedTime(from: dailyData.time[i], with: "EEE", for: timeZone),
            maxTemperature: dailyData.temperature_2m_max[i],
            minTemperature: dailyData.temperature_2m_min[i],
            temperatureUnit: response.daily_units.temperature_2m_min,
            weatherIconName: getWeatherIconName(code: dailyData.weather_code[i], isDay: 1))
        )
    }
    return dayArray
}

func showTemperature(from value: Float, of currentUnit: String, to preferredUnit: UnitTemperature) -> String {
    return String(convertTemperature(from: value, of: currentUnit, to: preferredUnit)) + "°"
}

func convertTemperature(from value: Float, of currentUnit: String, to preferredUnit: UnitTemperature) -> Double {
    let temperature = Measurement(value: Double(value), unit: currentUnit == "°C" ? UnitTemperature.celsius : UnitTemperature.fahrenheit)
    var rawValue = temperature.converted(to: preferredUnit).value
    rawValue = ceil(rawValue * 10) / 10.0
    return rawValue
}
