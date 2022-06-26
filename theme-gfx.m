/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import "globaldefines.h"
#import "picture.h"
#import "theme-gfx.h"

@implementation ThemeGfx
{
	Picture *_picture;
}

@synthesize name;

-(id) initWithName: (OBString *)n fromFile: (OBString *)path
{
	Picture *p = [[Picture alloc] initFromFile: path];

	if ((self = [super init]))
	{
		_picture = p;
		self.name = n;
	}

	return p && p.width == 48 && p.height == 432 ? self : nil;
}

-(VOID) drawItem: (LONG)type on: (struct RastPort *)rp left: (ULONG)x top: (ULONG)y width: (LONG)w height: (LONG)h alpha: (ULONG)a
{
	LONG off = type * 48 * 48 * 4;
	[_picture drawPart: rp offset: off srcWidth: 48 srcHeight: 48 left: x top: y width: w height: h alpha: a];
}

-(OBComparisonResult) compareNames: (id<Theme>) other
{
	return [self.name caseInsensitiveCompare: other.name];
}

@end
