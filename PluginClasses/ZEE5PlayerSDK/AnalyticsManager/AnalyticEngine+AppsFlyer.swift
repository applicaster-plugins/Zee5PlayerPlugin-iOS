//
//  AnalyticEngine+AppsFlyer.swift
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 15/04/20.
//

import Foundation

extension AnalyticEngine
{
    //MARK:- AppsFlyer And Qgraph Events
    
    @objc public func AddtoWatchlistAnlytics()
    {
        AllAnalyticsClass.shared.addtoWatchlistEvent()
    }
    
    @objc public func SubscribeCTAClicked()
    {
        AllAnalyticsClass.shared.subscribeBtnClicked()
    }

    @objc public func VideoWatch20Percent()
    {
        AllAnalyticsClass.shared.VideoWatch20()
    }
    
    @objc public func VideoWatch50Percent()
    {
         AllAnalyticsClass.shared.VideoWatch50()
    }
    
    @objc public func VideoWatch85Percent()
     {
          AllAnalyticsClass.shared.VideoWatch85()
     }

    
    
    
}
