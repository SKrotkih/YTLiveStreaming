//
//  HttpBodyEncoding.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 16.03.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//

import Foundation
import Alamofire

struct JSONBodyStringEncoding: ParameterEncoding {
    private let jsonBody: String

    init(jsonBody: String) {
        self.jsonBody = jsonBody
    }

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = urlRequest.urlRequest
        let dataBody = (jsonBody as NSString).data(using: String.Encoding.utf8.rawValue)
        if urlRequest?.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        urlRequest?.httpBody = dataBody
        return urlRequest!
    }
}
