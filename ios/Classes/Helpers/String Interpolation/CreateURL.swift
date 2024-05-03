//
//  CreateURL.swift
//  rppg_common
//
//  Created by Wegile on 21/01/24.
//

import Foundation

struct CreateURL {
    var webSocketUrl: String?
    
    mutating func createWebSocketURL(baseUrl: String, authToken: String, fps: String?, age: String?, sex: String?, height: String?, weight: String?) {
        var components = URLComponents(string: baseUrl)
        
        // Add query parameters
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "authToken", value: authToken))
        
        if let fps = fps {
            queryItems.append(URLQueryItem(name: "fps", value: fps))
        }
        
        if let age = age {
            queryItems.append(URLQueryItem(name: "age", value: age))
        }
        
        if let sex = sex {
            queryItems.append(URLQueryItem(name: "sex", value: sex))
        }
        
        if let height = height {
            queryItems.append(URLQueryItem(name: "height", value: height))
        }
        
        if let weight = weight {
            queryItems.append(URLQueryItem(name: "weight", value: weight))
        }
        
        components?.queryItems = queryItems
        
        /// Create and return the final URL
        webSocketUrl = components?.url?.absoluteString
    }
    
    
}
