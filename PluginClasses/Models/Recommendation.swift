//
//  Recommendation.swift
//
//
//  Created by Miri on 06/02/2019.
//

import Foundation

class Recommendation: NSObject {
    
    var src: String?
    var title: String?
    var moreLink: String?
    var moreTitle: String?
    
    init(object: [String:Any]?) {
        
        guard let object = object else  {
            return
        }
        
        if let src = object["src"] as? String {
            self.src = src
        }
        
        if let title = object["title"] as? String {
            self.title = title
        }
        
        if let moreLink = object["more_link"] as? String {
            self.moreLink = moreLink
        }
        
        if let moreTitle = object["more_title"] as? String {
            self.moreTitle = moreTitle
        }
    }
    
}
