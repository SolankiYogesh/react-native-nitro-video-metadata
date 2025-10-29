#include <jni.h>
#include "nitrovideometadataOnLoad.hpp"

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void*) {
  return margelo::nitro::nitrovideometadata::initialize(vm);
}
