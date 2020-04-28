//
//  LotameAnalytics.swift
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 05/02/20.
//

import Foundation
import LotameDMP
import CoreTelephony


extension AllAnalyticsClass{
    
    public func LotameAnalyticsData(with Duration:String ,Quartilevalue:String )
    {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let WeekDay = formatter.string(from: NSDate() as Date)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: NSDate() as Date)
        let componentsMonth = calendar.dateComponents([.month], from: NSDate() as Date)
        let componentsHour = calendar.dateComponents([.hour], from: NSDate() as Date)
        
        let dateOfMonth = String(components.day ?? 0)
        let monthOfYear = String(componentsMonth.month ?? 0)
        let hourOfDay = String(componentsHour.hour ?? 0)
        
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        let carrierName = carrier?.carrierName ?? ""
        
        print( "Carriar Name **** \(carrierName)")
        
    
        let LOTDuration = DictToString(with: "ContentDuration", value: Duration == "" ?notAppplicable:Duration)
        let LOTContentName = DictToString(with: "ContentName", value: contentName == "" ? notAppplicable:contentName)
        let LOTgenere = DictToString(with: "Genre", value: genereString  == "" ? notAppplicable : genereString)
        let LOTContentLanguage = DictToString(with: "ContentLanguage", value: audiolanguage.description == "" ? notAppplicable:audiolanguage.description)
        let LOTContentType = DictToString(with: "ContentType", value: assetSubtype == "" ? notAppplicable:assetSubtype)
        let LOTCast = DictToString(with: "Cast", value: notAppplicable)
        let LOTSubscriptiontype = DictToString(with: "SubscriptionType", value: ZEE5UserDefaults.getUserType())
        let LOTQuartileViews = DictToString(with: "QuartileViews", value: Quartilevalue == "" ? notAppplicable:Quartilevalue)
        let LOTCountry = DictToString(with: "Country", value: ZEE5UserDefaults.getCountry())
        let LOTState = DictToString(with: "State", value: ZEE5UserDefaults.getState())
      
        let LOTDisplayLanguage = DictToString(with: "DisplayLanguage", value: displaylanguage == "" ? notAppplicable:displaylanguage)
        
        let LOTOperator = DictToString(with: "Operator", value:carrierName == "" ? notAppplicable:carrierName)
        
        let LOTDay = DictToString(with: "Day", value: WeekDay == "" ? notAppplicable:WeekDay)
        let LOTHour = DictToString(with: "Hour", value: hourOfDay == "" ? notAppplicable:hourOfDay)
        let LOTDate = DictToString(with: "Date", value: dateOfMonth == "" ? notAppplicable:dateOfMonth)
        
        let LOTMonth = DictToString(with: "Month", value: monthOfYear == "" ? notAppplicable:monthOfYear)
        
        let LOTAge = DictToString(with: "Age", value: Age == "" ? notAppplicable:Age)
        let LOTGender = DictToString(with: "Gender", value: Gender == "" ? notAppplicable:Gender)
        
        
        DMP.initialize(LotameClientid)
        DMP.addBehaviorData(LOTDuration, forType: "genp")
        DMP.addBehaviorData(LOTContentName, forType: "genp")
        DMP.addBehaviorData(LOTgenere, forType: "genp")
        DMP.addBehaviorData(LOTContentLanguage, forType: "genp")
        DMP.addBehaviorData(LOTContentType, forType: "genp")
        DMP.addBehaviorData(LOTCast, forType: "genp")
        DMP.addBehaviorData(LOTSubscriptiontype, forType: "genp")
        DMP.addBehaviorData(LOTQuartileViews, forType: "genp")
        DMP.addBehaviorData(LOTCountry, forType: "genp")
        DMP.addBehaviorData(LOTState, forType: "genp")
        DMP.addBehaviorData(LOTDisplayLanguage, forType: "genp")
        DMP.addBehaviorData(LOTOperator, forType: "genp")
        DMP.addBehaviorData(LOTDay, forType: "genp")
        DMP.addBehaviorData(LOTHour, forType: "genp")
        DMP.addBehaviorData(LOTDate, forType: "genp")
        DMP.addBehaviorData(LOTMonth, forType: "genp")
        DMP.addBehaviorData(LOTAge, forType: "genp")
        DMP.addBehaviorData(LOTGender, forType: "genp")
        DMP.addBehaviorData("test_i_applicaster", forType: "genp")
        
        
        DMP.sendBehaviorData(){
            result in
            if result.isSuccess{
                print("Lotame Success \(String(describing: result))")
            } else{
                print("Lotame failure\(String(describing: result))")
            }
        }
    }
    
    func DictToString(with Keys:String, value:String) -> String
    {
        let value = [Keys:[value]]

        let cookieHeader = (value.compactMap({ (key, value) -> String in
            return "\(key):\(value)"
        }) as Array).joined(separator: ";")

        print(cookieHeader)
        return cookieHeader
    
    }

}
