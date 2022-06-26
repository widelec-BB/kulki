/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <proto/graphics.h>
#import "globaldefines.h"
#import "game-field.h"
#import "next-items.h"

@implementation NextItems
{
	GameField *_nextItems[3];
}

-(id) init
{
	if ((self = [super init]))
	{
		_nextItems[0] = [[GameField alloc] initWithColumn: 0 row: 0];
		_nextItems[1] = [[GameField alloc] initWithColumn: 0 row: 1];
		_nextItems[2] = [[GameField alloc] initWithColumn: 0 row: 2];
	}
	return self;
}

-(VOID) setNextItems: (LONG[3])nextItems
{
	_nextItems[0].type = nextItems[0];
	_nextItems[1].type = nextItems[1];
	_nextItems[2].type = nextItems[2];

	[self redraw: MADF_DRAWOBJECT];
}

-(BOOL) draw: (ULONG)flags
{
	LONG i;

	[super draw: flags];

	if (flags & MADF_DRAWOBJECT)
	{
		LONG field_width = (self.innerHeight - 3);

		SetAPen(self.rastPort, 13);
		Move(self.rastPort, self.left, self.top);
		Draw(self.rastPort, self.right, self.top);
		Move(self.rastPort, self.left, self.bottom);
		Draw(self.rastPort, self.right, self.bottom);

		for (i = 0; i <= 3; i++)
		{
			Move(self.rastPort, self.left + self.innerWidth / 3 * i, self.top);
			Draw(self.rastPort, self.left + self.innerWidth / 3 * i, self.bottom);
		}

		for (i = 0; i < 3; i++)
		{
			LONG left = self.left + self.innerWidth / 3 * i + 1;
			[_nextItems[i] draw: self.rastPort left: left width: field_width top: self.top + 1 height: self.bottom - self.top - 2];
		}
	}
	if (flags & MADF_DRAWUPDATE)
	{
		for (i = 0; i < 3; i++)
		{
			GameField *gf = _nextItems[i];

			[self drawBackground: gf.left top: gf.top width: gf.width height: gf.height xoffset: gf.left yoffset: gf.top flags: 0];
			[gf draw: self.rastPort];
		}
	}

	return NO;
}

-(VOID) askMinMax: (struct MUI_MinMax *)minmax
{
	minmax->MinWidth  +=  48 * 3 + 4;
	minmax->MinHeight +=  48 + 3 + 2;
	minmax->DefWidth  +=  48 * 3 + 4;
	minmax->DefHeight +=  48 + 3 + 2;
	minmax->MaxWidth  +=  48 * 3 + 4;
	minmax->MaxHeight +=  48 + 3 + 2;
}

@end
