package com.ice.himnarioiglesiacristianaevangelica.common.services

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.ice.himnarioiglesiacristianaevangelica.search.model.Himno

@Database(
    entities = [Himno::class],
    version = 1,
    exportSchema = false
)
abstract class HimnoDB : RoomDatabase() {

    abstract fun himnoDao() : HimnoDao

    companion object{
        @Volatile
        private var INSTANCE : HimnoDB? = null

        fun getDatabase(context:Context):HimnoDB{
            val tempInstance = INSTANCE
            if(tempInstance!=null){
                return tempInstance
            }
            synchronized(this){
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    HimnoDB::class.java, "Himno"
                ).build()
                INSTANCE=instance
                return instance
            }
        }
    }

}