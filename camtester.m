#import <AVFoundation/AVFoundation.h>
#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        // Set the video output to store frame in BGRA (It is supposed to be faster)
        NSDictionary* videoSettings = [NSDictionary
          dictionaryWithObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
          forKey: (id)kCVPixelBufferPixelFormatTypeKey];
        AVCaptureSession* captureSession = [AVCaptureSession new];
        NSError *error = nil;

        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            NSLog(@"%@", [device localizedName]);
            for (AVCaptureDeviceFormat* format in [device formats]) {
                CMVideoFormatDescriptionRef fmt = (CMVideoFormatDescriptionRef)[format formatDescription];
                if (CMFormatDescriptionGetMediaType(fmt) == kCMMediaType_Video) {
                    CMVideoDimensions dim = CMVideoFormatDescriptionGetDimensions(fmt);
                    FourCharCode fourCC = CMFormatDescriptionGetMediaSubType(fmt);
                    NSLog(@"\t%d x %d\t%@", dim.width, dim.height, NSFileTypeForHFSTypeCode(fourCC));
                }
            }
            AVCaptureDeviceInput* captureInput = [AVCaptureDeviceInput deviceInputWithDevice: device error:&error];
            if (error) {
                NSLog(@"deviceInputWithDevice failed with error %@", [error localizedDescription]);
                continue;
            }
            AVCaptureVideoDataOutput* captureOutput = [AVCaptureVideoDataOutput new];
            [captureOutput setVideoSettings: videoSettings];

            if ([captureSession canAddInput: captureInput]) {
                [captureSession addInput: captureInput];
            }
            if ([captureSession canAddOutput: captureOutput]) {
                [captureSession addOutput: captureOutput];
            }
            
            NSArray* presets = [NSArray arrayWithObjects:
                                    AVCaptureSessionPreset320x240,
                                    AVCaptureSessionPreset640x480,
                                    AVCaptureSessionPreset1280x720,
                                    AVCaptureSessionPresetHigh,
                                    AVCaptureSessionPresetMedium,
                                    AVCaptureSessionPresetLow,
                                    AVCaptureSessionPresetPhoto,
                                nil];
            for (NSString* preset in presets) {
                [captureSession beginConfiguration];
                if ([captureSession canSetSessionPreset: preset]) {
                    [captureSession setSessionPreset: preset];
                } else {
                    [captureSession commitConfiguration];
                    NSLog(@"\t%@ not available", preset);
                    continue;
                }
                [captureSession commitConfiguration];
                NSLog(@"\t%@ activeFormat: %@", [captureSession sessionPreset], [[captureInput device] activeFormat]);

            }

            for (AVCaptureInput *input1 in captureSession.inputs) {
                [captureSession removeInput: input1];
            }
            for (AVCaptureOutput *output1 in captureSession.outputs) {
                [captureSession removeOutput: output1];
            }
        }
    }
    return 0;
}
