package com.ice.himnarioiglesiacristianaevangelica.home.view

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.KeyEvent
import android.view.View
import android.widget.Toast
import androidx.room.Room
import com.ice.himnarioiglesiacristianaevangelica.R
import com.ice.himnarioiglesiacristianaevangelica.common.Constant
import com.ice.himnarioiglesiacristianaevangelica.common.Constant.TYPE_TEXT_SHARE
import com.ice.himnarioiglesiacristianaevangelica.databinding.ActivityHomeBinding
import com.ice.himnarioiglesiacristianaevangelica.common.services.HimnoDB
import com.ice.himnarioiglesiacristianaevangelica.common.utils.Utils.getDBPath
import com.ice.himnarioiglesiacristianaevangelica.search.view.FavoriteActivity
import com.ice.himnarioiglesiacristianaevangelica.search.view.SearchActivity
import java.io.*

class HomeActivity : AppCompatActivity() {

    private lateinit var binding: ActivityHomeBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityHomeBinding.inflate(layoutInflater)
        setContentView(binding.root)
        initDataBase()
        initButtons()
    }



    private fun initButtons(){
        //Abre la actividad busqueda y manda como parametro a esa actividad el numero buscado
        binding.btnSearch.setOnClickListener {
            if (binding.txtMusicNumber.text.isNotEmpty()) {
                val intent = Intent(this, SearchActivity::class.java)
                intent.putExtra(Constant.ID_MUSIC,binding.txtMusicNumber.text.toString().toInt())
                binding.txtMusicNumber.setText("")
                startActivity(intent)
            } else {
                Toast.makeText(this, getString(R.string.error_empty_field), Toast.LENGTH_SHORT).show()
            }
        }

        //Abre actividad favoritos que contiene himnos favoritosZ
        binding.btnFavorite.setOnClickListener {
            val intent = Intent(this, FavoriteActivity::class.java)
            startActivity(intent)
        }

        binding.btnShare.setOnClickListener {
            val intent = Intent(Intent.ACTION_SEND)
            intent.type = TYPE_TEXT_SHARE
            intent.putExtra(Intent.EXTRA_SUBJECT,resources.getString(R.string.app_name))
            intent.putExtra(Intent.EXTRA_TEXT,getString(R.string.share_text_user))
            startActivity(intent)
        }


        initEnterAction()

    }

    private fun initEnterAction(){
        // edit text enter key listener
        binding.txtMusicNumber.setOnKeyListener(object : View.OnKeyListener {
            override fun onKey(v: View?, keyCode: Int, event: KeyEvent): Boolean {
                // if the event is a key down event on the enter button
                if (event.action == KeyEvent.ACTION_DOWN &&
                    keyCode == KeyEvent.KEYCODE_ENTER
                ) {
                        binding.btnSearch.callOnClick()
                    return true
                }
                return false
            }
        })
    }



    //Primera ejecucion copia una base de datos preexistente al sistema
    private fun initDataBase() {
        val path = getDBPath(this)
        val fileName = Constant.NAME_DB_FILE
        val file = File(path + fileName)
        try {
        if (!file.exists()) {
            val app = Room.databaseBuilder(this,
                HimnoDB::class.java, Constant.NAME_DB).allowMainThreadQueries().build()
            app.himnoDao().getAll()
            val inputStream: InputStream = applicationContext.assets.open(fileName)
            val outputStream: OutputStream = FileOutputStream(file)
            val buffer = ByteArray(1024)
            var length: Int
            length = inputStream.read(buffer)
            while (length > 0) {
                outputStream.write(buffer, 0, length)
                length = inputStream.read(buffer)
            }
            outputStream.flush()
            outputStream.close()
            inputStream.close()
            Toast.makeText(this,getString(R.string.enjoy_app_text),Toast.LENGTH_LONG).show()
        }
            } catch (e : FileNotFoundException) {
                Toast.makeText(this,getString(R.string.error_db_not_exist),Toast.LENGTH_LONG).show()
                Log.d(getString(R.string.error), getString(R.string.error_file_not_found) + e.toString())
            } catch (e : IOException) {
                Toast.makeText(this,getString(R.string.error_copy_db),Toast.LENGTH_LONG).show()
                Log.d(getString(R.string.error), getString(R.string.error_copy_db_log) + e.toString())
            }
        }

    }
