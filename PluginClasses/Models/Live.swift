//
//  Live.swift
//
//
//  Created by Miri on 06/02/2019.
//

import Foundation

class Live: NSObject {
    
    var brandColor: String?
    var name: String?
    var src: String?
    var type: String?
    var programs: [Program]? = []
    var currentProgram: Program?
    var nextProgram: Program?
    var nextProgramTitle: String?
    var isDigitalRadio: Bool?
    var entryTitle: String?

    init(object:[String:Any]?) {
        
        guard let object = object else  {
            return
        }
        
        if let brandColor = object["channel_brand_color"] as? String {
            self.brandColor = brandColor
        }
        
        if let name = object["channel_name"] as? String {
            self.name = name
        }
        
        if let src = object["channel_src"] as? String {
            self.src = src
        }
        
        if let type = object["type"] as? String {
            self.type = type
        }
        
        if let programs = object["programs"] as? [[String:Any]?] {
            for programDict in programs {
                let program = Program.init(object: programDict)
                print("program \(program)")
                self.programs?.append(program)
                print("programs \(String(describing: self.programs))")
            }
            
        }
        
//        if let isDigitalRadio = object["is_digital_radio"] as? Bool {
//            self.isDigitalRadio = isDigitalRadio
//        }
        
//
//        let currentProgram: [String:Any]? = object["current_program"] as? [String:Any]
//        if currentProgram != nil {
//            self.currentProgram = Program.init(object: currentProgram)
//        }
//
//        let nextProgram: [String:Any]? = object["next_program"] as? [String:Any]
//        if nextProgram != nil {
//            self.currentProgram = Program.init(object: nextProgram)
//        }
    }
    
}
