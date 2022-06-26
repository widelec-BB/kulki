/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <ob/OBFramework.h>

struct RastPort;

@interface Picture : OBObject

@property (nonatomic) ULONG height;
@property (nonatomic) ULONG width;

-(id) initFromFile: (OBString *)path;
-(VOID) draw: (struct RastPort *)rp left: (LONG)x top: (LONG)y width: (LONG)w height: (LONG)h alpha: (LONG) alpha;
-(VOID) drawPart: (struct RastPort *)rp offset: (LONG)o srcWidth: (LONG)srcW srcHeight: (LONG)srcH left: (LONG)x top: (LONG)y width: (LONG)w height: (LONG)h alpha: (LONG)alpha;

@end