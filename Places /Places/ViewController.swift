/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

import MapKit
import CoreLocation

class ViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  fileprivate let locationManager = CLLocationManager()
  fileprivate var startedLoadingPOIs = false //tracks if there is a request in progress
  fileprivate var places = [Place]() //stores the received POIs
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.startUpdatingLocation()
    locationManager.requestWhenInUseAuthorization()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func showARController(_ sender: Any) {
  }
  
}

extension ViewController: CLLocationManagerDelegate{
 
 
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
    //part 1
    
    if locations.count > 0 {   //every time location manager updates the location
      let location = locations.last!
      print("Accuracy: \(location.horizontalAccuracy)")  //it sends this message to its delegate updating the location
      
      //part 2
      if location.horizontalAccuracy < 100 {  //this checks if the accuracy is high enough
        //part 3
        manager.stopUpdatingLocation()  //then it stops updating the location to save battery life
        let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.region = region
        
        if !startedLoadingPOIs{
          startedLoadingPOIs = true
          
          let  loader = PlacesLoader()
          loader.loadPOIS(location: location, radius: 1000) { placesDict, error in
            if let dict = placesDict {
              print(dict)
            }
          }
        }
      }
    }
  }
  
}

