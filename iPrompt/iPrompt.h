//
//  iPrompt.h
//
//  Version 1.0
//
//  Created by Nick Lockwood on 06/12/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/iPrompt
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif


@interface iPrompt: NSObject

//prompt management
+ (NSDictionary *)allPrompts;
+ (void)addPrompt:(iPrompt *)prompt;

//create prompt
- (id)initWithName:(NSString *)name;
- (id)initWithDictionary:(NSDictionary *)dict;

//unique prompt name
@property (nonatomic, copy, readonly) NSString *name;

//message and button text
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *actionButtonLabel;
@property (nonatomic, copy) NSString *remindButtonLabel;
@property (nonatomic, strong) NSURL *actionURL;

//usage settings - these have sensible defaults
@property (nonatomic, assign) NSUInteger usesUntilPrompt;
@property (nonatomic, assign) float daysUntilPrompt;
@property (nonatomic, assign) float remindPeriod;

//debugging and notification overrides
@property (nonatomic, assign, getter = isRecurring) BOOL recurring;
@property (nonatomic, assign) BOOL disableAlertViewResizing;
@property (nonatomic, assign) BOOL verboseLogging;
@property (nonatomic, assign) BOOL previewMode;

@end