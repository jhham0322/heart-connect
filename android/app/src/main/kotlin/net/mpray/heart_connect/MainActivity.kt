package net.mpray.heart_connect

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.CalendarContract
import android.database.Cursor
import android.telephony.SmsManager
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import java.io.File
import java.util.Date

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.heartconnect/ai"
    private val CALENDAR_CHANNEL = "com.heartconnect/calendar"
    private val SMS_CHANNEL = "com.heartconnect/sms"
    private val MMS_CHANNEL = "com.heartconnect/mms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // AI Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAiCoreAvailable" -> {
                    val isAvailable = checkAiCoreAvailability()
                    result.success(isAvailable)
                }
                "refineMessageWithNano" -> {
                    val message = call.argument<String>("message")
                    if (message != null) {
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
        
        // Calendar Channel - 직접 ContentProvider를 통해 캘린더 조회
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CALENDAR_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCalendarEvents" -> {
                    val startMillis = call.argument<Long>("start") ?: System.currentTimeMillis()
                    val endMillis = call.argument<Long>("end") ?: (startMillis + 45L * 24 * 60 * 60 * 1000)
                    
                    try {
                        val events = getCalendarEvents(startMillis, endMillis)
                        result.success(events)
                    } catch (e: Exception) {
                        result.error("CALENDAR_ERROR", e.message, null)
                    }
                }
                "isNaverCalendarInstalled" -> {
                    result.success(isAppInstalled("com.nhn.android.calendar"))
                }
                "openNaverCalendarSettings" -> {
                    try {
                        val intent = packageManager.getLaunchIntentForPackage("com.nhn.android.calendar")
                        if (intent != null) {
                            // 네이버 캘린더 앱 실행 (설정 화면으로 직접 이동은 불가하므로 앱 실행)
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } catch (e: Exception) {
                        result.error("OPEN_ERROR", e.message, null)
                    }
                }
                "hasNaverCalendarEvents" -> {
                    // 시스템 캘린더에 네이버 계정 일정이 있는지 확인
                    val hasNaver = checkNaverCalendarInSystem()
                    result.success(hasNaver)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // SMS Channel - 네이티브 SMS 발송
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSms" -> {
                    val phone = call.argument<String>("phone")
                    val message = call.argument<String>("message")
                    
                    if (phone != null && message != null) {
                        try {
                            sendSmsNative(phone, message)
                            result.success(true)
                        } catch (e: Exception) {
                            android.util.Log.e("SMS", "발송 오류: ${e.message}")
                            result.success(false)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Phone and message are required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // MMS Channel - Intent로 문자 앱 열기 (이미지 첨부)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendMms" -> {
                    val phone = call.argument<String>("phone")
                    val imagePath = call.argument<String>("imagePath")
                    val message = call.argument<String>("message") ?: ""
                    
                    if (phone != null && imagePath != null) {
                        try {
                            val success = sendMmsIntent(phone, imagePath, message)
                            result.success(success)
                        } catch (e: Exception) {
                            android.util.Log.e("MMS", "MMS Intent 오류: ${e.message}")
                            result.success(false)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Phone and imagePath are required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    /**
     * MMS Intent로 문자 앱 열기 (이미지 첨부)
     */
    private fun sendMmsIntent(phoneNumber: String, imagePath: String, message: String): Boolean {
        return try {
            val imageFile = File(imagePath)
            if (!imageFile.exists()) {
                android.util.Log.e("MMS", "이미지 파일 없음: $imagePath")
                return false
            }
            
            // FileProvider를 통해 URI 생성
            val imageUri = FileProvider.getUriForFile(
                this,
                "${packageName}.fileprovider",
                imageFile
            )
            
            android.util.Log.d("MMS", "이미지 URI: $imageUri")
            android.util.Log.d("MMS", "수신자: $phoneNumber")
            android.util.Log.d("MMS", "기본 SMS 앱: ${getDefaultSmsPackage()}")
            
            // 기본 SMS 앱 패키지 가져오기
            val defaultSmsApp = getDefaultSmsPackage()
            
            // MMS Intent 생성 - 삼성 메시지 앱 방식
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "image/jpeg"
                
                // 수신자 설정 (다양한 방식 시도)
                putExtra("address", phoneNumber)
                putExtra("sms_body", message)
                putExtra("exit_on_sent", true)
                
                // 이미지 첨부
                putExtra(Intent.EXTRA_STREAM, imageUri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                
                // 기본 SMS 앱 직접 지정
                if (defaultSmsApp != null) {
                    setPackage(defaultSmsApp)
                }
            }
            
            // Intent 실행 가능 여부 확인
            if (defaultSmsApp != null && intent.resolveActivity(packageManager) != null) {
                android.util.Log.d("MMS", "기본 SMS 앱으로 직접 열기: $defaultSmsApp")
                startActivity(intent)
            } else {
                // Fallback: SENDTO with smsto: scheme (이미지 없이)
                android.util.Log.d("MMS", "Fallback: smsto 방식 시도")
                val smsIntent = Intent(Intent.ACTION_SENDTO).apply {
                    data = android.net.Uri.parse("smsto:$phoneNumber")
                    putExtra("sms_body", message)
                }
                if (smsIntent.resolveActivity(packageManager) != null) {
                    startActivity(smsIntent)
                    // 이미지는 별도로 공유
                    val shareIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "image/jpeg"
                        putExtra(Intent.EXTRA_STREAM, imageUri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    startActivity(Intent.createChooser(shareIntent, "이미지 공유"))
                } else {
                    // 최종 Fallback: Chooser
                    android.util.Log.d("MMS", "Chooser 사용")
                    intent.setPackage(null)
                    startActivity(Intent.createChooser(intent, "문자로 보내기"))
                }
            }
            
            android.util.Log.d("MMS", "MMS Intent 성공: $phoneNumber")
            true
        } catch (e: Exception) {
            android.util.Log.e("MMS", "MMS Intent 오류: ${e.message}")
            e.printStackTrace()
            false
        }
    }
    
    /**
     * 기본 SMS 앱 패키지명 가져오기
     */
    private fun getDefaultSmsPackage(): String? {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            android.provider.Telephony.Sms.getDefaultSmsPackage(this)
        } else {
            null
        }
    }
    
    /**
     * 네이티브 SMS 발송
     */
    private fun sendSmsNative(phoneNumber: String, message: String) {
        val smsManager = SmsManager.getDefault()
        
        // 긴 메시지는 분할
        if (message.length > 160) {
            val parts = smsManager.divideMessage(message)
            smsManager.sendMultipartTextMessage(phoneNumber, null, parts, null, null)
        } else {
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
        }
        
        android.util.Log.d("SMS", "SMS 발송 완료: $phoneNumber")
    }
    
    /**
     * ContentProvider를 통해 캘린더 이벤트 조회
     */
    private fun getCalendarEvents(startMillis: Long, endMillis: Long): List<Map<String, Any?>> {
        val events = mutableListOf<Map<String, Any?>>()
        
        val projection = arrayOf(
            CalendarContract.Events._ID,
            CalendarContract.Events.TITLE,
            CalendarContract.Events.DTSTART,
            CalendarContract.Events.DTEND,
            CalendarContract.Events.CALENDAR_ID,
            CalendarContract.Events.ACCOUNT_NAME,
            CalendarContract.Events.CALENDAR_DISPLAY_NAME
        )
        
        val selection = "(${CalendarContract.Events.DTSTART} >= ?) AND (${CalendarContract.Events.DTSTART} <= ?)"
        val selectionArgs = arrayOf(startMillis.toString(), endMillis.toString())
        
        val cursor: Cursor? = contentResolver.query(
            CalendarContract.Events.CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            "${CalendarContract.Events.DTSTART} ASC"
        )
        
        cursor?.use {
            while (it.moveToNext()) {
                val id = it.getLong(it.getColumnIndexOrThrow(CalendarContract.Events._ID))
                val title = it.getString(it.getColumnIndexOrThrow(CalendarContract.Events.TITLE)) ?: "Untitled"
                val dtStart = it.getLong(it.getColumnIndexOrThrow(CalendarContract.Events.DTSTART))
                val accountName = it.getString(it.getColumnIndexOrThrow(CalendarContract.Events.ACCOUNT_NAME)) ?: ""
                val calendarName = it.getString(it.getColumnIndexOrThrow(CalendarContract.Events.CALENDAR_DISPLAY_NAME)) ?: ""
                
                // Determine source
                val source = when {
                    accountName.contains("gmail", ignoreCase = true) || 
                    accountName.contains("google", ignoreCase = true) -> "Google Calendar"
                    accountName.contains("naver", ignoreCase = true) -> "Naver Calendar"
                    else -> accountName.ifEmpty { "Phone" }
                }
                
                // Determine type
                val type = when {
                    title.contains("생일", ignoreCase = true) || 
                    title.contains("birthday", ignoreCase = true) -> "Birthday"
                    title.contains("기념일", ignoreCase = true) || 
                    title.contains("anniversary", ignoreCase = true) -> "Anniversary"
                    title.contains("holiday", ignoreCase = true) || 
                    title.contains("신정", ignoreCase = true) ||
                    title.contains("설날", ignoreCase = true) ||
                    title.contains("추석", ignoreCase = true) ||
                    title.contains("크리스마스", ignoreCase = true) ||
                    title.contains("christmas", ignoreCase = true) -> "Holiday"
                    else -> "Schedule"
                }
                
                events.add(mapOf(
                    "id" to id,
                    "title" to title,
                    "startMillis" to dtStart,
                    "source" to source,
                    "type" to type,
                    "calendarName" to calendarName
                ))
            }
        }
        
        android.util.Log.d("CalendarNative", "Found ${events.size} events from ContentProvider")
        return events
    }
    
    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: Exception) {
            false
        }
    }
    
    private fun checkNaverCalendarInSystem(): Boolean {
        // 시스템 캘린더에서 네이버 계정 캘린더가 있는지 확인
        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.ACCOUNT_NAME,
            CalendarContract.Calendars.ACCOUNT_TYPE
        )
        
        val cursor = contentResolver.query(
            CalendarContract.Calendars.CONTENT_URI,
            projection,
            null,
            null,
            null
        )
        
        cursor?.use {
            while (it.moveToNext()) {
                val accountName = it.getString(it.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_NAME)) ?: ""
                val accountType = it.getString(it.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_TYPE)) ?: ""
                
                if (accountName.contains("naver", ignoreCase = true) || 
                    accountType.contains("naver", ignoreCase = true)) {
                    return true
                }
            }
        }
        return false
    }

    private fun checkAiCoreAvailability(): Boolean {
        return false
    }

    private fun refineWithGeminiNano(message: String, callback: (String?, String?) -> Unit) {
        callback(null, "AICore not available yet. Using server API.")
    }
}
