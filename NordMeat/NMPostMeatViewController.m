//
//  NMPostMeatViewController.m
//  NordMeat
//
//  Created by Marcus Ramberg on 17.01.14.
//  Copyright (c) 2014 Nordaaker AS. All rights reserved.
//

#import "NMPostMeatViewController.h"



@interface NMPostMeatViewController ()
@property (retain,nonatomic) AVCaptureSession *session;

@end

@implementation NMPostMeatViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
  self.view=[[UIView alloc] initWithFrame: CGRectMake(0, 10, 320, 500)];
  self.view.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
  //[UIColor colorWithRed:0.918 green:0.486 blue:0.659 alpha:0.9500];
  [self setupCaptureSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupCaptureSession
{
  NSError *error = nil;
  
  // Create the session
  AVCaptureSession *session = [[AVCaptureSession alloc] init];
  
  // Configure the session to produce lower resolution video frames, if your
  // processing algorithm can cope. We'll specify medium quality for the
  // chosen device.
  session.sessionPreset = AVCaptureSessionPresetMedium;
  
  // Find a suitable AVCaptureDevice
  AVCaptureDevice *device = [AVCaptureDevice
                             defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  // Create a device input with the device and add it to the session.
  AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                      error:&error];
  if (!input) {
    // Handling the error appropriately.
    return;
  }
  [session addInput:input];
  
  // Create a VideoDataOutput and add it to the session
  AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
  [session addOutput:output];
  
  // Configure your output.
  dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
  [output setSampleBufferDelegate:self queue:queue];
  
  // Specify the pixel format
  output.videoSettings =
  [NSDictionary dictionaryWithObject:
   [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                              forKey:(id)kCVPixelBufferPixelFormatTypeKey];
  
  
  // If you wish to cap the frame rate to a known value, such as 15 fps, set
  // minFrameDuration.
  output.minFrameDuration = CMTimeMake(1, 5);
  
  // Start the session running to start the flow of data
  [session startRunning];
  
  // Assign session to an ivar.
  [self setSession:session];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
  // Create a UIImage from the sample buffer data
  UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
  
  
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
  // Get a CMSampleBuffer's Core Video image buffer for the media data
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  // Lock the base address of the pixel buffer
  CVPixelBufferLockBaseAddress(imageBuffer, 0);
  
  // Get the number of bytes per row for the pixel buffer
  void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
  
  // Get the number of bytes per row for the pixel buffer
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
  // Get the pixel buffer width and height
  size_t width = CVPixelBufferGetWidth(imageBuffer);
  size_t height = CVPixelBufferGetHeight(imageBuffer);
  
  // Create a device-dependent RGB color space
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  // Create a bitmap graphics context with the sample buffer data
  CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                               bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
  // Create a Quartz image from the pixel data in the bitmap graphics context
  CGImageRef quartzImage = CGBitmapContextCreateImage(context);
  // Unlock the pixel buffer
  CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  
  // Free up the context and color space
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  
  // Create an image object from the Quartz image
  UIImage *image = [UIImage imageWithCGImage:quartzImage];
  
  // Release the Quartz image
  CGImageRelease(quartzImage);
  
  return (image);
}

@end
