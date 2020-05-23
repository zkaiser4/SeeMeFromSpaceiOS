//
//  EarthImageViewController.swift
//  SeeMeFromSpace
//
//  Created by ZKApps on 5/10/20.
//  Copyright © 2020 ZKApps. All rights reserved.
//

import UIKit
import MapKit

class EarthImageViewController: UIViewController {

    @IBOutlet weak var earthImageView: UIImageView!
    
    var earthImageActivityIndicator : UIActivityIndicatorView? = nil
    
    var coordinates: CLLocationCoordinate2D? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //This will set up the activity indicator
        earthImageActivityIndicator =  earthImageView.activityIndicator
        
               
        if coordinates != nil {
            //Start the activity indicator
            DispatchQueue.main.async {
                self.earthImageActivityIndicator!.startAnimating()
            }
            
            
            loadImageData(){(earthImagery) in
                if (earthImagery != nil){
                    self.displayImage(earthImageryURL: earthImagery!.getUrl())
                }else {
                    
                    DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Earth Image was not found for this location", preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                        
                            self.earthImageActivityIndicator!.stopAnimating()
                            self.navigationController?.popViewController(animated: true)
                        
                

                    }))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                        
                    }
                }
                
                
            }
            
        }
        
    }
    
    
    // This function will load the image data for the location
    private func loadImageData(completion: @escaping (_ earthImageryObject: EarthImagery?) -> ()){
        
        
            //Set-up request
            let configuration = URLSessionConfiguration.default
            
            let session = URLSession(configuration: configuration)
            
            let url = URL(string: "https://api.nasa.gov/planetary/earth/imagery")!
            
            var urlComponents = URLComponents( string: "https://api.nasa.gov/planetary/earth/assets")

            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: "lat", value: "\(self.coordinates!.latitude)"))
            queryItems.append(URLQueryItem(name: "lon", value: "\(self.coordinates!.longitude)"))
            queryItems.append(URLQueryItem(name: "dim", value: "0.15"))
            queryItems.append(URLQueryItem(name: "date", value: Date().string(format: "yyyy-MM-dd")))
            queryItems.append(URLQueryItem(name: "api_key", value: "DEMO_KEY"))
        
            urlComponents?.queryItems = queryItems

          
            var request = URLRequest(url: (urlComponents?.url)!)
            request.httpMethod = "GET"
        
            print(request.description)
        
            let task = session.dataTask(with: request) { data, response, error in
              
             
              guard error == nil else {
                print ("error: \(error!)")
                return
              }
              
        
              guard let data = data else {
                print("No data")
                return
              }
                if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
               print(JSONString)
                }
              guard let locationImage = try? JSONDecoder().decode(EarthImagery.self, from: data) else {
                print("ERROR: Data could not be decoded")
                completion(nil)
                return
              }
              
            print(locationImage)
            completion(locationImage)
              
                
            }

            task.resume()
            
        
    }
    
    
    // This function will load the image from the provided url and display it
    func displayImage(earthImageryURL : String){
        
        getImageFromURL(urlString: earthImageryURL){ (imageData) in
            if let data = imageData {
                     DispatchQueue.main.async {
                        self.earthImageActivityIndicator!.stopAnimating()
                        self.earthImageActivityIndicator!.removeFromSuperview()
                        self.earthImageView.image = UIImage(data: data)
                     }
                 } else {
                     print("Error loading image");
                    DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Earth Image does not exist for this location", preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                        
                            self.earthImageActivityIndicator!.stopAnimating()
                            self.navigationController?.popViewController(animated: true)
                        
                

                    }))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                        
                    }
                 }
            
        }
    }
    
    //This function fetches the imageURL for the image to be displayed
    func getImageFromURL(urlString: String, completion: @escaping (_ data: Data?) -> ()) {
        
        //Set-up request
        let configuration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: configuration)
        
        let url = URL(string: urlString)

        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Image could not be fetched")
                completion(nil)
            } else {
                completion(data)
            }
        }
            
        dataTask.resume()
    }
    

   

}



//This extension is to format the date to be sent in the request
extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}


//This extension is for the imageview to enable an activity indicator
extension UIImageView {

    var activityIndicator: UIActivityIndicatorView {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.hidesWhenStopped = true
    activityIndicator.color = UIColor.blue
    self.addSubview(activityIndicator)

    activityIndicator.translatesAutoresizingMaskIntoConstraints = false

    let centerX = NSLayoutConstraint(item: self,
                                     attribute: .centerX,
                                     relatedBy: .equal,
                                     toItem: activityIndicator,
                                     attribute: .centerX,
                                     multiplier: 1,
                                     constant: 0)
    let centerY = NSLayoutConstraint(item: self,
                                     attribute: .centerY,
                                     relatedBy: .equal,
                                     toItem: activityIndicator,
                                     attribute: .centerY,
                                     multiplier: 1,
                                     constant: 0)
    self.addConstraints([centerX, centerY])
    return activityIndicator
}

}
