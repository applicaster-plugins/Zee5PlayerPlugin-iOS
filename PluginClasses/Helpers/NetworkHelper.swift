//
//  NetworkHelper.swift
//  Alamofire
//
//  Created by Evgenii Kievsky on 13.07.2020.
//

import Alamofire

class NetworkHelper {
    
    typealias RequestJsonObjectCompletion = ((Any?, Error?, ZEE5SdkError?, Int) -> Void)
    
    @discardableResult
    static func requestJsonObject(forUrlString urlString:String,
                                  method: Alamofire.HTTPMethod,
                                  parameters:[String: Any]?,
                                  headers: [String: String]?,
                                  completion: RequestJsonObjectCompletion?) -> URLSessionTask? {
        let request = Alamofire.SessionManager.default.request(urlString,
                                                               method: method,
                                                               parameters: parameters,
                                                               encoding: URLEncoding.default,
                                                               headers: headers)
        .validate()
        .responseJSON(completionHandler: { response in
            let statusCode = response.response?.statusCode ?? -1
            switch response.result {
            case .success:
                completion?(response.value, nil, nil, statusCode)
            case .failure(let error):
                let zee5Error = parseError(data: response.data, errorCode: statusCode)
                completion?(nil, error, zee5Error, statusCode)
            }
        })
        return request.task
    }
    
    private static func parseError(data: Data?, errorCode: Int) -> ZEE5SdkError? {
        guard
            let data = data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return nil }
        if json.keys.contains("message") {
            let zee5Code = json["code"] as? Int ?? -1
            let message = json["message"] as? String ?? ""
            return ZEE5SdkError.initWithErrorCode(errorCode,
                                                  andZee5Code: zee5Code,
                                                  andMessage: message)
        }
        else if json.keys.contains("error_msg") {
            let zee5Code = json["error_code"] as? Int ?? -1
            let message = json["error_msg"] as? String ?? ""
            return ZEE5SdkError.initWithErrorCode(errorCode,
                                                  andZee5Code: zee5Code,
                                                  andMessage: message)
        }
        return nil
    }
}
