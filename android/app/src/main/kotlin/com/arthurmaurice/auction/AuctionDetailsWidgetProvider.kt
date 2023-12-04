package com.arthurmaurice.auction

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class AuctionDetailsWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.auction_details_widget_layout).apply {
                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                ///set running auction count integer
                val runningAuctionCount = widgetData.getInt("runningAuctionCount", 0)
                setTextViewText(R.id.runningAuctionCount, runningAuctionCount.toString())

                ///set upcoming auction count integer
                val upcomingAuctionCount = widgetData.getInt("upcomingAuctionCount", 0)
                setTextViewText(R.id.upcomingAuctionCount, upcomingAuctionCount.toString())

                ///set upcoming auction count integer
                val closedAuctionCount = widgetData.getInt("closedAuctionCount", 0)
                setTextViewText(R.id.closedAuctionCount, closedAuctionCount.toString())


                ///lastUpdatedTime
                val lastUpdatedTime = widgetData.getString("lastUpdatedTime", null)
                setTextViewText(R.id.lastUpdatedTime, lastUpdatedTime
                        ?: "Loading...")
                /// Get chart image and put it in the widget, if it exists
               val imagePath = widgetData.getString("promotionImage", null)
               val imageFile = File(imagePath ?:"")
               val imageExists = imageFile.exists() 
               if (imageExists) {
                  setImageViewBitmap(R.id.promotionImage, BitmapFactory.decodeFile(imageFile.absolutePath))
                  setViewVisibility(R.id.promotionImage, View.VISIBLE)
               } else {
                  println("image not found!, looked @: $imagePath")
                  setViewVisibility(R.id.promotionImage, View.GONE)
               }

            }

            appWidgetManager.updateAppWidget(widgetId, views)
        } 
    }
}
/*
                /// Swap Title Text by calling Dart Code in the Background
                setTextViewText(R.id.widget_title, widgetData.getString("title", null)
                        ?: "No Title Set")
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("homeWidgetExample://titleClicked")
                )
                setOnClickPendingIntent(R.id.widget_title, backgroundIntent)

                /// show Message saved 
                val message = widgetData.getString("message", null)
                setTextViewText(R.id.widget_message, message
                        ?: "No Message Set")

                /// Show Images saved with `renderFlutterWidget`
                val image = widgetData.getString("dashIcon", null)
                if (image != null) {
                 setImageViewBitmap(R.id.widget_img, BitmapFactory.decodeFile(image))
                 setViewVisibility(R.id.widget_img, View.VISIBLE)
                } else {
                    setViewVisibility(R.id.widget_img, View.GONE)
                }
                // Detect App opened via Click inside Flutter
                val pendingIntentWithData = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("homeWidgetExample://message?message=$message"))
                setOnClickPendingIntent(R.id.widget_message, pendingIntentWithData)
*/


