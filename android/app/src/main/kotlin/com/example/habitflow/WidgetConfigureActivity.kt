package com.example.habitflow

import android.app.Activity
import android.app.AlertDialog
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle

class WidgetConfigureActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set result to CANCELED so if user backs out, launcher cancels widget add
        setResult(RESULT_CANCELED)

        val intent = intent
        val extras = intent.extras
        if (extras != null) {
            appWidgetId = extras.getInt(
                AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID
            )
        }

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        // Fetch active habits list from SharedPreferences
        val habits = getHabitsList(this)
        
        val options = mutableListOf<String>()
        options.add("Daily Momentum (All)")
        habits.forEach { options.add(it.title) }

        val builder = AlertDialog.Builder(this)
        builder.setTitle("Choose Habit for Widget")
        builder.setItems(options.toTypedArray()) { dialog, which ->
            val selectedHabitId = if (which == 0) null else habits[which - 1].id
            
            // Save widget configuration in HomeWidget preferences file
            val prefs = es.antonborri.home_widget.HomeWidgetPlugin.getData(this)
            
            if (selectedHabitId == null) {
                prefs.edit().remove("widget_selected_habit_id_$appWidgetId").apply()
            } else {
                prefs.edit().putString("widget_selected_habit_id_$appWidgetId", selectedHabitId).apply()
            }

            // Save appWidgetId to the comma-separated active_widget_ids_list
            val activeIdsString = prefs.getString("active_widget_ids_list", "") ?: ""
            val activeIds = activeIdsString.split(",").filter { it.isNotEmpty() }.toMutableSet()
            activeIds.add(appWidgetId.toString())
            prefs.edit().putString("active_widget_ids_list", activeIds.joinToString(",")).apply()

            // Trigger background render in Flutter
            try {
                val backgroundIntent = Intent(this, Class.forName("es.antonborri.home_widget.HomeWidgetBackgroundReceiver")).apply {
                    action = "es.antonborri.home_widget.action.BACKGROUND"
                    data = android.net.Uri.parse("habitflow://updateprogress?appWidgetId=$appWidgetId&configure=true")
                }
                sendBroadcast(backgroundIntent)
            } catch (e: Exception) {
                e.printStackTrace()
            }

            // Update native widget views
            val appWidgetManager = AppWidgetManager.getInstance(this)
            val widgetProvider = HabitWidgetProvider()
            widgetProvider.onUpdate(this, appWidgetManager, intArrayOf(appWidgetId))

            // Pass back original appWidgetId
            val resultValue = Intent().apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            setResult(RESULT_OK, resultValue)
            finish()
        }
        builder.setOnCancelListener {
            finish()
        }
        builder.show()
    }

    private fun getHabitsList(context: Context): List<HabitItem> {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val habitsData = prefs.getString("flutter.habits_data", null) ?: return emptyList()
        
        val jsonString = if (habitsData.startsWith("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!")) {
            habitsData.substring("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!".length)
        } else {
            habitsData
        }
        
        val list = mutableListOf<HabitItem>()
        try {
            val jsonArray = org.json.JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                val habitJsonStr = jsonArray.getString(i)
                val habitObj = org.json.JSONObject(habitJsonStr)
                val isArchived = habitObj.optBoolean("isArchived", false)
                if (!isArchived) {
                    val id = habitObj.getString("id")
                    val title = habitObj.getString("title")
                    list.add(HabitItem(id, title))
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return list
    }
}

data class HabitItem(val id: String, val title: String)
