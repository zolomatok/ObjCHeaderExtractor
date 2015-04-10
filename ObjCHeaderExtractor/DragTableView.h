//
//  DragTableVIew.h
//  ZMHeaderXtractor
//
//  Created by Zolo on 4/8/15.
//  Copyright (c) 2015 Zolo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DragTableViewDragDelegate <NSObject>
- (void)dragViewDidReceiveFileWithID:(NSArray *)filePaths;
- (void)dragViewDidDeleteItemsAtIndices:(NSIndexSet *)indices;
@end

@interface DragTableView : NSTableView
@property (weak) id <DragTableViewDragDelegate> dragDelegate;
@end
