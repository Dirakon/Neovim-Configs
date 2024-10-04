# This - https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ro/roslyn-ls/package.nix#L95
# Forked to update version for source-generated file referencing
{pkgs}:
with pkgs;
let
  pname = "roslyn-ls";
  dotnet-sdk =
    with dotnetCorePackages;
    combinePackages [
      sdk_6_0
      sdk_7_0
      sdk_8_0
      sdk_9_0
    ];
  # need sdk on runtime as well
  dotnet-runtime = dotnetCorePackages.sdk_9_0;
  rid = dotnetCorePackages.systemToDotnetRid stdenvNoCC.targetPlatform.system;

  project = "Microsoft.CodeAnalysis.LanguageServer";
in
buildDotnetModule rec {
  inherit pname dotnet-sdk dotnet-runtime;

  vsVersion = "42.42.42-placeholder";
  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "roslyn";
    rev = "6a176730c947fac84ec966c1bed0aa474931b8e6";
    hash = "sha256-5u+5UkcWn5XKxhbAbZeUBWBAI4B1nuZFP4qDF4cHerU=";
  };

  # versioned independently from vscode-csharp
  # "roslyn" in here:
  # https://github.com/dotnet/vscode-csharp/blob/main/package.json
  version = "4.13.0-1.24503.11";
  projectFile = "src/LanguageServer/${project}/${project}.csproj";
  useDotnetFromEnv = true;
  nugetDeps = ./deps.nix;

  nativeBuildInputs = [ jq ];

  postPatch = ''
    # Upstream uses rollForward = latestPatch, which pins to an *exact* .NET SDK version.
    jq '.sdk.rollForward = "latestMinor"' < global.json > global.json.tmp
    mv global.json.tmp global.json
  '';

  dotnetFlags = [
    # this removes the Microsoft.WindowsDesktop.App.Ref dependency
    "-p:EnableWindowsTargeting=false"
    # see this comment: https://github.com/NixOS/nixpkgs/pull/318497#issuecomment-2256096471
    # we can remove below line after https://github.com/dotnet/roslyn/issues/73439 is fixed
    "-p:UsingToolMicrosoftNetCompilers=false"
    "-p:TargetRid=${rid}"
  ];

  # two problems solved here:
  # 1. --no-build removed -> BuildHost project within roslyn is running Build target during publish
  # 2. missing crossgen2 7.* in local nuget directory when PublishReadyToRun=true
  # the latter should be fixable here but unsure how
  installPhase = ''
    runHook preInstall

    env dotnet publish $dotnetProjectFiles \
        -p:ContinuousIntegrationBuild=true \
        -p:Deterministic=true \
        -p:InformationalVersion=$version \
        -p:UseAppHost=true \
        -p:PublishTrimmed=false \
        -p:PublishReadyToRun=false \
        --configuration Release \
        --no-self-contained \
        --output "$out/lib/$pname" \
        --no-restore \
        --runtime ${rid} \
        ''${dotnetInstallFlags[@]}  \
        ''${dotnetFlags[@]}

    runHook postInstall
  '';
}
