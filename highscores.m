/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <ob/OBFramework.h>
#import <ob/OBDataMutable.h>
#import "globaldefines.h"
#import "highscores.h"

@implementation HighScores
{
	OBString *_names[10];
	OBNumber *_scores[10];
}

-(id) init
{
	if((self = [super init]))
	{
		self.fillArea = YES;
		self.customFont = @"//g";
	}
	return self;
}

-(BOOL) checkQualification: (ULONG)score
{
	return _scores[9].unsignedLongValue <= score;
}

-(VOID) addEntry: (OBString *)name score: (OBNumber *)score
{
	LONG i, setAt;

	for (i = 9; i >= 0 && _scores[i].unsignedLongValue <= score.unsignedLongValue; i--);

	setAt = i + 1;

	for (i = 9; i > setAt; i--)
	{
		_names[i] = _names[i - 1];
		_scores[i] = _scores[i - 1];
	}

	[self setEntry: i withName: name score: score];
}

-(VOID) setEntry: (ULONG)no withName: (OBString *)name score: (OBNumber *)score
{
	if (no >= 10)
		return;

	_names[no] = name;
	_scores[no] = score;
}

-(BOOL) draw: (ULONG)flags
{
	[super draw: flags];

	if (flags & MADF_DRAWOBJECT)
	{
		LONG i;
		LONG top = self.top;

		for (i = 0; i < 10; i++)
		{
			LONG line_height, no_right, score_left, name_width;
			ULONG dim;
			OBString *no = [OBString stringWithFormat: @"%u. ", i + 1];
			OBString *score = [_scores[i] stringValue];

			// place number
			dim = [self textDim: no len: no.length preparse: nil flags: 0];
			line_height = dim >> 16;
			no_right = self.left + dim & 0xFFFF;
			[self text: self.left top: top width: dim & 0xFFFF height: dim >> 16 text: no len: no.length preparse: nil flags: 0];

			// score (points)
			dim = [self textDim: score len: score.length preparse: nil flags: 0];
			if ((dim >> 16) > line_height)
				line_height = dim >> 16;
			score_left = self.right - (dim & 0xFFFF) - 5;
			[self text: score_left top: top width: dim & 0xFFFF height: dim >> 16 text: score len: score.length preparse: nil flags: 0];

			// name
			dim = [self textDim: _names[i] len: _names[i].length preparse: nil flags: 0];
			if ((dim >> 16) > line_height)
				line_height = dim >> 16;
			if ((dim & 0xFFFF) > score_left - no_right - 10)
				name_width = score_left - no_right - 10;
			else
				name_width = dim & 0xFFFF;
			[self text: no_right top: top width: name_width height: dim >> 16 text: _names[i] len: _names[i].length preparse: nil flags: 0];

			top += line_height;
		}
	}

	return NO;
}

-(VOID) askMinMax: (struct MUI_MinMax *)minmax
{
	ULONG dim = [self textDim: @"M" len: 1 preparse: nil flags: 0];

	minmax->MinWidth  +=  10 * (dim & 0xFFFF) + 15;
	minmax->MinHeight +=  10 * (dim >> 16);
	minmax->DefWidth  +=  20 * (dim & 0xFFFF) + 15;
	minmax->DefHeight +=  10 * (dim >> 16);
	minmax->MaxWidth  +=  MUI_MAXMAX;
	minmax->MaxHeight +=  MUI_MAXMAX;
}

-(IPTR) export: (MUIDataspace *)dataspace
{
	OBMutableData *data = [OBMutableData dataWithCapacity: 500];
	LONG i;

	for (i = 0; i < 10; i++)
	{
		[data appendData: [_names[i] dataWithEncoding: MIBENUM_UTF_8]];
		[data appendBytes: "\n" length: 1];
		[data appendData: [[_scores[i] stringValue] dataWithEncoding: MIBENUM_UTF_8]];
		[data appendBytes: "\n" length: 1];
	}

	[((MUIDataspace *)dataspace) setData: data forID: MAKE_ID('H', 'S', 'C', 'R')];

	return [super export: dataspace];
}

-(IPTR) import: (MUIDataspace *)dataspace
{
	OBData *data = [dataspace dataForID: MAKE_ID('H', 'S', 'C', 'R')];

	if (data != nil && data.length > 4)
	{
		LONG i;
		OBString *all = [OBString stringFromData: data encoding: MIBENUM_UTF_8];
		OBArray *split = [all componentsSeparatedByString: @"\n"];

		for (i = 0; i < 10; i++)
		{
			_names[i] = [split objectAtIndex: i * 2];
			_scores[i] = [OBNumber numberWithUnsignedLong: [[split objectAtIndex: i * 2 + 1] unsignedIntValue]];
		}
	}
	else
		[self setDefaultEntries];

	return [super import: dataspace];
}

-(VOID) setDefaultEntries
{
	[self setEntry: 0 withName: @"Albert Einstein" score: @250ul];
	[self setEntry: 1 withName: @"Leonardo Da Vinci" score: @200ul];
	[self setEntry: 2 withName: @"Nikola Tesla" score: @150ul];
	[self setEntry: 3 withName: @"Sir Isaac Newton" score: @100ul];
	[self setEntry: 4 withName: @"Stephen Hawking" score: @80ul];
	[self setEntry: 5 withName: @"Michelangelo" score: @60ul];
	[self setEntry: 6 withName: @"Archimedes" score: @40ul];
	[self setEntry: 7 withName: @"Warren Buffet" score: @20ul];
	[self setEntry: 8 withName: @"Swami Vivekananda" score: @10ul];
	[self setEntry: 9 withName: @"Samuel Johnson" score: @5ul];
}

@end
