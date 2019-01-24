//
//  ViewController.swift
//  LocationBeacon
//
//  Created by Jason C on 1/23/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{

    let manager = CLLocationManager()
    
    struct beaconPost: Codable {
        let locationID: Int
        let deviceID: Int
        let latitude: String
        let longitude: String
        let clientIP: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        
        // Check the authorization status and get it if it not yet determined
        if CLLocationManager.authorizationStatus() == .notDetermined {
            manager.requestAlwaysAuthorization()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
            print("startUpdatingLocation")
        }
        
    }
    

    
    func submitPost(post: beaconPost, completion:((Error?) -> Void)?) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "jasonthechiu.com"
        urlComponents.port = 8080
        urlComponents.path = "/api/locations/"
        
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        print("url: " + (request.url?.absoluteString)!)
        request.httpMethod = "POST"
        // Make sure that we include headers specifying that our request's HTTP body
        // will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        // Now let's encode out Post struct into JSON data...
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(post)
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            completion?(error)
        }
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                completion?(responseError!)
                return
            }
            
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
    }

    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let myPost = beaconPost(locationID: 1, deviceID: 1, latitude: "Hello World", longitude: "How are you all today?", clientIP: "hohoho")

        submitPost(post: myPost) { (error) in
            if let error = error {
                // fatalError(error.localizedDescription)
                print("error: " + error.localizedDescription)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

