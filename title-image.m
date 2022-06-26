/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import "picture.h"
#import "title-image.h"

@implementation TitleImage
{
	Picture *_picture;
}

-(id) initWithPicture: (Picture *)p
{
	if ((self = [super init]))
	{
		self.fillArea = YES;
		_picture = p;
	}
	return self;
}

-(BOOL) draw: (ULONG)flags
{
	[super draw: flags];

	if (flags & MADF_DRAWOBJECT)
	{
		LONG top_margin = 0, left_margin = 0, w, h;
		DOUBLE ratio = ((DOUBLE)self.innerWidth) / ((DOUBLE)_picture.width);

		w = MIN(_picture.width * ratio, self.innerWidth);
		h = MIN(_picture.height * ratio, self.innerHeight);

		if (h < self.innerHeight)
			top_margin = (self.innerHeight - h) / 2;
		if (w < self.innerWidth)
			left_margin = (self.innerWidth - w) / 2;

		[_picture draw: self.rastPort left: left_margin + self.left top: self.top + top_margin width: w height: h alpha: 0xFFFFFFFF];
	}
	return NO;
}

-(VOID) askMinMax: (struct MUI_MinMax *)minmax
{
	minmax->MinWidth  += _picture.width / 4;
	minmax->MinHeight += _picture.height / 4;
	minmax->DefWidth  += _picture.width;
	minmax->DefHeight += _picture.height;
	minmax->MaxWidth  += MUI_MAXMAX;
	minmax->MaxHeight += MUI_MAXMAX;
}

@end
