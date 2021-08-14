package com.ice.himnarioiglesiacristianaevangelica

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle

class BusquedaActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_busqueda)
    }

    var titulo:String="A casa vete y cuenta allí"
    var cancion:String="A casa vete y cuenta allí / que Cristo te libró; / que tus amigos vean en ti /" +
            " lo que Él por gracia obró. + A casa vete y cuenta allí / que Cristo comprendió / " +
            "tu gran necesidad, y así / su sangre derramó. + Ve, cuenta a los de en derredor / " +
            "que Él satisfará / sus almas, puesto que en su amor / la cruz sufrido ha. + Ve, cuenta a " +
            "los de más allá / que en Cristo hay perdón, / y que Él a todos salvará, / si quieren salvación. + "
    var coro : String="A casa vete y lo que en ti / Ha hecho Dios, que vean, / y puede ser que los de allí / lo buscarán también. + "

}