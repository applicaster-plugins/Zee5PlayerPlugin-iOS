//
//  DownloadRootController.swift
//  DemoProject
//
//  Created by Abbas's Mac Mini on 13/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit
import CarbonKit
import Zee5CoreSDK
import ZappPlugins

public class DownloadRootController: UIViewController {

    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var topview: UIView!
    private var selectedTabIndex: UInt = 0
    private var carbonNav: CarbonTabSwipeNavigation!
    
    private let bundle = Bundle(for: DownloadRootController.self)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupTopSgment()
         
        var nav = self.navigationController?.navigationBar
        
        nav?.barStyle = .black
        nav?.backgroundColor = UIColor.clear
        self.navigationItem.title =  PlayerConstants.localizedKeys.Downloads_Header_Downloads_Text.rawValue.localized()
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationItem.rightBarButtonItem?.title =
            PlayerConstants.localizedKeys.Downloads_SubHeader_Edit_Link.rawValue.localized()
    
    }
    
    @IBAction func actionBack(_ sender: Any) {
       ZAAppConnector.sharedInstance().navigationDelegate.navigateToHomeScreen()
    }
    
    func setupTopSgment() {
        let items = [PlayerConstants.localizedKeys.Downloads_SubHeader_Shows_Tab.rawValue.localized(),
        PlayerConstants.localizedKeys.Downloads_SubHeader_Movies_Tab.rawValue.localized(),
        PlayerConstants.localizedKeys.Downloads_SubHeader_Videos_Tab.rawValue.localized()]
        carbonNav = CarbonTabSwipeNavigation(items: items, delegate: self)
        carbonNav.insert(intoRootViewController: self)
        
        carbonNav.toolbar.isTranslucent = false
        carbonNav.toolbar.barTintColor = AppColor.gray
        carbonNav.carbonTabSwipeScrollView.isScrollEnabled = false
        
        carbonNav.setNormalColor(AppColor.white, font: AppFont.medium(size: 12))
        carbonNav.setSelectedColor(AppColor.pink, font: AppFont.semibold(size: 12))
        carbonNav.setTabExtraWidth(0)
        carbonNav.setTabBarHeight(50)
        carbonNav.setIndicatorHeight(0)
        
        let wth = UIScreen.main.bounds.size.width / 3
        carbonNav.carbonSegmentedControl?.setWidth(wth, forSegmentAt: 0)
        carbonNav.carbonSegmentedControl?.setWidth(wth, forSegmentAt: 1)
        carbonNav.carbonSegmentedControl?.setWidth(wth, forSegmentAt: 2)
    }
    
    @IBAction func actionEdit(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Download", bundle: bundle)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: EditDownloadController.identifier) as? EditDownloadController else { return }
        editVC.selectedIndex = Int(selectedTabIndex)
        self.navigationController?.pushViewController(editVC, animated: false)
    }
}

extension DownloadRootController: CarbonTabSwipeNavigationDelegate, ChangeDownloadTabDelegate {
    
    public func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Download", bundle: bundle)
        switch index {
        case 0:
            guard let showVC = storyboard.instantiateViewController(withIdentifier: ShowsDownloadController.identifier) as? ShowsDownloadController else { return UIViewController() }
            showVC.delegate = self
            return showVC
        case 1:
            guard let movieVC = storyboard.instantiateViewController(withIdentifier: MovieDownloadController.identifier) as? MovieDownloadController else { return UIViewController() }
            movieVC.delegate = self
            return movieVC
        case 2:
            guard let videoVC = storyboard.instantiateViewController(withIdentifier: VideoDownloadController.identifier) as? VideoDownloadController else { return UIViewController() }
            videoVC.delegate = self
            return videoVC
        default:
            return UIViewController()
        }
    }
    
    public func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAt index: UInt) {
        self.selectedTabIndex = index
    }
    
    func changeCurrentTab() {
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
////            self.selectedTabIndex += 1
////            self.selectedTabIndex = self.selectedTabIndex >= 3 ? 0 : self.selectedTabIndex
////            self.carbonNav.setCurrentTabIndex(self.selectedTabIndex, withAnimation: true)
//        }
    }
}
