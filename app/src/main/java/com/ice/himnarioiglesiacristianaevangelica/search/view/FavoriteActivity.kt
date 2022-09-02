package com.ice.himnarioiglesiacristianaevangelica.search.view

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import com.ice.himnarioiglesiacristianaevangelica.search.model.Himno
import com.ice.himnarioiglesiacristianaevangelica.R
import com.ice.himnarioiglesiacristianaevangelica.common.Constant
import com.ice.himnarioiglesiacristianaevangelica.databinding.ActivityFavoriteBinding
import com.ice.himnarioiglesiacristianaevangelica.search.presenter.SQLiteHelper

class FavoriteActivity : AppCompatActivity() {


    private val serviceDB : SQLiteHelper = SQLiteHelper(this, Constant.NAME_DB_FILE,null,1)
    //Necesario para trabajar con viewbinding
    private lateinit var binding : ActivityFavoriteBinding

    var listFavoriteText = ArrayList<String>()
    var listFavorite = ArrayList<Himno>()


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_favorite)
        binding = ActivityFavoriteBinding.inflate(layoutInflater)
        setContentView(binding.root)
        initListFavorite()
        setUpButtons()

    }

    private fun setUpButtons(){
        binding.btnBack.setOnClickListener {
            onBackPressed()
        }

        binding.lViewFavoritos.onItemClickListener =
            AdapterView.OnItemClickListener { _, _, position, _ ->

                val intent = Intent(this, SearchActivity::class.java)
                intent.putExtra(Constant.ID_MUSIC, listFavorite[position].id)
                startActivity(intent)
            }


    }


    private fun initListFavorite(){
        listFavorite = serviceDB.searchFavorite()
        for (i in listFavorite){
            listFavoriteText.add("${i.id} - ${i.titulo}")
        }
        val adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1,listFavoriteText)
        binding.lViewFavoritos.adapter = adapter
    }


}