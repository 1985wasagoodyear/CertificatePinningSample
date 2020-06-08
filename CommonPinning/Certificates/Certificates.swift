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

public enum CertificateData {
    private static func loadCert(name: String, type: String) -> Data {
        return try! Data(resourceFromBundle: name, ofType: type)!
    }
    public static let pokeApi: [Data] = {[
        loadCert(name: "sni-cloudflaressl-com", type: "cer"),
        loadCert(name: "sni-cloudflaressl-com", type: "pem"),
        loadCert(name: "sni-cloudflaressl-com2", type: "crt"), // this is used
    ]}()
    public static let gitHub: [Data] = {[
        loadCert(name: "github-com", type: "cer"),
        loadCert(name: "github-com", type: "pem"),
        loadCert(name: "www-github-com", type: "cer"),
        loadCert(name: "www-github-com", type: "crt") // this is used
    ]}()
}

public extension CertificateData {
    static let permitted: [Data] = {
        CertificateData.pokeApi + CertificateData.gitHub
    }()
}

public enum CertificateKeys {
    public static let permitted: [SecKey] = {
        (SecCertificate.pokeApi + SecCertificate.gitHub)
            .compactMap {
                SecKey.publicKey(for: $0)
            }
    }()
}

// for use to generate public keys
public extension SecCertificate {
    static let pokeApi: [SecCertificate] = {
        CertificateData
            .pokeApi
            .compactMap {
                SecCertificateCreateWithData(nil, $0 as CFData)
            }
    }()
    static let gitHub: [SecCertificate] = {
        CertificateData
            .gitHub
            .compactMap {
                SecCertificateCreateWithData(nil, $0 as CFData)
            }
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

