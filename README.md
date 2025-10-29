# react-native-nitro-video-metadata

A high-performance React Native library for extracting comprehensive video metadata across iOS, Android, and Web platforms. Built with [Nitro Modules](https://nitro.margelo.com/) for optimal performance.

## Features

- 🎥 **Extract comprehensive video metadata** including duration, dimensions, codec, bitrate, and more
- 🌐 **Cross-platform support** for iOS, Android, and Web
- ⚡ **High performance** using native modules via Nitro Modules
- 📱 **Local and remote videos** support from device storage or URLs
- 🎯 **TypeScript support** with full type definitions
- 📊 **Advanced metadata** including HDR detection, orientation, location data, and audio properties

## Installation

```sh
npm install react-native-nitro-video-metadata react-native-nitro-modules
```

> **Note:** `react-native-nitro-modules` is required as this library relies on [Nitro Modules](https://nitro.margelo.com/).

### Additional Setup

#### iOS

For iOS, you need to install the pods:

```sh
cd ios && pod install
```

#### Android

No additional setup required for Android.

#### Expo

This library works with Expo, but requires [Expo Dev Client](https://docs.expo.dev/develop/development-builds/introduction/) for native module support.

## Usage

### Basic Usage

```typescript
import { getVideoInfoAsync } from 'react-native-nitro-video-metadata';

// Get metadata from a local video file
const videoInfo = await getVideoInfoAsync('file://path/to/video.mp4', {});

console.log('Video duration:', videoInfo.duration);
console.log('Video dimensions:', videoInfo.width, 'x', videoInfo.height);
console.log('Video codec:', videoInfo.codec);
```

### Example with React Component

```typescript
import React, { useState } from 'react';
import { View, Text, Button } from 'react-native';
import { launchImageLibrary } from 'react-native-image-picker';
import { getVideoInfoAsync } from 'react-native-nitro-video-metadata';

export default function VideoMetadataExample() {
  const [videoInfo, setVideoInfo] = useState(null);

  const pickVideo = async () => {
    try {
      const result = await launchImageLibrary({
        mediaType: 'video',
      });

      if (result.assets?.[0]?.uri) {
        const info = await getVideoInfoAsync(result.assets[0].uri, {});
        setVideoInfo(info);
      }
    } catch (error) {
      console.error('Error getting video info:', error);
    }
  };

  return (
    <View style={{ padding: 20 }}>
      <Button title="Pick Video" onPress={pickVideo} />
      {videoInfo && (
        <View>
          <Text>Duration: {videoInfo.duration}s</Text>
          <Text>Resolution: {videoInfo.width}x{videoInfo.height}</Text>
          <Text>Codec: {videoInfo.codec}</Text>
          <Text>FPS: {videoInfo.fps}</Text>
          <Text>Bitrate: {videoInfo.bitRate} bps</Text>
        </View>
      )}
    </View>
  );
}
```

### Remote Video URL

```typescript
// Get metadata from a remote video URL
const videoInfo = await getVideoInfoAsync('https://example.com/video.mp4', {
  headers: {
    Authorization: 'Bearer your-token',
  },
});
```

## API Reference

### `getVideoInfoAsync(source: string, options: VideoInfoOptions): Promise<VideoInfoResult>`

#### Parameters

- `source` (string): The video source URI. Can be:
  - Local file URI: `file://path/to/video.mp4`
  - Remote URL: `https://example.com/video.mp4`
  - Asset URI from camera roll

- `options` (VideoInfoOptions): Configuration options
  - `headers` (Record<string, string>): Optional headers for remote video requests

#### Return Value

Returns a promise that resolves to a `VideoInfoResult` object with the following properties:

| Property             | Type                        | Description                                   | Platform Support                  |
| -------------------- | --------------------------- | --------------------------------------------- | --------------------------------- |
| `duration`           | `number`                    | Duration in seconds (float)                   | All                               |
| `hasAudio`           | `boolean`                   | Whether video has audio track                 | All                               |
| `isHDR`              | `boolean \| null`           | HDR video detection                           | iOS ≥14, Android                  |
| `width`              | `number`                    | Video width in pixels                         | All                               |
| `height`             | `number`                    | Video height in pixels                        | All                               |
| `fps`                | `number`                    | Frame rate (frames per second)                | iOS, Android, Web (except Safari) |
| `bitRate`            | `number`                    | Bit rate in bits per second                   | All                               |
| `fileSize`           | `number`                    | File size in bytes (0 for remote files)       | All                               |
| `codec`              | `string`                    | Video codec                                   | All                               |
| `orientation`        | `string`                    | Video orientation (Portrait, Landscape, etc.) | All                               |
| `naturalOrientation` | `string`                    | Natural orientation without rotation          | All                               |
| `aspectRatio`        | `number`                    | Aspect ratio                                  | All                               |
| `is16_9`             | `boolean`                   | Whether video is 16:9 aspect ratio            | All                               |
| `audioSampleRate`    | `number`                    | Audio sample rate (samples per second)        | All                               |
| `audioChannels`      | `number`                    | Audio channel count                           | All                               |
| `audioCodec`         | `string`                    | Audio codec                                   | All                               |
| `location`           | `VideoLocationType \| null` | GPS location data                             | iOS, Android                      |

#### VideoLocationType

```typescript
type VideoLocationType = {
  latitude: number;
  longitude: number;
  altitude?: number;
};
```

## Platform-Specific Notes

### iOS

- Full metadata support including HDR detection (iOS 14+)
- Location data extraction from video metadata
- Excellent codec and format support

### Android

- Comprehensive metadata extraction
- HDR video detection support
- Location data extraction

### Web

- Basic metadata support (duration, dimensions, codec)
- Limited frame rate detection (not available in Safari)
- File size returns 0 for remote videos

## Error Handling

```typescript
try {
  const videoInfo = await getVideoInfoAsync(videoUri, {});
  // Handle successful result
} catch (error) {
  console.error('Failed to get video metadata:', error);
  // Handle errors:
  // - Invalid video file
  // - Network errors for remote videos
  // - Permission issues
  // - Unsupported video format
}
```

## Common Use Cases

### 1. Video Upload with Metadata

```typescript
const uploadVideoWithMetadata = async (videoUri: string) => {
  const metadata = await getVideoInfoAsync(videoUri, {});

  // Upload video with metadata to your server
  await fetch('/api/upload', {
    method: 'POST',
    body: JSON.stringify({
      videoUri,
      metadata: {
        duration: metadata.duration,
        resolution: `${metadata.width}x${metadata.height}`,
        codec: metadata.codec,
        fileSize: metadata.fileSize,
      },
    }),
  });
};
```

### 2. Video Quality Assessment

```typescript
const assessVideoQuality = (metadata: VideoInfoResult) => {
  const quality = {
    isHD: metadata.width >= 1280 && metadata.height >= 720,
    isHDR: metadata.isHDR === true,
    hasGoodBitrate: metadata.bitRate > 2000000, // 2 Mbps
    hasAudio: metadata.hasAudio,
  };

  return quality;
};
```

### 3. Video Processing Pipeline

```typescript
const processVideo = async (videoUri: string) => {
  const metadata = await getVideoInfoAsync(videoUri, {});

  if (metadata.duration > 300) {
    // 5 minutes
    throw new Error('Video too long');
  }

  if (!metadata.hasAudio) {
    console.warn('Video has no audio track');
  }

  return {
    metadata,
    requiresProcessing: metadata.width > 1920, // Needs downscaling
  };
};
```

## Troubleshooting

### Common Issues

1. **"Module not found" error**
   - Ensure `react-native-nitro-modules` is installed
   - Run `pod install` for iOS
   - Restart Metro bundler

2. **"Invalid video source" error**
   - Verify the video URI is valid and accessible
   - For local files, ensure proper file permissions
   - For remote videos, check network connectivity

3. **Missing metadata on Web**
   - Some metadata (FPS, fileSize for remote videos) may not be available on Web
   - Consider platform-specific fallbacks

4. **Performance issues with large videos**
   - Metadata extraction is fast, but consider using worker threads for very large files
   - Cache metadata results when possible

### Debugging

Enable debug logging to see detailed information:

```typescript
const videoInfo = await getVideoInfoAsync(videoUri, {});
console.log('Video metadata:', JSON.stringify(videoInfo, null, 2));
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## License

MIT © [Yogesh Solanki](https://github.com/SolankiYogesh)

---

Built with [create-react-native-library](https://github.com/callstack/react-native-builder-bob) and powered by [Nitro Modules](https://nitro.margelo.com/).
