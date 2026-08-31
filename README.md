# PocketTTSKit

SwiftPM packaging of **Kyutai Pocket TTS** for on-device text-to-speech on iOS,
used by [supertonic-ios](https://github.com/alastairapple/supertonic-ios).

This repo only re-packages upstream artifacts for SwiftPM consumption:

- `Sources/PocketTTSKit/pocket_tts_ios.swift`, `PocketTTSSwift.swift` — the UniFFI
  Swift bindings + async wrapper from
  [`UnaMentis/pocket-tts-ios` release v0.4.1](https://github.com/UnaMentis/pocket-tts-ios/releases/tag/v0.4.1).
- Release `0.4.1` asset `PocketTTS.xcframework.zip` — the upstream
  `PocketTTS.xcframework` (Rust/Candle static library, `ios-arm64` +
  `ios-arm64-simulator`) with its module map simplified to a single
  `pocket_tts_iosFFI` clang module and the redundant umbrella header removed, so it
  resolves as a plain static-library binary target.

No source changes to the engine. See `ATTRIBUTION.md` for the full chain.

## Usage

```swift
.package(url: "https://github.com/alastairapple/pocket-tts-spm.git", exact: "0.4.1")
```

```swift
import PocketTTSKit

let tts = PocketTTSSwift(modelPath: modelDirectoryPath)
try await tts.load()
try await tts.configure(.default)
let result = try await tts.synthesize(text: "Hello, world!")
// result.audioData is a 32-bit-float WAV at result.sampleRate
```

Model files (`model.safetensors`, `tokenizer.model`, `voices/*.safetensors`) are
**not** included — download them from
[`kyutai/pocket-tts-without-voice-cloning`](https://huggingface.co/kyutai/pocket-tts-without-voice-cloning)
(CC-BY-4.0) and point `modelPath` at the directory that contains them.
