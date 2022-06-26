/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <proto/exec.h>
#import <proto/graphics.h>
#import <proto/cybergraphics.h>
#import <cybergraphx/cybergraphics.h>
#import <graphics/gfxmacros.h>
#import <proto/intuition.h>
#import "globaldefines.h"
#import "theme-internal.h"

@implementation ThemeInternal
{
	ULONG *_items[9];
}

const LONG itemWidth = 48;
const LONG itemHeight = 48;

@synthesize name;

-(id) init
{
	if ((self = [super init]))
	{
		LONG i;

		self.name = OBL(@"Basic", @"Name for internal (default) theme");

		for (i = 0; i < 9; i++)
		{
			_items[i] = AllocMem(itemWidth * itemHeight * sizeof(ULONG), MEMF_ANY);
			if (!_items[i])
				return nil;
		}

		[ThemeInternal createCircleMaskIn: (ULONG *)_items[8]];

		[ThemeInternal copyMask: _items[8] to: _items[0] withColor: 0xFFDD0907]; // red
		[ThemeInternal copyMask: _items[8] to: _items[1] withColor: 0xFFFF6403]; // orange
		[ThemeInternal copyMask: _items[8] to: _items[2] withColor: 0xFFFBF305]; // yellow
		[ThemeInternal copyMask: _items[8] to: _items[3] withColor: 0xFF1FB714]; // green
		[ThemeInternal copyMask: _items[8] to: _items[4] withColor: 0xFF0000D3]; // blue
		[ThemeInternal copyMask: _items[8] to: _items[5] withColor: 0xFF4700A5]; // purple
		[ThemeInternal copyMask: _items[8] to: _items[6] withColor: 0xFFF20884]; // magenta
		[ThemeInternal copyMask: _items[8] to: _items[7] withColor: 0xFF562C05]; // brown
		[ThemeInternal copyMask: _items[8] to: _items[8] withColor: 0xFF02ABEA]; // cyan
	}

	return self;
}

-(VOID) dealloc
{
	LONG i;
	for (i = 0; i < 9; i++)
	{
		if (_items[i])
			FreeMem(_items[i], itemWidth * itemHeight * sizeof(ULONG));
	}
}

-(VOID) drawItem: (LONG)type on: (struct RastPort *)rp left: (ULONG)x top: (ULONG)y width: (LONG)w height: (LONG)h alpha: (ULONG)a
{
	ScalePixelArrayAlpha(_items[type], itemWidth, itemHeight, itemWidth << 2, rp, x, y, w, h, a);
}

+(APTR) createCircleMaskIn: (ULONG *)dst
{
	const LONG rasterSize = 96;
	PLANEPTR plane;

	if ((plane = AllocRaster(rasterSize, rasterSize)))
	{
		struct BitMap *bm;

		if ((bm = AllocBitMap(itemWidth, itemHeight, 16, BMF_CLEAR, NULL)))
		{
			struct RastPort rp;
			struct AreaInfo areaInfo;
			struct TmpRas tmpRas;
			UBYTE areaBuffer[2 * 5];

			InitRastPort(&rp);
			rp.BitMap = bm;

			InitArea(&areaInfo, areaBuffer, 2);
			rp.AreaInfo = &areaInfo;

			InitTmpRas(&tmpRas, plane, RASSIZE(rasterSize, rasterSize));
			rp.TmpRas = &tmpRas;

			SetAPen(&rp, 0);
			AreaCircle(&rp, itemWidth / 2, itemHeight / 2, itemWidth / 2 - 1); // yes, all of that just for this call and we still have to change the color manually :-D
			AreaEnd(&rp);

			ReadPixelArray(dst, 0, 0, itemWidth << 2, &rp, 0, 0, itemWidth, itemHeight, RECTFMT_ARGB);

			FreeBitMap(bm);
		}
		FreeRaster(plane, rasterSize, rasterSize);
	}

	return dst;
}

+(VOID) copyMask: (ULONG *)src to: (ULONG *)dst withColor: (LONG)c
{
	LONG i = 0;

	for (i = 0; i < itemWidth * itemHeight; i++)
	{
		if (src[i] & 0x00FFFFFF)
			dst[i] = c;
		else
			dst[i] = 0UL;
	}
}

@end
