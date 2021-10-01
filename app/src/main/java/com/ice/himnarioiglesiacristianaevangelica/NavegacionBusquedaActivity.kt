package com.ice.himnarioiglesiacristianaevangelica

import android.os.Bundle
import android.view.MotionEvent
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2


class NavegacionBusquedaActivity : AppCompatActivity() {
    private val adapter by lazy{ ViewPagerAdapter(this)   }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_navegacion_busqueda)
        val pager = this.findViewById(R.id.pager) as ViewPager2
        pager.reduceDragSensitivity()
        pager.adapter = adapter

    }

    private fun ViewPager2.reduceDragSensitivity() {
        val recyclerViewField = ViewPager2::class.java.getDeclaredField("mRecyclerView")
        recyclerViewField.isAccessible = true
        val recyclerView = recyclerViewField.get(this) as RecyclerView

        val touchSlopField = RecyclerView::class.java.getDeclaredField("mTouchSlop")
        touchSlopField.isAccessible = true
        val touchSlop = touchSlopField.get(recyclerView) as Int
        touchSlopField.set(recyclerView, touchSlop*5)       // El numero al final indica la sensivilidad del viewpage2
    }
}