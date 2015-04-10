//
//  AppDelegate.m
//  ObjCHeaderExtractor
//
//  Created by Zolo on 4/10/15.
//  Copyright (c) 2015 Zolo. All rights reserved.
//

#import "AppDelegate.h"
#import "ControllerVC.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property ControllerVC *controllerVC;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.controllerVC = [[ControllerVC alloc] initWithNibName:nil bundle:nil];
    self.controllerVC.view.frame = ((NSView*)self.window.contentView).bounds;
    [self.window.contentView addSubview:self.controllerVC.view];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
