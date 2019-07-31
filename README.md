# OpenWeather


App consists of 3 controllers: WeatherViewController, ForecastViewController and SearchViewController.

For the WeatherViewController I used:
Alamofire framework - for request and Download progress;
SwiftyJSON framework - for parsing current weather conditions JSON;
MapView with MKMapViewDelegate - to find out logitude and latitude (position of centered Pin);
CoreLocation - to find out current location

Views: 
ShapeView - Center "Current" button on the bottom side of the screen;
TrackView around ShapeView - Progress view for displaying download progress;
ForecastView - View with imageView and temperatureLabel in the right top corner of the screen. Displays current weather condition for the center location.

//----------------------------------
For the ForecastViewController I used:
Alamofire framework - for request and Download progress; params = [latitude ,longitude, appID]
Decodable - for parsing the weather forecast JSON;

Views: 
CollectionView with FlowLayout
ProgressView

//----------------------------------
For the SearchViewController I used:
TextField, that passes inputText to ForecastViewController, as a parametr; params = [cityName, appID]

ALSO the app checks the internetConnection and will show DefaultAlert if needed.
