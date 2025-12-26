package net.mpray.heart_connect

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.heartconnect/ai"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAiCoreAvailable" -> {
                    // Check if AICore (Gemini Nano) is available on this device
                    val isAvailable = checkAiCoreAvailability()
                    result.success(isAvailable)
                }
                "refineMessageWithNano" -> {
                    val message = call.argument<String>("message")
                    if (message != null) {
                        // Call Gemini Nano via AICore
                        refineWithGeminiNano(message) { refinedText, error ->
                            if (error != null) {
                                result.error("AI_ERROR", error, null)
                            } else {
                                result.success(refinedText)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Message is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Check if AICore (Gemini Nano) is available on this device.
     * Currently, AICore is available on:
     * - Pixel 8 / 8 Pro / 8a
     * - Samsung Galaxy S24 series
     * - Other devices with Android 14+ and AICore support
     */
    private fun checkAiCoreAvailability(): Boolean {
        // TODO: Implement actual AICore availability check
        // When Google releases the public AICore SDK, use:
        // try {
        //     val aiCore = AICoreClient.getInstance(this)
        //     return aiCore.isModelAvailable(ModelType.GEMINI_NANO)
        // } catch (e: Exception) {
        //     return false
        // }
        
        // For now, return false to use server fallback
        // Once AICore SDK is publicly available, implement the actual check
        return false
    }

    /**
     * Refine message using Gemini Nano via AICore.
     * This is a placeholder that will be implemented when AICore SDK is public.
     */
    private fun refineWithGeminiNano(message: String, callback: (String?, String?) -> Unit) {
        // TODO: Implement actual AICore / Gemini Nano call
        // When Google releases the public AICore SDK, use:
        // 
        // val prompt = "Rewrite this message to be more warm and emotional: $message"
        // aiCore.generateText(prompt) { result ->
        //     if (result.isSuccess) {
        //         callback(result.text, null)
        //     } else {
        //         callback(null, result.errorMessage)
        //     }
        // }
        
        // For now, return an error to trigger server fallback
        callback(null, "AICore not available yet. Using server API.")
    }
}
