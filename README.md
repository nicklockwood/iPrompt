Purpose
--------------

iPrompt is a library to help you schedule in-app notifications or user prompts based on installed time and usage of your app.


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 6.0 / Mac OS 10.8 (Xcode 4.5, Apple LLVM compiler 4.1)
* Earliest supported deployment target - iOS 5.0 / Mac OS 10.7
* Earliest compatible deployment target - iOS 4.3 / Mac OS 10.6

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
    
    - (id)initWithName:(NSString *)name;
    
Initialise a prompt by name, which is the minimum required configuration. To configure the other settings of the prompt, use the properties listed below.
    
    - (id)initWithDictionary:(NSDictionary *)dict;
    
Initialise a prompt using a dictionary of settings, following the formst defined in the iPrompt.plist specification above.
 
 
Properties
--------------

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
    
This is the label for the "remind me later" button in the alert. If not set, the button label will default to "Remind Me Later". If you wish to disable the remind button, set this to an empty string.
    
    @property (nonatomic, strong) NSURL *actionURL;
    
This is a URL that will be opened when the user presses the action button in the alert (required).
    
    @property (nonatomic, assign) NSUInteger usesUntilPrompt;
    
This is the number of app launches (integer) before the prompt will be displayed for the first time. If omitted, this defaults to 10 launches.

    @property (nonatomic, assign) float daysUntilPrompt;
    
This is the number of days (floating point) after the app is first launched before the prompt will be displayed for the first time. If omitted, this defaults to 10 days.
    
    @property (nonatomic, assign) float remindPeriod;
    
This is the number of days (floating point) after pressing the "remind me" button before the prompt will be displayed again. If omitted, this defaults to 1 day.
    
    @property (nonatomic, assign, getter = isRecurring) BOOL recurring;
    
This is a boolean indicating whether the prompt should reccur after the first time it has been either actioned or dismissed. Defaults to NO.
    

Advanced properties
----------------------

The following properties are used for debugging purposes and/or for controlling how the prompt is displayed in the application.
    
    @property (nonatomic, assign) BOOL disableAlertViewResizing;
    
On iOS, iPrompt includes some logic to resize the alert view to ensure that your prompt message is visible in both portrait and landscape mode, and that it doesn't scroll or become truncated. The code to do this is a rather nasty hack, so if your alert text is very short and/or your app only needs to function in portrait mode on iPhone, you may wish to set this property to YES, which may help make your app more robust against future iOS updates.
    
    @property (nonatomic, assign) BOOL verboseLogging;
    
This option will cause iPrompt to send detailed logs to the console about the prompt decision process. If your app is not correctly prompting when you would expect it to, this will help you figure out why. Verbose logging is enabled by default on debug builds, and disabled on release and deployment builds.
    
    @property (nonatomic, assign) BOOL previewMode;
    
If set to YES, iPrompt will always display the rating prompt on launch, regardless of how long the app has been in use or whether it's the latest version. Use this to proofread your message and check your configuration is correct during testing, but disable it for the final release (defaults to NO).