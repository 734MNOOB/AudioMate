//
//  NSTableView+ContextMenu.m
//  AudioMate
//
//  Created by Ruben Nine on 2/26/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "NSTableView+ContextMenu.h"

@implementation NSTableView (ContextMenu)

- (NSMenu*)menuForEvent:(NSEvent*)event
{
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:location];

    if (!(row >= 0) || ([event type] != NSRightMouseDown))
    {
        return [super menuForEvent:event];
    }

    NSIndexSet *selected = [self selectedRowIndexes];

    if (![selected containsIndex:row])
    {
        selected = [NSIndexSet indexSetWithIndex:row];
        [self selectRowIndexes:selected byExtendingSelection:NO];
    }

    if ([[self delegate] respondsToSelector:@selector(tableView:menuForRows:)])
    {
        return [(id)[self delegate] tableView : self menuForRows : selected];
    }


    return [super menuForEvent:event];
}

@end
