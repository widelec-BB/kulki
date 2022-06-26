/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */
#import <proto/cybergraphics.h>
#import "globaldefines.h"
#import "game-field.h"

@implementation GameField
{
	LONG _bounceOffset, _bounceDiff;
	BOOL _active;
	LONG _type;
}

id <Theme> activeTheme;

+(VOID) setActiveTheme: (id <Theme>)t
{
	activeTheme = t;
}

@synthesize left;
@synthesize width;
@synthesize top;
@synthesize height;
@synthesize row;
@synthesize column;
@synthesize type = _type;
@synthesize alpha;

-(id) initWithColumn: (LONG)c row: (LONG)r
{
	if((self = [super init]))
	{
		row = r;
		column = c;
		alpha = 0xFFFFFFFF;

		_type = -1;
	}
	return self;
}

-(BOOL) isInObject: (WORD)x y: (WORD)y
{
	return x >= left && x <= self.right && y >= top && y <= self.bottom;
}

-(VOID) draw: (struct RastPort *)rp
{
	if (_type >= 0)
	{
		if (_active)
		{
			[activeTheme drawItem: _type on: rp left: left + 8 top: top + 8 + _bounceOffset width: width - 16 height: height - 16 alpha: self.alpha];
		}
		else
		{
			[activeTheme drawItem: _type on: rp left: left + 8 top: top + 8 width: width - 16 height: height - 16 alpha: self.alpha];
		}
	}
}

-(VOID) draw: (struct RastPort *)rp left: (LONG)l width: (LONG)w top: (LONG)t height: (LONG)h
{
	left = l;
	width = w;
	top = t;
	height = h;

	[self draw: rp];
}

-(VOID) clear
{
	self.type = -1;
}

-(LONG) right
{
	return self.left + self.width;
}

-(LONG) bottom
{
	return self.top + self.height;
}

-(BOOL) empty
{
	return self.type == -1;
}

-(VOID) bounce
{
	_bounceOffset += _bounceDiff;
	if (_bounceOffset == -5 || _bounceOffset == 5)
		_bounceDiff = -_bounceDiff;
}

-(VOID) setActive: (BOOL)value
{
	_active = value;
	_bounceOffset = 0;
	_bounceDiff = -1;
}

-(BOOL) active
{
	return _active;
}

@end
