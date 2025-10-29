package com.margelo.nitro.nitrovideometadata
  
import com.facebook.proguard.annotations.DoNotStrip

@DoNotStrip
class NitroVideoMetadata : HybridNitroVideoMetadataSpec() {
  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }
}
