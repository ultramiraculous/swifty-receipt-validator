//
//  SubscriptionValidationRequest.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 19/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation

public struct SRVSubscriptionValidationRequest {
    let sharedSecret: String?
    let receiptDataSource: ReceiptDataSource
    let excludeOldTransactions: Bool
    let now: Date
    
    /// SRVSubscriptionValidationRequest
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    /// - parameter now: The current date.
    public init(sharedSecret: String?,
                refreshLocalReceiptIfNeeded: Bool,
                excludeOldTransactions: Bool,
                now: Date) {
        self.sharedSecret = sharedSecret
        self.receiptDataSource = ReceiptURLFetcher(refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,        appStoreReceiptURL: { Bundle.main.appStoreReceiptURL },
                                                   fileManager: FileManager.default)
        self.excludeOldTransactions = excludeOldTransactions
        self.now = now
    }

    /// SRVSubscriptionValidationRequest
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    /// - parameter now: The current date.
    public init(sharedSecret: String?,
                receiptData: Data,
                excludeOldTransactions: Bool,
                now: Date = Date()) {
        self.sharedSecret = sharedSecret
        self.receiptDataSource = LoadedDataSource(data: receiptData)
        self.excludeOldTransactions = excludeOldTransactions
        self.now = now
    }

    /// SRVSubscriptionValidationRequest
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    /// - parameter now: The current date.
    public init(sharedSecret: String?,
                receiptFile: URL,
                excludeOldTransactions: Bool,
                now: Date = Date()) {
        self.sharedSecret = sharedSecret
        self.receiptDataSource = LazyLoadingDataSource(url: receiptFile)
        self.excludeOldTransactions = excludeOldTransactions
        self.now = now
    }
}

struct LoadedDataSource: ReceiptDataSource {
    let data: Data

    func fetchReceiptData(onCompletion handler: @escaping ReceiptDataFetcherCompletion) {
        handler(.success(data))
    }
}

struct LazyLoadingDataSource: ReceiptDataSource {
    let url: URL

    func fetchReceiptData(onCompletion handler: @escaping ReceiptDataFetcherCompletion) {
        do {
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            handler(.success(data))
        } catch {
            handler(.failure(.other(error)))
        }
    }
}

