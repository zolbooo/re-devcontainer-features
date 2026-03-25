#!/bin/bash
set -e

source dev-container-features-test-lib

check "NDK home directory exists" bash -c "test -d \$ANDROID_NDK_HOME"
check "current symlink points to NDK" bash -c "test -L /usr/local/lib/android-ndk/current"
check "aarch64 clang compiler available" bash -c "which aarch64-linux-android24-clang"
check "cmake available" bash -c "cmake --version"
check "ninja available" bash -c "ninja --version"
check "cmake toolchain file exists" bash -c "test -f \$CMAKE_TOOLCHAIN_FILE"
check "env.sh helper exists" bash -c "test -f /usr/local/lib/android-ndk/env.sh"

check "compile JNI shared library for ARM64" bash -c '
    WORK="$(mktemp -d)"
    trap "rm -rf $WORK" EXIT
    cat > "$WORK/native.c" <<'"'"'CEOF'"'"'
#include <jni.h>

JNIEXPORT jstring JNICALL
Java_com_test_Native_hello(JNIEnv *env, jobject thiz) {
    return (*env)->NewStringUTF(env, "hello from native");
}
CEOF
    aarch64-linux-android24-clang \
        -shared -fPIC \
        -o "$WORK/libnative.so" \
        "$WORK/native.c" && \
    file "$WORK/libnative.so" | grep -q "ELF 64-bit.*ARM aarch64"
'

reportResults
