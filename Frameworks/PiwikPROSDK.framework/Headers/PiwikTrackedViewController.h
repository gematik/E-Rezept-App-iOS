//
//  PTViewController.h
//  PiwikTracker
//
//  Created by Mattias Levin on 8/12/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Controllers that inherit from this view controller with send a screen view event to Piwik each time the controller did show.

 The tracker will use the trackedViewName as the screen view name or if that is not set the title of the controller. If neither is set, no event will be send.

 */
@interface PiwikTrackedViewController : UIViewController

/**
 The screen view name that will be used in the event sent to Piwik.

 If not set the controllers title will be used.
 */
@property (nullable, nonatomic, strong) NSString *trackedViewName;

@end

NS_ASSUME_NONNULL_END
