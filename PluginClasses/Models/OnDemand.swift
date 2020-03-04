//
//  OnDemand.swift
//
//
//  Created by Miri on 06/02/2019.
//

import Foundation

class OnDemand: NSObject {
    
    var longTitle: String?
    var longDescription: String?
    var showName: String?
    var moreTitle: String?
    var publishDate: String?

    init(object: [String:Any]?) {
        
        guard let object = object else  {
            return
        }
        
        if let longTitle = object["title"] as? String {
            self.longTitle = longTitle
        }
        
        if let longDescription = object["description"] as? String {
            self.longDescription = longDescription
        }
        
        if let showName = object["show_name"] as? String {
            self.showName = showName
        }
    }
    
}
