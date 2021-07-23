//
//  PiwikTransaction.h
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PiwikTransactionBuilder;

typedef void (^TransactionBuilderBlock)(PiwikTransactionBuilder *builder);

/**
 A transaction is a composite object containing transaction information as well as an optional list of items included in the transaction.
 */
@interface PiwikTransaction : NSObject

/**
 A unique transaction identifier. Mandatory.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 The grand total for the ecommerce order. Mandatory.
 */
@property (nonatomic, readonly) NSNumber *grandTotal;

/**
 The sub total of the transaction (excluding shipping cost). Optional.
 */
@property (nullable, nonatomic, readonly) NSNumber *subTotal;

/**
 The total tax. Optional.
 */
@property (nullable, nonatomic, readonly) NSNumber *tax;

/**
 The total shipping cost. Optional.
 */
@property (nullable, nonatomic, readonly) NSNumber *shippingCost;

/**
 The total offered discount. Optional.
 */
@property (nullable, nonatomic, readonly) NSNumber *discount;

/**
 A list of items included in the transaction. Optional.
 @see PiwikTransactionItem
 */
@property (nullable, nonatomic, readonly) NSArray *items;

/**
 Create a transaction using a transaction builder.
 @param block a transaction builder block
 @return a new transaction
 @see PiwikTransactionBuilder
 */
+ (nullable instancetype)transactionWithBlock:(void (^)(PiwikTransactionBuilder *builder))block;

/**
 Create a transaction from the builder.
 Use the builder method to create a new instance.
 @param builder the transaction will be created from this builder
 @return a new transaction
 @see transactionWithBuilder:
 */
- (nullable id)initWithBuilder:(PiwikTransactionBuilder *)builder;

@end

NS_ASSUME_NONNULL_END
