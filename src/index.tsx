import { NitroModules } from 'react-native-nitro-modules';
import type { NitroVideoMetadata } from './NitroVideoMetadata.nitro';

const NitroVideoMetadataHybridObject =
  NitroModules.createHybridObject<NitroVideoMetadata>('NitroVideoMetadata');

export function multiply(a: number, b: number): number {
  return NitroVideoMetadataHybridObject.multiply(a, b);
}
