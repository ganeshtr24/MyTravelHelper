//
//  URLSessionMock.swift
//  MyTravelHelper
//
//  Created by Ganesh TR on 11/04/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import Foundation

enum TestCaseScenario {
    case fetchAllStations
    
    func response(_ url: URL) -> SessionResponse {
        switch self {
        case .fetchAllStations:
            return URLSessionMockResponse.fetchAllStations(url: url)
        }
    }
}

class URLSessionMock: URLSessionProtocol {
    var scenario: TestCaseScenario
    init(scenario: TestCaseScenario) {
        self.scenario = scenario
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSessionMockDataTask {
            let mockResponse = self.scenario.response(request.url!)
            completionHandler(mockResponse.0, mockResponse.1, mockResponse.2)
        }
    }
}

class URLSessionMockDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping ()->Void) {
        self.closure = closure
    }
    
    override func resume() {
        self.closure()
    }
}

typealias SessionResponse = (Data?, URLResponse?, Error?)

struct URLSessionMockResponse {
    static func fetchAllStations(url:URL) -> SessionResponse {
        let data = MXMLData().getDataFromBundleFor(file:"All_Stations_Success_Response")
        let httpsResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        return (data,httpsResponse,nil)
    }
}

class MXMLData {
    func getDataFromBundleFor(file: String) -> Data? {
        guard let path =
                Bundle(for: type(of: self))
                .path(forResource: file, ofType: "xml"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options:.mappedIfSafe)else {
            return nil
        }
        return data
    }
}
