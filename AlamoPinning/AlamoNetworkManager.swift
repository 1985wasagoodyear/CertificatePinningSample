//
//  AlamoNetworkManager.swift
//  Created 3/23/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import Foundation
import Alamofire
import CommonPinning

// https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#session

public class AlamoNetworkManager {
    
    // MARK: - Properties
    
    let session: Session
    let manager: ServerTrustManager
    let decoder = JSONDecoder()
    
    // MARK: - Init
    
    public init() {
        // using default boolean values in implementation
        // (re-)written here for transparency
        let serverTrustPolicies: [String: ServerTrustEvaluating] = [
            // Certificate-based SSL Pinning
            "pokeapi.co":
                PinnedCertificatesTrustEvaluator(certificates: SecCertificate.pokeApi,
                                                 acceptSelfSignedCertificates: false,
                                                 performDefaultValidation: true,
                                                 validateHost: true),
            "github.com":
                PinnedCertificatesTrustEvaluator(certificates: SecCertificate.gitHub,
                                                 acceptSelfSignedCertificates: false,
                                                 performDefaultValidation: true,
                                                 validateHost: true),
            "www.github.com":
                PinnedCertificatesTrustEvaluator(certificates: SecCertificate.gitHub,
                                                 acceptSelfSignedCertificates: false,
                                                 performDefaultValidation: true,
                                                 validateHost: true),
            "sni.cloudflaressl.com":
                PinnedCertificatesTrustEvaluator(certificates: SecCertificate.pokeApi,
                                                 acceptSelfSignedCertificates: false,
                                                 performDefaultValidation: true,
                                                 validateHost: true),
            "raw.githubusercontent.com":
                PinnedCertificatesTrustEvaluator(certificates: SecCertificate.gitHub,
                                                 acceptSelfSignedCertificates: false,
                                                 performDefaultValidation: true,
                                                 validateHost: true),
            
            // Public Key-based SSL Pinning
            /*
            "pokeapi.co" : PublicKeysTrustEvaluator(keys: [SecKey.publicKey(for: SecCertificate.pokeApi)!],
                                                    performDefaultValidation: true,
                                                    validateHost: true)
             */
             
        ]
        manager = ServerTrustManager(evaluators: serverTrustPolicies)
        session = Session(serverTrustManager: manager)
    }
    
    // MARK: - Downloading
    
    public func download(_ monName: String,
                  _ completion: @escaping (MonResult) -> Void) {
        guard let url = APIs.with(mon: monName) else {
            completion(.failure(.badName)); return
        }
        session
            .request(url)
            .responseDecodable(of: Mon.self, queue: .global(), decoder: decoder)
            { (response) in
                if let error = response.error {
                    completion(.failure(.error(error))); return
                }
                if response.data == nil {
                    completion(.failure(.noData)); return
                }
                switch response.result {
                    case .success(let mon):
                        completion(.success(mon))
                    case .failure(let err):
                        completion(.failure(.badParsing(err)))
                }
            }
            .resume()
    }
    
    public func image(from url: URLConvertible,
                      _ completion: @escaping (Data?) -> Void) {
        session
            .request(url)
            .responseData
            { (response) in
                if let error = response.error {
                    print(error)
                    completion(nil); return
                }
                completion(response.data)
            }
            .resume()
    }
    
}
