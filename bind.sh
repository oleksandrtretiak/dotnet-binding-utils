#!/bin/bash
# Add at the beginning of bind.sh

echo "🔧 Setting up 16KB page size support..."

# Export 16KB support flags
export APP_SUPPORT_FLEXIBLE_PAGE_SIZES=true
export ANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON
export ANDROID_NDK_VERSION=28.2.13676358

# Ensure we're using the right NDK
if [ ! -z "$ANDROID_NDK_HOME" ]; then
    echo "Using NDK: $ANDROID_NDK_HOME"
else
    export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/28.2.13676358
    echo "Set NDK to: $ANDROID_NDK_HOME"
fi


rm -rf ./src/libs/BindingHost/*.props
rm -rf ./src/libs/BindingHost/bin
rm -rf ./src/libs/BindingHost/obj
# dotnet nuget locals -c all
dotnet tool restore
dotnet clean ./src/libs/BindingHost/BindingHost.csproj

dotnet cake "$@"

# Install Android workload
echo "Install Android workload"
dotnet workload install android wasi-experimental

dotnet restore ./src/libs/BindingHost/BindingHost.csproj
dotnet run --project ./src/libs/BindingHost/BindingHost.csproj \
    --verbosity minimal \
    -- --base-path=$PWD "$@"

# dotnet run --project ./src/libs/BindingHost/BindingHost.csproj \
#     --verbosity detailed \
#     -- --base-path=$PWD "$@"
