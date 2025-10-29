import { NitroModules } from 'react-native-nitro-modules';
import type {
  NitroVideoMetadata,
  VideoInfoOptions,
  VideoInfoResult,
} from './NitroVideoMetadata.nitro';

const NitroVideoMetadataHybridObject =
  NitroModules.createHybridObject<NitroVideoMetadata>('NitroVideoMetadata');

export function getVideoInfoAsync(
  source: string,
  options: VideoInfoOptions
): Promise<VideoInfoResult> {
  return NitroVideoMetadataHybridObject.getVideoInfoAsync(source, options);
}
