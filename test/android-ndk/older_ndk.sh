#!/bin/bash
set -e

source dev-container-features-test-lib

check "NDK r26d installed" bash -c "readlink /usr/local/lib/android-ndk/current | grep -q r26d"
check "API 21 aarch64 compiler available" bash -c "which aarch64-linux-android21-clang"
check "cmake available" bash -c "cmake --version"
check "cmake toolchain file exists" bash -c "test -f \$CMAKE_TOOLCHAIN_FILE"

check "compile JNI shared library with r26d API 21" bash -c '
    WORK="$(mktemp -d)"
    trap "rm -rf $WORK" EXIT
    cat > "$WORK/native.c" <<'"'"'CEOF'"'"'
#include <jni.h>

JNIEXPORT jint JNICALL
Java_com_test_Native_add(JNIEnv *env, jobject thiz, jint a, jint b) {
    return a + b;
}
CEOF
    aarch64-linux-android21-clang \
        -shared -fPIC \
        -o "$WORK/libnative.so" \
        "$WORK/native.c" && \
    file "$WORK/libnative.so" | grep -q "ELF 64-bit.*ARM aarch64"
'

reportResults
