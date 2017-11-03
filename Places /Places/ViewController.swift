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
  fileprivate var arViewController: ARViewController!
  
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
    arViewController = ARViewController()
    
    //1 The dataSource for the arViewController is set.
    //  The dataSource provides views for visible POIs
    arViewController.dataSource = self
    
    //2
    arViewController.maxVisibleAnnotations = 30     //limiting this to 30 keeps things smooth but
                                                    //limits how many can be see at once in places
                                                    //with many POIS
    
    arViewController.headingSmoothingFactor = 0.05  //0.00 to 1 higher values cause jumping,
                                                    //lower values will smooth out the animation
                                                    //but the views may be a bit behind
    
    //For a scavenger hunt type of game or to simply limit the number of annotations in a busy area
    //you may also want to use maxDistance which limits the annotations given the meters in distance
    //See ARController.swift for more details
    
    //3 This shows the arViewController
    arViewController.setAnnotations(places)
    
    self.present(arViewController, animated: true, completion: nil)
    
  }
  
}

extension ViewController: ARDataSource {
  func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
    let annotationView = AnnotationView()
    annotationView.annotation = viewForAnnotation
    annotationView.delegate = self
    annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
    
    return annotationView
  }
}

extension ViewController:AnnotationViewDelegate {
  func didTouch(annotationView: AnnotationView){
    print("Tapped view for POI: \(annotationView.titleLabel?.text)")
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
              
              //1  The guard statement checks that the response has the expected format
              guard let placesArray = dict.object(forKey: "results") as? [NSDictionary] else {return}
              
              //2 This line iterates over the recived POI's
              for placeDict in placesArray{
                
                //3 These lines get the needed information from the dictionary.
                //  The response contains a lot more information that is not needed for this app.
                let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
                let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                let reference = placeDict.value(forKey: "reference") as! String
                let name = placeDict.value(forKey: "name") as! String
                let address = placeDict.value(forKey: "vicinity") as! String
                
                let location = CLLocation(latitude: latitude, longitude: longitude)
                
                //4 With the extracted information a Place object is created and appended to the places array
                let place = Place(location: location, reference: reference, name:name, address: address)
                self.places.append(place)
                
                //5 The next line creates a PlaceAnnotation that is used to show an annotation on the map view
                let annotation = PlaceAnnotation(location: place.location!.coordinate, title: place.placeName)
                
                //6 Finally the annotation is added to the map view.
                //Since this manipulates the UI, the code has to be executed on the main thread
                DispatchQueue.main.async {
                  self.mapView.addAnnotation(annotation)
                }
              }
            }
          }
        }
      }
    }
  }
  
}

