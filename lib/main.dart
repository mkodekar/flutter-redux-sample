import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:sampleredux/src/redux_persistence.dart';


void main() => runApp(new Main());


class AppState {
  final String name;

  AppState({this.name});

  AppState copyWith({String name}) => new AppState(name: name ?? this.name);

  static AppState fromJson(dynamic json) => new AppState(name: json["name"] as String);

  dynamic toJson() => {'name': name};
}

class IncrementAction {

  String name;
  
  IncrementAction(this.name);
}

AppState reducer(AppState state, Object action) {

  if (action is LoadedAction<AppState>) {
    return action.state ?? state;
  } else if (action is IncrementAction) {
    return state.copyWith(name: action.name);
  }
  return state;
}


class Main extends StatelessWidget {
  
  Persistor<AppState> persistor;
  Store<AppState> store;

  Main() {
    persistor = new Persistor<AppState>(
      storage: new FlutterStorage("my-app"),
      decoder: AppState.fromJson
    );

    store = new Store<AppState>(
      reducer,
      initialState: new AppState(),
      middleware:  [persistor.createMiddleware()],
   );

   persistor.start(store);
  }

  final _iosTheme = new ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    brightness: Brightness.dark
  );

  final _androidTheme = new ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    accentColor: Colors.amberAccent
  );

  @override
  Widget build(context) => new PersistorGate(
    persistor: persistor,
    builder: (context) => new StoreProvider(
      store: store,
      child: new MaterialApp(
        theme: defaultTargetPlatform == TargetPlatform.iOS ? _iosTheme : _androidTheme,
        title: 'Sample Redux',
        home: new Home(),
      ),
    ),
  );
}

class Home extends StatelessWidget {

  TextEditingController nameController = new TextEditingController();

  @override
  Widget build(context) => new Scaffold(
    appBar: new AppBar(
      title: new Text('Sample Redux')     
    ),
    body: new Container(
      child: new ListView(
        children: <Widget>[
          new ListTile(
            title: new StoreConnector<AppState, String>(
              converter: (store) => store.state.name,
              builder: (context, name) => new Text(
                name != null ? name : "", style: new TextStyle(
                  color: Colors.blue,
                  fontSize: 18.0,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center
              ),
            ),
          ),

          new ListTile(
            title: new TextField(
              textAlign: TextAlign.center,
              autocorrect: true,
              controller: nameController,
              style: new TextStyle(
                color: Colors.lightBlue,
                fontSize: 14.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w500
              ), 
            ),
          ),

          new ListTile(
            title: new StoreConnector<AppState, VoidCallback>(
              converter: (store) => () => store.dispatch(new IncrementAction(nameController.value.text)),
              builder: (context, callback) => new RaisedButton(child: new Text(
                'Change name', style: new TextStyle(
                  color: Colors.white,
                  fontSize: 13.0,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700
                ),
              ), color: Colors.blue, onPressed: callback,),
            ),
          )
        ],
      ),
    ),
  );
}