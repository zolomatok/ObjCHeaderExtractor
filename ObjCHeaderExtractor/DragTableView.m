//
//  DragTableVIew.m
//  ZMHeaderXtractor
//
//  Created by Zolo on 4/8/15.
//  Copyright (c) 2015 Zolo. All rights reserved.
//

#import "DragTableView.h"

@implementation DragTableView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    return self;
}



#pragma mark - Drag 'n' Drop
- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender {
    return NSDragOperationCopy;
}


- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}


- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {

    if ( [sender draggingSource] != self ) {
        NSPasteboard *pasteboard = [sender draggingPasteboard];
        NSData *data = [pasteboard dataForType:NSFilenamesPboardType];
        NSArray *fileNames = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:nil];

        if (self.dragDelegate) {
            [self.dragDelegate dragViewDidReceiveFileWithID:fileNames];
        }
    }
    
    return YES;
}


- (void)keyDown:(NSEvent *)theEvent {
    
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter) {
        
        [self deleteItem];
        return;
    }
    
    [super keyDown:theEvent];
    
}


- (void)deleteItem {
    if ([self numberOfSelectedRows] == 0) return;
    
    NSIndexSet *indices = [self selectedRowIndexes];
    if (self.dragDelegate) {
        [self.dragDelegate dragViewDidDeleteItemsAtIndices:indices];
    }
}


@end
