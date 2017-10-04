#import <AVFoundation/AVFoundation.h>
#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[])
{
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
    }
    return 0;
}
