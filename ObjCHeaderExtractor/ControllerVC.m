//
//  ControllerVC.m
//  ZMHeaderXtractor
//
//  Created by Zolo on 4/8/15.
//  Copyright (c) 2015 Zolo. All rights reserved.
//

#define HEADER_DIR [@"~/Desktop/RuntimeHeaders" stringByExpandingTildeInPath]
#define DUMP_DIR [HEADER_DIR stringByAppendingPathComponent:@"dump"]

#import "ControllerVC.h"
#import "DragTableView.h"

@interface ControllerVC () <NSTableViewDataSource, NSTableViewDelegate, DragTableViewDragDelegate>
@property (strong) DragTableView *tableView;
@property NSTextView *hintTextView;
@property NSButton *button;
@property (strong) NSMutableArray *dataArray;


@end

@implementation ControllerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLayout];
}

- (void)loadView {
    CGSize windowSize = [(NSWindow *)[[[NSApplication sharedApplication] windows] firstObject] frame].size;
    self.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, windowSize.height)];
}




#pragma mark - UI
- (void)createLayout {
    
    // Scrollview
    NSScrollView * scrollView = [[NSScrollView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2-20, self.view.frame.size.width, self.view.frame.size.height/2)];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setAutohidesScrollers:YES];
    [scrollView setBorderType:NSBezelBorder];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:scrollView];
    
    
    // Tableview
    self.tableView = [[DragTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, scrollView.frame.size.height)];
    self.tableView.dragDelegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [NSColor clearColor];
    [self.tableView setAllowsMultipleSelection:YES];
    [self.tableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [scrollView setDocumentView:self.tableView];

    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"column"];
    column.title = @"File paths";
    column.width = self.tableView.frame.size.width;
    [self.tableView addTableColumn:column];
    
    
    // Hint view
    CGSize hintTextSize = CGSizeMake(self.view.frame.size.width/2, self.view.frame.size.height/4-20);
    
    self.hintTextView = [[NSTextView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height/8, hintTextSize.width, hintTextSize.height)];
    self.hintTextView.font = [NSFont systemFontOfSize:17];
    self.hintTextView.selectable = NO;
    self.hintTextView.editable = NO;
    self.hintTextView.drawsBackground = NO;
    [self.view addSubview:self.hintTextView];
    
    
    NSString *hintText = @"Drag 'n' Drop files into the list\nRemove with backspace\n\nExported headers will be placed on the desktop in the RuntimeHeaders folder";
    NSMutableAttributedString *attributedHintString = [[NSMutableAttributedString alloc] initWithString:hintText];
    [attributedHintString addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:13] range:NSMakeRange(0, 13)];
    [attributedHintString addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:13] range:NSMakeRange(34, 6)];
    [attributedHintString addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:13] range:NSMakeRange(96, 7)];
    [attributedHintString addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:13] range:NSMakeRange(110, 20)];
    [[self.hintTextView textStorage] appendAttributedString:attributedHintString];

    
    // Button read dem files
    self.button = [[NSButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2+130/2, self.view.frame.size.height/4-20-50/2, 130, 50)];
    [self.button setButtonType:NSMomentaryLightButton];
    [self.button setBezelStyle:NSTexturedSquareBezelStyle];
    [self.button setTarget:self];
    [self.button setAction:@selector(buttonPressed)];
    [self.button setTitle:@"Make dem headers"];
    [self.view addSubview:self.button];
}




#pragma mark - Table view
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataArray.count;
}


- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    // Reuse cell
    NSTextField *result = [tableView makeViewWithIdentifier:@"PathView" owner:self];
    
    
    // Create if needed
    if (result == nil) {
        result = [[NSTextField alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, 1)];
        result.identifier = @"PathView";
        result.selectable = NO;
        result.editable = NO;
        result.bezeled = NO;
        result.drawsBackground = NO;
        [result setLineBreakMode:NSLineBreakByTruncatingTail];
    }
    
    
    // Set value
    result.stringValue = self.dataArray[row];
    
    
    return result;
};




#pragma mark - Dragging
- (void)dragViewDidReceiveFileWithID:(NSArray *)filePaths {
    
    if (self.dataArray) {
        [self.dataArray addObjectsFromArray:filePaths];
    } else {
        self.dataArray = [NSMutableArray arrayWithArray:filePaths];
    }
    [self.tableView reloadData];
}


- (void)dragViewDidDeleteItemsAtIndices:(NSIndexSet *)indices {
    [self.tableView removeRowsAtIndexes:indices withAnimation:NSTableViewAnimationEffectNone];
    [self.dataArray removeObjectsAtIndexes:indices];
}




#pragma mark - Header generation
- (void)buttonPressed {
    
    if (self.dataArray.count > 0) {
        [self enableButton:NO];
        [self performSelector:@selector(dump) withObject:nil afterDelay:0.1];
    }
}


- (void)enableButton:(BOOL)enable {
    
    if (enable) {
        self.button.enabled = YES;
        self.button.alphaValue = 1;
        [self.button setTitle:@"Make dem headers"];
    } else {
        self.button.enabled = NO;
        self.button.alphaValue = 0.5;
        [self.button setTitle:@"WORKING"];
    }
}


- (void)dump {
    
    // Create the directories
    NSError *createDirectoryError;
    [[NSFileManager defaultManager] createDirectoryAtPath:DUMP_DIR withIntermediateDirectories:YES attributes:nil error:&createDirectoryError];
    if (createDirectoryError) {
        [self handleError:createDirectoryError WithMessage:@"Couldn't create dump directory on the desktop/RuntimeHeaders"];
        return;
    }
    
    
    // Iterate through the filespaths and run class-dump on them
    NSString *execPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"class-dump"];
    for (NSString *path in self.dataArray) {
        
        // Run class-dump
        NSPipe *dumpPipe = [[NSPipe alloc] init];
        NSTask *dumpTask = [[NSTask alloc] init];
        [dumpTask setArguments:@[path,@" > ",[DUMP_DIR stringByAppendingPathComponent:path.lastPathComponent]]];
        [dumpTask setLaunchPath: execPath];
        [dumpTask setStandardOutput:dumpPipe];
        [dumpTask waitUntilExit];
        [dumpTask launch];
        
        
        // Read the output
        NSFileHandle *file = [dumpPipe fileHandleForReading];
        NSData *data = [file readDataToEndOfFile];
        NSString *dumpResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        // Save to file
        NSError *writeToFileError = nil;
        NSString *dumpFilePath = [[DUMP_DIR stringByAppendingPathComponent:path.lastPathComponent]stringByAppendingPathExtension:@"txt"];
        [dumpResult writeToFile:dumpFilePath atomically:YES encoding:NSUTF8StringEncoding error:&writeToFileError];
        if (writeToFileError) {
            [self handleError:writeToFileError WithMessage:@"Couldn't save a dump file"];
            return;
        }
    }
    
    
    [self parse];
}


- (void)parse {
    
    // Iterate through the dumps
    NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL URLWithString:DUMP_DIR] includingPropertiesForKeys:@[NSURLNameKey] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants  errorHandler:nil];
    
    for (NSURL *theURL in dirEnumerator) {
        
        // Retrieve the file name
        NSString *fileName;
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        if ([fileName isEqualToString:@".DS_Store"]) {
            continue;
        }
        
        
        // Read the contents
        NSError *readError = nil;
        NSString *filePath = [DUMP_DIR stringByAppendingPathComponent:fileName];
        NSString *content = [NSString stringWithContentsOfFile:filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&readError];
        if (readError) {
            [self handleError:readError WithMessage:@"Couldn't read one of the dump files"];
            return;
        }

        
        // Parsing
        NSArray *protocols = [self itemsOfType:@"@protocol" inString:content];
        NSArray *interfaces = [self itemsOfType:@"@interface" inString:content];
        
        
        // Writing out
        NSString *folderPath = [self createDirectoryForFileName:fileName];
        [self writeOutItemsToFolder:folderPath inArray:protocols];
        [self writeOutItemsToFolder:folderPath inArray:interfaces];
    }
    
    
    // Delete dumps
    NSError *removeDumpError = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:DUMP_DIR error:&removeDumpError]) {
        [self handleError:removeDumpError WithMessage:@"SUCCESS, but couldn't remove dump folder"];
    }
    

    // Reset the button
    [self enableButton:YES];


    // Success
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Success!"];
    [alert runModal];
}


- (NSArray *)itemsOfType:(NSString *)type inString:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSUInteger count = [self countTheOccurencesOfSubstring:type inString:string];
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        NSString *body;
        [scanner scanUpToString:type intoString:nil];
        [scanner scanUpToString:@"@end" intoString:&body];
        body = [body stringByAppendingString:@"@end"];
        [items addObject:body];
    }
    
    return items;
}


- (NSUInteger)countTheOccurencesOfSubstring:(NSString *)subString inString:(NSString *)string {
    NSUInteger count = 0, length = [string length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [string rangeOfString:subString options:0 range:range];
        if(range.location != NSNotFound)
        {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            count++;
        }
    }
    return count;
}


- (NSString *)createDirectoryForFileName:(NSString *)name {
    NSArray *components = [name componentsSeparatedByString:@"."];
    NSString *fullPath = [HEADER_DIR stringByAppendingPathComponent:components.firstObject];
    
    BOOL isDir;
    NSError *createFolderError = nil;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:fullPath isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&createFolderError])
            [self handleError:createFolderError WithMessage:@"Couldn't create folder for header item"];
    
    return fullPath;
}


- (void)writeOutItemsToFolder:(NSString *)folderPath inArray:(NSArray *)items {
    
    for (NSString *item in items) {
        
        NSString *fileName;
        NSScanner *nameFinderScanner = [[NSScanner alloc] initWithString:item];
        [nameFinderScanner scanUpToString:@" " intoString:nil];
        
        NSUInteger scanLocationAtBeginning = nameFinderScanner.scanLocation;
        [nameFinderScanner scanUpToString:@" " intoString:nil];
        
        NSUInteger scanLocationAfterScanningForSpace = nameFinderScanner.scanLocation;
        nameFinderScanner.scanLocation = scanLocationAtBeginning;
        
        [nameFinderScanner scanUpToString:@"\n" intoString:nil];
        NSUInteger scanLocationAfterScanningForNewLine = nameFinderScanner.scanLocation;
        
        
        nameFinderScanner.scanLocation = scanLocationAtBeginning;
        if (scanLocationAfterScanningForNewLine < scanLocationAfterScanningForSpace) {
            [nameFinderScanner scanUpToString:@"\n" intoString:&fileName];
        } else {
            [nameFinderScanner scanUpToString:@" " intoString:&fileName];
        }
        
        NSString *postfix;
        if ([[item substringWithRange:NSMakeRange(nameFinderScanner.scanLocation+1, 1)] isEqualToString:@"("]) {
            nameFinderScanner.scanLocation = nameFinderScanner.scanLocation+2;
            [nameFinderScanner scanUpToString:@")" intoString:&postfix];
            fileName = [NSString stringWithFormat:@"%@-%@",fileName,postfix];
        }
        
        
        // Include license
        NSString *licenseString = @"//\n//     Generated by class-dump 3.5 (64 bit).\n//\n//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.\n//";
        NSString *finalItem = [NSString stringWithFormat:@"%@\n\n\n%@",licenseString,item];
        
        
        // Write out
        [finalItem writeToFile:[[folderPath stringByAppendingPathComponent:fileName] stringByAppendingString:@".h"]
               atomically:NO
                 encoding:NSUTF8StringEncoding
                    error:nil];
    }
}


- (void)handleError:(NSError *)error WithMessage:(NSString *)message {
    
    [self enableButton:YES];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithFormat:@"%@\n\nError: %@",message,error]];
    [alert runModal];
}

@end
