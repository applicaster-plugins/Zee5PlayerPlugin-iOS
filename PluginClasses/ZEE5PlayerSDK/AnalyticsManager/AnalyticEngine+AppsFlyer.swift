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
        
        if ZEE5PlayerSDK.getConsumpruionType() == Movie{
            AllAnalyticsClass.shared.MovieAddToWatch()
        }else if ZEE5PlayerSDK.getConsumpruionType() == Episode{
               AllAnalyticsClass.shared.TVShowAddToWatch()
        }else if ZEE5PlayerSDK.getConsumpruionType() == Original{
            AllAnalyticsClass.shared.originalAddToWatch()
        }else if ZEE5PlayerSDK.getConsumpruionType() == Video{
             AllAnalyticsClass.shared.VideoAddToWatch()
        }else if ZEE5PlayerSDK.getConsumpruionType() == Trailer{
            
        }else if ZEE5PlayerSDK.getConsumpruionType() == Music{
            
        }
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
    @objc public func VideoClick1Event()
    {
        AllAnalyticsClass.shared.VideoClicked1()
    }
    @objc public func VideoClick3Event()
    {
        AllAnalyticsClass.shared.VideoClicked3()
    }
    @objc public func VideoClick5Event()
    {
        AllAnalyticsClass.shared.VideoClicked5()
    }
    @objc public func VideoClick7Event()
    {
        AllAnalyticsClass.shared.VideoClicked7()
    }
    @objc public func VideoClick10Event()
    {
        AllAnalyticsClass.shared.VideoClicked10()
    }
    @objc public func VideoClick15Event()
    {
      AllAnalyticsClass.shared.VideoClicked15()
    }
    @objc public func VideoClick20Event()
    {
      AllAnalyticsClass.shared.VideoClicked20()
    }
    
    @objc public func ConsumptionAnalyticEvents(){
        
        if ZEE5PlayerSDK.getConsumpruionType() == Live {
            AllAnalyticsClass.shared.livePlayed()
        }
        else if ZEE5PlayerSDK.getConsumpruionType() == Music{
             AllAnalyticsClass.shared.Musicplayed()
        }else if ZEE5PlayerSDK.getConsumpruionType() == Movie{
            AllAnalyticsClass.shared.MoviesPlayed()
             AllAnalyticsClass.shared.MovieSectionplayed()
        }else if ZEE5PlayerSDK.getConsumpruionType() == Episode{
             AllAnalyticsClass.shared.TvShowplayed()
            AllAnalyticsClass.shared.TvShowSectionplayed()
        }else if ZEE5PlayerSDK.getConsumpruionType() == Original{
            AllAnalyticsClass.shared.OriginalSectionplayed()
        }else if ZEE5PlayerSDK.getConsumpruionType() == Video{
            AllAnalyticsClass.shared.videoContentSectionplayed()
            AllAnalyticsClass.shared.videoContentplayed()
        }else if ZEE5PlayerSDK.getConsumpruionType() == Trailer{
            
        }
        
        
    }
    
    
    // MARK:Calculate Percent Duration
    
    @objc public func VideoWatchPercentCalc(with Direction:String){
        
        let totalDuration = ZEE5PlayerManager .sharedInstance().getTotalDuration()
        let  currentDuration = ZEE5PlayerManager.sharedInstance().getCurrentDuration()
       
        let Percentage = (currentDuration * 100 / totalDuration).rounded(.toNearestOrAwayFromZero)
        
 
        if (20...49).contains(Percentage) && VideWatchInt != 20 && Direction == "Forward" && VideWatchInt != 50 && VideWatchInt != 85  {
            VideoWatch20Percent()
            VideWatchInt = 20
            
        }else if (50...84).contains(Percentage) && VideWatchInt != 50 && Direction == "Forward" && VideWatchInt != 85 {
            VideoWatch50Percent()
            VideWatchInt = 50
           
        }else if Percentage >= 85.0 &&  VideWatchInt != 85 && Direction == "Forward"  {
            VideoWatch85Percent()
            VideWatchInt = 85
        }else{}
    }

    
    
    
}
