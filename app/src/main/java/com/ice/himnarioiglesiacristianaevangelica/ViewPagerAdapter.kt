package com.ice.himnarioiglesiacristianaevangelica

import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter

class ViewPagerAdapter(fragmentActivity : FragmentActivity) : FragmentStateAdapter(fragmentActivity){


    private val ARG_OBJECT = "Id"

    override fun getItemCount(): Int {
        return 517
    }

    override fun createFragment(position: Int): Fragment {
        val fragment = ViewPageFragment()
        fragment.arguments = Bundle().apply {
            putInt(ARG_OBJECT,position+1)
        }
        return fragment
    }
}