//
//  StarPrint.m
//  Star Print
//
//  Created by Shashwat Triapthi (github.com/goforgold) on 19 May 2014.
//  Copyright 2014 Shashwat Triapthi. All rights reserved.
//  MIT licensed
//

#import "StarPrint.h"
#import <sys/time.h>

@interface StarPrint (Private)
-(void) doPrint;
-(void) callbackWithFuntion:(NSString *)function withData:(NSString *)value;
- (BOOL) isPrintServiceAvailable;
@end

@implementation StarPrint

//@synthesize successCallback, failCallback, printHTML, dialogTopPos, dialogLeftPos;
@synthesize successCallback, failCallback, portName, printContent;

/*
 Is printing available. Callback returns true/false if printing is available/unavailable.
 */
 - (void) isPrintingAvailable:(CDVInvokedUrlCommand*)command{
    NSUInteger argc = [command.arguments count];
    
    if (argc < 1) {
        return;
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:([self isPrintServiceAvailable] ? YES : NO)];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) print:(CDVInvokedUrlCommand*)command{
    NSUInteger argc = [command.arguments count];
    NSLog(@"Array contents: %@", command.arguments);
    if (argc < 1) {
        return;
    }
    
    self.portName = [command.arguments objectAtIndex:0];
    self.printContent = [command.arguments objectAtIndex:1];
    
    CDVPluginResult* pluginResult = nil;
    
    // call sendCommand here
    
    NSString *printerReponse = [self sendCommand:[self.printContent dataUsingEncoding:NSUTF8StringEncoding] portName:self.portName portSettings:@"Standard" timeoutMillis:10000];
    
    if (printerReponse == nil || [printerReponse isEqual: @""]) {
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"{\"success\": true}"];
    }
    else {
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"success\": false, \"available\": true, \"error\": \"%@\"}", printerReponse]];
    }
    
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSString *)sendCommand:(NSData *)commandsToPrint portName:(NSString *)_portName portSettings:(NSString *)_portSettings timeoutMillis:(u_int32_t)timeoutMillis
{
    int commandSize = (int)[commandsToPrint length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    
    NSString *returnMsg = @"";
    
    @try
    {
        starPort = [SMPort getPort:_portName :_portSettings :timeoutMillis];
        if (starPort == nil)
        {
            returnMsg = @"Failed to Open Port";
            return returnMsg;
        }
        
        StarPrinterStatus_2 status;
        [starPort beginCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            returnMsg = @"Printer is offline";
            return returnMsg;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :remaining];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        if (totalAmountWritten < commandSize)
        {
            returnMsg = @"Write port timed out";
            
        }
        
        starPort.endCheckedBlockTimeoutMillis = 30000;
        [starPort endCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            returnMsg = @"Printer is offline";
            return returnMsg;
        }
    }
    @catch (PortException *exception)
    {
        returnMsg = @"Write port timed out";
    }
    @finally
    {
        free(dataToSentToPrinter);
        [SMPort releasePort:starPort];
        return returnMsg;
    }
}


- (BOOL) isPrintServiceAvailable{
    
    Class myClass = NSClassFromString(@"UIPrintInteractionController");
    if (myClass) {
        UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
        return (controller != nil) && [UIPrintInteractionController isPrintingAvailable];
    }
    
    
    return NO;
}

@end
