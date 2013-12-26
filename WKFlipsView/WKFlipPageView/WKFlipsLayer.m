//
//  WKFlipsLayer.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-13.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKFlipsLayer.h"
#import "WKFlipsView.h"
#pragma makr - _WKFlipsLayerView
@interface _WKFlipsLayerView(){
    
}

@end
@implementation _WKFlipsLayerView
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self){
        self.userInteractionEnabled=NO;
    }
    return self;
}
-(id)initWithFlipsView:(WKFlipsView *)flipsView{
    self=[super initWithFrame:flipsView.bounds];
    if (self){
        self.userInteractionEnabled=NO;
        self.flipsView=flipsView;
        //[self buildLayers];
    }
    return self;
}
-(void)dealloc{
    [super dealloc];
}
-(int)numbersOfLayers{
    return [self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView]*2;
}
-(void)buildLayers{
    ///先删除现有的layer
    for (CALayer *layer in self.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
    ///layer的总数比页面数要多1
    int layersNumber=[self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView]*2;
//    int layersNumber=1;
    ///在重新创建新的layer
    CGRect layerFrame=CGRectMake(0.0f, self.bounds.size.height/2, self.bounds.size.width, self.bounds.size.height/2);
    for (int a=0; a<layersNumber; a++) {
        WKFlipsLayer* layer=[[[WKFlipsLayer alloc]initWithFrame:layerFrame] autorelease];
        [self.layer insertSublayer:layer atIndex:0];
//        [self.layer addSublayer:layer];
//        layer.frontLayer.contents=(id)[UIImage imageNamed:@"weather-default-bg"].CGImage;
//        layer.backLayer.contents=(id)[UIImage imageNamed:@"weather-default-bg"].CGImage;
        [layer drawWords:[NSString stringWithFormat:@"layer %d front",(layersNumber-a-1)] onPosition:0];
        [layer drawWords:[NSString stringWithFormat:@"layer %d back",(layersNumber-a-1)] onPosition:1];
        layer.rotateDegree=0.0f;
        ///在当前页面之前的页面全部翻页到上面
//        if (a<1){
//            [layer setRotateDegree:180.0f];
//        }
    }
//    [self flipToPageIndex:1 completion:^(BOOL completion) {
//        
//    }];
//    WKFlipsLayer* firstLayer=self.layer.sublayers[5];
//    [firstLayer setRotateDegree:182.0f duration:3.0f afterDelay:3.0f completion:^{
//        
//    }];
//    WKFlipsLayer* secondLayer=self.layer.sublayers[4];
//    [secondLayer setRotateDegree:181.0f duration:3.0f afterDelay:3.5f completion:^{
//        
//    }];
//    WKFlipsLayer* thirdLayer=self.layer.sublayers[3];
//    [thirdLayer setRotateDegree:180.0f duration:3.0f afterDelay:3.8f completion:^{
//        
//    }];
//    [firstLayer setRotateDegreeV2:182.0f afterDelay:3.0f completion:^{
//        WKFlipsLayer* secondLayer=self.layer.sublayers[4];
//        [secondLayer setRotateDegreeV2:181.0f afterDelay:1.0f completion:^{
//            WKFlipsLayer* thirdLayer=self.layer.sublayers[3];
//            [thirdLayer setRotateDegreeV2:180.0f afterDelay:1.0f completion:^{
//                
//            }];
//        }];
//        
//    }];
//    CGFloat delay=0.0f;
//    CGFloat duration=3.0f;
//    for (int layerIndex=layersNumber-1; layerIndex>0; layerIndex--) {
//        delay+=0.3f;
//        WKFlipsLayer* flipLayer=self.layer.sublayers[layerIndex];
//        CGFloat rotateDegree=[self calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:1];
//        [flipLayer setRotateDegree:rotateDegree duration:duration afterDelay:delay completion:^{
//            
//        }];
//    }
    [self flipToPageIndex:3 completion:^(BOOL completed) {
        [self flipToPageIndex:1 completion:^(BOOL completed) {
            [self flipToPageIndex:2 completion:^(BOOL completed) {
                
            }];
        }];
    }];
}
#pragma mark - flips
-(void)flipToPageIndex:(int)pageIndex{
    ///往前翻页，也就是把上半部分的页面往下面翻
    if (pageIndex<self.flipsView.pageIndex){
        for (int layerIndex=self.flipsView.pageIndex; layerIndex<pageIndex; layerIndex--) {
            WKFlipsLayer* flipLayer=self.layer.sublayers[layerIndex];
            flipLayer.rotateDegree=0.0f;
        }
    }
    else if (pageIndex>self.flipsView.pageIndex){ ///往后面翻页,也就是把下半部分的往上面翻
        for (int layerIndex=self.flipsView.pageIndex+1; layerIndex<=pageIndex; layerIndex++) {
            WKFlipsLayer* flipLayer=self.layer.sublayers[layerIndex];
            flipLayer.rotateDegree=180.0f;
        }
    }
}
-(void)flipToPageIndex:(int)pageIndex completion:(void (^)(BOOL completed))completionBlock{
    
    ///往前翻页，也就是把上半部分往下面翻页
    CGFloat durationLong=3.0f;
    CGFloat durationShort=0.1f;
    CGFloat delay=0.0f;
    int layersNumber=[self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView]*2;
    __block int complete_hits=0;
    if (pageIndex<self.flipsView.pageIndex){
        for (int layerIndex=0; layerIndex<layersNumber; layerIndex++) {
            delay+=0.3f;
            CGFloat rotateDegree=[self calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:pageIndex];
            NSLog(@"layerIndex:%d,%f",layerIndex,rotateDegree);
            WKFlipsLayer *flipLayer=self.layer.sublayers[layerIndex];
            ///翻转比较大的角度,用的时间比较多
            if (fabsf(rotateDegree-flipLayer.rotateDegree)>=60.0f){
                [flipLayer setRotateDegree:rotateDegree duration:durationLong afterDelay:delay completion:^{
                    if (++complete_hits>=layersNumber){
                        NSLog(@"flip completed");
                        self.flipsView.pageIndex=pageIndex;
                        completionBlock(YES);
                    }
                }];
            }
            else{   ///翻转比较小的角度，用的时间更少
                [flipLayer setRotateDegree:rotateDegree duration:durationShort afterDelay:delay completion:^{
                    if (++complete_hits>=layersNumber){
                        NSLog(@"flip completed");
                        self.flipsView.pageIndex=pageIndex;
                        completionBlock(YES);
                    }
                }];
            }
            
        }
    }
    else{
        for (int layerIndex=layersNumber-1; layerIndex>=0; layerIndex--) {
            delay+=0.3f;
            CGFloat rotateDegree=[self calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:pageIndex];
            NSLog(@"layerIndex:%d,%f",layerIndex,rotateDegree);
            WKFlipsLayer* flipLayer=self.layer.sublayers[layerIndex];
            if (fabs(rotateDegree-flipLayer.rotateDegree)>=60.0f){
                [flipLayer setRotateDegree:rotateDegree duration:durationLong afterDelay:delay completion:^{
                    if (++complete_hits>=layersNumber){
                        NSLog(@"flip completed");
                        self.flipsView.pageIndex=pageIndex;
                        completionBlock(YES);
                    }
                }];
            }
            else{
                [flipLayer setRotateDegree:rotateDegree duration:durationShort afterDelay:delay completion:^{
                    if (++complete_hits>=layersNumber){
                        NSLog(@"flip completed");
                        self.flipsView.pageIndex=pageIndex;
                        completionBlock(YES);
                    }
                }];
            }
        }
    }
}
///当翻页到一个pageIndex,为每个layer计算角度
-(CGFloat)calculateRotateDegreeForLayerIndex:(int)layerIndex toTargetPageIndex:(int)pageIndex{
    int layersNumber=[self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView]*2;
    int stopLayerIndexAtTop=layersNumber-1-pageIndex;
    int stopLayerIndexAtBottom=stopLayerIndexAtTop-1;
    CGFloat spaceRotate=1.0f;
    if (layerIndex>=stopLayerIndexAtTop){
        return 180.0f+(layerIndex-stopLayerIndexAtTop)*spaceRotate;
    }
    else if (layerIndex<=stopLayerIndexAtBottom){
        return 0.0f-(stopLayerIndexAtBottom-layerIndex)*spaceRotate;
    }
    else{
        return 0.0f;
    }

}
#pragma mark - Drag
-(void)dragBegan{
    NSLog(@"dragBegan");
}
-(void)dragEnded{
    NSLog(@"dragEnded");
}
-(void)draggingWithTranslation:(CGPoint)translation{
    NSLog(@"dragging");
}
@end

#pragma mark - WKFlipsLayer
@interface WKFlipsLayer(){
    
}
@end
@implementation WKFlipsLayer
-(id)initWithFrame:(CGRect)frame{
    self=[super init];
    if (self){
        self.frame=frame;
        self.doubleSided=YES;
        self.anchorPoint=CGPointMake(0.5, 0.0f);
        self.position=CGPointMake(self.position.x,
                                  self.position.y-self.frame.size.height/2);
        _frontLayer=[[CALayer alloc]init];
        _frontLayer.frame=self.bounds;
        _frontLayer.backgroundColor=[UIColor grayColor].CGColor;
        _frontLayer.doubleSided=NO;
        _frontLayer.name=@"frontLayer";
        
        _backLayer=[[CALayer alloc]init];
        _backLayer.frame=self.bounds;
        _backLayer.backgroundColor=[UIColor whiteColor].CGColor;
        _backLayer.doubleSided=YES;
        _backLayer.name=@"backLayer";
        _backLayer.transform=WKFlipCATransform3DPerspectSimpleWithRotate(180.0f);
        
        [self insertSublayer:_frontLayer atIndex:0];
        [self insertSublayer:_backLayer atIndex:0];
    }
    return self;
}
-(void)dealloc{
    [_frontLayer release];
    [_backLayer release];
    [super dealloc];
}
-(void)drawWords:(NSString *)words onPosition:(int)position{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity); // 2-1
    CGContextTranslateCTM(context, 0, self.frame.size.height); // 3-1
    CGContextScaleCTM(context, 1.0, -1.0); // 4-1
    ///Text
    NSMutableAttributedString* attributeString=[[[NSMutableAttributedString alloc]initWithString:words] autorelease];
    CTFontRef fontRefBold = CTFontCreateWithName((CFStringRef)@"Helvetica-Bold", 20.0f, NULL); // 3-3  字体
    NSDictionary *attrDictionaryBold = [NSDictionary dictionaryWithObjectsAndKeys:(id)fontRefBold, (NSString *)kCTFontAttributeName, (id)[[UIColor blackColor] CGColor], (NSString *)(kCTForegroundColorAttributeName), nil]; // 4-3，另一个格式，用来设置部分文字的样式
    [attributeString addAttributes:attrDictionaryBold range:NSMakeRange(0,attributeString.length)]; // 5-3 一段范围内的文字格式，添加这个样式（只对应指定长度内）
    CFRelease(fontRefBold); // 6-3
    CGMutablePathRef path = CGPathCreateMutable(); // 5-2
    CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)); // 6-2 绘制的区域
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString); // 7-2，设置text frame的样式和内容
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributeString length]), path, NULL); // 8-2 创建text frame
    CFRelease(framesetter); // 9-2
    CFRelease(path); // 10-2
    CTFrameDraw(theFrame, context); // 11-2 绘制这个区域
    CFRelease(theFrame); // 12-2
    UIImage* imageOutput=UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
    CALayer *wordsLayer=[[[CALayer alloc]init] autorelease];
    wordsLayer.frame=self.bounds;
    wordsLayer.contents=(id)imageOutput.CGImage;
    if (position==0){
        [self.frontLayer addSublayer:wordsLayer];
    }
    else{
        [self.backLayer addSublayer:wordsLayer];
    }
}
#pragma mark - rotateDegree
-(void)setRotateDegree:(CGFloat)rotateDegree{
    _rotateDegree=rotateDegree;
    self.transform=WKFlipCATransform3DPerspectSimpleWithRotate(rotateDegree);
}
-(CGFloat)rotateDegree{
    return _rotateDegree;
}

-(void)setRotateDegree:(CGFloat)rotateDegree duration:(CGFloat)duration afterDelay:(NSTimeInterval)delay completion:(void (^)())completion{
    CATransform3D fromTrnasform=self.transform;
    CGFloat halfRotateDegree=self.rotateDegree+(rotateDegree-self.rotateDegree)/2.0f;
    CATransform3D halfTransform=WKFlipCATransform3DPerspectSimpleWithRotate(halfRotateDegree);
    CATransform3D toTransform=WKFlipCATransform3DPerspectSimpleWithRotate(rotateDegree);
    NSLog(@"%f,%f,%f",self.rotateDegree,halfRotateDegree,rotateDegree);
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
    CAKeyframeAnimation* flipAnimation=[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    flipAnimation.delegate=self;
    flipAnimation.duration=duration;
    flipAnimation.beginTime=[self convertTime:CACurrentMediaTime() fromLayer:nil]+delay;
    flipAnimation.removedOnCompletion=NO;
    flipAnimation.fillMode=kCAFillModeForwards;
    flipAnimation.keyTimes=@[@0.0f,@0.5f,@1.0f];
    flipAnimation.values=@[[NSValue valueWithCATransform3D:fromTrnasform],[NSValue valueWithCATransform3D:halfTransform],
                           [NSValue valueWithCATransform3D:toTransform]];
    [CATransaction setCompletionBlock:^{
        [self removeAllAnimations];
        self.rotateDegree=rotateDegree;
        completion();
    }];
    [self addAnimation:flipAnimation forKey:@"animation-flip-continues-down"];
    [CATransaction commit];
}
@end