/*
 * Quartz Help Library
 * QuartzHelpLibrary.m
 *
 * Copyright (c) Yuichi YOSHIDA, 11/04/20
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi Yoshida" nor the names of its contributors may be u
 * sed to endorse or promote products derived from this software without specific prior 
 * written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "QuartzHelpLibrary.h"

@interface UIImage(pixel)

- (NSData*)PNGRepresentaion;
- (NSData*)JPEGRepresentaion;
- (NSData*)JPEGRepresentaionWithCompressionQuality:(float)compressionQuality;

@end

typedef enum {
	ReadImage8bit,
	ReadImage16bitSkipLast,
	ReadImage16bitSkipFirst,
	ReadImage24bit,
	ReadImage32bitSkipLast,
	ReadImage32bitSkipFirst,
}ReadImageType;

#pragma mark -
#pragma mark Load image file

CGImageRef CGImageCreateWithPNGorJPEGFilePath(CFStringRef filePath) {
	CGImageRef outputImage = NULL;
	
	CGDataProviderRef providerRef = CGDataProviderCreateWithFilename([(NSString*)filePath UTF8String]);
	
	if (outputImage == NULL)
		outputImage = CGImageCreateWithPNGDataProvider(providerRef, NULL, NO, 0);
	
	if (outputImage == NULL)
		outputImage = CGImageCreateWithJPEGDataProvider(providerRef, NULL, NO, 0);
	
	CGDataProviderRelease(providerRef);
	
	return outputImage;
}

#pragma mark -
#pragma mark Dump CGImage information

void CGImageDumpImageInformation(CGImageRef imageRef) {
	CGImageDumpImageAttribute(imageRef);
	CGImageDumpAlphaInformation(imageRef);
	CGImageDumpBitmapInformation(imageRef);
}

void CGImageDumpImageAttribute(CGImageRef imageRef) {
	size_t width = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);
	size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
	size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
	size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
	
	printf("width              = %d\n", (int)width);
	printf("height             = %d\n", (int)height);
	printf("bits per component = %d\n", (int)bitsPerComponent);
	printf("bits per pixel     = %d\n", (int)bitsPerPixel);
	printf("bytes per pixel    = %d\n", (int)bitsPerPixel/8);
	printf("bytes per row      = %d\n", (int)bytesPerRow);
}

void CGImageDumpAlphaInformation(CGImageRef imageRef) {
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	// alpha information
	switch(alphaInfo) {
		case kCGImageAlphaNone:
			printf("Alpha Info         = kCGImageAlphaNone\n");
			break;
		case kCGImageAlphaPremultipliedLast:
			printf("Alpha Info         = kCGImageAlphaPremultipliedLast\n");
			break;
		case kCGImageAlphaPremultipliedFirst:
			printf("Alpha Info         = kCGImageAlphaPremultipliedFirst\n");
			break;
		case kCGImageAlphaLast:
			printf("Alpha Info         = kCGImageAlphaLast\n");
			break;
		case kCGImageAlphaFirst:
			printf("Alpha Info         = kCGImageAlphaFirst\n");
			break;
		case kCGImageAlphaNoneSkipLast:
			printf("Alpha Info         = kCGImageAlphaNoneSkipLast\n");
			break;
		case kCGImageAlphaNoneSkipFirst:
			printf("Alpha Info         = kCGImageAlphaNoneSkipFirst\n");
			break;
		default:
			printf("Alpha Info         = Error unknown\n");
			break;
	}
}

void CGImageDumpBitmapInformation(CGImageRef imageRef) {
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGBitmapInfo byteOrderInfo = (bitmapInfo & kCGBitmapByteOrderMask);
	
	// special case
	if (bitmapInfo == kCGBitmapFloatComponents) {
		printf("Bitmap Info        = kCGBitmapFloatComponents\n");
		printf("Alpha Info         = ?\n");
		return;
	}
	
	// bitmap information
	switch(byteOrderInfo) {
		case kCGBitmapByteOrderMask:
			printf("Bitmap Info        = kCGBitmapByteOrderMask\n");
			break;
		case kCGBitmapByteOrderDefault:
			printf("Bitmap Info        = kCGBitmapByteOrderDefault\n");
			break;
		case kCGBitmapByteOrder16Little:
			printf("Bitmap Info        = kCGBitmapByteOrder16Little\n");
			break;
		case kCGBitmapByteOrder32Little:
			printf("Bitmap Info        = kCGBitmapByteOrder32Little\n");
			break;
		case kCGBitmapByteOrder16Big:
			printf("Bitmap Info        = kCGBitmapByteOrder16Big\n");
			break;
		case kCGBitmapByteOrder32Big:
			printf("Bitmap Info        = kCGBitmapByteOrder32Big\n");
			break;
		default:
			printf("Bitmap Info        = Error unknown\n");
			break;
	}
}

#pragma mark - Convert RGB to Y
int getYFromRGB(int r, int g, int b) {
	int  y =
	  ( ( 306 * (int)r + 512 ) >> 10 )
	+ ( ( 601 * (int)g + 512 ) >> 10 )
	+ ( ( 117 * (int)b + 512 ) >> 10 );
	if ( y < 0x00 )  y = 0x00;
	if ( y > 0xFF )  y = 0xFF;
	return  y;
}

#pragma mark -
#pragma mark Read pixel from CGImage

void _CGCreate8bitPixelBufferWithImage(CGImageRef imageRef, unsigned char **pixel, int *width, int *height, int *bytesPerPixel, QH_PIXEL_TYPE pType) {
	CGImageAlphaInfo bitmapAlphaInfo = CGImageGetBitmapInfo(imageRef) & kCGBitmapAlphaInfoMask;
	size_t inputImageBytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
	
	// save image info
	*width = CGImageGetWidth(imageRef);
	*height = CGImageGetHeight(imageRef);
	*pixel = (unsigned char*)malloc(sizeof(unsigned char) * (*width) * (*height));
	*bytesPerPixel = 1;
	
	// source image data
	CGDataProviderRef inputImageProvider = CGImageGetDataProvider(imageRef);
	CFDataRef data = CGDataProviderCopyData(inputImageProvider);
	unsigned char *sourceImagePixelData = (unsigned char *) CFDataGetBytePtr(data);
	size_t bytesPerRowSourceImage = CGImageGetBytesPerRow(imageRef);
	size_t bytesPerRowOutputImage = *width * QH_BYTES_PER_PIXEL_8BIT;
	CGBitmapInfo byteOrderInfo = (CGImageGetBitmapInfo(imageRef) & kCGBitmapByteOrderMask);
	
	switch(inputImageBytesPerPixel) {
		case QH_BYTES_PER_PIXEL_8BIT:
			{
				// open color table
				CGColorSpaceRef space = CGImageGetColorSpace(imageRef);
				
				if (CGColorSpaceGetModel(space) == kCGColorSpaceModelIndexed) {
					int tableCount = CGColorSpaceGetColorTableCount(space);
					unsigned char* table = (unsigned char* )malloc(tableCount * 3 * sizeof(unsigned char));
					CGColorSpaceGetColorTable(space, table);
					
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							int index =  sourceImagePixelData[offset];
							int k = (table[index * 3 + 0]>>2)
							+ (table[index * 3 + 1]>>1)
							+ (table[index * 3 + 2]>>2);
							
							(*pixel)[y * bytesPerRowOutputImage + x] = k;
						}
					}
					free(table);
				}
				else {
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							(*pixel)[y * bytesPerRowOutputImage + x] = sourceImagePixelData[offset];
						}
					}
				}
			}
			break;
		case QH_BYTES_PER_PIXEL_16BIT:
			// first alpha
			if (bitmapAlphaInfo == kCGImageAlphaFirst || bitmapAlphaInfo == kCGImageAlphaNoneSkipFirst || bitmapAlphaInfo == kCGImageAlphaPremultipliedFirst) {
				if (byteOrderInfo == kCGBitmapByteOrder16Little || byteOrderInfo == kCGBitmapByteOrder16Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian AY
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 1;
							(*pixel)[y * bytesPerRowOutputImage + x] = sourceImagePixelData[offset];
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder16Big) {
					// big endian YA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 0;
							(*pixel)[y * bytesPerRowOutputImage + x] = sourceImagePixelData[offset];
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			// last alpha
			else if (bitmapAlphaInfo == kCGImageAlphaLast || bitmapAlphaInfo == kCGImageAlphaNoneSkipLast || bitmapAlphaInfo == kCGImageAlphaPremultipliedLast) {
				if (byteOrderInfo == kCGBitmapByteOrder16Little || byteOrderInfo == kCGBitmapByteOrder16Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian YA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 0;
							(*pixel)[y * bytesPerRowOutputImage + x] = sourceImagePixelData[offset];
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder16Big) {
					// big endian AY
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 1;
							(*pixel)[y * bytesPerRowOutputImage + x] = sourceImagePixelData[offset];
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			break;
		case QH_BYTES_PER_PIXEL_24BIT:
			// maybe, there are not any following caces.
			// little endian?
			for (int y = 0; y < *height; y++) {
				for (int x = 0; x < *width; x++) {
					int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
					int k = (sourceImagePixelData[offset + 0]>>2)
					+ (sourceImagePixelData[offset + 1]>>1)
					+ (sourceImagePixelData[offset + 2]>>2);
					(*pixel)[y * bytesPerRowOutputImage + x] = k;
				}
			}
			break;
		case QH_BYTES_PER_PIXEL_32BIT:
			// first alpha
			if (bitmapAlphaInfo == kCGImageAlphaFirst || bitmapAlphaInfo == kCGImageAlphaNoneSkipFirst || bitmapAlphaInfo == kCGImageAlphaPremultipliedFirst) {
				if (byteOrderInfo == kCGBitmapByteOrder32Little || byteOrderInfo == kCGBitmapByteOrder32Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian ARGB
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							int k = (sourceImagePixelData[offset + 1]>>2)
							+ (sourceImagePixelData[offset + 2]>>1)
							+ (sourceImagePixelData[offset + 3]>>2);
							(*pixel)[y * bytesPerRowOutputImage + x] = k;
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder32Big) {
					// big endian BGRA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							int k = (sourceImagePixelData[offset + 2]>>2)
							+ (sourceImagePixelData[offset + 1]>>1)
							+ (sourceImagePixelData[offset + 0]>>2);
							(*pixel)[y * bytesPerRowOutputImage + x] = k;
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			
			// last alpha
			else if (bitmapAlphaInfo == kCGImageAlphaLast || bitmapAlphaInfo == kCGImageAlphaNoneSkipLast || bitmapAlphaInfo == kCGImageAlphaPremultipliedLast) {
				if (byteOrderInfo == kCGBitmapByteOrder32Little || byteOrderInfo == kCGBitmapByteOrder32Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian RGBA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							int k = (sourceImagePixelData[offset + 0]>>2)
							+ (sourceImagePixelData[offset + 1]>>1)
							+ (sourceImagePixelData[offset + 2]>>2);
							(*pixel)[y * bytesPerRowOutputImage + x] = k;
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder32Big) {
					// big endian BGRA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							
							int k = getYFromRGB(sourceImagePixelData[offset + 2], sourceImagePixelData[offset + 1], sourceImagePixelData[offset]);
							
							/*
							int k = (sourceImagePixelData[offset + 3]>>2)
							+ (sourceImagePixelData[offset + 2]>>1)
							+ (sourceImagePixelData[offset + 1]>>2);
							*/
							(*pixel)[y * bytesPerRowOutputImage + x] = k;
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			break;
		default:
			goto LOAD_EXCEPTION;
			break;
	}
	CFRelease(data);
	return;
LOAD_EXCEPTION:
	printf("Error\n");
	free(*pixel);
	*width = 0;
	*height = 0;
	*bytesPerPixel = 0;
	*pixel = NULL;
	CFRelease(data);
	return;
}

void _CGCreate24bitPixelBufferWithImage(CGImageRef imageRef, unsigned char **pixel, int *width, int *height, int *bytesPerPixel, QH_PIXEL_TYPE pType) {
	CGImageAlphaInfo bitmapAlphaInfo = CGImageGetBitmapInfo(imageRef) & kCGBitmapAlphaInfoMask;
	size_t inputImageBytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
	
	// save image info
	*width = CGImageGetWidth(imageRef);
	*height = CGImageGetHeight(imageRef);
	*bytesPerPixel = QH_BYTES_PER_PIXEL_24BIT;
	*pixel = (unsigned char*)malloc(sizeof(unsigned char) * (*width) * (*height) * (*bytesPerPixel));
	
	// source image data
	CGDataProviderRef inputImageProvider = CGImageGetDataProvider(imageRef);
	CFDataRef data = CGDataProviderCopyData(inputImageProvider);
	unsigned char *sourceImagePixelData = (unsigned char *) CFDataGetBytePtr(data);
	size_t bytesPerRowSourceImage = CGImageGetBytesPerRow(imageRef);
	size_t bytesPerRowOutputImage = *width * (*bytesPerPixel);
	CGBitmapInfo byteOrderInfo = (CGImageGetBitmapInfo(imageRef) & kCGBitmapByteOrderMask);
	
	switch(inputImageBytesPerPixel) {
		case QH_BYTES_PER_PIXEL_8BIT:
		{
			// open color table
			CGColorSpaceRef space = CGImageGetColorSpace(imageRef);
			
			if (CGColorSpaceGetModel(space) != kCGColorSpaceModelIndexed) {
				goto LOAD_EXCEPTION;
			}
			
			int tableCount = CGColorSpaceGetColorTableCount(space);
			unsigned char* table = (unsigned char* )malloc(tableCount * (*bytesPerPixel) * sizeof(unsigned char));
			CGColorSpaceGetColorTable(space, table);
			
			for (int y = 0; y < *height; y++) {
				for (int x = 0; x < *width; x++) {
					int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
					int index =  sourceImagePixelData[offset];
					
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = table[index * 3 + 0];
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = table[index * 3 + 1];
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = table[index * 3 + 2];
				}
			}
			free(table);
		}
			break;
		case QH_BYTES_PER_PIXEL_16BIT:
			// first alpha
			if (bitmapAlphaInfo == kCGImageAlphaFirst || bitmapAlphaInfo == kCGImageAlphaNoneSkipFirst || bitmapAlphaInfo == kCGImageAlphaPremultipliedFirst) {
				if (byteOrderInfo == kCGBitmapByteOrder16Little || byteOrderInfo == kCGBitmapByteOrder16Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian AY
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 1;
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset];
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder16Big) {
					// big endian YA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 0;
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset];
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			// last alpha
			else if (bitmapAlphaInfo == kCGImageAlphaLast || bitmapAlphaInfo == kCGImageAlphaNoneSkipLast || bitmapAlphaInfo == kCGImageAlphaPremultipliedLast) {
				if (byteOrderInfo == kCGBitmapByteOrder16Little || byteOrderInfo == kCGBitmapByteOrder16Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian YA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 0;
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset];
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder16Big) {
					// big endian AY
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 1;
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset];
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			break;
		case QH_BYTES_PER_PIXEL_24BIT:
			// maybe, there are not any following caces.
			// little endian?
			for (int y = 0; y < *height; y++) {
				for (int x = 0; x < *width; x++) {
					int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
					
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset + 0];
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset + 1];
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset + 2];
				}
			}
			break;
		case QH_BYTES_PER_PIXEL_32BIT:
			// first alpha
			if (bitmapAlphaInfo == kCGImageAlphaFirst || bitmapAlphaInfo == kCGImageAlphaNoneSkipFirst || bitmapAlphaInfo == kCGImageAlphaPremultipliedFirst) {
				if (byteOrderInfo == kCGBitmapByteOrder32Little || byteOrderInfo == kCGBitmapByteOrder32Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian BGRA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset + 2];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset + 1];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset + 0];
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder32Big) {
					// big endian ARGB
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset + 1];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset + 2];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset + 3];
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			
			// last alpha
			else if (bitmapAlphaInfo == kCGImageAlphaLast || bitmapAlphaInfo == kCGImageAlphaNoneSkipLast || bitmapAlphaInfo == kCGImageAlphaPremultipliedLast) {
				if (byteOrderInfo == kCGBitmapByteOrder32Little || byteOrderInfo == kCGBitmapByteOrder32Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian RGBA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset + 0];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset + 1];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset + 2];
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder32Big) {
					// big endian BGRA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset + 2];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset + 1];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset + 0];
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			break;
		default:
			goto LOAD_EXCEPTION;
			break;
	}
	CFRelease(data);
	return;
LOAD_EXCEPTION:
	printf("Error\n");
	free(*pixel);
	*width = 0;
	*height = 0;
	*bytesPerPixel = 0;
	*pixel = NULL;
	CFRelease(data);
	return;
}

void _CGCreate32bitPixelBufferWithImage(CGImageRef imageRef, unsigned char **pixel, int *width, int *height, int *bytesPerPixel, QH_PIXEL_TYPE pType) {
	CGImageAlphaInfo bitmapAlphaInfo = CGImageGetBitmapInfo(imageRef) & kCGBitmapAlphaInfoMask;
	size_t inputImageBytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
	
	// save image info
	*width = CGImageGetWidth(imageRef);
	*height = CGImageGetHeight(imageRef);
	*bytesPerPixel = QH_BYTES_PER_PIXEL_32BIT;
	*pixel = (unsigned char*)malloc(sizeof(unsigned char) * (*width) * (*height) * (*bytesPerPixel));
	
	// source image data
	CGDataProviderRef inputImageProvider = CGImageGetDataProvider(imageRef);
	CFDataRef data = CGDataProviderCopyData(inputImageProvider);
	unsigned char *sourceImagePixelData = (unsigned char *) CFDataGetBytePtr(data);
	size_t bytesPerRowSourceImage = CGImageGetBytesPerRow(imageRef);
	size_t bytesPerRowOutputImage = *width * (*bytesPerPixel);
	CGBitmapInfo byteOrderInfo = (CGImageGetBitmapInfo(imageRef) & kCGBitmapByteOrderMask);
	
	switch(inputImageBytesPerPixel) {
		case QH_BYTES_PER_PIXEL_8BIT:
		{
			// open color table
			CGColorSpaceRef space = CGImageGetColorSpace(imageRef);
			
			if (CGColorSpaceGetModel(space) != kCGColorSpaceModelIndexed) {
				goto LOAD_EXCEPTION;
			}
			
			int tableCount = CGColorSpaceGetColorTableCount(space);
			unsigned char* table = (unsigned char* )malloc(tableCount * (*bytesPerPixel) * sizeof(unsigned char));
			CGColorSpaceGetColorTable(space, table);
			
			for (int y = 0; y < *height; y++) {
				for (int x = 0; x < *width; x++) {
					int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
					int index =  sourceImagePixelData[offset];
					
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = table[index * 3 + 0];
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = table[index * 3 + 1];
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = table[index * 3 + 2];
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 3] = DEFAULT_ALPHA_VALUE;
				}
			}
			free(table);
		}
			break;
		case QH_BYTES_PER_PIXEL_16BIT:
			// first alpha
			if (bitmapAlphaInfo == kCGImageAlphaFirst || bitmapAlphaInfo == kCGImageAlphaNoneSkipFirst || bitmapAlphaInfo == kCGImageAlphaPremultipliedFirst) {
				if (byteOrderInfo == kCGBitmapByteOrder16Little || byteOrderInfo == kCGBitmapByteOrder16Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian AY
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 1;
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 3] = sourceImagePixelData[offset - 1];
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder16Big) {
					// big endian YA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 0;
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 3] = sourceImagePixelData[offset + 1];
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			// last alpha
			else if (bitmapAlphaInfo == kCGImageAlphaLast || bitmapAlphaInfo == kCGImageAlphaNoneSkipLast || bitmapAlphaInfo == kCGImageAlphaPremultipliedLast) {
				if (byteOrderInfo == kCGBitmapByteOrder16Little || byteOrderInfo == kCGBitmapByteOrder16Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian YA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 0;
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 3] = sourceImagePixelData[offset + 1];
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder16Big) {
					// big endian AY
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel + 1;
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 3] = sourceImagePixelData[offset - 1];
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			break;
		case QH_BYTES_PER_PIXEL_24BIT:
			// maybe, there are not any following caces.
			// little endian?
			for (int y = 0; y < *height; y++) {
				for (int x = 0; x < *width; x++) {
					int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
					
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset + 0];
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset + 1];
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset + 2];
					(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 3] = DEFAULT_ALPHA_VALUE;
				}
			}
			break;
		case QH_BYTES_PER_PIXEL_32BIT:
			// first alpha
			if (bitmapAlphaInfo == kCGImageAlphaFirst || bitmapAlphaInfo == kCGImageAlphaNoneSkipFirst || bitmapAlphaInfo == kCGImageAlphaPremultipliedFirst) {
				if (byteOrderInfo == kCGBitmapByteOrder32Little || byteOrderInfo == kCGBitmapByteOrder32Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian BGRA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset + 1];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset + 2];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset + 3];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 3] = sourceImagePixelData[offset + 0];
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder32Big) {
					// big endian ARGB
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset + 2];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset + 1];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset + 0];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 3] = sourceImagePixelData[offset + 3];
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			
			// last alpha
			else if (bitmapAlphaInfo == kCGImageAlphaLast || bitmapAlphaInfo == kCGImageAlphaNoneSkipLast || bitmapAlphaInfo == kCGImageAlphaPremultipliedLast) {
				if (byteOrderInfo == kCGBitmapByteOrder32Little || byteOrderInfo == kCGBitmapByteOrder32Host || byteOrderInfo == kCGBitmapByteOrderDefault) {
					// little endian RGBA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset + 0];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset + 1];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset + 2];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 3] = sourceImagePixelData[offset + 3];
						}
					}
				}
				else if (byteOrderInfo == kCGBitmapByteOrder32Big) {
					// big endian -> BGRA
					for (int y = 0; y < *height; y++) {
						for (int x = 0; x < *width; x++) {
							int offset = y * bytesPerRowSourceImage + x * inputImageBytesPerPixel;
							
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 0] = sourceImagePixelData[offset + 2];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 1] = sourceImagePixelData[offset + 1];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 2] = sourceImagePixelData[offset + 0];
							(*pixel)[y * bytesPerRowOutputImage + x * (*bytesPerPixel) + 3] = sourceImagePixelData[offset + 3];
						}
					}
				}
				else
					goto LOAD_EXCEPTION;
			}
			break;
		default:
			goto LOAD_EXCEPTION;
			break;
	}
	
	CFRelease(data);
	
	return;
LOAD_EXCEPTION:
	printf("Error\n");
	free(*pixel);
	*width = 0;
	*height = 0;
	*bytesPerPixel = 0;
	*pixel = NULL;
	CFRelease(data);
	return;
}

void CGCreatePixelBufferWithImage(CGImageRef imageRef, unsigned char **pixel, int *width, int *height, int *bytesPerPixel, QH_PIXEL_TYPE pType) {
	size_t inputImageBytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
	
	switch(pType) {
		case QH_PIXEL_GRAYSCALE:
			_CGCreate8bitPixelBufferWithImage(imageRef, pixel, width, height, bytesPerPixel, pType);
			break;
		case QH_PIXEL_COLOR:
			_CGCreate24bitPixelBufferWithImage(imageRef, pixel, width, height, bytesPerPixel, pType);
			break;
		case QH_PIXEL_ANYCOLOR:
			if (inputImageBytesPerPixel == QH_BYTES_PER_PIXEL_8BIT) {
				_CGCreate8bitPixelBufferWithImage(imageRef, pixel, width, height, bytesPerPixel, pType);
			}
			else if (inputImageBytesPerPixel == QH_BYTES_PER_PIXEL_16BIT) {
				// 8 + alpha
				_CGCreate8bitPixelBufferWithImage(imageRef, pixel, width, height, bytesPerPixel, pType);
			}
			else if (inputImageBytesPerPixel == QH_BYTES_PER_PIXEL_24BIT) {
				// 24
				_CGCreate24bitPixelBufferWithImage(imageRef, pixel, width, height, bytesPerPixel, pType);
			}
			else if (inputImageBytesPerPixel == QH_BYTES_PER_PIXEL_32BIT) {
				// 32
				_CGCreate32bitPixelBufferWithImage(imageRef, pixel, width, height, bytesPerPixel, pType);
			}
			else {
				printf("Error\n");
			}
			break;
		default:
			printf("Error\n");
			break;
	}
}

#pragma mark -
#pragma mark Creating CGImage

CGImageRef CGImageGrayColorCreateWithGrayPixelBuffer(unsigned char *pixel, int width, int height) {
	CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(pixel, width, height, 8, width, grayColorSpace, kCGImageAlphaNone);
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGColorSpaceRelease(grayColorSpace);
	return image;
}

CGImageRef CGImageRGBColorCreateWithGrayPixelBuffer(unsigned char *pixel, int width, int height) {
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	
	unsigned char *rgbPixel = (unsigned char*)malloc(sizeof(unsigned char) * width * height * 4);
	
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			rgbPixel[y * width * 4 + 4 * x + 0] = pixel[y * width + x + 0];
			rgbPixel[y * width * 4 + 4 * x + 1] = pixel[y * width + x + 0];
			rgbPixel[y * width * 4 + 4 * x + 2] = pixel[y * width + x + 0];
			rgbPixel[y * width * 4 + 4 * x + 3] = 255;
		}
	}
	
	CGContextRef context = CGBitmapContextCreate(rgbPixel, width, height, 8, width * 4, rgbColorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGColorSpaceRelease(rgbColorSpace);
	free(rgbPixel);
	return image;
}

CGImageRef CGImageRGBColorCreateWithRGBPixelBuffer(unsigned char *pixel, int width, int height) {
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	
	unsigned char *rgbPixel = (unsigned char*)malloc(sizeof(unsigned char) * width * height * 4);
	
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			rgbPixel[y * width * 4 + 4 * x + 0] = pixel[y * width * 3 + 3 * x + 0];
			rgbPixel[y * width * 4 + 4 * x + 1] = pixel[y * width * 3 + 3 * x + 1];
			rgbPixel[y * width * 4 + 4 * x + 2] = pixel[y * width * 3 + 3 * x + 2];
		}
	}
	
	CGContextRef context = CGBitmapContextCreate(rgbPixel, width, height, 8, width * 4, rgbColorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGColorSpaceRelease(rgbColorSpace);
	free(rgbPixel);
	return image;
}

CGImageRef CGImageRGBAColorCreateWithRGBPixelBuffer(unsigned char *pixel, int width, int height) {
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	
	unsigned char *rgbPixel = (unsigned char*)malloc(sizeof(unsigned char) * width * height * 4);
	
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			rgbPixel[y * width * 4 + 4 * x + 0] = pixel[y * width * 3 + 3 * x + 0];
			rgbPixel[y * width * 4 + 4 * x + 1] = pixel[y * width * 3 + 3 * x + 1];
			rgbPixel[y * width * 4 + 4 * x + 2] = pixel[y * width * 3 + 3 * x + 2];
			rgbPixel[y * width * 4 + 4 * x + 3] = 255;
		}
	}
	
	CGContextRef context = CGBitmapContextCreate(rgbPixel, width, height, 8, width * 4, rgbColorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGColorSpaceRelease(rgbColorSpace);
	free(rgbPixel);
	return image;
}

#pragma mark -
#pragma mark Convert CGImage to image file binary

NSData* CGImageGetPNGPresentation(CGImageRef imageRef) {
	UIImage *uiimage = [UIImage imageWithCGImage:imageRef];
	return [uiimage PNGRepresentaion];
}

NSData* CGImageGetJPEGPresentation(CGImageRef imageRef) {
	UIImage *uiimage = [UIImage imageWithCGImage:imageRef];
	return [uiimage JPEGRepresentaion];
}

#pragma mark -
#pragma mark UIImage QuartzHelpLibrary category implementation

@implementation UIImage(pixel)

- (NSData*)PNGRepresentaion {
	return UIImagePNGRepresentation(self);
}

- (NSData*)JPEGRepresentaion {
	return [self JPEGRepresentaionWithCompressionQuality:1];
}

- (NSData*)JPEGRepresentaionWithCompressionQuality:(float)compressionQuality {
	return UIImageJPEGRepresentation(self, compressionQuality);
}

@end