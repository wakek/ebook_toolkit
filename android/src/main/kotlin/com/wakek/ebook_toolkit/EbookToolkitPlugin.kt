package com.wakek.ebook_toolkit

import android.content.ContentResolver
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.pdf.PdfRenderer
import android.graphics.pdf.PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.os.ParcelFileDescriptor.MODE_READ_ONLY
import android.util.SparseArray
import android.view.Surface
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.TextureRegistry
import kotlinx.coroutines.*
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.nio.ByteBuffer

/** EbookToolkitPlugin */
class EbookToolkitPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

    private val documents: SparseArray<PdfRenderer> = SparseArray()
    private val textures: SparseArray<TextureRegistry.SurfaceTextureEntry> = SparseArray()
    private var lastDocId: Int = 0

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ebook_toolkit")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @OptIn(DelicateCoroutinesApi::class)
    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "openPdfFromFilePath" -> {
                    try {
                        val pdfRenderer: PdfRenderer =
                            openPdfFromFilePath(call.arguments as String)
                        result.success(cachePdf(pdfRenderer))
                    } catch (e: Exception) {
                        result.error("exception", "Failed to open pdf from file path", e.message)
                    }
                }
                "openAssetPdf" -> {
                    try {
                        val pdfRenderer: PdfRenderer = openAssetPdf(call.arguments as String)
                        result.success(cachePdf(pdfRenderer))
                    } catch (e: Exception) {
                        result.error("exception", "Failed to open asset pdf document", e.message)
                    }
                }
                "openPdfFromMemory" -> {
                    try {
                        val pdfRenderer: PdfRenderer =
                            openPdfFromMemory(call.arguments as ByteArray)
                        result.success(cachePdf(pdfRenderer))
                    } catch (e: Exception) {
                        result.error("exception", "Failed to open pdf from memory", e.message)
                    }
                }
                "closePdf" -> {
                    close(call.arguments as Int)
                    result.success(0)
                }
                "getPdfInfo" -> {
                    val (renderer, id) = getCachedPdf(call)
                    result.success(getPdfInfo(renderer, id))
                }
                "getPageInfo" -> {
                    @Suppress("UNCHECKED_CAST")
                    result.success(getPageInfo(call.arguments as HashMap<String, Any>))
                }
                "render" -> {
                    @Suppress("UNCHECKED_CAST")
                    GlobalScope.launch(Dispatchers.Default) {
                        render(call.arguments as HashMap<String, Any>, result)
                    }
                }
                "releaseBuffer" -> {
                    releaseBuffer(call.arguments as Long)
                    result.success(0)
                }
                "allocTexture" -> {
                    result.success(allocTexture())
                }
                "releaseTexture" -> {
                    releaseTexture(call.arguments as Int)
                    result.success(0)
                }
                "updateTexture" -> {
                    @Suppress("UNCHECKED_CAST")
                    result.success(updateTexture(call.arguments as HashMap<String, Any>))
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("exception", "Internal error.", e)
        }
    }

    private fun openPdfFromFilePath(filePath: String): PdfRenderer {
        val fd = ParcelFileDescriptor.open(File(filePath), MODE_READ_ONLY)
        return PdfRenderer(fd)
    }

    private fun openAssetPdf(assetName: String): PdfRenderer {
        val pdfRenderer: PdfRenderer?
        val assetPath: String = flutterPluginBinding
            .flutterAssets
            .getAssetFilePathByName(assetName)

        val inputStream: InputStream =
            flutterPluginBinding.applicationContext.assets.open(assetPath)

        pdfRenderer = copyToTempFileAndOpenDoc { inputStream.copyTo(it) }

        inputStream.close()

        return pdfRenderer
    }

    private fun openPdfFromMemory(data: ByteArray): PdfRenderer {
        return copyToTempFileAndOpenDoc { it.write(data) }
    }

    private fun copyToTempFileAndOpenDoc(writeData: (OutputStream) -> Unit): PdfRenderer {
        val file = File.createTempFile("temp_pdf", null, null)
        try {
            file.outputStream().use {
                writeData(it)
            }
            file.inputStream().use {
                return PdfRenderer(ParcelFileDescriptor.dup(it.fd))
            }
        } finally {
            file.delete()
        }
    }


    private fun cachePdf(pdfRenderer: PdfRenderer): HashMap<String, Any> {
        val id = ++lastDocId
        documents.put(id, pdfRenderer)
        return getPdfInfo(pdfRenderer, id)
    }

    private fun getCachedPdf(call: MethodCall): Pair<PdfRenderer, Int> {
        val id = call.arguments as Int
        return Pair(documents[id], id)
    }

    private fun getPdfInfo(pdfRenderer: PdfRenderer, id: Int): HashMap<String, Any> {
        return hashMapOf(
            "documentId" to id,
            "pageCount" to pdfRenderer.pageCount,
            "verMajor" to 1,
            "verMinor" to 7,
        )
    }

    private fun close(id: Int) {
        val renderer = documents[id]
        if (renderer != null) {
            renderer.close()
            documents.remove(id)
        }
    }

    private fun getPageInfo(args: HashMap<String, Any>): HashMap<String, Any>? {
        val documentId = args["documentId"] as? Int ?: return null
        val renderer = documents[documentId] ?: return null
        val pageIndex = args["pageIndex"] as? Int ?: return null
        if (pageIndex < 0 || pageIndex >= renderer.pageCount) return null

        renderer.openPage(pageIndex).use {
            return hashMapOf(
                "documentId" to documentId,
                "pageIndex" to pageIndex,
                "width" to it.width.toDouble(),
                "height" to it.height.toDouble()
            )
        }
    }

    private suspend fun renderOnByteBuffer(
        args: HashMap<String, Any>,
        createBuffer: (Int) -> ByteBuffer
    ): HashMap<String, Any?> = withContext(Dispatchers.Default) {
        val documentId = args["documentId"] as Int
        val renderer = documents[documentId]
        val pageIndex = args["pageIndex"] as Int
        renderer.openPage(pageIndex).use {
            val x = args["x"] as? Int? ?: 0
            val y = args["y"] as? Int? ?: 0
            val width = args["width"] as? Int? ?: 0
            val height = args["height"] as? Int? ?: 0
            val w = if (width > 0) width else it.width
            val h = if (height > 0) height else it.height
            val fullWidth = args["fullWidth"] as? Double ?: 0.0
            val fullHeight = args["fullHeight"] as? Double ?: 0.0
            val fw = if (fullWidth > 0) fullWidth.toFloat() else w.toFloat()
            val fh = if (fullHeight > 0) fullHeight.toFloat() else h.toFloat()
            val backgroundFill = args["backgroundFill"] as? Boolean ?: true

            val buf = createBuffer(w * h * 4)

            val mat = Matrix()
            mat.setValues(
                floatArrayOf(
                    fw / it.width,
                    0f,
                    -x.toFloat(),
                    0f,
                    fh / it.height,
                    -y.toFloat(),
                    0f,
                    0f,
                    1f
                )
            )

            val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)

            if (backgroundFill) {
                bmp.eraseColor(Color.WHITE)
            }

            it.render(bmp, null, mat, RENDER_MODE_FOR_DISPLAY)

            bmp.copyPixelsToBuffer(buf)
            bmp.recycle()

            return@withContext hashMapOf(
                "documentId" to documentId,
                "pageIndex" to pageIndex,
                "x" to x,
                "y" to y,
                "width" to w,
                "height" to h,
                "fullWidth" to fw.toDouble(),
                "fullHeight" to fh.toDouble(),
                "pageWidth" to it.width.toDouble(),
                "pageHeight" to it.height.toDouble()
            )
        }
    }

    private suspend fun render(args: HashMap<String, Any>, result: Result) {
        var buf: ByteBuffer? = null
        var addr = 0L
        var map: HashMap<String, Any?>

        coroutineScope {
            val deferredMap: Deferred<HashMap<String, Any?>> = async(Dispatchers.Default) {
                renderOnByteBuffer(args) {
                    val (addr_, bbuf) = allocBuffer(it)
                    buf = bbuf
                    addr = addr_
                    return@renderOnByteBuffer bbuf
                }
            }
            map = deferredMap.await()
        }

        if (addr != 0L) {
            map["addr"] = addr
        } else {
            map["data"] = buf?.array()
        }
        map["size"] = buf?.capacity()

        result.success(map)
    }

    private fun allocBuffer(size: Int): Pair<Long, ByteBuffer> {
        val addr = ByteBufferHelper.malloc(size.toLong())
        val bb = ByteBufferHelper.newDirectBuffer(addr, size.toLong())
        return addr to bb
    }

    private fun releaseBuffer(addr: Long) {
        ByteBufferHelper.free(addr)
    }

    private fun allocTexture(): Int {
        val surfaceTexture = flutterPluginBinding.textureRegistry.createSurfaceTexture()
        val id = surfaceTexture.id().toInt()
        textures.put(id, surfaceTexture)
        return id
    }

    private fun releaseTexture(texId: Int) {
        val tex = textures[texId]
        tex?.release()
        textures.remove(texId)
    }

    private fun updateTexture(args: HashMap<String, Any>): Int {
        val texId = args["texId"] as Int
        val documentId = args["documentId"] as Int
        val pageIndex = args["pageIndex"] as Int
        val tex = textures[texId] ?: return -8

        val renderer = documents[documentId]

        renderer.openPage(pageIndex).use { page ->
            val fullWidth = args["fullWidth"] as? Double ?: page.width.toDouble()
            val fullHeight = args["fullHeight"] as? Double ?: page.height.toDouble()
            val width = args["width"] as? Int ?: 0
            val height = args["height"] as? Int ?: 0
            val srcX = args["srcX"] as? Int ?: 0
            val srcY = args["srcY"] as? Int ?: 0
            val backgroundFill = args["backgroundFill"] as? Boolean ?: true

            if (width <= 0 || height <= 0)
                return -7

            val mat = Matrix()
            mat.setValues(
                floatArrayOf(
                    (fullWidth / page.width).toFloat(),
                    0f,
                    -srcX.toFloat(),
                    0f,
                    (fullHeight / page.height).toFloat(),
                    -srcY.toFloat(),
                    0f,
                    0f,
                    1f
                )
            )

            val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            if (backgroundFill) {
                bmp.eraseColor(Color.WHITE)
            }
            page.render(bmp, null, mat, RENDER_MODE_FOR_DISPLAY)

            tex.surfaceTexture().setDefaultBufferSize(width, height)

            Surface(tex.surfaceTexture()).use {
                val canvas = it.lockCanvas(Rect(0, 0, width, height));

                canvas.drawBitmap(bmp, 0f, 0f, null)
                bmp.recycle()

                it.unlockCanvasAndPost(canvas)
            }
        }
        return 0
    }

    private fun checkIfPdfIsPasswordProtected(uri: Uri, contentResolver: ContentResolver): Boolean {
        val parcelFileDescriptor = contentResolver.openFileDescriptor(uri, "r")
            ?: return false
        return try {
            PdfRenderer(parcelFileDescriptor)
            false
        } catch (securityException: SecurityException) {
            true
        }
    }
}

fun <R> Surface.use(block: (Surface) -> R): R {
    try {
        return block(this)
    } finally {
        this.release()
    }
}