//
//  NetworkManager.swift
//  Created 3/22/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import Foundation
import CommonPinning

public enum PinningOption: Int {
    case certificate = 0
    case publicKey
}

public class NetworkManager: NSObject {
    
    // MARK: - Properties
    
    lazy var session: URLSession = {
        URLSession(configuration: .default,
                   delegate: self,
                   delegateQueue: nil)
    }()
    
    let decoder = JSONDecoder()
    
    public var pinningOption: PinningOption = .certificate {
        didSet {
            switch pinningOption {
                case .certificate:
                    print("Pinning Option changed: now using Certificate-pinning")
                case .publicKey:
                    print("Pinning Option changed: now using Public Key-pinning")
            }
        }
    }
}

extension NetworkManager {
    
    // MARK: - Downloading
    
    public func download(_ monName: String,
                  _ completion: @escaping (MonResult) -> Void) {
        guard let url = APIs.with(mon: monName) else {
            completion(.failure(.badName)); return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.error(error))); return
            }
            guard let data = data else {
                completion(.failure(.noData)); return
            }
            do {
                let mon = try self.decoder.decode(Mon.self, from: data)
                completion(.success(mon))
            } catch {
                completion(.failure(.badParsing(error)))
            }
        }
        
        task.resume()
    }
    
    public func image(from urlString: String,
                      _ completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil); return
        }
        image(from: url, completion)
    }
    
    public func image(from url: URL,
                      _ completion: @escaping (Data?) -> Void) {
        session.dataTask(with: url) { data, _, _ in
            completion(data)
        }.resume()
    }
}

extension NetworkManager: URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // declare response and credentials
        var disposition: URLSession.AuthChallengeDisposition = .cancelAuthenticationChallenge
        var credential: URLCredential? = nil
        
        // will always be giving some completion
        defer { completionHandler(disposition, credential) }
        
        // ensure there is a certificate provided from the server
        guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
            return
        }
        
        switch pinningOption {
            case .certificate:
                // Compare the server certificate with our own stored
                if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) {
                    let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
                    if CertificateData.permitted.contains(serverCertificateData) {
                        // if certificate-pinning succeeds, approve usage
                        disposition = .useCredential
                        credential = URLCredential(trust: trust)
                    }
            }
            case .publicKey:
                // Or, compare the public keys
                if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0),
                    let serverCertificateKey = SecKey.publicKey(for: serverCertificate) {
                    if CertificateKeys.permitted.contains(serverCertificateKey) {
                        // if public key-pinning succeeds, approve usage
                        disposition = .useCredential
                        credential = URLCredential(trust: trust)
                    }
            }
        }
    }
}
