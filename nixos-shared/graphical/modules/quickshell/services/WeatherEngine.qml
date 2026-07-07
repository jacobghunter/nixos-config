import QtQuick

Item {
    id: engine

    // Engine State Properties
    property string timeString: ""
    property real latitude: 0.0
    property real longitude: 0.0

    // Weather Output Properties
    property string currentForecast: "Locating..."
    property double currentTemp: 0.0
    property string tempUnit: "F"
    property string errorString: ""

    // 1. Time Tracking
    Timer {
        id: internalTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: engine.timeString = new Date().toLocaleTimeString(Qt.locale(), "hh:mm AP")
        Component.onCompleted: engine.timeString = new Date().toLocaleTimeString(Qt.locale(), "hh:mm AP")
    }

    // 2. Weather Fetch Interval (Updates every 15 minutes)
    Timer {
        id: weatherTimer
        interval: 900000
        running: true
        repeat: true
        onTriggered: fetchLocation()
    }

    // Automatically detect location when the engine mounts
    Component.onCompleted: fetchLocation()

    // 3. Geolocation & Weather Pipeline

    // Step 0: Auto-Detect Coordinates via IP Address
    function fetchLocation() {
        let url = "https://freeipapi.com/api/json";
        let xhr = new XMLHttpRequest();

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    let response = JSON.parse(xhr.responseText);
                    engine.latitude = response.latitude;
                    engine.longitude = response.longitude;

                    // Move to Step 1 now that we have valid coordinates
                    fetchNwsGridPoints();
                } else {
                    engine.errorString = "Location detection failed.";
                    console.error("GeoIP Error: ", xhr.statusText);
                }
            }
        };

        xhr.open("GET", url);
        xhr.send();
    }

    // Step 1: Convert Lat/Lon to NWS Grid Endpoint
    function fetchNwsGridPoints() {
        let url = `https://api.weather.gov/points/${engine.latitude},${engine.longitude}`;
        let xhr = new XMLHttpRequest();

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    let response = JSON.parse(xhr.responseText);
                    let forecastUrl = response.properties.forecastHourly;

                    // Move to Step 2
                    fetchActualForecast(forecastUrl);
                } else {
                    engine.errorString = "Failed to locate weather grid.";
                    console.error("NWS Point Lookup Error: ", xhr.statusText);
                }
            }
        };

        xhr.open("GET", url);
        xhr.setRequestHeader("User-Agent", "QMLWeatherWidgetEngine/1.0");
        xhr.send();
    }

    // Step 2: Fetch the actual hourly forecast data from the grid
    function fetchActualForecast(url) {
        let xhr = new XMLHttpRequest();

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    let response = JSON.parse(xhr.responseText);
                    let currentPeriod = response.properties.periods[0];

                    // Map data back to our UI properties
                    engine.currentForecast = currentPeriod.shortForecast;
                    engine.currentTemp = currentPeriod.temperature;
                    engine.tempUnit = currentPeriod.temperatureUnit;
                    engine.errorString = "";
                } else {
                    engine.errorString = "Failed to fetch weather data.";
                    console.error("NWS Forecast Error: ", xhr.statusText);
                }
            }
        };

        xhr.open("GET", url);
        xhr.setRequestHeader("User-Agent", "QMLWeatherWidgetEngine/1.0");
        xhr.send();
    }
}
