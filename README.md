# SLVideo
**一款通过AVPlayer自定制的视频播放器**

 
* **AVPlayer**：视频播放器，控制视频的播放，暂停等

* **AVPlayerItem**：视频资源的管理者

* **AVURLAsset**：视频资源

```
SLVideoView *video = [[SLVideoView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width) url:@"http://7xrpiy.com1.z0.glb.clouddn.com/video%2F1.mp4"];

//video.delegate = self;
[self.view addSubview:video];
```