//
//  PiwikDispatcher.h
//  PiwikTracker
//
//  Created by Mattias Levin on 29/08/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 The dispatcher is responsible for performing the actual network request to the Piwik server.

 Developers can provide their own dispatchers by implementing this protocol. This may be necessary if the app a require specific security schema, authentication, http client frameworks or network and server configurations.
 */
@protocol PiwikDispatcher <NSObject>

/**
 Send a single tracking event to the Piwik server.

 The dispatcher must send a GET request to the Piwik server, appending the parameters as a URL encoded query string.

 @param parameters Event parameters. These parameters should be added to the path as a URL encoded query string
 @param successBlock Run the block if the dispatch to the Piwik server is successful.
 @param failureBlock Run this block if the dispatch to the Piwik server fails. Provide a YES to indicate if the SDK should attempt to send any pending event or NO if pending events should be saved until next dispatch. E.g. there is no use trying to send pending events if there is no network connection.
 */
- (void)sendSingleEventWithParameters:(NSDictionary *)parameters success:(void (^)(void))successBlock failure:(void (^)(BOOL shouldContinue))failureBlock;

/**
 Send a a bulk of tracking events to the Piwik server.

 The dispatcher must send a POST request to the Piwik server, adding the parameters as a JSON encoded body to the request.

 @param parameters Event parameters. These parameters should be JSON encoded and added to the request body.
 @param successBlock Run the block if the dispatch to the Piwik server is successful.
 @param failureBlock Run this block if the dispatch to the Piwik server fails. Provide a YES to indicate if the SDK should attempt to send any pending event or NO if pending events should be saved until next dispatch. E.g. there is no use trying to send pending events if there is no network connection.
 */
- (void)sendBulkEventWithParameters:(NSDictionary *)parameters success:(void (^)(void))successBlock failure:(void (^)(BOOL shouldContinue))failureBlock;

/**
 Send a a bulk of data manager events to the Piwik server.

 The dispatcher must send a POST request to the Piwik data manager endpoint, adding the events as a JSON encoded body to the request.

 @param events Data manager events. These parameters should be JSON encoded and added to the request body.
 @param successBlock Run the block if the dispatch to the Piwik server is successful.
 @param failureBlock Run this block if the dispatch to the Piwik server fails. Provide a YES to indicate if the SDK should attempt to send any pending event or NO if pending events should be saved until next dispatch. E.g. there is no use trying to send pending events if there is no network connection.
 */
- (void)sendAudienceManagerEvents:(NSArray *)events success:(void (^)(void))successBlock failure:(void (^)(BOOL shouldContinue))failureBlock;

/**
 Send a request to check audience membership to the Piwik server.

 @param visitorID Visitor ID.
 @param websiteID Website ID.
 @param audienceID Audience ID.
 @param successBlock Run the block if the request to the Piwik server is successful.
 @param failureBlock Run this block if the request to the Piwik server fails.
 */
- (void)checkAudienceMembershipWithVisitorID:(NSString *)visitorID websiteID:(NSString *)websiteID audienceID:(NSString *)audienceID success:(void (^)(BOOL isMember))successBlock failure:(void (^)(NSError *error))failureBlock;


/**
 Send a request to get user profile attributes from the Piwik server.
 
 @param visitorID Visitor ID.
 @param websiteID Website ID.
 @param successBlock Run the block if the request to the Piwik server is successful.
 @param failureBlock Run this block if the request to the Piwik server fails.
 */
- (void)audienceManagerGetUserProfileAttributes:(NSString *)visitorID websiteID:(NSString *)websiteID success:(void (^)(NSDictionary *profileAttributes))successBlock failure:(void (^)(NSError *error))failureBlock;


@optional

/**
 *  Set a custom user agent the dispatchers will use for requests.
 *
 *  @param userAgent The user agent string.
 */
- (void)setUserAgent:(NSString *)userAgent;

/**
 *  Set to use gzip compression.
 *
 *  @param useGzip YES if gzip should be used.
 */
- (void)setUseGzip:(BOOL)useGzip;

@end

NS_ASSUME_NONNULL_END
