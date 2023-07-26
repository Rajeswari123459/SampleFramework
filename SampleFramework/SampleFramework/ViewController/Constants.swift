//
//  Constants.swift
//  Decree
//
//  Created by Apple on 19/02/21.
//

import Foundation
import UIKit

let story_Board = UIStoryboard.init(name: "Main", bundle: nil)
let MAX_LENGTH:Int8 = 30
var wentBackgroundDate:Date? = nil
var cameForeGroundDate:Date? = nil

// MARK:- Global Device Constant

let IS_IPHONE = (UI_USER_INTERFACE_IDIOM() == .phone)

let IS_IPAD = (UIDevice.current.userInterfaceIdiom == .pad)
let IS_IPHONE_4 = (IS_IPHONE && UIScreen.main.bounds.size.height == 480.0)
let IS_IPHONE_5 = (IS_IPHONE && UIScreen.main.bounds.size.height == 568.0)
let IS_IPHONE_6 = (IS_IPHONE && UIScreen.main.bounds.size.height == 667.0)
let IS_IPHONE_6plus = (IS_IPHONE && UIScreen.main.bounds.size.height == 736.0)
let IS_IPHONE_X = (IS_IPHONE && UIScreen.main.bounds.size.height >= 812.0)
let IS_IPHONE_XR = (IS_IPHONE && UIScreen.main.bounds.size.height == 597.33)
let IS_IPHONE_XS_MAX = (IS_IPHONE && UIScreen.main.bounds.size.height == 896.0)

// MARK:- Global Size Constant

var screenWidth : CGFloat = UIScreen.main.bounds.size.width
var screenHeight : CGFloat = UIScreen.main.bounds.size.height

// MARK:- Color Constants
let appThemeColor = "#4378c0"



let theme_lightBlue = "#F1F9FF"
let theme_midBlue = "#00CFFF"
let theme_midNightBlue = "#00468c"
let theme_gold = "#D4AF37"
let theme_red = "#FF0000"


func getDeviceType() -> UIUserInterfaceIdiom? {
  let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom

    // 2. check the idiom
    switch (deviceIdiom) {

    case .pad:
        return .pad
    case .phone:
        return .phone
    case .tv:
        return .tv
    default:
        return nil

    }
 
  }
class FireBaseToken {
    static let shared = FireBaseToken()
    
    var token = ""
}
