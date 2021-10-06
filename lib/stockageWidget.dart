import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StockageDialogWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: const Text("Merci d'autorisé la demande"),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("L'écriture et la lecture en mémoire permettent à l'application de stocker les creds de connexion et des données concernant l'edt"),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
      ],
    );
  }

}