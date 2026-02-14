package com.example.signroute

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.YuvImage
import android.os.Bundle
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.vosk.Model
import org.vosk.Recognizer
import org.vosk.android.RecognitionListener
import org.vosk.android.SpeechService
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.Executors

private const val VOSK_CHANNEL = "vosk_channel"
private const val SIGN_CHANNEL = "signroute/prediction"

class MainActivity : FlutterActivity(), RecognitionListener {

    /* ================= Vosk Variables ================= */
    private var model: Model? = null
    private var recognizer: Recognizer? = null
    private var speechService: SpeechService? = null
    private var voskChannel: MethodChannel? = null

    /* ================= SignRoute Variables ================= */
    private lateinit var signChannel: MethodChannel
    private lateinit var handHelper: HandLandmarkerHelper

    // Background thread for ML processing (UI Freez na ho)
    private val executor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Channels Setup
        voskChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOSK_CHANNEL)
        signChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SIGN_CHANNEL)

        // 2. Initialize Helper
        handHelper = HandLandmarkerHelper(this)
        handHelper.setup()

        // 3. Setup Handlers
        setupVoskChannel()
        setupSignChannel() // New Handler for Images

        checkAudioPermission()
        loadVoskModel()
    }

    private fun setupSignChannel() {
        signChannel.setMethodCallHandler { call, result ->
            if (call.method == "processFrame") {
                val bytes = call.argument<ByteArray>("bytes")
                val width = call.argument<Int>("width")
                val height = call.argument<Int>("height")
                val rotation = call.argument<Int>("rotation") ?: 90 // Default 90

                if (bytes != null && width != null && height != null) {
                    executor.execute {
                        // 1. Image process karein
                        val prediction = processImageFromFlutter(bytes, width, height, rotation)

                        runOnUiThread {
                            if (prediction != null) {
                                // Agar Sign mil gaya
                                signChannel.invokeMethod("onPrediction", prediction)
                                signChannel.invokeMethod("onDebug", "✅ Sign Found: $prediction")
                            } else {
                                // Agar Sign nahi mila (Taake pata chale code chal raha hai)
                                signChannel.invokeMethod("onDebug", "👀 Scanning... (No Hand or Low Confidence)")
                            }
                            result.success(prediction)
                        }
                    }
                } else {
                    result.error("INVALID_DATA", "Image data missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // Helper: Bytes -> Bitmap -> ML
    private fun processImageFromFlutter(nv21: ByteArray, width: Int, height: Int, rotation: Int): String? {
        try {
            // 1. Convert NV21 Bytes to Bitmap
            val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
            val out = ByteArrayOutputStream()
            yuvImage.compressToJpeg(Rect(0, 0, width, height), 100, out)
            val imageBytes = out.toByteArray()
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

            // 2. Rotate Bitmap (Phone portrait mein hota hai isliye rotate zaroori hai)
            val matrix = Matrix()
            matrix.postRotate(rotation.toFloat())
            val rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)

            // 3. Pass to your Helper
            return handHelper.processFrame(rotatedBitmap)
        } catch (e: Exception) {
            Log.e("SignRoute", "Error processing frame: ${e.message}")
            return null
        }
    }

    /* ================= Vosk Logic (Same as before) ================= */
    private fun setupVoskChannel() {
        voskChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> { startListening(); result.success(null) }
                "stopListening" -> { stopListening(); result.success(null) }
                else -> result.notImplemented()
            }
        }
    }

    private fun startListening() {
        if (model == null) return
        recognizer = Recognizer(model, 16000.0f)
        speechService = SpeechService(recognizer, 16000.0f)
        speechService?.startListening(this)
    }

    private fun stopListening() {
        speechService?.stop()
        speechService?.shutdown()
        speechService = null
    }

    override fun onPartialResult(hypothesis: String?) { voskChannel?.invokeMethod("onPartialResult", hypothesis) }
    override fun onResult(hypothesis: String?) { voskChannel?.invokeMethod("onFinalResult", hypothesis) }
    override fun onFinalResult(hypothesis: String?) { voskChannel?.invokeMethod("onFinalResult", hypothesis) }
    override fun onError(e: Exception?) {}
    override fun onTimeout() {}

    private fun checkAudioPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), 1)
        }
    }

    private fun loadVoskModel() {
        Thread {
            try {
                val modelPath = File(filesDir, "model")
                if (!modelPath.exists()) copyAssets("model", modelPath)
                model = Model(modelPath.absolutePath)
            } catch (e: Exception) { Log.e("VOSK", "Failed", e) }
        }.start()
    }

    private fun copyAssets(assetDir: String, destDir: File) {
        destDir.mkdirs()
        val assetList = assets.list(assetDir) ?: return
        for (asset in assetList) {
            val assetPath = "$assetDir/$asset"
            val outFile = File(destDir, asset)
            if (assets.list(assetPath)?.isNotEmpty() == true) {
                copyAssets(assetPath, outFile)
            } else {
                assets.open(assetPath).use { input -> FileOutputStream(outFile).use { output -> input.copyTo(output) } }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        handHelper.close()
        stopListening()
    }
}