import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:giphy/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _procura;//String pra procurar os gifs
  int _offset = 0;//Carregar mais Gifs



  Future<Map> _pegaGifs() async{
    http.Response response;
    if(_procura == null)//Se for igual a null, vai trazer os melhores gifs do momento, caso seja preenchido, vai trazer os gifs procurados pela API
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=fTU69sQBsq61r1ErLbp1E8jxg7CRzZQV&limit=25&rating=G");
    else
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=fTU69sQBsq61r1ErLbp1E8jxg7CRzZQV&q=$_procura&limit=24&offset=$_offset&rating=G&lang=pt");

    return json.decode(response.body);

  }



  @override
  void initState(){
    _pegaGifs().then((map){
      print(map);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),//Para pegar uma imagem da net
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
              onSubmitted: (text){//Quando clica pra pesquisar algo do teclado
               setState(() {
                 _procura = text;
                 _offset = 0;
               });
              }
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _pegaGifs(),
                builder: (context, snapshot){//Aq é oq ele vai pegar para carregar os Gifs, enquanto fica carregando
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(//Aq é a barra circular que vai aparecer enquanto carregava
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),//A cor que a animação vai ser enquanto carrega
                          strokeWidth: 5,//Largura do icone que vai ficar girando
                        ),
                      );
                    default:
                      if(snapshot.hasError) return Text("Erro");
                      else return _criarTabelaGif(context, snapshot);
                  }
                }
            ),
          )
        ],
      ),
    );
  }

int _getCount(List data){
    if(_procura == null){
      return data.length;
    }else {
      return data.length + 1;
    }
}

  Widget _criarTabelaGif(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(//Criando a Grid para mostrar os Gifs
        crossAxisCount: 2,//Quantos itens ele vai poder ter na Horizontal
        crossAxisSpacing: 10,//Espaçamento lateral dos itens, um do lado do outro quanto q vai ter
        mainAxisSpacing: 10//Espaçamento na vertical
      ),
      itemCount: _getCount(snapshot.data["data"]),//Quantidade de Gifs q eu vou colocar na tela
      itemBuilder: (context, index){//Cada item que tiver construindo na tela, ele vai chamar essa função para refazer a tela
        if(_procura == null || index < snapshot.data["data"].length)
          return GestureDetector(//Para ele entender que está sendo tocado
            child: FadeInImage.memoryNetwork(//Para trazer as imagens de uma forma mais suave
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300,
              fit: BoxFit.cover,
            ),
            onTap: (){//Função para abrir o gif em tela grande
              Navigator.push(context, MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index])));
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              };
            },
         );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white,size: 70,),
                  Text("Carregar mais...",
                  style: TextStyle(color: Colors.white, fontSize: 22),)
                ],
              ),
              onTap: (){
                setState(() {
                  _offset +=19;
                });
              },
            ),
          );
      }
    );
  }
}