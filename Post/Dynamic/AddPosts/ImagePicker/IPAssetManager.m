//
//  IPAssetManager.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPAssetManager.h"

#import<AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "IPAlbumModel.h"
#import "IPAlbumView.h"
#import "IPImageCell.h"
#import "IPPrivateDefine.h"

@interface IPAssetManager ()

/**数据模型暂存数组*/
@property (nonatomic, strong)NSMutableArray *tempArray;

/**全部的数据*/
@property (nonatomic, strong)NSMutableArray *allImageModel;

/**缓存路径*/
@property (nonatomic, copy)NSString *captureDirectory;

/**用于倒序数据--数组*/
@property (nonatomic, strong)NSMutableArray *reverserArray;

@end

@implementation IPAssetManager

static IPAssetManager *manager;

+ (instancetype)defaultAssetManager{
//    if (manager == nil) {
        IPAssetManager *manager = [[IPAssetManager alloc]init];
//    }
    
    return manager;
}
+ (void)freeAssetManger{
//    if (manager) {
//        [manager clearData];
//        manager = nil;
//    }
    
}
- (void)clearData{
    [self.allImageModel removeAllObjects];
    [self.albumArr removeAllObjects];
    [self.currentPhotosArr removeAllObjects];
}
- (void)dealloc{
     
    IPLog(@"IPAssetManager--dealloc");
}


#pragma mark 获取相册的所有图片
- (void)reloadImagesFromLibrary
{
    [self clearData];
    if (iOS8Later) {
        [self getAllAlbumsIOS8];
    }else{
        [self getAllAlbumsIOS7];
        
    }
    
}
- (void)performDelegateWithSuccess:(BOOL)success{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (iOS8Later) {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusDenied) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageUserDeny:)]) {
                    [self.delegate loadImageUserDeny:self];
                }
            }
            else {
                if (success == NO) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageOccurError:)]) {
                        [self.delegate loadImageOccurError:self];
                    }
                }else {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageDataFinish:)]) {
                        [self.delegate loadImageDataFinish:self];
                    }
                }
                
                
            }
        }else {
            ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
            if (status == ALAuthorizationStatusDenied) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageUserDeny:)]) {
                    [self.delegate loadImageUserDeny:self];
                }
            }else {
                if (success == NO) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageOccurError:)]) {
                        [self.delegate loadImageOccurError:self];
                    }
                }else {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageDataFinish:)]) {
                        [self.delegate loadImageDataFinish:self];
                    }
                }
                
                
            }
        }
        
        
        
    });
}
- (void)getImagesForAlbumModel:(IPAlbumModel *)albumModel{
    if (iOS8Later) {
        if (self.allImageModel.count == 0) {
            [self.allImageModel addObjectsFromArray:self.currentPhotosArr];
        }
        [self.currentPhotosArr removeAllObjects];
        [self.tempArray removeAllObjects];
        [self getImageAssetsFromFetchResult:albumModel.groupAsset];
    }else{
        [self getImagesWithGroupModel:albumModel];
    }
    
}
#pragma mark - ios6_ios7 -
- (void)getAllAlbumsIOS7{
    //关闭监听共享照片流产生的频繁通知信息
    [ALAssetsLibrary disableSharedPhotoStreamsSupport];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
                [weakSelf performDelegateWithSuccess:NO];
                
            };
            
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result!=NULL) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        
                        IPAssetModel *imgModel = [[IPAssetModel alloc]init];
                        imgModel.creatDate = [result valueForProperty:ALAssetPropertyDate];
                        imgModel.location = [result valueForProperty:ALAssetPropertyLocation];
                        imgModel.assetType = IPAssetModelMediaTypePhoto;
                        imgModel.asset = result;
                        
                        imgModel.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                        
                        [weakSelf.reverserArray addObject:imgModel];
                        
                    }
                }else {
                    IPLog(@"遍历相册完毕");
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
                
                if (group == nil)
                {
                    
                    weakSelf.currentAlbumModel.isSelected = YES;
                    [weakSelf.defaultLibrary groupForURL:weakSelf.currentAlbumModel.groupURL resultBlock:^(ALAssetsGroup *group) {
                        [group enumerateAssetsUsingBlock:groupEnumerAtion];
                        
                        weakSelf.currentPhotosArr = [NSMutableArray arrayWithArray:[[weakSelf.reverserArray reverseObjectEnumerator] allObjects]];
                        [weakSelf.reverserArray removeAllObjects];
                        
                        [weakSelf performDelegateWithSuccess:YES];
                    } failureBlock:^(NSError *error) {
                        [weakSelf performDelegateWithSuccess:NO];
                    }];
                    
                }
                
                if (group!=nil) {
                    
                    IPAlbumModel *model = [[IPAlbumModel alloc]init];
                    model.posterImage = [UIImage imageWithCGImage:group.posterImage];
                    model.imageCount = group.numberOfAssets;
                    if (model.imageCount > 0) {
                        if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"]) {
                            model.albumName =@"相机胶卷";
                        }else if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Recently Added"]){
                            model.albumName =@"最近添加";
                        }
                        else if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"My Photo Stream"]){
                            model.albumName =@"我的照片流";
                        }
                        else if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"All Photos"]){
                            model.albumName =@"所有照片";
                        }
                        else {
                            model.albumName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                        }
                        IPLog(@"%@",(NSString *)[group valueForProperty:ALAssetsGroupPropertyName]);
                        model.groupURL = (NSURL *)[group valueForProperty:ALAssetsGroupPropertyURL];
                        [weakSelf.albumArr addObject:model];
                        if (weakSelf.currentAlbumModel == nil || weakSelf.currentAlbumModel.imageCount < model.imageCount) {
                            
                            weakSelf.currentAlbumModel = model;
                        }
                    }
                    
                    
                }
                
            };
            
            [weakSelf.defaultLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                                   usingBlock:libraryGroupsEnumeration
                                                 failureBlock:failureblock];
        }
        
    });
}
- (void)getImagesWithGroupModel:(IPAlbumModel *)groupModel{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result!=NULL) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        IPAssetModel *model = [[IPAssetModel alloc]init];
                        model.assetType = IPAssetModelMediaTypePhoto;
                        model.asset = result;
                        model.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                        [weakSelf.allImageModel enumerateObjectsUsingBlock:^(IPAssetModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj.assetUrl isEqual:model.assetUrl]) {
                                //此处逻辑要注意..当之前的那张图片已经存在过了,就加到当前数组中
                                [weakSelf.tempArray addObject:obj];
                                model.isSame = YES;
                            }
                        }];
                        if (model.isSame == NO) {
                            [weakSelf.tempArray addObject:model];
                        }
                        
                    }
                }else {
                    [weakSelf.reverserArray addObjectsFromArray:weakSelf.tempArray];
                    
                    weakSelf.currentPhotosArr = [NSMutableArray arrayWithArray:[[weakSelf.reverserArray reverseObjectEnumerator] allObjects]];
                    [weakSelf.reverserArray removeAllObjects];
                    
                    [self performDelegateWithSuccess:YES];
                    [weakSelf.tempArray removeAllObjects];
                }
                
            };
            [self.defaultLibrary groupForURL:groupModel.groupURL resultBlock:^(ALAssetsGroup *group) {
                if (weakSelf.allImageModel.count == 0) {
                    [weakSelf.allImageModel addObjectsFromArray:weakSelf.currentPhotosArr];
                }
                [weakSelf.currentPhotosArr removeAllObjects];
                [group enumerateAssetsUsingBlock:groupEnumerAtion];
                
            } failureBlock:^(NSError *error) {
                [self performDelegateWithSuccess:NO];
            }];
        }
        
    });
}
#pragma mark - lazy -
- (ALAssetsLibrary *)defaultLibrary{
    if (_defaultLibrary == nil) {
        _defaultLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _defaultLibrary;
}
- (NSMutableArray *)albumArr{
    if (_albumArr == nil) {
        _albumArr = [NSMutableArray array];
    }
    return _albumArr;
}
- (NSMutableArray *)currentPhotosArr
{
    if (_currentPhotosArr == nil) {
        _currentPhotosArr = [NSMutableArray array];
    }
    return _currentPhotosArr;
}
- (NSMutableArray *)tempArray{
    if (_tempArray == nil) {
        _tempArray = [NSMutableArray array];
    }
    return _tempArray;
}
- (NSMutableArray *)allImageModel{
    if (_allImageModel == nil) {
        _allImageModel = [NSMutableArray array];
    }
    return _allImageModel;
}
- (NSMutableArray *)reverserArray{
    if (_reverserArray == nil) {
        _reverserArray = [NSMutableArray array];
    }
    return _reverserArray;
}
#pragma mark - iOS8 -
/**
 *  遍历图库,获得所有相册数据
 */
- (void)getAllAlbumsIOS8{
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied ) {
        [self performDelegateWithSuccess:NO];
        return;
    }
    PHAssetCollectionSubtype smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded ;
    // For iOS 9, We need to show ScreenShots Album && SelfPortraits Album
    if (iOS9Later) {
        smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumScreenshots | PHAssetCollectionSubtypeSmartAlbumSelfPortraits | PHAssetCollectionSubtypeSmartAlbumFavorites|PHAssetCollectionSubtypeAlbumMyPhotoStream ;
    }
    
    //获取智能相册
    PHFetchOptions *imageOption = [[PHFetchOptions alloc] init];
    imageOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    imageOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum  subtype:smartAlbumSubtype options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        IPLog(@"collection %@",collection.localizedTitle);
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:imageOption];
        if (fetchResult.count < 1) continue;
        if ([collection.localizedTitle containsString:@"Deleted"]) continue;
        
        IPAlbumModel * model = [self modelWithResult:fetchResult name:collection.localizedTitle];
        model.albumIdentifier = collection.localIdentifier;
        [self.albumArr addObject:model];
        if (self.currentAlbumModel == nil || self.currentAlbumModel.imageCount < model.imageCount) {
            
            self.currentAlbumModel = model;
        }
    }
    
    //获取普通相册
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    for (PHAssetCollection *collection in albums) {
        IPLog(@"collection %@",collection.localizedTitle);
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:imageOption];
        
        if (fetchResult.count < 1) continue;
        IPAlbumModel * model = [self modelWithResult:fetchResult name:collection.localizedTitle];
        model.albumIdentifier = collection.localIdentifier;
        [self.albumArr addObject:model];
        if (self.currentAlbumModel == nil || self.currentAlbumModel.imageCount < model.imageCount) {
            
            self.currentAlbumModel = model;
        }
        
    }
    [self getImageAssetsFromFetchResult:self.currentAlbumModel.groupAsset];
    self.currentAlbumModel.isSelected = YES;
    
    
}
/**
 *  生成相册模型数据
 *
 *  @param result 系统模型
 *  @param name   系统相册名称
 *
 *  @return 自定义的相册模型
 */
- (IPAlbumModel *)modelWithResult:(id)result name:(NSString *)name{
    IPAlbumModel *model = [[IPAlbumModel alloc] init];
    model.groupAsset = result;
    model.albumName = [self getNewAlbumName:name];
    [self getPhotoWithAsset:model photoWidth:CGSizeMake(50.0f, 50.0f)];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        model.imageCount = fetchResult.count;
    }
    return model;
}
/**
 *  将英文相册名称转换为中文名称
 *
 *  @param name 英文名
 *
 *  @return 中文名
 */
- (NSString *)getNewAlbumName:(NSString *)name {
    if (iOS8Later) {
        NSString *newName;
        if ([name containsString:@"Roll"])         newName = @"相机胶卷";
        else if ([name containsString:@"Stream"])  newName = @"我的照片流";
        else if ([name containsString:@"Added"])   newName = @"最近添加";
        else if ([name containsString:@"Selfies"]) newName = @"自拍";
        else if ([name containsString:@"shots"])   newName = @"截屏";
        else if ([name containsString:@"Videos"])  newName = @"视频";
        else if ([name containsString:@"Favorites"])  newName = @"个人收藏";
        else if ([name containsString:@"Panoramas"])  newName = @"全景照片";
        else if ([name containsString:@"All Photos"])  newName = @"全部照片";
        else newName = name;
        return newName;
    } else {
        return name;
    }
}
/**
 *  根据一个 相册集合 对象生成对应的 图片模型
 *
 *  @param result 相册集合
 */
- (void)getImageAssetsFromFetchResult:(PHFetchResult *)result{
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        IPAssetModelMediaType type = IPAssetModelMediaTypePhoto;
        if (asset.mediaType == PHAssetMediaTypeImage) {
//            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) type = IPAssetModelMediaTypeLivePhoto;
        }
        
        IPAssetModel *imgModel = [[IPAssetModel alloc]init];
        imgModel.assetType = type;
        imgModel.localIdentiy = asset.localIdentifier;
        imgModel.assetUrl = [NSURL URLWithString:asset.localIdentifier];
        imgModel.asset = asset;
//        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
//        [outputFormatter setLocale:[NSLocale currentLocale]];
//        [outputFormatter setDateFormat:@"yyyy年MM月dd日 HH时mm分ss秒"];
//        NSString *creatDateStr = [outputFormatter stringFromDate:asset.creationDate];
        imgModel.creatDate = asset.creationDate;
        
        imgModel.modityDate = asset.modificationDate;
        
        if (self.allImageModel.count > 0) {
            [self.allImageModel enumerateObjectsUsingBlock:^(IPAssetModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj.localIdentiy isEqualToString:asset.localIdentifier]) {
                    imgModel.isSame = YES;
                    [self.tempArray addObject:obj];
                }
                
            }];
        }
        if (imgModel.isSame == NO) {
            [self.tempArray addObject:imgModel];
        }
        
    }];
    IPAssetModel *model = [[IPAssetModel alloc]init];
    model.assetType = IPAssetModelMediaTypeTakePhoto;
    [self.currentPhotosArr addObject:model];
    [self.currentPhotosArr addObjectsFromArray:self.tempArray];
    [self performDelegateWithSuccess:YES];
}
/**
 *  获取相册的封面图片
 *
 *  @param albumModel 相册模型
 *  @param photoSize  相框尺寸
 */
- (void)getPhotoWithAsset:(IPAlbumModel *)albumModel photoWidth:(CGSize)photoSize{
    PHAsset *phAsset = [albumModel.groupAsset lastObject];
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = photoSize.width * multiple;
    CGFloat pixelHeight = photoSize.height * multiple;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined) {
            albumModel.posterImage = result;
        }
    }];
}

- (void)getAspectPhotoWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    if (iOS8Later) {
        [self ios8_AsyncLoadAspectThumbilImageWithSize:photoSize asset:imageModel completion:completion];
    }else {//ios8之前
        @try {
            ALAsset *asset = (ALAsset *)imageModel.asset;
            UIImage *aspectThumbnail = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
            if (completion) {
                completion(aspectThumbnail,nil);
            }
        }
        @catch (NSException *e) {
            if (completion) {
                completion(nil,nil);
            }
        }
    }
}
- (void)getFullScreenImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    
    if (iOS8Later) {
        [self ios8_AsyncLoadFullScreenImageWithSize:photoSize asset:imageModel completion:completion];
    }else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            @try {
                ALAsset *asset = (ALAsset *)imageModel.asset;
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                CGImageRef iref = [rep fullScreenImage];
                UIImage *fullScreenImage;
                if (iref) {
                    fullScreenImage = [UIImage imageWithCGImage:iref];
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(fullScreenImage,nil);
                    }
                    
                });
            } @catch (NSException *e) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil,nil);
                });
            }
            
        });
    }
    
    
}
- (void)getThumibImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    if(iOS8Later){
        [self ios8_asynLoadThumibImageWithSize:photoSize asset:imageModel completion:completion];
    }else {
        @try {
            ALAsset *asset = (ALAsset *)imageModel.asset;
            UIImage *aspectThumbnail = [UIImage imageWithCGImage:asset.thumbnail];
            if (imageModel.assetType == IPAssetModelMediaTypeVideo) {
                imageModel.VideoThumbail = aspectThumbnail;
            }
            if (completion) {
                completion(aspectThumbnail,nil);
            }
        }
        @catch (NSException *e) {
            if (completion) {
                completion(nil,nil);
            }
        }
        
    }

    
}

#pragma mark - ios8later -
/**
 *  正方形缩略图
 *
 *  @param imageSize 图片size
 *  @param imagModel 图片模型
 */

- (void)ios8_asynLoadThumibImageWithSize:(CGSize)imageSize asset:(IPAssetModel *)imagModel completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    PHAsset *phAsset = (PHAsset *)imagModel.asset;
    
    __block IPAssetModel *tempModel = imagModel;
    //    PHAsset *phAsset = imagModel.imageAsset;
    
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = imageSize.width * multiple;//PHImageManagerMaximumSize
    CGFloat pixelHeight = imageSize.height * multiple;//CGSizeMake(pixelWidth, pixelHeight)
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        IPLog(@"高清缩略图--%@",info);
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (tempModel.assetType == IPAssetModelMediaTypeVideo) {
            tempModel.VideoThumbail = result;
        }
        if (downloadFinined) {
            completion(result,nil);
            
        }else {
            completion(nil,nil);
        }
        
        
    }];
    
    
}
/**
 *  加载高清图
 */
- (void)ios8_AsyncLoadFullScreenImageWithSize:(CGSize)imageSize asset:(IPAssetModel *)imagModel completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    PHAsset *phAsset = (PHAsset *)imagModel.asset;
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//                IPLog(@"高清图--%@",info);
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined) {
            completion(result,nil);
            
        }else {
            completion(nil,nil);
        }
    }];
}
/**
 *  高清预览图
 */
- (void)ios8_AsyncLoadAspectThumbilImageWithSize:(CGSize)imageSize asset:(IPAssetModel *)imagModel completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    PHAsset *phAsset = (PHAsset *)imagModel.asset;
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = imageSize.width * multiple;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        //        IPLog(@"高清缩略图--%@",info);
        // 排除取消，错误，得到低清图三种情况，即已经获取到了低清图
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined) {
            completion(result,nil);
            
        }else {
            completion(nil,nil);
        }
    }];
}

#pragma mark 视频
- (void)reloadVideosFromLibrary{
    
     [self clearData];
    
    if (self.currentPhotosArr.count == 0) {
        IPAssetModel *imgModel = [[IPAssetModel alloc]init];
        imgModel.assetType = IPAssetModelMediaTypeTakeVideo;
        
        [self.currentPhotosArr addObject:imgModel];
    }
    
    
    if (iOS8Later) {
        [self getAllVideosIOS8];
    }else{
        [self getAllVideosIOS7];
        
    }
}
- (void)getAllVideosIOS8{
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied ) {
        [self performDelegateWithSuccess:NO];
        return;
    }
    PHFetchOptions *imageOption = [[PHFetchOptions alloc] init];
    imageOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    imageOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    //获取普通相册albums	PHUnauthorizedFetchResult
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil];
    for (PHAssetCollection *collection in albums) {
        IPLog(@"collection %@",collection.localizedTitle);
        if ([collection.localizedTitle isEqualToString:@"Videos"] || [collection.localizedTitle isEqualToString:@"视频"]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:imageOption];
            IPAlbumModel * model = [[IPAlbumModel alloc]init];
            model.albumName = @"选择视频";
            
            if (self.currentAlbumModel == nil ) {
                self.currentAlbumModel = model;
            }
            
            [self getVideoAssetsFromFetchResult:fetchResult];
        }
    }
    
}
- (void)getAllVideosIOS7{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
                [weakSelf performDelegateWithSuccess:NO];
                
            };
            
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result!=NULL) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                        
                        IPAssetModel *videoModel = [[IPAssetModel alloc]init];
                        
                        videoModel.assetType = IPAssetModelMediaTypeVideo;
                        
                        videoModel.asset = result;
                        NSTimeInterval duration = [[result valueForProperty:ALAssetPropertyDuration] integerValue];
                        videoModel.duration = duration;
                        NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
                        timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
                        videoModel.videoDuration = timeLength;
                        [weakSelf.currentPhotosArr addObject:videoModel];
                        
                    }
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
                
                if (group == nil)
                {
                    if (self.currentAlbumModel == nil) {
                        
                        IPAlbumModel *model = [[IPAlbumModel alloc]init];
                        model.albumName = @"全部视频";
                        weakSelf.currentAlbumModel = model;
                        [weakSelf performDelegateWithSuccess:YES];
                    }
                    
                    
                }
                
                if (group!=nil) {
                    [group enumerateAssetsUsingBlock:groupEnumerAtion];
                }
                
            };
            
            [weakSelf.defaultLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                                   usingBlock:libraryGroupsEnumeration
                                                 failureBlock:failureblock];
        }
    });
    
}
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}
- (void)getVideoAssetsFromFetchResult:(PHFetchResult *)result{
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (asset.mediaSubtypes != PHAssetMediaSubtypeVideoHighFrameRate && asset.mediaSubtypes != PHAssetMediaSubtypeVideoTimelapse) {//慢动作,延时摄影
            IPAssetModelMediaType type = IPAssetModelMediaTypeVideo;
            __block IPAssetModel *videoModel = [[IPAssetModel alloc]init];
            videoModel.assetType = type;
            videoModel.localIdentiy = asset.localIdentifier;
            videoModel.asset = asset;
            if (type == IPAssetModelMediaTypeVideo) {
                [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                    NSString *str = info[@"PHImageFileSandboxExtensionTokenKey"];
                    NSArray *strArr = [str componentsSeparatedByString:@";"];
                    NSString *videoPath = [strArr lastObject];
                    videoModel.assetUrl = [NSURL URLWithString:videoPath];
                }];
                
            }
            
            NSString *timeLength = type == IPAssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",asset.duration] : @"";
            videoModel.duration = asset.duration;
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            videoModel.videoDuration = timeLength;
            [self.currentPhotosArr addObject:videoModel];
            
        }
        
        
        
    }];
    
//    IPLog(@"performDelegateWithSuccess");
    [self performDelegateWithSuccess:YES];
   
}

- (void)compressVideoWithAssetModel:(IPAssetModel *)assetModel CompleteBlock:(functionBlock)block{
    
    if ([assetModel.asset isKindOfClass:[PHAsset class]]) {
        [[PHImageManager defaultManager] requestPlayerItemForVideo:assetModel.asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(playerItem);
            });
            
        }];
    } else if ([assetModel.asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)assetModel.asset;
        ALAssetRepresentation *defaultRepresentation = [alAsset defaultRepresentation];
        NSString *uti = [defaultRepresentation UTI];
        NSURL *videoURL = [[alAsset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
        block(playerItem);
    }
}

- (void)getAspectThumbailWithModel:(IPAssetModel *)model completion:(void (^)(UIImage *, NSDictionary *))completion{
    __block UIImage *img = nil;
    if (iOS8Later) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        PHAsset *phAsset = (PHAsset *)model.asset;
        
        CGFloat pixelWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat pixelHeight = pixelWidth * (9.0/16.0);
        
        [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            img = result;
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            if (downloadFinined) {
                completion(result,nil);
                
            }else {
                completion(nil,nil);
            }
        }];
    }else {
        ALAsset *asset = (ALAsset *)model.asset;
        img = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        completion(img,nil);
    }
    
}
//- (void)compressVideoWithPlayerItem:(AVPlayerItem *)item CompleteBlock:(functionBlock)block
//{
//    
//    NSURL *output = [NSURL fileURLWithPath:[self getTemporayPath:@"_compress.mp4"]];
//    
//    AVAsset *avAsset = item.asset;
//    CMTime assetTime = [avAsset duration];
//    Float64 duration = CMTimeGetSeconds(assetTime);
//    IPLog(@"视频时长 %f\n",duration);
//    
//    AVMutableVideoComposition *avMutableVideoComposition = [self getVideoComposition:avAsset];
//    
//    AVAssetExportSession *avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
//    [avAssetExportSession setVideoComposition:avMutableVideoComposition];
//    [avAssetExportSession setOutputURL:output];
//    if ([avAssetExportSession.supportedFileTypes containsObject:AVFileTypeMPEG4]) {
//        [avAssetExportSession setOutputFileType:AVFileTypeMPEG4];
////        avAssetExportSession.outputFileType = @"com.apple.quicktime-movie";
//        //     [avAssetExportSession setOutputFileType:AVFileTypeQuickTimeMovie];//这句话要是要的话，会出错的。。。
//    }
//    else{
//        [avAssetExportSession setOutputFileType:[avAssetExportSession.supportedFileTypes firstObject]];
//    }
//    [avAssetExportSession setShouldOptimizeForNetworkUse:YES];
//    __block NSDate *beginDate = [NSDate date];
//    [avAssetExportSession exportAsynchronouslyWithCompletionHandler:^(void){
//        
//            if(avAssetExportSession.status == AVAssetExportSessionStatusCompleted){
//                IPLog(@"%f",[[NSDate date] timeIntervalSinceDate:beginDate]);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    block(output);
//                });
//            } else if(avAssetExportSession.status == AVAssetExportSessionStatusFailed){
//                IPLog(@"exporting failed %@",[avAssetExportSession error]);
//            }
//    }];
//    
//}
//-(AVMutableVideoComposition *) getVideoComposition:(AVAsset *)asset
//{
//    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    AVMutableComposition *composition = [AVMutableComposition composition];
//    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
//    CGSize videoSize = videoTrack.naturalSize;
//    BOOL isPortrait_ = [self isVideoPortrait:asset];
//    if(isPortrait_) {
//        IPLog(@"video is portrait ");
//        videoSize = CGSizeMake(videoSize.height, videoSize.width);
//    }
//    composition.naturalSize     = videoSize;
//    videoComposition.renderSize = videoSize;
//    videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
//    
//    AVMutableCompositionTrack *compositionVideoTrack;
//    compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
//    AVMutableVideoCompositionLayerInstruction *layerInst;
//    layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//    [layerInst setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
//    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
//    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
//    videoComposition.instructions = [NSArray arrayWithObject:inst];
//    return videoComposition;
//}
//
//
//-(BOOL) isVideoPortrait:(AVAsset *)asset
//{
//    BOOL isPortrait = FALSE;
//    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
//    if([tracks    count] > 0) {
//        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
//        
//        CGAffineTransform t = videoTrack.preferredTransform;
//        // Portrait
//        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
//        {
//            isPortrait = YES;
//        }
//        // PortraitUpsideDown
//        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
//            
//            isPortrait = YES;
//        }
//        // LandscapeRight
//        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
//        {
//            isPortrait = NO;
//        }
//        // LandscapeLeft
//        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
//        {
//            isPortrait = NO;
//        }
//    }
//    return isPortrait;
//}
//
//
//- (NSString *) getTemporayPath:(NSString *)extension
//{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    
//    if(!self.captureDirectory)
//    {
//        formatter.dateFormat = @"yyyyMMddHHmm";
//        NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        dir = [[dir stringByAppendingPathComponent:@"CompressVideos"]
//               stringByAppendingPathComponent:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]]];
//        
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        BOOL isDir = FALSE;
//        BOOL isDirExist = [fileManager fileExistsAtPath:dir isDirectory:&isDir];
//        
//        if(!(isDirExist && isDir))
//        {
//            BOOL bCreateDir = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
//            if(!bCreateDir){
//                PLog(@"创建文件夹失败");
//                
//            }
//            
//        }
//        
//        self.captureDirectory = dir;
//    }
//    formatter.dateFormat = @"yyyyMMddHHmmsss";
//    NSString *outputPath = [self.captureDirectory stringByAppendingPathComponent:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]]];
//    
//    return [outputPath stringByAppendingString:extension];
//}

//#define KCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
//// 将原始视频的URL转化为NSData数据,写入沙盒
//- (void)videoWithUrl:(NSURL *)url withFileName:(NSString *)fileName
//{
//    
//    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
//    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
//    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if (url) {
//            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
//                ALAssetRepresentation *rep = [asset defaultRepresentation];
//                NSString * videoPath = [KCachesPath stringByAppendingPathComponent:fileName];
//                IPLog(@"%@",videoPath);
//                char const *cvideoPath = [videoPath UTF8String];
//                
//                FILE *file = fopen(cvideoPath, "a+");
//                if (file) {
//                    const int bufferSize = 1024 * 1024;
//                    // 初始化一个1M的buffer
//                    Byte *buffer = (Byte*)malloc(bufferSize);
//                    NSUInteger read = 0, offset = 0, written = 0;
//                    NSError* err = nil;
//                    if (rep.size != 0)
//                    {
//                        do {
//                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
//                            written = fwrite(buffer, sizeof(char), read, file);
//                            offset += read;
//                        } while (read != 0 && !err);//没到结尾，没出错，ok继续
//                    }
//                    // 释放缓冲区，关闭文件
//                    free(buffer);
//                    buffer = NULL;
//                    fclose(file);
//                    file = NULL;
//                }
//            } failureBlock:nil];
//        }
//    });
//}
//- (void)compressVideoWithPlayerItem:(AVPlayerItem *)item CompleteBlock:(functionBlock)block
//{
//    
//    NSURL *output = [NSURL fileURLWithPath:[self getTemporayPath:@"_compress.mp4"]];
//    
//    AVAsset *avAsset = item.asset;
//    CMTime assetTime = [avAsset duration];
//    Float64 duration = CMTimeGetSeconds(assetTime);
//    IPLog(@"视频时长 %f\n",duration);
//    
//    AVMutableComposition *avMutableComposition = [AVMutableComposition composition];
//    
//    AVAssetTrack *avAssetTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    
//    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:avAssetTrack];
//    CGAffineTransform layerTransform = avAssetTrack.preferredTransform;
//    BOOL portrait = [self isVideoPortrait:avAsset];
//    if (portrait) {//竖屏
//        //        [0, 1, -1, 0, 1080, 0]
//        
//        //        IPLog(@"%@",NSStringFromCGAffineTransform(layerTransform));
//        layerTransform = CGAffineTransformMakeTranslation(avAssetTrack.naturalSize.width, 0);
//        ////        IPLog(@"%@",NSStringFromCGAffineTransform(layerTransform));
//        layerTransform = CGAffineTransformScale(layerTransform,-1.0, 1.0);//
//        //        IPLog(@"%@",NSStringFromCGAffineTransform(layerTransform));
//    }else {//横屏
//        
//    }
//    [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
//    
//    //    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [self layerInstructionAfterFixingOrientationForAsset:avAsset forTrack:avAssetTrack atTime:assetTime];
//    AVMutableVideoComposition *avMutableVideoComposition = [[AVMutableVideoComposition alloc]init];
//    // 这个视频大小可以由你自己设置。比如源视频640*480.而你这320*480.最后出来的是320*480这么大的，640多出来的部分就没有了。并非是把图片压缩成那么大了。
//    avMutableVideoComposition.renderSize = avAssetTrack.naturalSize;
//    avMutableVideoComposition.frameDuration = CMTimeMake(1, 24);
//    IPLog(@"natural:width=%f;height:%f",avAssetTrack.naturalSize.width,avAssetTrack.naturalSize.height);
//    
//    AVMutableVideoCompositionInstruction *avMutableVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    
//    [avMutableVideoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, assetTime)];
//    
//    avMutableVideoCompositionInstruction.layerInstructions = @[layerInstruciton];
//    
//    
//    avMutableVideoComposition.instructions = @[avMutableVideoCompositionInstruction];
//    
//    AVAssetExportSession *avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
//    [avAssetExportSession setVideoComposition:avMutableVideoComposition];
//    [avAssetExportSession setOutputURL:output];
//    if ([avAssetExportSession.supportedFileTypes containsObject:AVFileTypeMPEG4]) {
//        [avAssetExportSession setOutputFileType:AVFileTypeMPEG4];
//        //        avAssetExportSession.outputFileType = @"com.apple.quicktime-movie";
//        //     [avAssetExportSession setOutputFileType:AVFileTypeQuickTimeMovie];//这句话要是要的话，会出错的。。。
//    }
//    else{
//        [avAssetExportSession setOutputFileType:[avAssetExportSession.supportedFileTypes firstObject]];
//    }
//    [avAssetExportSession setShouldOptimizeForNetworkUse:YES];
//    
//    [avAssetExportSession exportAsynchronouslyWithCompletionHandler:^(void){
//        
//        if(avAssetExportSession.status == AVAssetExportSessionStatusCompleted){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                block(output);
//            });
//        } else if(avAssetExportSession.status == AVAssetExportSessionStatusFailed){
//            IPLog(@"exporting failed %@",[avAssetExportSession error]);
//        }
//    }];
//    
//}

@end
