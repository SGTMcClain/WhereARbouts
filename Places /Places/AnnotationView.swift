//
//  AnnotationView.swift
//  Places
//
//  Created by Nathan McClain on 11/3/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

//1 Create a delegate protocol
protocol AnnotationViewDelegate{
  func didTouch(annotationView: AnnotationView)
}

//2 This creates a subclass of ARAnnotationView which is used to show a view for a POI
class AnnotationView: ARAnnotationView {
  
  //3 Shows a label with the name of the POI and a second label with the distance.
  // These lines delare the needed properties and a third one you again need later
  var titleLabel: UILabel?
  var distanceLabel: UILabel?
  var delegate: AnnotationViewDelegate?
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    loadUI()
  }
  
  //4 loadUI() adds and configures the labels
  func loadUI() {
    titleLabel?.removeFromSuperview()
    distanceLabel?.removeFromSuperview()
    
    let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
    label.font = UIFont.systemFont(ofSize: 16)
    label.numberOfLines = 0
    label.backgroundColor = UIColor.white
    self.addSubview(label)
    self.titleLabel = label
    
    distanceLabel = UILabel(frame: CGRect(x: 10, y:30, width: self.frame.size.width, height: 20))
    distanceLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
    distanceLabel?.textColor = UIColor.green
    distanceLabel?.font = UIFont.systemFont(ofSize: 12)
    self.addSubview(distanceLabel!)
    
    if let annotation = annotation as? Place {
      titleLabel?.text = annotation.placeName
      distanceLabel?.text = String(format: "%.2f km", annotation.distanceFromUser / 1000)
    }
  }
  
  //1 This method is called everytime the view needs to be redrawn and you simply make sure that the frames of the label have the crrect values by reseting them.
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel?.frame = CGRect(x: 10, y:0, width: self.frame.size.width, height: 30)
    distanceLabel?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20)
  }
  
  //2 Here you tell the delegate that a view was touched, so the delegate can decide if and which action is needed
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
    delegate?.didTouch(annotationView: self)
  }
}


