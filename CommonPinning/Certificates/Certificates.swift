//
//  Certificates.swift
//  Created 3/22/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import Foundation

/// unused?
public enum CertificateType {
    case pokeApi
    case gitHub
    case wwwGitHub
}

public enum CertificateData {
    public static let pokeApi: Data = {
        return try! Data(resourceFromBundle: "sni-cloudflaressl-com", ofType: "cer")!
    }()
    public static let gitHub: Data = {
        return try! Data(resourceFromBundle: "github-com", ofType: "cer")!
    }()
    public static let wwwGitHub: Data = {
        return try! Data(resourceFromBundle: "www-github-com", ofType: "cer")!
    }()
}

public extension CertificateData {
    static let permitted: [Data] = {
        [CertificateData.pokeApi,
         CertificateData.gitHub,
         CertificateData.wwwGitHub]
    }()
}

public enum CertificateKeys {
    public static let permitted: [SecKey] = {
        [
            SecKey.publicKey(for: .pokeApi)!,
            SecKey.publicKey(for: .gitHub)!,
            SecKey.publicKey(for: .wwwGitHub)!
        ]
    }()
}

// for use to generate public keys
public extension SecCertificate {
    static let pokeApi: SecCertificate = {
        let data = CertificateData.pokeApi
        return SecCertificateCreateWithData(nil, data as CFData)!
    }()
    static let gitHub: SecCertificate = {
        let data = CertificateData.gitHub
        return SecCertificateCreateWithData(nil, data as CFData)!
    }()
    static let wwwGitHub: SecCertificate = {
        let data = CertificateData.wwwGitHub
        return SecCertificateCreateWithData(nil, data as CFData)!
    }()
}

// generates a public key, for public key pinning
public extension SecKey {
    static func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
}

