//
//  ReceiptURLFetcher.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 14/04/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import StoreKit

typealias ReceiptDataFetcherCompletion = (Result<Data, SRVError>) -> Void
typealias ReceiptURLFetcherRefreshRequest = SKReceiptRefreshRequest

typealias ReceiptURLFetcherCompletion = (Result<URL, SRVError>) -> Void


protocol ReceiptDataSource {
    func fetchReceiptData(onCompletion handler: @escaping ReceiptDataFetcherCompletion)
}

final class ReceiptURLFetcher: NSObject {
    
    // MARK: - Properties

    private let refreshRequest: SKReceiptRefreshRequest?
    private let appStoreReceiptURL: () -> URL?
    private let fileManager: FileManager
    private var completionHandler: ReceiptURLFetcherCompletion?
    private var receiptRefreshRequest: ReceiptURLFetcherRefreshRequest?
    
    // MARK: - Computed Properties
    
    private var hasReceipt: Bool {
        guard let path = appStoreReceiptURL()?.path else { return false }
        return fileManager.fileExists(atPath: path)
    }
    
    // MARK: - Initialization
    
    init(refreshLocalReceiptIfNeeded: Bool, appStoreReceiptURL: @escaping () -> URL?, fileManager: FileManager) {
        self.refreshRequest = refreshLocalReceiptIfNeeded ? SKReceiptRefreshRequest(receiptProperties: nil) : nil
        self.appStoreReceiptURL = appStoreReceiptURL
        self.fileManager = fileManager
    }
}

// MARK: - ReceiptURLFetcherType

extension ReceiptURLFetcher: ReceiptDataSource {
    
    func fetch(refreshRequest: ReceiptURLFetcherRefreshRequest?, handler: @escaping ReceiptDataFetcherCompletion) {
        completionHandler = { [weak self] (result) in
            let newResult = result.flatMap { url -> Result<Data, SRVError> in
                do {
                    let receiptData = try Data(contentsOf: url, options: .alwaysMapped)
                    return .success(receiptData)
                } catch {
                    return .failure(.other(error))
                }
            }

            handler(newResult)
            self?.clean()
        }

        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            if let refreshRequest = refreshRequest {
                receiptRefreshRequest = refreshRequest
                receiptRefreshRequest?.delegate = self
                receiptRefreshRequest?.start()
            } else {
                handler(.failure(.noReceiptFoundInBundle))
            }
            return
        }

        completionHandler?(.success(appStoreReceiptURL))
    }

    func fetchReceiptData(onCompletion handler: @escaping (Result<Data, SRVError>) -> Void) {
        fetch(refreshRequest: nil, handler: handler)
    }
}

// MARK: - SKRequestDelegate

extension ReceiptURLFetcher: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        defer {
            clean()
        }
        
        guard hasReceipt, let appStoreReceiptURL = appStoreReceiptURL() else {
            completionHandler?(.failure(.noReceiptFoundInBundle))
            return
        }
        
        completionHandler?(.success(appStoreReceiptURL))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        completionHandler?(.failure(.other(error)))
        clean()
    }
}

// MARK: - Private Methods

private extension ReceiptURLFetcher {
    
    func clean() {
        completionHandler = nil
        receiptRefreshRequest = nil
    }
}
