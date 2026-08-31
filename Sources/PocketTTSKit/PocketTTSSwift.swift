//
//  PocketTTSSwift.swift
//  Pocket TTS
//
//  Swift wrapper for the Rust Pocket TTS implementation.
//  Provides an async/await API for SwiftUI integration.
//
//  Derived from UnaMentis/pocket-tts-ios v0.4.1. The token-chunked streaming
//  helper was removed here — the underlying engine only exposes sync synthesis
//  plus `startTrueStreaming`, and this package's consumers use sync synthesis.
//

import Foundation

/// Swift-native wrapper for Pocket TTS with async/await support.
@available(iOS 17.0, *)
public actor PocketTTSSwift {

    // MARK: - Types

    public struct SynthesisResult: Sendable {
        public let audioData: Data
        public let sampleRate: UInt32
        public let channels: UInt32
        public let durationSeconds: Double
    }

    public struct Voice: Sendable, Identifiable {
        public let id: UInt32
        public let name: String
        public let gender: String
        public let description: String

        public init(index: UInt32, name: String, gender: String, description: String) {
            self.id = index
            self.name = name
            self.gender = gender
            self.description = description
        }
    }

    public struct Config: Sendable {
        public var voiceIndex: UInt32
        public var temperature: Float
        public var topP: Float
        public var speed: Float
        public var consistencySteps: UInt32
        public var useFixedSeed: Bool
        public var seed: UInt32

        public init(
            voiceIndex: UInt32 = 0,
            temperature: Float = 0.7,
            topP: Float = 0.9,
            speed: Float = 1.0,
            consistencySteps: UInt32 = 2,
            useFixedSeed: Bool = false,
            seed: UInt32 = 42
        ) {
            self.voiceIndex = voiceIndex
            self.temperature = temperature
            self.topP = topP
            self.speed = speed
            self.consistencySteps = consistencySteps
            self.useFixedSeed = useFixedSeed
            self.seed = seed
        }

        public static let `default` = Config()
        public static let lowLatency = Config(consistencySteps: 1)
        public static let highQuality = Config(temperature: 0.5, consistencySteps: 4)
    }

    // MARK: - Properties

    private var engine: PocketTtsEngine?
    private let modelPath: String

    // MARK: - Initialization

    public init(modelPath: String) {
        self.modelPath = modelPath
    }

    // MARK: - Public API

    public func load() throws {
        engine = try PocketTtsEngine(modelPath: modelPath)
    }

    public var isLoaded: Bool {
        engine?.isReady() ?? false
    }

    public func unload() {
        engine?.unload()
        engine = nil
    }

    public func configure(_ config: Config) throws {
        guard let engine else { throw PocketTTSSwiftError.modelNotLoaded }
        try engine.configure(config: TtsConfig(
            voiceIndex: config.voiceIndex,
            temperature: config.temperature,
            topP: config.topP,
            speed: config.speed,
            consistencySteps: config.consistencySteps,
            useFixedSeed: config.useFixedSeed,
            seed: config.seed
        ))
    }

    public static var voices: [Voice] {
        availableVoices().map { info in
            Voice(index: info.index, name: info.name, gender: info.gender, description: info.description)
        }
    }

    public func synthesize(text: String) throws -> SynthesisResult {
        guard let engine else { throw PocketTTSSwiftError.modelNotLoaded }
        let result = try engine.synthesize(text: text)
        return SynthesisResult(
            audioData: Data(result.audioData),
            sampleRate: result.sampleRate,
            channels: result.channels,
            durationSeconds: result.durationSeconds
        )
    }

    public func synthesize(text: String, voice: UInt32) throws -> SynthesisResult {
        guard let engine else { throw PocketTTSSwiftError.modelNotLoaded }
        let result = try engine.synthesizeWithVoice(text: text, voiceIndex: voice)
        return SynthesisResult(
            audioData: Data(result.audioData),
            sampleRate: result.sampleRate,
            channels: result.channels,
            durationSeconds: result.durationSeconds
        )
    }

    public func cancel() {
        engine?.cancel()
    }

    public var version: String {
        engine?.modelVersion() ?? "unknown"
    }

    public var parameterCount: UInt64 {
        engine?.parameterCount() ?? 0
    }
}

@available(iOS 17.0, *)
public enum PocketTTSSwiftError: Error, LocalizedError {
    case modelNotLoaded
    case synthesisError(String)

    public var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Pocket TTS model is not loaded"
        case .synthesisError(let message):
            return "Synthesis failed: \(message)"
        }
    }
}
