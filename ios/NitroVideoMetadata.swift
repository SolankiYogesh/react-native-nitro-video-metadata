import Foundation
import AVFoundation
import Photos
import NitroModules

struct VideoMetadataError: LocalizedError {
  let message: String
  var errorDescription: String? { message }
}

func doubleValue(_ value: Any?) -> Double {
  if let num = value as? NSNumber { return num.doubleValue }
  if let dbl = value as? Double { return dbl }
  if let flt = value as? Float { return Double(flt) }
  if let intVal = value as? Int { return Double(intVal) }
  return 0
}

class NitroVideoMetadata: HybridNitroVideoMetadataSpec {

  func getVideoInfoAsync(source: String, options: VideoInfoOptions) throws -> NitroModules.Promise<VideoInfoResult> {
    let promise = NitroModules.Promise<VideoInfoResult>()
    
    let inputURL: URL?
    if source.starts(with: "file://") {
      inputURL = URL(fileURLWithPath: source.replacingOccurrences(of: "file://", with: ""))
    } else {
      inputURL = URL(string: source)
    }

    guard let url = inputURL else {
      promise.reject(withError: VideoMetadataError(message: "Invalid URL: \(source)"))
      return promise
    }
    
    resolveVideoURL(url) { resolvedURL in
      guard let videoURL = resolvedURL else {
        promise.reject(withError: VideoMetadataError(message: "Failed to resolve video URI."))
        return
      }

      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let infoDict = try VideoMetadata.getVideoInfo(from: videoURL, options: VideoMetadata.Options(headers: options.headers ?? [:]))

          let result = VideoInfoResult(
            duration: doubleValue(infoDict["duration"]),
            hasAudio: infoDict["hasAudio"] as? Bool ?? false,
            isHDR: infoDict["isHDR"] as? Bool ?? false,
            width: doubleValue(infoDict["width"]),
            height: doubleValue(infoDict["height"]),
            fps: doubleValue(infoDict["fps"]),
            bitRate: doubleValue(infoDict["bitrate"]),
            fileSize: doubleValue(infoDict["fileSize"]),
            codec: infoDict["codec"] as? String ?? "",
            orientation: infoDict["orientation"] as? String ?? "",
            naturalOrientation: infoDict["naturalOrientation"] as? String ?? "",
            aspectRatio: doubleValue(infoDict["aspectRatio"]),
            is16_9: infoDict["is16_9"] as? Bool ?? false,
            audioSampleRate: doubleValue(infoDict["audioSampleRate"]),
            audioChannels: doubleValue(infoDict["audioChannels"]),
            audioCodec: infoDict["audioCodec"] as? String ?? "",
            location: {
              if let loc = infoDict["location"] as? [String: Double] {
                return VideoLocationType(
                  latitude: loc["latitude"] ?? 0,
                  longitude: loc["longitude"] ?? 0,
                  altitude: loc["altitude"]
                )
              }
              return nil
            }()
          )

          promise.resolve(withResult: result)
        } catch {
          promise.reject(withError: VideoMetadataError(message: "Failed to extract video info: \(error.localizedDescription)"))
        }
      }
    }
    
    return promise
  }

  private func resolveVideoURL(_ uri: URL, completion: @escaping (URL?) -> Void) {
    if uri.scheme == "ph" {
      let assetID = uri.absoluteString.replacingOccurrences(of: "ph://", with: "")
      let results = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil)
      guard let phAsset = results.firstObject else {
        completion(nil)
        return
      }

      let options = PHVideoRequestOptions()
      options.isNetworkAccessAllowed = true

      PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { avAsset, _, _ in
        if let urlAsset = avAsset as? AVURLAsset {
          completion(urlAsset.url)
        } else {
          completion(nil)
        }
      }
    } else {
      completion(uri)
    }
  }
}
