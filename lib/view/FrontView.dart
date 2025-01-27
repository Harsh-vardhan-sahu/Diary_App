import 'package:flutter/material.dart';


class FrontView extends StatelessWidget {
  const FrontView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return  Padding(padding: const EdgeInsets.all(20.0),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //month number
              const  Text(
                  '1',
                  textScaleFactor:3.5,
                  style:TextStyle(
                    color:Colors.white,
                  )
              ),
              const    Text(
                  'JAN',
                  textScaleFactor:2.5,
                  style:TextStyle(
                    color:Colors.white,
                  )
              ),
              const Spacer(),
              Row(
                children: [
                  //progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const  Text(
                          '5/31',
                          style: TextStyle(
                            color:Colors.white,
                          ),),
                        Container(
                            width: double.infinity,
                            height: 3.0,
                            color: Colors.white30,
                            child:FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 5/31,
                                child:Container(
                                  color:Colors.white,
                                )
                            )
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                    size: 30.0,
                  )
                  //option button
                ],
              ),
            ],
          )
    );
  }
}
