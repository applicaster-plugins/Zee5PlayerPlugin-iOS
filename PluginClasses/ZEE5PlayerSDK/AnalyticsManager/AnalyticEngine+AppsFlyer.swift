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
    
    @objc public func ConsumptionAnalyticEvents(){
        if ZEE5PlayerSDK.getConsumpruionType() == Live {
            
            AllAnalyticsClass.shared.livePlayed()
            
        }else if ZEE5PlayerSDK.getConsumpruionType() == Music{
            
             AllAnalyticsClass.shared.Musicplayed()
            
        }else if ZEE5PlayerSDK.getConsumpruionType() == Movie{
            
            AllAnalyticsClass.shared.MoviesPlayed()
            
        }else if ZEE5PlayerSDK.getConsumpruionType() == Episode{
            
             AllAnalyticsClass.shared.TvShowplayed()
            
        }else if ZEE5PlayerSDK.getConsumpruionType() == Trailer{
            
        }
        
        
    }
    
    
    // MARK:Calculate Percent Duration
    
    @objc public func VideoWatchPercentCalc(){
        
        let totalDuration = ZEE5PlayerManager .sharedInstance().getTotalDuration()
        let  currentDuration = ZEE5PlayerManager.sharedInstance().getCurrentDuration()
       
        let Percentage = (currentDuration * 100 / totalDuration).rounded(.toNearestOrAwayFromZero)
        
 
        if (20...49).contains(Percentage) && VideWatchInt != 20  {
            VideoWatch20Percent()
            VideWatchInt = 20
            
        }else if (50...84).contains(Percentage) && VideWatchInt != 50  {
            VideoWatch50Percent()
            VideWatchInt = 50
           
        }else if Percentage >= 85.0 &&  VideWatchInt != 85  {
            VideoWatch85Percent()
            VideWatchInt = 85
        }else{}
    }

    
    
    
}
