/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <ob/OBFramework.h>
#import <intuition/classusr.h>
#import <classes/multimedia/video.h>
#import <classes/multimedia/streams.h>
#import <proto/multimedia.h>
#import <proto/cybergraphics.h>
#import <proto/intuition.h>
#import "globaldefines.h"
#import "picture.h"

@implementation Picture
{
	UBYTE *_data;
}

@synthesize width;
@synthesize height;

-(id) initFromFile: (NSString *)path
{
	if((self = [super init]))
	{
		Boopsiobject *pic;

		pic = MediaNewObjectTags(
			MMA_StreamType, (IPTR)"file.stream",
			MMA_StreamName, (IPTR)path.cString,
			MMA_MediaType, MMT_PICTURE,
		TAG_END);

		if (pic)
		{
			ULONG buffer_length;

			self.height = MediaGetPort(pic, 0, MMA_Video_Height);
			self.width = MediaGetPort(pic, 0, MMA_Video_Width);

			buffer_length = (self.height * self.width) << 4;

			if ((_data = (BYTE*)MediaAllocVec(buffer_length)))
				DoMethod(pic, MMM_Pull, 0, (IPTR) _data, buffer_length);
			else
				self = nil;

			DisposeObject(pic);
		}
		else
			self = nil;
	}

	return self;
}

-(VOID) draw: (struct RastPort *)rp left: (LONG)x top: (LONG)y width: (LONG)w height: (LONG)h alpha: (LONG)alpha
{
	ScalePixelArrayAlpha(_data, self.width, self.height, self.width << 2, rp, x, y, w, h, alpha);
}

-(VOID) drawPart: (struct RastPort *)rp offset: (LONG)o srcWidth: (LONG)srcW srcHeight: (LONG)srcH left: (LONG)x top: (LONG)y width: (LONG)w height: (LONG)h alpha: (LONG)alpha
{
	ScalePixelArrayAlpha(_data + o, srcW, srcH, srcW << 2, rp, x, y, w, h, alpha);
}

-(VOID) dealloc
{
	if (_data)
		MediaFreeVec(_data);
}

@end
