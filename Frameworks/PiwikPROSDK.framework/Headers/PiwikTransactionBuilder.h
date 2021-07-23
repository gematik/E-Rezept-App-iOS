//
//  PiwikTransactionBuilder.h
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PiwikTransaction;
@class PiwikTransactionItem;

/**
 A transaction builder for building Piwik ecommerce transactions.
 A transaction contains information about the transaction as will as the items included in the transaction.
 */
@interface PiwikTransactionBuilder : NSObject

/**
 A unique transaction identifier.
 */
@property (nullable, nonatomic, strong) NSString *identifier;

/**
 The grand total for the ecommerce order
 */
@property (nullable, nonatomic, strong) NSNumber *grandTotal;

/**
 The sub total of the transaction (excluding shipping cost).
 */
@property (nullable, nonatomic, strong) NSNumber *subTotal;

/**
 The total tax.
 */
@property (nullable, nonatomic, strong) NSNumber *tax;

/**
 The total shipping cost
 */
@property (nullable, nonatomic, strong) NSNumber *shippingCost;

/**
 The total offered discount.
 */
@property (nullable, nonatomic, strong) NSNumber *discount;

/**
 A list of items included in the transaction.
 @see PiwikTransactionItem
 */
@property (nullable, nonatomic, strong) NSMutableArray<PiwikTransactionItem *> *items;

/**
 Add a transaction item.

 @param sku The unique SKU of the item
 @param name The name of the item
 @param category The category of the added item
 @param price The price
 @param quantity The quantity of the product in the transaction
 */
- (void)addItemWithSku:(NSString *)sku name:(nullable NSString *)name category:(nullable NSString *)category price:(nullable NSNumber *)price quantity:(nullable NSNumber *)quantity NS_SWIFT_NAME(addItem(sku:name:category:price:quantity:));

/**
 Add a transaction item to the transaction.

 @param sku The unique SKU of the item
 @see addItemWithSku:name:category:price:quantity:
 */
- (void)addItemWithSku:(NSString *)sku NS_SWIFT_NAME(addItem(sku:));

/**
 Build a transaction from the builder.
 @return a new transaction
 */
- (nullable PiwikTransaction *)build;

@end

NS_ASSUME_NONNULL_END
