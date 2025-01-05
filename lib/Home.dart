import 'package:flutter/material.dart';
import 'package:diary/screen/login.dart';
import 'package:diary/screen/signup.dart';
import 'package:diary/widgets/global_widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover,image: AssetImage('assets/images/log.png'))),
        child: Column(children: [
          const SizedBox (height:55),
          Text('Welcome to Diary',style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold,color: Colors.black),),
         Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center,
           children:[

             GlobalWidgets.button(width: width, onTap: (){
               Navigator.of(context).push(MaterialPageRoute(
                   builder: (context){
                     return Signup();
                   }
               ));
             }, buttonText:'Sign Up'),
             const SizedBox(height: 5,),
            GlobalWidgets.button(width: width, onTap: (){
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context){
                    return LoginScreen();
                  }
              ));
            }, buttonText:'Login')
           ]
         ))
        ],),
      ),
    );

    return const Placeholder();
  }
}
