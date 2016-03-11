/*
 *  Document Version: 1.0 (10-19-13)
 *
 *	Copyright 2013 Jake Chasan
 *
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without modification, are 
 *	permitted provided that the following conditions are met:
 *
 *	Redistributions of source code must retain the above copyright notice which includes the
 *	name(s) of the copyright holders. It must also retain this list of conditions and the 
 *	following disclaimer. 
 *
 *	Redistributions in binary form must reproduce the above copyright notice, this list 
 *	of conditions and the following disclaimer in the documentation and/or other materials 
 *	provided with the distribution. 
 *
 *	Neither the name of Jake Chasan, or jakechasan.com nor the names of its contributors 
 *	may be used to endorse or promote products derived from this software without specific 
 *	prior written permission.
 *
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 *	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 *	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
 *	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 *	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 *	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
 *	OF SUCH DAMAGE. 
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSON.h"
#import "BT_application.h"
#import "BT_strings.h"
#import "BT_viewUtilities.h"
#import "BT_appDelegate.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "BT_viewControllerManager.h"
#import "JC_ShareController.h"

#import "BT_item.h"
#import "BT_fileManager.h"
#import "BT_color.h"
#import "BT_downloader.h"
#import "BT_debugger.h"

@implementation JC_ShareController

//viewDidLoad
-(void)viewDidLoad {
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];

    //Check if device is running iOS 6 or greater
    float currentVersion = 6.0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion)
    {
        [BT_debugger showIt:self theMessage:@"Device is capable of showing the shareMenu"];
        
        //All data you want to share (this will be filled in later)
        NSMutableArray* dataToShare = [NSMutableArray arrayWithObjects:nil];
        
        [BT_debugger showIt:self theMessage:@"Attaching Objects to Array"];
        //Items to be Attached
        //Text String
        NSString *shareTextString = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareText" defaultValue:@""];
        [dataToShare addObject:shareTextString];
        
        //Local Images
        NSArray *Local_images = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareLocalImage" defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
        
        for (NSString *string in Local_images) {
            if (![string isEqualToString:@""])
                [dataToShare addObject:[UIImage imageNamed:string]];
        }
        
        //URL Images
        NSArray *URL_images = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareURLImage" defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
        
        for (NSString *string in URL_images) {
            if (![string isEqualToString:@""])
                [dataToShare addObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:string]]]];
        }
        
        //Attaching Documents
        NSArray *Local_Documents = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareLocalDocuments" defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
        
        for (NSString *string in Local_Documents) {
            if (![string isEqualToString:@""])
            {
                @try {
                    int extCount;
                    NSMutableString *fileExtBackward = [[NSMutableString alloc] init];
                    NSMutableString *fileExt = [[NSMutableString alloc] init];
                    NSString *stringFileName = @"";
                    for(extCount=string.length-1; extCount>0; extCount--)
                    {
                        if([string characterAtIndex:extCount] != '.')
                        {
                            [fileExtBackward appendFormat:@"%c", [string characterAtIndex:extCount]];
                        }
                        else
                        {
                            break;
                        }
                    }
                    for(extCount=fileExtBackward.length-1; extCount>=0; extCount--)
                    {
                        [fileExt appendFormat:@"%c", [fileExtBackward characterAtIndex:extCount]];
                    }
                    
                    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"File Extension: %@", fileExt]];
                    
                    stringFileName = [string substringToIndex:string.length-(fileExt.length)-1];
                    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"File Name: %@", stringFileName]];
                    
                    NSString *documentString = [[NSBundle mainBundle] pathForResource:stringFileName ofType:fileExt];
                    [dataToShare addObject:[NSURL fileURLWithPath:documentString]];
                    
                    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Attached URL Image: %@", string]];
                }
                @catch (NSException *exception) {
                    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Error: %@, Attaching Document: %@", exception, string]];
                    [self showAlert:@"Error Attaching Document" theMessage:[NSString stringWithFormat:@"There was an error attaching the document: %@", string] alertTag:0];
                    continue;
                }
                @finally {
                }
            }
        }

        //URL Strings
        NSArray *shareURLs = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareURLs" defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
        for (NSString *string in shareURLs) {
            if (![string isEqualToString:@""])
                [dataToShare addObject:[NSURL URLWithString:string]];
        }
        
        [BT_debugger showIt:self theMessage:@"Initializing the Share Controller"];
        //Start Share Controller
        UIActivityViewController* shareController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        
        [BT_debugger showIt:self theMessage:@"Initializing the Array: shareServices"];
        //Initializing the Array
        NSMutableArray *shareServices = [NSMutableArray arrayWithObjects:nil];
        
        /*This code is for a BT2.0 Project and should not be used with iOS 7. Please use BT3.0 for full iOS 7 compatibility
         * UIActivityTypePostToFacebook;
         * UIActivityTypePostToTwitter;
         * UIActivityTypePostToWeibo;
         * UIActivityTypeMessage;
         * UIActivityTypeMail;
         * UIActivityTypePrint;
         * UIActivityTypeCopyToPasteboard;
         * UIActivityTypeAssignToContact;
         * UIActivityTypeSaveToCameraRoll;
        */
         
        //Filling the Array with Objects specified in the Control Panel
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareMail" defaultValue:@"1"] isEqualToString:@"0"])
        {
            //Mail
            [shareServices addObject:UIActivityTypeMail];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypeMail"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareMessage" defaultValue:@"1"] isEqualToString:@"0"])
        {
            //Message
            [shareServices addObject:UIActivityTypeMessage];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypeMessage"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareFacebook" defaultValue:@"1"] isEqualToString:@"0"])
        {
            //Facebook
            [shareServices addObject:UIActivityTypePostToFacebook];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypePostToFacebook"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareTwitter" defaultValue:@"1"] isEqualToString:@"0"])
        {
            //Twitter
            [shareServices addObject:UIActivityTypePostToTwitter];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypePostToTwitter"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareWeibo" defaultValue:@"1"] isEqualToString:@"0"])
        {
            //Weibo
            [shareServices addObject:UIActivityTypePostToWeibo];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypePostToWeibo"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareCopy" defaultValue:@"1"] isEqualToString:@"0"])
        {
            //Copy to Pasteboard
            [shareServices addObject:UIActivityTypeCopyToPasteboard];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypeCopyToPasteboard"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"sharePrint" defaultValue:@"1"] isEqualToString:@"0"])
        {
            //Print
            [shareServices addObject:UIActivityTypePrint];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypePrint"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareCameraRoll" defaultValue:@"1"] isEqualToString:@"0"])
        {
            //Save to Photos (Camera Role)
            [shareServices addObject:UIActivityTypeSaveToCameraRoll];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypeSaveToCameraRoll"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareCameraRoll" defaultValue:@"1"] isEqualToString:@"0"])
        {
            //Assign to Contact
            [shareServices addObject:UIActivityTypeAssignToContact];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypeAssignToContact"];
        }

        //This is an array of excluded activities to appear on the UIActivityViewController (shareController)
        shareController.excludedActivityTypes = shareServices;
        
        [self presentViewController:shareController animated:YES completion:^{}];
        
        //This will be the nav bar color after the Alert is launched
        [BT_viewUtilities configureBackgroundAndNavBar:self theScreenData:[self screenData]];
    }
    else
    {
        [BT_debugger showIt:self theMessage:@"This device is not running iOS 6 or Greater. Prompt User with Alert."];
        [self showiOSAlert];
    }
}

//If device is not runing iOS 6 or above.
- (void)showiOSAlert
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"iOS 6 or Greater Required"
                            
                                                      message:@"Please update your iOS device to the latest operating system."
                            
                                                     delegate:self
                            
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    
}

//view will appear
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewWillAppear"];
	
	//flag this as the current screen
	BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.rootApp.currentScreenData = self.screenData;
	
	//setup navigation bar and background
	[BT_viewUtilities configureBackgroundAndNavBar:self theScreenData:[self screenData]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

//dealloc
-(void)dealloc {
    [super dealloc];
}

@end