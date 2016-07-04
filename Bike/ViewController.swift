//
//  ViewController.swift
//  Bike
//
//  Created by LarryStanley on 2016/7/3.
//  Copyright © 2016年 LarryStanley. All rights reserved.
//

import UIKit
import Hex
import ionicons
import Material
import Advance
import NVActivityIndicatorView
import Alamofire
import SwiftLocation
import LTMorphingLabel
import CoreLocation

class ViewController: UIViewController {

    var indicatorView: NVActivityIndicatorView!
    var menuButton, searchButton, navigateButton, moreDetailsButton: UIButton!
    var nearLabel, nearNameLabel, nearDistanceLabel, rentLabel, rentCountLabel, returnLabel, returnCountLabel, loadingLabel: UILabel!

    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.width = self.view.frame.size.width
        self.height = self.view.frame.size.height
        
        // Status Bar
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Background gradient
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(hex: "43CEA2").CGColor, UIColor(hex: "185A9D").CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width + 10, height: self.view.frame.size.height)
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
        // Loading view
        loadingLabel = LTMorphingLabel()
        loadingLabel.text = "資料載入中"
        loadingLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        loadingLabel.sizeToFit()
        loadingLabel.center = self.view.center
        loadingLabel.frame = CGRectMake(0, loadingLabel.frame.origin.y, self.width, loadingLabel.frame.height)
        loadingLabel.textAlignment = .Center
        loadingLabel.textColor = UIColor.whiteColor()
        loadingLabel.alpha = 0
        self.view.addSubview(loadingLabel)
        
        indicatorView = NVActivityIndicatorView(frame: CGRectMake(0,0, 60, 60), type: NVActivityIndicatorType.BallScaleRipple, color: UIColor.whiteColor())
        indicatorView.center = CGPointMake(loadingLabel.center.x, loadingLabel.center.y - 70)
        self.view.addSubview(indicatorView)
        
        UIView.animateWithDuration(0.5, animations: {
            self.indicatorView.startAnimation()
            self.loadingLabel.alpha = 1
        })
        
        Alamofire.request(.GET, "http://data.taipei/youbike", parameters: nil)
            .responseJSON { response in
                
                if let JSON = response.result.value {
                    let retVal = JSON["retVal"]
                    let componentArray = (retVal!!.allKeys as! [String]).sort(<)
                    self.loadingLabel.text = "位置取得完畢"
                    
                    LocationManager.shared.observeLocations(.Block, frequency: .OneShot, onSuccess: { location in
                        var distance = CLLocationDistance(10000000)
                        var nearIndex = "0001"
                        for index in componentArray {
                            let latitude = retVal!![index]!!["lat"]?!.doubleValue
                            let longitude = retVal!![index]!!["lng"]?!.doubleValue
                            let stationCoordinate = CLLocation(latitude: latitude!, longitude: longitude!)
                            if (location.distanceFromLocation(stationCoordinate) < distance) {
                                distance = location.distanceFromLocation(stationCoordinate)
                                nearIndex = index
                            }
                        }
                        self.initUserInterface(retVal!![nearIndex]!!["sna"] as! String
                            , nearDistance: String(distance), rentCount: retVal!![nearIndex]!!["tot"] as! String, returnCount: retVal!![nearIndex]!!["sbi"] as! String)
                        self.showResultAnimation()
                        
                    }) { error in
                        self.loadingLabel.text = "位置取得失敗"
                        print(error)
                    }
                }
        }
    
    }

    func showResultAnimation() {
        
        UIView.animateWithDuration(0.5, animations: {
            self.indicatorView.stopAnimation()
            self.loadingLabel.alpha = 0
            self.nearLabel.alpha = 1
            }, completion: {
                finished in
                UIView.animateWithDuration(0.5, animations: {
                    self.nearLabel.alpha = 1
                    self.nearNameLabel.alpha = 1
                    self.nearDistanceLabel.alpha = 1
                    }, completion: {
                        finished in
                        UIView.animateWithDuration(0.5, animations: {
                            self.navigateButton.transform = CGAffineTransformMakeScale(1, 1)
                            self.navigateButton.alpha = 1
                            }, completion: {
                                finished in
                                UIView.animateWithDuration(0.5, animations: {
                                    self.returnLabel.alpha = 1
                                    self.rentLabel.alpha = 1
                                    }, completion: {
                                        finished in
                                        UIView.animateWithDuration(0.5, animations: {
                                            self.returnCountLabel.alpha = 1
                                            self.rentCountLabel.alpha = 1
                                            }, completion: {
                                                finished in
                                                UIView.animateWithDuration(0.5, animations: {
                                                    self.menuButton.frame = CGRectMake( 10, 30, 44, 44)
                                                    self.menuButton.alpha = 1
                                                    self.searchButton.frame = CGRectMake( self.width - 54, 30, 44, 44)
                                                    self.searchButton.alpha = 1
                                                    self.moreDetailsButton.frame = CGRectMake(0, self.height - 64, self.width, 64);
                                                })
                                        })
                                })
                        })
                })
        })
    }
    
    func initUserInterface(nearName: String, nearDistance: String, rentCount: String, returnCount: String) {
        // Up button
        menuButton = UIButton()
        menuButton.frame = CGRectMake( -44, 30, 44, 44)
        menuButton.titleLabel?.font = IonIcons.fontWithSize(50)
        menuButton.setTitle(ion_navicon, forState: .Normal)
        menuButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        menuButton.alpha = 0
        self.view.addSubview(menuButton)
        
        searchButton = UIButton()
        searchButton.frame = CGRectMake( width, 30, 44, 44)
        searchButton.titleLabel?.font = IonIcons.fontWithSize(50)
        searchButton.setTitle(ion_ios_search, forState: .Normal)
        searchButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        searchButton.alpha = 0
        self.view.addSubview(searchButton)
        
        nearLabel = UILabel()
        nearLabel.text = "最近站點"
        nearLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        nearLabel.sizeToFit()
        nearLabel.frame = CGRectMake(width/2 - nearLabel.frame.width/2, height/2 - 150, nearLabel.frame.width, nearLabel.frame.height)
        nearLabel.textColor = UIColor.whiteColor()
        nearLabel.alpha = 0
        self.view.addSubview(nearLabel)
        
        nearNameLabel = UILabel()
        nearNameLabel.text = nearName
        nearNameLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 24)
        nearNameLabel.sizeToFit()
        nearNameLabel.frame = CGRectMake(width/2 - nearNameLabel.frame.width/2, nearLabel.frame.size.height + nearLabel.frame.origin.y + 5, nearNameLabel.frame.width, nearNameLabel.frame.height)
        nearNameLabel.textColor = UIColor.whiteColor()
        nearNameLabel.alpha = 0
        self.view.addSubview(nearNameLabel)
        
        nearDistanceLabel = UILabel()
        nearDistanceLabel.text = nearDistance
        nearDistanceLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        nearDistanceLabel.sizeToFit()
        nearDistanceLabel.frame = CGRectMake(width/2 - nearDistanceLabel.frame.width/2, nearNameLabel.frame.size.height + nearNameLabel.frame.origin.y + 5, nearDistanceLabel.frame.width, nearDistanceLabel.frame.height)
        nearDistanceLabel.textColor = UIColor.whiteColor()
        nearDistanceLabel.alpha = 0
        self.view.addSubview(nearDistanceLabel)
        
        navigateButton = UIButton()
        navigateButton.frame = CGRectMake( width/2 - 22, nearDistanceLabel.frame.size.height + nearDistanceLabel.frame.origin.y + 10, 44, 44)
        navigateButton.titleLabel?.font = IonIcons.fontWithSize(50)
        navigateButton.setTitle(ion_ios_navigate, forState: .Normal)
        navigateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        navigateButton.alpha = 0
        self.view.addSubview(navigateButton)
        navigateButton.transform = CGAffineTransformMakeScale(0, 0);
        
        moreDetailsButton = FlatButton()
        moreDetailsButton.frame = CGRectMake(0, height, width, 64);
        moreDetailsButton.backgroundColor = UIColor(hex: "616161")
        moreDetailsButton.alpha = 0.4
        moreDetailsButton.setTitle("詳細資訊", forState: .Normal)
        moreDetailsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.view.addSubview(moreDetailsButton)
        
        rentLabel = UILabel()
        rentLabel.text = "可借"
        rentLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        rentLabel.sizeToFit()
        rentLabel.frame = CGRectMake(width/2 - rentLabel.frame.width/2 - 60, height - 200, rentLabel.frame.width, rentLabel.frame.height)
        rentLabel.textColor = UIColor.whiteColor()
        rentLabel.alpha = 0
        self.view.addSubview(rentLabel)
        
        rentCountLabel = UILabel()
        rentCountLabel.text = rentCount
        rentCountLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 72)
        rentCountLabel.sizeToFit()
        rentCountLabel.frame = CGRectMake(rentLabel.center.x - rentCountLabel.frame.width/2, rentLabel.frame.size.height + rentLabel.frame.origin.y + 5, rentCountLabel.frame.width, rentCountLabel.frame.height)
        rentCountLabel.textColor = UIColor.whiteColor()
        rentCountLabel.alpha = 0
        self.view.addSubview(rentCountLabel)
        
        returnLabel = UILabel()
        returnLabel.text = "可還"
        returnLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        returnLabel.sizeToFit()
        returnLabel.frame = CGRectMake(width/2 - returnLabel.frame.width/2 + 60, height - 200, returnLabel.frame.width, returnLabel.frame.height)
        returnLabel.textColor = UIColor.whiteColor()
        returnLabel.alpha = 0
        self.view.addSubview(returnLabel)
        
        
        returnCountLabel = UILabel()
        returnCountLabel.text = returnCount
        returnCountLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 72)
        returnCountLabel.sizeToFit()
        returnCountLabel.frame = CGRectMake(returnLabel.center.x - returnCountLabel.frame.width/2, returnLabel.frame.size.height + returnLabel.frame.origin.y + 5, returnCountLabel.frame.width, returnCountLabel.frame.height)
        returnCountLabel.textColor = UIColor.whiteColor()
        returnCountLabel.alpha = 0
        self.view.addSubview(returnCountLabel)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

