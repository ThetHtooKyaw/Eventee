package com.example.eventee

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.eventee/calendar"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // NotificationChannel
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) { 
            val channelId = "booking_channel_id" 
            val channelName = "Booking Updates"
            val descriptionText = "Notifications regarding your event bookings"
            val importance = NotificationManager.IMPORTANCE_HIGH

            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = descriptionText
            }

            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }

        // Calendar MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "addToCalendar") {
                val title = call.argument<String>("title")
                val description = call.argument<String>("description")
                val startTime = call.argument<Long>("startTime")
                val endTime = call.argument<Long>("endTime")

                val intent = Intent(Intent.ACTION_INSERT).apply {
                    data = CalendarContract.Events.CONTENT_URI
                    putExtra(CalendarContract.Events.TITLE, title)
                    putExtra(CalendarContract.Events.DESCRIPTION, description)
                    putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startTime)
                    putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endTime)
                }

                try {
                    startActivity(intent)
                    result.success("Event added to calendar")
                } catch (e: Exception) {

                    result.error("UNAVAILABLE", "Calendar app not found", null)
                }

            } else {
                result.notImplemented()
            }
        }
    }
}
