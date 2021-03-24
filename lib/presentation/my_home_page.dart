// Copyright(c) 2021 Fredrick Allan Grott. All rights reserved.
// Use of this source code is governed by a BSD-style license.



import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:logging/logging.dart';

final Logger myHomePageLogger = Logger('myHomePageLogger');


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Command<void, String> _incrementCounterCommand;

  _MyHomePageState() {
    _incrementCounterCommand = Command.createSyncNoParam(() {
      _counter++;
      return _counter.toString();
    }, '0');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    // ignore: newline-before-return
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        // null workaround via testing
        title: Text(widget.title ?? ""),
      ),
      // ignore: prefer_const_literals_to_create_immutables
      body: Column(children: <Widget>[
        const Positioned(
          top: 100,
          left: 100,
          child: Text('You have pushed this many times')),
          Align(
                    alignment: Alignment.topCenter,
                    child: ValueListenableBuilder<String>(
                               valueListenable: _incrementCounterCommand,
                               builder: (context, val, _) {
                                         return Text(
                                           val,
                                          style: Theme.of(context).textTheme.headline4,
                                        );
                               }),
                  ),
          
          
          ],
          
          
          ),
          

      
      
      
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
