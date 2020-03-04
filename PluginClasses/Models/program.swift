//
//  Program.swift
//
//
//  Created by Miri on 06/02/2019.
//

import Foundation

class Program: NSObject {
    
    var title: String?
    var subTitle: String?
    var startTime: Int?
    var endTime: Int?
    var imageSrc: String?

    init(object: [String:Any]?) {

        guard let object = object else  {
            return
        }
        
        if let title = object["title"] as? String {
            self.title = title
        }
        
        if let description = object["description"] as? String {
            self.subTitle = description
        }
        
        if let startTime = object["start_time"] as? Int {
            self.startTime = startTime
        }
        
        if let endTime = object["end_time"] as? Int {
            self.endTime = endTime
        }
        
        if let imageSrc = object["image"] as? String {
            self.imageSrc = imageSrc
        }
    }
}
