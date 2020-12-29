import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _taskList = [];
  Map<String,dynamic> _lastTaskRemoved = Map();
  TextEditingController _controllerTask = TextEditingController();

  Future<File> get _getFile async {
    final directory = await getApplicationDocumentsDirectory();
    print("${directory.path}/dados.json");
    return File( "${directory.path}/dados.json" );
  }

  _saveTask(){
    String _textTask = _controllerTask.text;
    Map<String,dynamic> task = Map();
    
    task['title'] = _textTask;
    task['status'] = false;

    setState(() {
      _taskList.add(task);  
    });
    _saveList();
    _controllerTask.text = "";
  }

  _saveList() async {
    var file = await _getFile;
    String data = json.encode(_taskList);
  
    file.writeAsString(data); 
    print('escrito ${data.toString()}');
  }

  _readList() async {
    try{
      var file = await _getFile;
      print('lido');
      return file.readAsString();
    }catch(e){
      print('erro');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    //print("antes de ler");

    try{
      _readList().then( (data){
        setState(() {
          _taskList = json.decode(data);
          
        });
        }
      );
    }
    catch(e){
      print(e.toString());
    }
    
    //print("aqui passou");
  }

  Widget createItemList(context, index){

    var item = DateTime.now().millisecondsSinceEpoch.toString();
    
    return Dismissible(
      key: Key(item),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white
            )
          ],
        ),
      ),
      onDismissed: (direction){
        
        _lastTaskRemoved = _taskList[index];

        _taskList.removeAt(index);
        _saveList();

        final snackbar = SnackBar(
          content: Text("Item removido com sucesso"),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: "Desfazer", 
            onPressed: () {

                setState(() {
                  _taskList.insert(index, _lastTaskRemoved);  
                });
                _saveList();

            },
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);

      },
      child: CheckboxListTile(
          title: Text(_taskList[index]['title']), 
          value: _taskList[index]['status'],
          onChanged: (valueChanged){
            setState(() {
              _taskList[index]['status'] = valueChanged;
            });
            _saveList();
          },
        ),
    );

  }

  @override
  Widget build(BuildContext context) {

    //_saveList();
    //print("itens: " + _taskList.toString());

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
        onPressed: (){
          showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                title: Text("Adicionar tarefa"),
                content: TextField(
                  controller: _controllerTask,
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.redAccent,
                  decoration: InputDecoration(
                    labelText: "Digite sua nova tarefa",
                    labelStyle: TextStyle(color: Colors.redAccent),
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Cancelar"),
                    color: Colors.white,
                    textColor: Colors.grey,
                    onPressed: ()=> Navigator.pop(context),
                  ),
                  FlatButton(
                    child: Text("Salvar"),
                    color: Colors.redAccent,
                    onPressed: (){
                      _saveTask();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            }
            );
        },
      ),
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.redAccent
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _taskList.length,
                itemBuilder: createItemList

              ),
           )
          ],
        ),
      ),
    );
  }
}
