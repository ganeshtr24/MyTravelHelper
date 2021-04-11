//
//  NetworkManager.swift
//  MyTravelHelper
//
//  Created by Ganesh TR on 10/04/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import Foundation
import XMLParsing

protocol NetworkManageable {
    func request<T: Codable>(url: String,
                            completion: @escaping (Result<T,Error>) -> Void)
}

enum NetworkError: Error {
    case parseError
}

class NetworkManger: NetworkManageable  {
    private let urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    func request<T:Codable>(url: String,
                            completion: @escaping (Result<T,Error>) -> Void) {
        urlSession.dataTask(with: URLRequest(url: URL(string: url)!)) { (data, response, error) in
            guard let data = data else {
                completion(.failure(NetworkError.parseError))
                return
            }
            do {
                let decodedData = try XMLDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(NetworkError.parseError))
                return
            }
        }.resume()
    }
}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession : URLSessionProtocol {
    
}

class XMLData {
    func loadDataFromFile(fileName: String) {
        var parser : XMLParser?
        if let path = Bundle.main.path(forResource: fileName, ofType: "xml") {
            parser = XMLParser(contentsOf: URL(fileURLWithPath: path))
            if parser?.parse() ?? false {
                
            }else {
                print("Unable to parse")
            }
        }else {
            print("File read error")
        }
    }
}
