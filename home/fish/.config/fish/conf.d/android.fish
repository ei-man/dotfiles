# Android SDK. Populated by Android Studio's first-run wizard, which defaults
# to this location.
set -gx ANDROID_HOME $HOME/Android/Sdk
set -gx ANDROID_SDK_ROOT $ANDROID_HOME

# The Android Gradle Plugin does not support the system default JDK (26), so
# point Gradle at the JBR (25) that Android Studio ships with.
if test -d /opt/android-studio/jbr
    set -gx JAVA_HOME /opt/android-studio/jbr
end

# platform-tools goes on PATH ahead of /usr/bin so that its adb (37.0.1) shadows
# the pacman android-tools one (36.0.1). Gradle always invokes the SDK copy, and
# two adb versions on one machine means each kills the other's server on start.
for d in $ANDROID_HOME/platform-tools $ANDROID_HOME/emulator $ANDROID_HOME/cmdline-tools/latest/bin
    if test -d $d
        fish_add_path -g $d
    end
end
