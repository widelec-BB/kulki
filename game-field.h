/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */
#import <ob/OBFramework.h>
#import <graphics/rastport.h>
#import "theme.h"

@interface GameField : OBObject

@property (nonatomic) LONG left;
@property (nonatomic) LONG width;
@property (nonatomic) LONG top;
@property (nonatomic) LONG height;
@property (nonatomic) BYTE type;
@property (nonatomic) BOOL active;
@property (nonatomic) LONG row;
@property (nonatomic) LONG column;
@property (nonatomic, readonly) BOOL empty;
@property (nonatomic) ULONG alpha;

+(VOID) setActiveTheme: (id <Theme>)set;

-(id) initWithColumn: (LONG)c row: (LONG)r;
-(BOOL) isInObject: (WORD)x y: (WORD)y;
-(VOID) draw: (struct RastPort *)rp;
-(VOID) draw: (struct RastPort *)rp left: (LONG)l width: (LONG)w top: (LONG)t height: (LONG)h;
-(VOID) clear;
-(VOID) bounce;

@end
