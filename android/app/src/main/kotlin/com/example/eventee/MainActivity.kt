package com.example.eventee

import android.content.Intent
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.eventee/calendar"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
