import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "dart:async";
import "dart:io";
import "dart:convert";

void main(){
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _todoController = TextEditingController();
  List _todoList = [];

  Map<String, dynamic> _lastRemoved;

  int _lastRemovedPos;


  @override
  void initState() {
    super.initState();

    _readData().then((value){
      setState(() {
        _todoList = json.decode(value);
      });
    });
  }

  void _addTodo(){
    setState(() {
      Map<String,dynamic> newTodo = Map();
      newTodo["title"] = _todoController.text;
      _todoController.text = "";
      newTodo["ok"] = false;
      _todoList.add(newTodo);
      _saveData();
    });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));
    _todoList.sort((a,b){
      if(a["ok"] && !b["ok"]) return 1;
      if(!a["ok"] && b["ok"]) return -1;
      return 0;
    });
    setState(() {
      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: "Nova Tarefa",
                          labelStyle: TextStyle(color: Colors.blueAccent)
                      ),
                      controller: _todoController,
                    ),
                ),
                RaisedButton(
                  onPressed: _addTodo,
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: _todoList.length,
                    itemBuilder: buildItem),
                onRefresh: _refresh,
              )
          )
        ],
      ),
    );
  }

  Widget buildItem(context, index){
    return Dismissible(
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9,0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
        direction: DismissDirection.startToEnd,
        key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
        child: CheckboxListTile(
          title: Text(_todoList[index]["title"]),
          value: _todoList[index]["ok"],
          secondary: CircleAvatar(
            child: Icon(
                _todoList[index]["ok"] ? Icons.check : Icons.error
            ),
          ),
          onChanged: (c){
            setState(() {
              _todoList[index]["ok"] = c;
              _saveData();
            });
          },
        ),
        onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPos = index;
          _todoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
              content: Text("Tarefa ${_lastRemoved["title"]} removida!"),
            action: SnackBarAction(label: "Desfazer", onPressed: (){
              setState(() {
                _todoList.insert(_lastRemovedPos, _lastRemoved);
                _saveData();
              });
            },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();  
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async{
    try{
      final file = await _getFile();

      return file.readAsString();
    }catch(e){
      return null;
    }
  }
}


