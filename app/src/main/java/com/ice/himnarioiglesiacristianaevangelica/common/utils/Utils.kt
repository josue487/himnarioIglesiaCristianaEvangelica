package com.ice.himnarioiglesiacristianaevangelica.common.utils

import android.annotation.SuppressLint
import android.app.Activity

object Utils {




    @SuppressLint("SdCardPath")
    fun getDBPath(activity: Activity) : String{
        return "/data/data/${activity.packageName}/databases/"
    }

}