FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN mkdir -p /usr/local/lib/android/cmdline-tools/latest/bin \
    /usr/local/lib/android/cmdline-tools/latest/lib \
 && printf '#!/bin/sh\necho preseed\n' > /usr/local/lib/android/cmdline-tools/latest/bin/preseed \
 && chmod +x /usr/local/lib/android/cmdline-tools/latest/bin/preseed \
 && printf 'preseed\n' > /usr/local/lib/android/cmdline-tools/latest/lib/preseed.txt
