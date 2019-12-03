import 'package:flutter/material.dart';
import 'package:giphy/home_page.dart';//importando a outra página que criamos


void main(){
  runApp(MaterialApp(
   home: HomePage(),//Dessa vez vamos ter mais de uma página, então especifca qual página é
  theme: ThemeData(hintColor: Colors.white),
  ));
}

