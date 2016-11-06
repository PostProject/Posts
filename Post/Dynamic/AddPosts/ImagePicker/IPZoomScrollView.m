//
//  IPZoomScrollView.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPZoomScrollView.h"
#import "IPAssetModel.h"
#import "IPTapDetectImageView.h"
#import "IPTapDetectView.h"
#import "IPAssetManager.h"
#import "IPickerViewController.h"

@interface IPickerViewController ()

- (void)getImagesForAlbumModel:(IPAlbumModel *)albumModel;
- (void)getAspectPhotoWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getFullScreenImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getThumibImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

@end
@interface IPZoomScrollView ()<UIScrollViewDelegate,IPTapDetectViewDelegate,IPTapDetectImageViewDelegate>

/**背景view*/
@property (nonatomic, strong)IPTapDetectView *tapView;

/**图像view*/
@property (nonatomic, strong)IPTapDetectImageView *photoImageView;



@end

@implementation IPZoomScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initilization];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initilization];
    }
    return self;
}
- (void)initilization{
    // Tap view for background
    _tapView = [[IPTapDetectView alloc] initWithFrame:self.bounds];
    _tapView.tapDelegate = self;
    _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tapView.backgroundColor = [UIColor clearColor];
    [self addSubview:_tapView];
    
    // Image view
    _photoImageView = [[IPTapDetectImageView alloc] initWithFrame:CGRectZero];
    _photoImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _photoImageView.tapDelegate = self;
    _photoImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_photoImageView];
    
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

}
- (void)prepareForReuse {
    _imageModel = nil;
    _photoImageView.hidden = YES;
    _photoImageView.image = nil;
    
}

- (void)setImageModel:(IPAssetModel *)imageModel{
    
    if (_imageModel != imageModel && imageModel != nil) {
        _imageModel = imageModel;
        
        [self displayImage];
    }
}
- (void)displayImageWithFullScreenImage{
    
    [self.ipVc getFullScreenImageWithAsset:_imageModel photoWidth:CGSizeMake(self.bounds.size.width, 0) completion:^(UIImage *img, NSDictionary *info) {
        if (img) {
            if (!CGSizeEqualToSize(img.size, _photoImageView.image.size)) {
                // Set image
                _photoImageView.image = img;
                _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
                // Setup photo frame
                CGRect photoImageViewFrame;
                photoImageViewFrame.origin = CGPointZero;
                
                CGFloat width = self.bounds.size.width;
                
                CGFloat height = width *  _imageModel.thumbnailScale;
                
                photoImageViewFrame.size = CGSizeMake(width, height);
                
                _photoImageView.frame = photoImageViewFrame;
                
                self.contentSize = photoImageViewFrame.size;
                
                // Set zoom to minimum zoom
                [self setMaxMinZoomScalesForCurrentBounds];
                [self setNeedsLayout];
            }
            
        }
        
        
    }];
}

// Get and display image
- (void)displayImage {
    if (_imageModel && _photoImageView.image == nil) {
        
        
        
        // Get image from browser as it handles ordering of fetching
        [self.ipVc getAspectPhotoWithAsset:_imageModel photoWidth:CGSizeMake(self.bounds.size.width, 0) completion:^(UIImage *img, NSDictionary *info) {
            if (img) {
                
                // Reset
                self.maximumZoomScale = 1;
                self.minimumZoomScale = 1;
                self.zoomScale = 1;
                
                 _photoImageView.contentMode = UIViewContentModeScaleToFill;
                // Set image
                _photoImageView.image = img;
                _photoImageView.hidden = NO;
                
                // Setup photo frame
                CGRect photoImageViewFrame;
                photoImageViewFrame.origin = CGPointZero;
                CGFloat width = self.bounds.size.width;
                
                 CGFloat height = width * img.size.height /img.size.width;
                _imageModel.thumbnailScale = img.size.height /img.size.width;
                photoImageViewFrame.size = CGSizeMake(width, height);
                
                _photoImageView.frame = photoImageViewFrame;
                
            }
            [self setNeedsLayout];
        }];
    
    }
}
//设置当前情况下,最大和最小伸缩比
- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail if no image
    if (_photoImageView.image == nil) return;
    
    // Reset position
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // Calculate Max
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    // Set min/max zoom
    self.maximumZoomScale = maxScale;
    
    // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
//    self.scrollEnabled = NO;
    
}

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_photoImageView ) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _photoImageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
        }
    }
    return zoomScale;
}



#pragma mark - Layout

- (void)layoutSubviews {
   
    // Update tap view frame
    _tapView.frame = self.bounds;
   
    
    // Super
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
        _photoImageView.frame = frameToCenter;
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
     self.scrollEnabled = YES; // reset
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollEnabled = YES; // reset
   
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    
    
    
    // Zoom
    if (self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScaleWithMinScale]) {
        
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
        
    } else {
        
        // Zoom in to twice the size
        CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        
    }
    
}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleSingleTap:CGPointMake(touchX, touchY)];
}
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}

@end
