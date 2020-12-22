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
  List _todoList = [];
  final _todoController = TextEditingController();
  void _addTodo(){
    setState(() {
      Map<String,dynamic> newTodo = Map();
      newTodo["title"] = _todoController.text;
      _todoController.text = "";
      newTodo["ok"] = false;
      _todoList.add(newTodo);
    });
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
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _todoList.length,
                  itemBuilder: (context, index){
                   return CheckboxListTile(
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
                       });
                     },
                   );
                  })
          )
        ],
      ),
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


