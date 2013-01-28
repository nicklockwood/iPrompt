Purpose
--------------

iPrompt is a library for iOS to help you schedule in-app notifications or prompts based on installed time and usage of your app. It is ideal for implementing "upgrade to pro version" alerts for "lite" or trial versions of apps.


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 6.0 (Xcode 4.5, Apple LLVM compiler 4.1)
* Earliest supported deployment target - iOS 5.0
* Earliest compatible deployment target - iOS 4.3

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

iPrompt requires ARC. If you wish to use iPrompt in a non-ARC project, just add the -fobjc-arc compiler flag to the iPrompt.m class. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click iPrompt.m in the list and type -fobjc-arc into the popover.

If you wish to convert your whole project to ARC, comment out the #error line in iPrompt.m, then run the Edit > Refactor > Convert to Objective-C ARC... tool in Xcode and make sure all files that you wish to use ARC for (including iPrompt.m) are checked.


Thread Safety
--------------

iPrompt is not thread-safe, and the iPrompt methods should only be accessed from the main thread.


Installation
--------------

To install iPrompt into your app, drag the iPrompt.h and .m files into your project. iPrompt can then be configured either programmatically or by adding an iPrompt.plist file to your app resources with the following format:

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>prompt 1</key>
        <dict>
            <key>title</key>
            <string>Prompt Title</string>
            <key>message</key>
            <string>The message to display in the prompt</string>
            <key>actionURL</key>
            <string>http://example.com</string>
            <key>actionButton</key>
            <string>ActionButtonLabel</string>
            <key>remindButton</key>
            <string>RemindButtonLabel</string>
            <key>remindPeriod</key>
            <integer>5</integer>
            <key>daysUntilPrompt</key>
            <integer>10</integer>
            <key>usesUntilPrompt</key>
            <string>10</string>
            <key>recurring</key>
            <true/>
        </dict>
        <key>prompt 2</key>
        <dict>
            ...
        </dict>
    </dict>
    </plist>
    
The iPrompt.plist file is a simple way to configure one or more prompts for your application without writing any code. The plist consists of a dictionary containing one or more sub-dictionaries (one for each prompt), each with a unique key. The prompt dictionaries should each contain values matching the properties listed under "Properties" below.


Methods
--------------

Use the following methods to create and access existing prompts:

    + (NSDictionary *)allPrompts;
    
Returns all existing prompts.
    
    + (void)addPrompt:(iPrompt *)prompt;
    
Add a new prompt to the application.

    + (iPrompt *)defaults;
    
This is a global prompt object used to set the defaults for all prompts. Any values set on this object will be applied to all other prompt instances unless they explicitly override the values. You can configure the defaults with the iPrompt.plist by adding a prompt dictionary with the key "defaults".
    
    - (id)initWithName:(NSString *)name;
    
Initialise a prompt by name, which is the minimum required configuration. To configure the other settings of the prompt, use the properties listed below.
    
    - (id)initWithDictionary:(NSDictionary *)dict;
    
Initialise a prompt using a dictionary of settings. The key names match the properties defined below.
 
    - (void)setWithDictionary:(NSDictionary *)dict;
    
This is a convenience method that can be used to set the properties for an existing prompt object from a dictionary of values after it has been created.
 
 
Configuration Properties
----------------------

Each prompt has the following configurable properties:

    @property (nonatomic, copy, readonly) NSString *name;
    
The prompt name. This must be globally unique and cannot be modified after the prompt has been created. This corresponds to the key in the iPrompt.plist dictionary.
    
    @property (nonatomic, copy) NSString *title;
        
This is the title that will be displayed in the prompt alert. If not set, the alert will have no title.

    @property (nonatomic, copy) NSString *message;
    
This is the message that will be displayed in the prompt alert. If not set, the alert will have no message.
     
    @property (nonatomic, copy) NSString *actionButtonLabel;
    
This is the label for the action button in the alert. If not set, the action button label will default to "OK".

    @property (nonatomic, copy) NSString *remindButtonLabel;
    
This is the label for the "remind me later" button in the alert. If not set, the button label will default to "Remind Me Later". If you wish to disable the remind button, set this to an empty string. If the user presses the remind button on a prompt, it will not be shown again until the remind period has passed..
    
    @property (nonatomic, copy) NSString *cancelButtonLabel;
    
This is the label for the cancel button in the alert. If not set, the cancel button will be hidden. If you wish to enable the cancel button, set this to a non-empty string. If the user presses the cancel button on a prompt, it will never be displayed again even if it is marked as recurring.
    
    @property (nonatomic, strong) NSURL *actionURL;
    
This is a URL that will be opened when the user presses the action button in the alert. If not set, the action button will close the alert without performing any further function (although you can still detect and react to this event using the delegate).
    
    @property (nonatomic, assign) NSUInteger usesUntilPrompt;
    
This is the number of app launches (integer) before the prompt will be displayed for the first time. If omitted, this defaults to 10 launches.

    @property (nonatomic, assign) float daysUntilPrompt;
    
This is the number of days (floating point) after the app is first launched before the prompt will be displayed for the first time. If omitted, this defaults to 10 days.
    
    @property (nonatomic, assign) float remindPeriod;
    
This is the number of days (floating point) after pressing the "remind me" button before the prompt will be displayed again. If omitted, this defaults to 1 day.
    
    @property (nonatomic, assign, getter = isRecurring) BOOL recurring;
    
This is a boolean indicating whether the prompt should reccur after the action button has been pressed. Defaults to NO.

    @property (nonatomic, assign) BOOL disableAlertViewResizing;
    
iPrompt includes some logic to resize the alert view to ensure that your prompt message is visible in both portrait and landscape mode, and that it doesn't scroll or become truncated. The code to do this is a rather nasty hack, so if your alert text is very short and/or your app only needs to function in portrait mode on iPhone, you may wish to set this property to YES, which may help make your app more robust against future iOS updates.


Debugging properties
----------------------

The following properties are used for debugging purposes:
    
    @property (nonatomic, assign) BOOL verboseLogging;
    
This option will cause iPrompt to send detailed logs to the console about the prompt decision process. If your app is not correctly prompting when you would expect it to, this will help you figure out why. Verbose logging is enabled by default on debug builds, and disabled on release and deployment builds.
    
    @property (nonatomic, assign) BOOL previewMode;
    
If set to YES, iPrompt will always display the rating prompt on launch, regardless of how long the app has been in use or whether it's the latest version. Use this to proofread your message and check your configuration is correct during testing, but disable it for the final release (defaults to NO).


Advanced properties
--------------

If the default iPrompt configuration options don't meet your requirements, you can implement your own logic by using the advanced properties, methods and delegate. The properties below let you access internal state and override it. You would not normally configure these properties using the iPrompt.plist.

    @property (nonatomic, strong) NSDate *firstUsed;

The first date on which the user launched the app. This is used to calculate whether the daysUntilPrompt criterion has been met.

    @property (nonatomic, strong) NSDate *lastReminded;

The date on which the user last requested to be reminded about a prompt.

    @property (nonatomic, assign) NSUInteger usesCount;

The number of times the app has been used (launched) since it was installed.

    @property (nonatomic, assign, getter = isViewed) BOOL viewed;

This flag indicates whether the user has already pressed the prompt action button (view the prompt). If this is set to YES, the prompt will never be shown again. Note that if the `recurring` property is set to YES, pressing the prompt action will merely reset the `lastReminded` date, and will not set `viewed` to YES.

    @property (nonatomic, assign, getter = isCancelled) BOOL cancelled;

This flag indicates whether the user has declined this prompt by pressing the Cancel button. If the user has declined the prompt, it will never be shown again even if `recurring` is set to YES.

    @property (nonatomic, weak_delegate) id<iPromptDelegate> delegate;

An object you have supplied that implements the `iPromptDelegate` protocol, documented below. Use this to detect and/or override iPrompt's default behaviour. This defaults to the App Delegate, so if you are using your App Delegate as your iPrompt delegate, you don't need to set this property.


Delegate methods
---------------

The iPromptDelegate protocol provides the following methods that can be used intercept iPrompt events and override the default behaviour. All methods are optional.

    - (BOOL)iPromptShouldDisplayPrompt:(iPrompt *)prompt;
    
This method is called immediately before the prompt is displayed to the user. You can use this method to implement custom prompt logic. You can also use this method to block the standard prompt alert and display the prompt in a different way, or bypass it altogether.
    
    - (BOOL)iPromptShouldOpenActionURL:(iPrompt *)prompt;
    
This method is called when the user pressed the action button, before the URL is opened. You can use this method to intercept an action URL and perform some other behaviour, such as loading a native view controller.
    
    - (void)iPromptUserDidPressActionButton:(iPrompt *)prompt;
    
This method is called after the user presses the action button, but before the action URL is opened. This is useful if you want to log user interaction with iPrompt. This method is only called if you are using the standard iPrompt alert view prompt and will not be called automatically if you provide a custom alert implementation by implementing the `iPromptShouldDisplayPrompt:` method and returning NO.
    
    - (void)iPromptUserDidPressRemindButton:(iPrompt *)prompt;
    
This method is called after the user presses the remind button. This is useful if you want to log user interaction with iPrompt. This method is only called if you are using the standard iPrompt alert view prompt and will not be called automatically if you provide a custom alert implementation by implementing the `iPromptShouldDisplayPrompt:` method and returning NO.
    
    - (void)iPromptUserDidPressCancelButton:(iPrompt *)prompt;
    
This method is called after the user presses the cancel button. This is useful if you want to log user interaction with iPrompt. This method is only called if you are using the standard iPrompt alert view prompt and will not be called automatically if you provide a custom alert implementation by implementing the `iPromptShouldDisplayPrompt:` method and returning NO.