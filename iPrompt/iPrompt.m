//
//  iPrompt.m
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

#import "iPrompt.h"


#define SECONDS_IN_A_DAY 86400.0


@interface iPrompt() <UIAlertViewDelegate>

@property (nonatomic, strong) id visibleAlert;
@property (nonatomic, assign) int previousOrientation;

@end


@implementation iPrompt

+ (void)load
{
    [self performSelectorOnMainThread:@selector(allPrompts) withObject:nil waitUntilDone:NO];
}

+ (NSDictionary *)allPrompts
{
    static NSMutableDictionary *allPrompts = nil;
    if (allPrompts == nil)
    {
        allPrompts = [NSMutableDictionary dictionary];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"iPrompt" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        for (NSString *name in dict)
        {
            NSMutableDictionary *promptDict = [dict[name] mutableCopy];
            promptDict[@"name"] = name;
            iPrompt *prompt = [[iPrompt alloc] initWithDictionary:promptDict];
            [self performSelectorOnMainThread:@selector(addPrompt:) withObject:prompt waitUntilDone:NO];
        }
    }
    return allPrompts;
}

+ (void)addPrompt:(iPrompt *)prompt
{
    ((NSMutableDictionary *)[self allPrompts])[prompt.name] = prompt;
    
    //register for application event
    if (&UIApplicationWillEnterForegroundNotification)
    {
        [[NSNotificationCenter defaultCenter] addObserver:prompt
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    //register for otientation event
    prompt.previousOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [[NSNotificationCenter defaultCenter] addObserver:prompt
                                             selector:@selector(willRotate)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    //application launched
    [prompt performSelectorOnMainThread:@selector(applicationLaunched) withObject:nil waitUntilDone:NO];
}

- (id)initWithName:(NSString *)name
{
    if ((self = [super init]))
    {
        _name = [name copy];
        _actionButtonLabel = @"OK";
        _remindButtonLabel = @"Remind Me Later";
        _usesUntilPrompt = 10;
        _daysUntilPrompt = 10.0f;
        _remindPeriod = 1.0f;
        _recurring = NO;
        
#ifdef DEBUG
        
        //enable verbose logging in debug mode
        self.verboseLogging = YES;
        
#endif

    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if ((self = [self initWithName:dict[@"name"]]))
    {
        self.title = dict[@"title"];
        self.message = dict[@"message"];
        self.actionButtonLabel = dict[@"actionButton"] ?: self.actionButtonLabel;
        self.remindButtonLabel = dict[@"remindButton"] ?: self.remindButtonLabel;
        self.actionURL = [NSURL URLWithString:dict[@"actionURL"]];
        self.usesUntilPrompt = [dict[@"usesUntilPrompt"] ?: @(self.usesUntilPrompt) integerValue];
        self.daysUntilPrompt = [dict[@"daysUntilPrompt"] ?: @(self.daysUntilPrompt) floatValue];
        self.remindPeriod = [dict[@"remindPeriod"] ?: @(self.remindPeriod) floatValue];
        self.recurring = [dict[@"recurring"] boolValue];
    }
    return self;
}

- (void)resizeAlertView:(UIAlertView *)alertView
{
    if (!self.disableAlertViewResizing)
    {
        NSInteger imageCount = 0;
        CGFloat offset = 0.0f;
        CGFloat messageOffset = 0.0f;
        for (UIView *view in alertView.subviews)
        {
            CGRect frame = view.frame;
            if ([view isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)view;
                if ([label.text isEqualToString:alertView.title])
                {
                    [label sizeToFit];
                    offset = label.frame.size.height - fmax(0.0f, 45.f - label.frame.size.height);
                    if (label.frame.size.height > frame.size.height)
                    {
                        offset = messageOffset = label.frame.size.height - frame.size.height;
                        frame.size.height = label.frame.size.height;
                    }
                }
                else if ([label.text isEqualToString:alertView.message])
                {
                    label.lineBreakMode = NSLineBreakByWordWrapping;
                    label.numberOfLines = 0;
                    label.alpha = 1.0f;
                    [label sizeToFit];
                    offset += label.frame.size.height - frame.size.height;
                    frame.origin.y += messageOffset;
                    frame.size.height = label.frame.size.height;
                }
            }
            else if ([view isKindOfClass:[UITextView class]])
            {
                view.alpha = 0.0f;
            }
            else if ([view isKindOfClass:[UIImageView class]])
            {
                if (imageCount++ > 0)
                {
                    view.alpha = 0.0f;
                }
            }
            else if ([view isKindOfClass:[UIControl class]])
            {
                frame.origin.y += offset;
            }
            view.frame = frame;
        }
        CGRect frame = alertView.frame;
        frame.origin.y -= roundf(offset/2.0f);
        frame.size.height += offset;
        alertView.frame = frame;
    }
}

- (void)willRotate
{
    [self performSelectorOnMainThread:@selector(didRotate) withObject:nil waitUntilDone:NO];
}

- (void)didRotate
{
    if (self.previousOrientation != [UIApplication sharedApplication].statusBarOrientation)
    {
        self.previousOrientation = [UIApplication sharedApplication].statusBarOrientation;
        [self resizeAlertView:self.visibleAlert];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    [self resizeAlertView:alertView];
}

- (id)defaultsObjectForKey:(NSString *)key
{
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"iPrompt"];
    dictionary = dictionary[_name];
    return dictionary[key];
}

- (void)setDefaultsObject:(id)object forKey:(NSString *)key
{
    NSMutableDictionary *dictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"iPrompt"] mutableCopy];
    if (!dictionary) dictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *subDictionary = [dictionary[_name] mutableCopy];
    if (!subDictionary) subDictionary = [NSMutableDictionary dictionary];
    subDictionary[key] = object;
    dictionary[_name] = subDictionary;
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:@"iPrompt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)firstUsed
{
    return [self defaultsObjectForKey:@"firstUsed"];
}

- (void)setFirstUsed:(NSDate *)date
{
    [self setDefaultsObject:date forKey:@"firstUsed"];    
}

- (NSDate *)lastReminded
{
    return [self defaultsObjectForKey:@"lastReminded"];
}

- (void)setLastReminded:(NSDate *)date
{
    [self setDefaultsObject:date forKey:@"lastReminded"]; 
}

- (BOOL)viewed
{
    return [[self defaultsObjectForKey:@"viewed"] boolValue];
}

- (void)setViewed:(BOOL)viewed
{
    [self setDefaultsObject:@(viewed) forKey:@"viewed"];
}

- (NSUInteger)usesCount
{
    return [[self defaultsObjectForKey:@"usesCount"] integerValue];
}

- (void)setUsesCount:(NSUInteger)count
{
    [self setDefaultsObject:@(count) forKey:@"usesCount"];
}

- (void)incrementUseCount
{
    self.usesCount ++;
}

- (BOOL)shouldPrompt
{
    //preview mode?
    if (self.previewMode)
    {
        NSLog(@"iPrompt preview mode is enabled - make sure you disable this for release");
        return YES;
    }
    
    //already viewed?
    if (self.viewed)
    {
        NSLog(@"iPrompt did not display the \"%@\" prompt because it has already been viewed", _name);
        return NO;
    }
    
    //check how long we've been using the app
    else if ([[NSDate date] timeIntervalSinceDate:self.firstUsed] < self.daysUntilPrompt * SECONDS_IN_A_DAY)
    {
        if (self.verboseLogging)
        {
            NSLog(@"iPrompt did not display the \"%@\" prompt because the app was first used less than %g days ago", self.name, self.daysUntilPrompt);
        }
        return NO;
    }
    
    //check how many times we've used it and the number of significant events
    else if (self.usesCount < self.usesUntilPrompt)
    {
        if (self.verboseLogging)
        {
            NSLog(@"iPrompt did not display the \"%@\" prompt because the app has only been used %i times", self.name, (int)self.usesCount);
        }
        return NO;
    }
    
    //check if within the reminder period
    else if (self.lastReminded != nil && [[NSDate date] timeIntervalSinceDate:self.lastReminded] < self.remindPeriod * SECONDS_IN_A_DAY)
    {
        if (self.verboseLogging)
        {
            NSLog(@"iPrompt did not display the \"%@\" prompt because the user last asked to be reminded less than %g days ago", self.name, self.remindPeriod);
        }
        return NO;
    }
    
    //lets prompt!
    return YES;
}

- (void)displayPrompt
{
    if (!self.visibleAlert)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.title
                                                        message:self.message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:self.actionButtonLabel, nil];
        if ([self.remindButtonLabel length])
        {
            [alert addButtonWithTitle:self.remindButtonLabel];
        }
        
        self.visibleAlert = alert;
        [self.visibleAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        //remind later
        self.lastReminded = [NSDate date];
    }
    else
    {
        if (self.recurring)
        {
            //remind later
            self.lastReminded = [NSDate date];
        }
        else
        {
            //mark as viewed
            self.viewed = YES;
        }
        
        //call action
        [[UIApplication sharedApplication] openURL:self.actionURL];
    }
    
    //release alert
    self.visibleAlert = nil;
}

- (void)applicationLaunched
{
    //set first launch date
    if (![self defaultsObjectForKey:@"firstUsed"])
    {
        [self setDefaultsObject:[NSDate date] forKey:@"firstUsed"];
    }
    
    [self incrementUseCount];
    if ([self shouldPrompt])
    {
        [self displayPrompt];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        [self incrementUseCount];
        if ([self shouldPrompt])
        {
            [self displayPrompt];
        }
    }
}

@end
