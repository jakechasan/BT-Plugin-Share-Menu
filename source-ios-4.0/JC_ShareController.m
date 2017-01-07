/*
 *	Copyright 2013-2017 Jake Chasan
 *  Current Revision January 2017, v2.6
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
 *	The name of Jake Chasan, jakechasan.com, and the names of its contributors may not be
 *	used to endorse or promote products derived from this software without specific
 *	prior written permission, under any circumstances.
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
#import "BT_application.h"
#import "BT_strings.h"
#import "BT_viewUtilities.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "JC_ShareController.h"

@implementation JC_ShareController

-(void)viewDidLoad {
    [BT_debugger showIt:self theMessage:@"viewDidLoad"];
    [super viewDidLoad];
    
    //Present the ShareSheet
    [self performSelector:@selector(presentShareSheet) withObject:nil afterDelay:0.2];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [BT_debugger showIt:self theMessage:@"viewWillAppear"];
    
    //flag this as the current screen
    appDelegate.rootApp.currentScreenData = self.screenData;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)presentShareSheet{
    NSLog(@"Present");
    
    //Check if device is running iOS 6
    float baseVersion = 6.0;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= baseVersion)
    {
        [BT_debugger showIt:self theMessage:@"Device is capable of showing the ShareSheet"];
        
        //All data you want to share (this will be filled in later)
        NSMutableArray* dataToShare = [NSMutableArray new];
        
        
        [BT_debugger showIt:self theMessage:@"Attaching Objects to Array"];
        //Items to be Attached
        //Text String
        NSString *shareTextString = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareText" defaultValue:@""];
        [dataToShare addObject:shareTextString];
        
        //Attaching Local Images
        NSArray *Local_images = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareLocalImage" defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
        
        for (NSString *string in Local_images) {
            if(![string isEqualToString:@""])
                @try {
                    [dataToShare addObject:[UIImage imageNamed:string]];
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Attached Local Image: %@", string]];
                }
            @catch (NSException *exception) {
                [BT_debugger showIt:self message:[NSString stringWithFormat:@"Error: %@, Attaching Local Image: %@", exception, string]];
                [self showAlert:@"Error Attaching Image" theMessage:[NSString stringWithFormat:@"There was an error attaching the local image: %@", string] alertTag:0];
                continue;
            }
            @finally {
            }
        }
        
        //Attaching URL Images
        NSArray *URL_images = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareURLImage" defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
        
        for (NSString *string in URL_images) {
            if(![string isEqualToString:@""])
            {
                @try {
                    [dataToShare addObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:string]]]];
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Attached URL Image: %@", string]];
                }
                @catch (NSException *exception) {
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Error: %@, Attaching URL Image: %@", exception, string]];
                    [self showAlert:@"Error Attaching Image" theMessage:[NSString stringWithFormat:@"There was an error attaching the URL image: %@", string] alertTag:0];
                    continue;
                }
                @finally {
                }
            }
        }
        
        //Attaching Documents
        NSArray *Local_Documents = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareLocalDocuments" defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
        
        for (NSString *string in Local_Documents) {
            if(![string isEqualToString:@""])
            {
                @try {
                    int extCount;
                    NSMutableString *fileExtBackward = [[NSMutableString alloc] init];
                    NSMutableString *fileExt = [[NSMutableString alloc] init];
                    NSString *stringFileName = @"";
                    for(extCount=(int)string.length - 1; extCount>0; extCount--)
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
                    for(extCount=(int)fileExtBackward.length - 1; extCount>=0; extCount--)
                    {
                        [fileExt appendFormat:@"%c", [fileExtBackward characterAtIndex:extCount]];
                    }
                    
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"File Extension: %@", fileExt]];
                    
                    stringFileName = [string substringToIndex:string.length-(fileExt.length)-1];
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"File Name: %@", stringFileName]];
                    
                    NSString *documentString = [[NSBundle mainBundle] pathForResource:stringFileName ofType:fileExt];
                    [dataToShare addObject:[NSURL fileURLWithPath:documentString]];
                    
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Attached URL Image: %@", string]];
                }
                @catch (NSException *exception) {
                    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Error: %@, Attaching Document: %@", exception, string]];
                    [self showAlert:@"Error Attaching Document" theMessage:[NSString stringWithFormat:@"There was an error attaching the document: %@", string] alertTag:0];
                    continue;
                }
                @finally {
                }
            }
        }
        
        //Attaching URL Strings
        NSArray *shareURLs = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareURLs" defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
        for (NSString *string in shareURLs) {
            if(![string isEqualToString:@""])
                [dataToShare addObject:[NSURL URLWithString:string]];
        }
        
        [BT_debugger showIt:self theMessage:@"Initializing the Share Controller"];
        
        //Initialize the Share Controller
        UIActivityViewController* shareController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        
        [BT_debugger showIt:self theMessage:@"Initializing the Array: shareServices"];
        
        //Initializing the Array
        NSMutableArray *shareServices = [NSMutableArray new];
        
        //Filling the Array with Objects specified in the Control Panel
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareMail" defaultValue:@"1"] isEqualToString:@"0"])
        {
            [shareServices addObject:UIActivityTypeMail];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypeMail"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareMessage" defaultValue:@"1"] isEqualToString:@"0"])
        {
            [shareServices addObject:UIActivityTypeMessage];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypeMessage"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareFacebook" defaultValue:@"1"] isEqualToString:@"0"])
        {
            [shareServices addObject:UIActivityTypePostToFacebook];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypePostToFacebook"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareTwitter" defaultValue:@"1"] isEqualToString:@"0"])
        {
            [shareServices addObject:UIActivityTypePostToTwitter];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypePostToTwitter"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareWeibo" defaultValue:@"1"] isEqualToString:@"0"])
        {
            [shareServices addObject:UIActivityTypePostToWeibo];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypePostToWeibo"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareCopy" defaultValue:@"1"] isEqualToString:@"0"])
        {
            [shareServices addObject:UIActivityTypeCopyToPasteboard];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypeCopyToPasteboard"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"sharePrint" defaultValue:@"1"] isEqualToString:@"0"])
        {
            [shareServices addObject:UIActivityTypePrint];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypePrint"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareCameraRoll" defaultValue:@"1"] isEqualToString:@"0"])
        {
            [shareServices addObject:UIActivityTypeSaveToCameraRoll];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypeSaveToCameraRoll"];
        }
        
        if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"shareCameraRoll" defaultValue:@"1"] isEqualToString:@"0"])
        {
            [shareServices addObject:UIActivityTypeAssignToContact];
            [BT_debugger showIt:self theMessage:@"Not Showing: UIActivityTypeAssignToContact"];
        }
        
        //This release automatically disables Reading List, Flickr, Wimeo, TecnentWeibo, and AirDrop
        //Comment out the lines below to enable these services.
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            [shareServices addObject:UIActivityTypeAddToReadingList];
            [shareServices addObject:UIActivityTypePostToFlickr];
            [shareServices addObject:UIActivityTypePostToVimeo];
            [shareServices addObject:UIActivityTypePostToTencentWeibo];
            [shareServices addObject:UIActivityTypeAirDrop];
        }
        
        //This is an array of excluded activities to appear on the UIActivityViewController (shareController)
        shareController.excludedActivityTypes = shareServices;
        
        if(([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) && ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)){
            CGRect screenRect = self.view.bounds;
            
            UIView *popoverView = [[UIView alloc] init];
            popoverView.frame = CGRectMake(roundf((screenRect.size.width - 50) * 0.5f),
                                           roundf((screenRect.size.height - 50) * 0.5f),
                                           50,
                                           50);
            shareController.popoverPresentationController.sourceView = popoverView;
        }
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:shareController animated:YES completion:^{}];
    }
    else
    {
        [BT_debugger showIt:self theMessage:@"This device is not running iOS 6 or Greater. Prompt User with Alert."];
        [self showiOSAlert];
    }
}

//If iOS is not greater than 6.0
- (void)showiOSAlert
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"iOS 6 or Greater Required"
                            
                                                      message:@"Please update your iOS device to the latest operating system."
                            
                                                     delegate:self
                            
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

@end
