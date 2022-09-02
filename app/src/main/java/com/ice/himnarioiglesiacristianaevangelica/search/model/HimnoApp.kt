package com.ice.himnarioiglesiacristianaevangelica.search.model

import android.app.Application
import androidx.room.Room
import com.ice.himnarioiglesiacristianaevangelica.common.services.HimnoDB

class HimnoApp : Application() {

    val db = Room.databaseBuilder(
        applicationContext,
        HimnoDB::class.java, "Himno"
    ).build()

}