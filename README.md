# iOS-Video_Record
Recording Video implemented by AVFoundation Framework

## Branch

1. **master**
   An video capturing camera APP
2. **Filter-beta**
   For beta feature - realtime filtered (XRay) previewing and recording, based on master branch.

### Using Framework:

- AVFoundation
- AssetsLibrary
- AVKit
- Core Video
- Core Image 



## Flow

Containing camera session flow in <code>CameraSessionController</code>

1. Create AVCaptureSession (property)
2. create AVAssetWriter and bind with filePath and fileType(MP4)
3. Get Video / Audio Device (property)
4. Add AVdeviceInput into AVCaptureSession, and set video setting(MP4, AAC)
5. Add and set AVCaptureOutput to \<SampleBufferDelegate\>
6. remember to rotate by detecting AVCaptureVideoOrientationPortrait
7. init AVCaptureVideoPreviewLayer with created AVCaptureSession(1)

**ViewWillAppear** 

8. Start AVCaptureSession  running -> previewing -> output stream to previewLayer(UI)

**After user pressing record button**

9. handle state by isRecording (record button pressed) and isStartWrite
10. if start recording, start assetWriter
11. get CMSampleBufferRef from <code>captureOutput didOutputSampleBuffer</code>

**\*\*Optional**

a. process SampleBuffer to CIImage

b. Apply CIFilter to CCIImage 

c. show added filter result

d. turn CIImage back to SampleBuffer then save



12. if isRecording, record data by AVAssetWriterInput appendSampleBuffer

13. released assetWriter after all procedure done





UI allocate in <code>CameraViewController</code> bind controller with <code><CameraSessionViewSource> delegate</code>

- AVCaptureVideoPreviewLayer - for showing preview result
  Setup PreviewLayer after AVdevice init

- UIButton with action (record / album / cancel)

  -> call CameraSessionController flow

<code>VideoPreviewController</code>

- AVPlayerLayer for showing video result



## Future Work

1. More detailed UI 
   - Album video chooser (UITableView)
   - Filter option (UIPicker)
   - Recording time (NSTimer)
2. Switch front / back camera (AVCaptureDevice)
3. Focus / Exposure on touch (UI -> onTouchPoint->setFocusPointOfInterest)
4. Landscape mode handle

## Known issue

1. **master**

   a. Multi-thread AVAssetwriter markasfinished stop issue (removed)

2. **Filter-beta**

   a. memory issue - crash when processing too many CV frames

   b. buffer size incorrect - not familiar with CIImage and CMSampleBufferRef, size incorrect after implement filter on input stream currently.

   



