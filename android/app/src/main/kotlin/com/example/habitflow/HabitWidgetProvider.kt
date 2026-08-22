package com.example.habitflow

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetPlugin

abstract class BaseWidgetProvider(private val widgetType: String) : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        android.util.Log.d("BaseWidgetProvider", "onUpdate for $widgetType called with ids: ${appWidgetIds.joinToString()}")
        
        // Clean up legacy active_widget_ids HashSet to prevent ClassCastException
        if (widgetData.contains("active_widget_ids")) {
            widgetData.edit().remove("active_widget_ids").apply()
        }
        if (widgetData.contains("flutter.active_widget_ids")) {
            widgetData.edit().remove("flutter.active_widget_ids").apply()
        }
        
        // Update active widget IDs set using a specific key for this widget type
        val activeIdsString = widgetData.getString("active_widget_ids_list_$widgetType", "") ?: ""
        val activeIds = activeIdsString.split(",").filter { it.isNotEmpty() }.toMutableSet()
        appWidgetIds.forEach { activeIds.add(it.toString()) }
        val newIdsString = activeIds.joinToString(",")
        android.util.Log.d("BaseWidgetProvider", "saving newIdsString for $widgetType: $newIdsString")
        widgetData.edit().putString("active_widget_ids_list_$widgetType", newIdsString).apply()

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Get the path of the rendered image from SharedPreferences for this specific widgetId and type
                var imagePath = widgetData.getString("widget_image_${widgetType}_$widgetId", null)
                if (imagePath == null) {
                    // Fallback to default widget_image for this type
                    imagePath = widgetData.getString("widget_image_$widgetType", null)
                }
                
                if (imagePath != null) {
                    val bitmap = android.graphics.BitmapFactory.decodeFile(imagePath)
                    if (bitmap != null) {
                        setImageViewBitmap(R.id.widget_image, bitmap)
                    }
                }

                // Add a background click intent including the appWidgetId and widgetType
                val backgroundIntent = es.antonborri.home_widget.HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    android.net.Uri.parse("habitflow://updateprogress?appWidgetId=$widgetId&widgetType=$widgetType")
                )
                setOnClickPendingIntent(R.id.widget_image, backgroundIntent)
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        android.util.Log.d("BaseWidgetProvider", "onDeleted for $widgetType called with ids: ${appWidgetIds.joinToString()}")
        val prefs = es.antonborri.home_widget.HomeWidgetPlugin.getData(context)
        
        // Clean up legacy active_widget_ids HashSet to prevent ClassCastException
        if (prefs.contains("active_widget_ids")) {
            prefs.edit().remove("active_widget_ids").apply()
        }
        if (prefs.contains("flutter.active_widget_ids")) {
            prefs.edit().remove("flutter.active_widget_ids").apply()
        }

        val activeIdsString = prefs.getString("active_widget_ids_list_$widgetType", "") ?: ""
        val activeIds = activeIdsString.split(",").filter { it.isNotEmpty() }.toMutableSet()
        appWidgetIds.forEach { 
            activeIds.remove(it.toString())
            prefs.edit().remove("widget_selected_habit_id_$it").remove("widget_image_${widgetType}_$it").apply()
        }
        val newIdsString = activeIds.joinToString(",")
        prefs.edit().putString("active_widget_ids_list_$widgetType", newIdsString).apply()
        super.onDeleted(context, appWidgetIds)
    }
}

// Subclasses for all widget variants
class HabitWidgetProvider : BaseWidgetProvider("streak") // Keep legacy name as alias for Streak
class StreakWidgetProvider : BaseWidgetProvider("streak")
class DailyFlowWidgetProvider : BaseWidgetProvider("flow")
class QuickFocusWidgetProvider : BaseWidgetProvider("focus")
class PriorityHabitsWidgetProvider : BaseWidgetProvider("priority")
class CircadianWidgetProvider : BaseWidgetProvider("circadian")
class MasterGridWidgetProvider : BaseWidgetProvider("master_grid")
class LockRingWidgetProvider : BaseWidgetProvider("lock_ring")
class LockStreakWidgetProvider : BaseWidgetProvider("lock_streak")
