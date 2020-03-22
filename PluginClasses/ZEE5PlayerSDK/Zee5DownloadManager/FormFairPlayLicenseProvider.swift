//
//  FormFairPlayLicenseProvider.swift
//  Zee5DownloadManager
//
//  Created by User on 13/06/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import Foundation
import PlayKit

public class FormFairPlayLicenseProvider: NSObject, FairPlayLicenseProvider {
    
    public var customData: String?
    
    // For expiry date only
    var expiryTime = ""
    var elementName = ""
    var timeRemaining: TimeInterval = 0
    
    public func getLicense(spc: Data, assetId: String, requestParams: PKRequestParams, callback: @escaping (Data?, TimeInterval, Error?) -> Void) {
        var request = URLRequest(url: requestParams.url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
        request.httpBody = "assetid=\(assetId)&spc=\(spc.base64EncodedString(options: Data.Base64EncodingOptions.lineLength76Characters))".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        if let headers = requestParams.headers {
            for (header, value) in headers {
                request.setValue(value, forHTTPHeaderField: header)
            }
        }
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(self.customData, forHTTPHeaderField: "customData")

        // For getting an expiry time of content
        let offlineDuration = self.getOfflineDurationWith(data: self.customData)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Handle HTTP error
            if error != nil {
                callback(nil, 0, error)
                return
            }
            
            // ASSUMING the response data is base64-encoded CKC.
            guard let data = data, let ckc = Data(base64Encoded: data) else {
                ZeeUtility.utility.console("License Error: \(String(describing: error?.localizedDescription))")
                callback(nil, 0, NSError(domain: "FormFairPlayLicenseProvider", code: 1, userInfo: nil));
                return
            }
            callback(ckc, offlineDuration ?? 0, nil)
        }.resume()
    }
}

extension FormFairPlayLicenseProvider: XMLParserDelegate {

    // calculate expiry time
    func getOfflineDurationWith(data: String?) -> TimeInterval? {
        
        if let data = data {
            guard let decodedData = Data(base64Encoded: data) else {
                ZeeUtility.utility.console("cannot decode data")
                return nil
            }
            guard let str = String(data: decodedData, encoding: .utf8) else {
                ZeeUtility.utility.console("cannot get xml string")
                return nil
            }
            guard let xmlData = str.data(using: .utf8) else {
                ZeeUtility.utility.console("unable to get xml data")
                return nil
            }
            let parser = XMLParser(data: xmlData)
            parser.delegate = self
            parser.parse()
            
            return self.timeRemaining
        }
        return nil
    }
    
    // XML parser delegate
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "Data" {
            self.expiryTime = ""
        }
        self.elementName = elementName
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Data" {
            ZeeUtility.utility.console("expiryTime **** \(self.expiryTime)")
            let expiryDate = self.expiryTime.toDate() ?? Date()
            self.timeRemaining = Double(expiryDate.secondsSince1970 - Date().secondsSince1970)
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if data.isEmpty == false {
            if self.elementName == "ExpirationTime" {
                self.expiryTime += data
            }
        }
    }
}

extension Date {
    var secondsSince1970:Int {
        return Int(self.timeIntervalSince1970.rounded())
    }
}

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.S"
        return dateFormatter.date(from: self)
    }
}
