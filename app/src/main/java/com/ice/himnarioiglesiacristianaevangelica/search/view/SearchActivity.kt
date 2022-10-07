package com.ice.himnarioiglesiacristianaevangelica.search.view

import android.graphics.Typeface
import android.os.Bundle
import android.text.SpannableString
import android.text.Spanned
import android.text.method.ScrollingMovementMethod
import android.text.style.StyleSpan
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.ice.himnarioiglesiacristianaevangelica.search.model.Himno
import com.ice.himnarioiglesiacristianaevangelica.R
import com.ice.himnarioiglesiacristianaevangelica.common.Constant
import com.ice.himnarioiglesiacristianaevangelica.search.presenter.SQLiteHelper
import com.ice.himnarioiglesiacristianaevangelica.databinding.ActivitySearchBinding

class SearchActivity : AppCompatActivity() {


    private val serviceDB : SQLiteHelper = SQLiteHelper(this, Constant.NAME_DB_FILE,null,1)

    private lateinit var binding : ActivitySearchBinding

    //Comentario Formato de la Base de Datos para trabajar
    // Simbolos
    // / significa salto de linea
    // * significa que en este lugar va el coro si o si
    // + Significa que en este lugar va el coro opcionalmente como para que aparezca en multiples ocaciones


    private var position : Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding= ActivitySearchBinding.inflate(layoutInflater)
        setContentView(binding.root)
        binding.lblSong.movementMethod = ScrollingMovementMethod()
        val idMusic: Int = intent.getIntExtra(Constant.ID_MUSIC,0)
        initMusic(idMusic)
        setUpButtons()
    }



    private fun setUpButtons(){

        binding.btnBack.setOnClickListener {
            onBackPressed()
        }

        binding.btnPrevious.setOnClickListener {
            if(position-1 != 0){
                initMusic(position-1)
            }
            else{
                Toast.makeText(this,getString(R.string.first_music),Toast.LENGTH_LONG).show()
            }
        }

        binding.btnNext.setOnClickListener {
            if(position+1 != 518)
                initMusic(position+1)
            else
                Toast.makeText(this,getString(R.string.last_music),Toast.LENGTH_LONG).show()
        }

        binding.btnFavorite.setOnClickListener {
            formatFavorite(serviceDB.changeStateFavorite(position))
        }
    }



    //Formatea el texto ejm los espacios determinados con / el coro determinado con * y el coro repetido determinado por +
    private fun formatMusicText (musicSearch : Himno){
        //Creacion de titulo con su id
        val finalTitle:String = musicSearch.id.toString() + " " + musicSearch.titulo
        //Agregado de separadores de linea al reemplazarlos del texto original (variable reservada para eso '/') en la cancion
        var finalMusic:String = musicSearch.cancion.replace("/", System.getProperty("line.separator"))
        //Agregado de separadores de linea al reemplazarlos del texto original (variable reservada para eso '/') en el coro
        val finalChorus:String = musicSearch.coro.replace("/", System.getProperty("line.separator"))

        //agregado del coro a la cancion para obtener la cancion final
        finalMusic=finalMusic.replace("*", finalChorus)


        finalMusic = finalMusic.replace("+", finalChorus)
        //Una vez formateado lo carga en la vista de acuerdo al formato aplicado
        formatMusicForView(finalMusic, finalTitle, musicSearch.versiculo)
    }


    private fun formatMusicForView(finalMusic : String, finalTitle : String, verse : String){

        var formatMusic = finalMusic
        var startChorus = 0
        var finalChorus = 0
        // creacion del estilo negrita
        var bold = StyleSpan(Typeface.BOLD_ITALIC)
        //una vez guardadas las 2 posiciones mencionadas anteriormente se crea el objeto Spannable para asi poder aplicar negrita
        val ss = SpannableString(finalMusic.replace("(negrita)","").replace("(finNegrita)", ""))

        while(formatMusic.indexOf("(negrita)",startChorus) != -1){
            //bloque de codigo que lo que hace es:
            //1) obtener el indice de inicio de coro para despues poner en negrita y guardarlo en una variable
            startChorus = formatMusic.indexOf("(negrita)",startChorus)
            //2) quitar el texto reservado (negrita) que identificaba el inicio del coro
            formatMusic = formatMusic.replaceFirst("(negrita)", "")
            //3) obtener el indice de final de coro para delimitar el tamaño de la negrita y guardarlo en una variable
            finalChorus = formatMusic.indexOf("(finNegrita)",finalChorus)
            //4) quitar el texto reservado (finNegrita) que identificaba el fin del coro
            formatMusic = formatMusic.replaceFirst("(finNegrita)", "")
            bold = StyleSpan(Typeface.BOLD_ITALIC)
            //formateo del texto final con el coro en negrita delimitado por inicioCoro y finalCoro
            ss.setSpan(bold,startChorus,finalChorus,Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        }


        //bindeo con la vista para mostrar titulo con el id y el titulo del himnario
        binding.lblTitle.text=finalTitle
        //bindeo con la vista para mostrar la cancion completa y formateada
        binding.lblSong.text=ss
        //bindeo con la vista para mostrar los versiculos basados en la creacion del himno
        binding.lblVerses.text=verse

    }

    private fun formatFavorite(himnoFavorito : Boolean){
        if(himnoFavorito)
            binding.btnFavorite.setImageResource(R.drawable.ic_baseline_favorite_24)
        else
            binding.btnFavorite.setImageResource(R.drawable.ic_baseline_favorite_border_24)
    }



    private fun initMusic(idMusic : Int){
        binding.lblSong.scrollTo(0, 0)
        position=idMusic
        val songSearch : Himno = serviceDB.searchSong(idMusic)
        if (songSearch.cancion != ""){
            formatFavorite(songSearch.favorito)
            formatMusicText(songSearch)
        }else{
            Toast.makeText(this, getString(R.string.no_exist_music), Toast.LENGTH_LONG).show()
            onBackPressed()
        }
    }
}