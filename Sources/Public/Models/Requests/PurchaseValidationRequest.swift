//
//  PurchaseValidationRequest.swift
//  SwiftyReceiptValidator
//
//  Created by Dominik Ringler on 19/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation

public struct SRVPurchaseValidationRequest {
    let productId: String
    let receiptDataSource: ReceiptDataSource
    let sharedSecret: String?

    
    /// SRVPurchaseValidationRequest
    ///
    /// - parameter productId: The product id of the purchase to validate.
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    public init(productId: String,
                sharedSecret: String?,
                refreshLocalReceiptIfNeeded: Bool,
                excludeOldTransactions: Bool,
                now: Date) {
        self.productId = productId
        self.receiptDataSource = ReceiptURLFetcher(refreshLocalReceiptIfNeeded: refreshLocalReceiptIfNeeded,        appStoreReceiptURL: { Bundle.main.appStoreReceiptURL },
                                                   fileManager: FileManager.default)
        self.sharedSecret = sharedSecret
    }

    /// SRVSubscriptionValidationRequest
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    /// - parameter now: The current date.
    public init(productId: String,
                sharedSecret: String?,
                receiptData: Data) {
        self.productId = productId
        self.sharedSecret = sharedSecret
        self.receiptDataSource = LoadedDataSource(data: receiptData)
    }

    /// SRVSubscriptionValidationRequest
    ///
    /// - parameter sharedSecret: The shared secret setup in iTunes.
    /// - parameter refreshReceiptIfNoneFound: If true, make SKReceiptRefreshRequest if no receipt on device. This will show a login alert.
    /// - parameter excludeOldTransactions: If value is true, response includes only the latest renewal transaction for any subscriptions.
    /// - parameter now: The current date.
    public init(productId: String,
                sharedSecret: String?,
                receiptFile: URL) {
        self.productId = productId
        self.sharedSecret = sharedSecret
        self.receiptDataSource = LazyLoadingDataSource(url: receiptFile)
    }
}
