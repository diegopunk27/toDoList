import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Todo list",
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class Tareas {
  String name;
  bool state;
  String date;

  Tareas(this.name)
      : state = false,
        date = DateFormat('dd/MM/yyyy')
            .add_Hm()
            .format(DateTime.now()); //new DateTime.now();

  Tareas.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        state = json['state'],
        date = json['date'];

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "state": state,
      "date": date,
    };
  }

  String toString() => "$name, $state, $date";

  void toogleState() {
    state = !state;
  }
}

class _TodoListState extends State<TodoList> {
  List<Tareas> listAct;
  bool loading;

  @override
  void initState() {
    listAct = [];
    loading = true;
    readJson();
    super.initState();
  }

  /* Se utiliza esta función que escucha cada vez que se llama al setState en la aplicacion. De esta manera
    para cada cambio de estado en la lista, se escribe en el archivo
   */
  @override
  void setState(fn) {
    super.setState(fn);
    writeJson();
  }

  readJson() async {
    /*await Future.delayed(Duration(seconds: 5));
    super.setState(() {
      listAct = [
        Tareas("Tarea 1"),
        Tareas("Tarea 3"),
      ];
      loading = false;
    });*/
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/todoList.jsons");
      final json = jsonDecode(await file.readAsString());
      List<Tareas> newList = [];
      for (var item in json) {
        newList.add(Tareas.fromJson(item));
      }
      /* Utilizo el "super.setState", que es la clase padre de SetState, para que refresque la Lista 
        y no invoque al "void setState(fn)" que contiene al "writeJson". Sino se generaria una escritura
        cada vez que se lee, generando un bucle o error
      */
      super.setState(() {
        listAct = newList;
        loading = false;
      });
    } catch (e) {
      print("No se pudo escribir el archivo");
      /*Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("No se pudo escribir el archivo"),
        ),
      );*/
    }
  }

  writeJson() async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/todoList.json");
      List newjson = [];
      //print(listAct[0].toString());
      //print(listAct[0].toJson());
      for (var item in listAct) {
        newjson.add(item.toJson());
      }
      String json = jsonEncode(newjson);
      await file.writeAsString(json);
    } catch (e) {
      print("No se pudo leer el archivo");
      /*Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("No se pudo leer el archivo"),
        ),
      );*/
    }
  }

  @override
  Widget build(BuildContext context) {
    int cantStatusOk() {
      return listAct.where((element) => element.state).length;
    }

    void _confirmarElimina() {
      if (cantStatusOk() > 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Confirmación"),
              content: Text(
                  "¿Está seguro que desea eliminar las tareas seleccionadas?"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancelar"),
                ),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Borrar"),
                ),
              ],
            );
          },
        ).then((value) {
          if (value) {
            setState(() {
              listAct.removeWhere((element) => element.state);
            });
          }
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista Tareas"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => _confirmarElimina(),
          ),
        ],
      ),
      body: Container(
        child: ListView.separated(
          itemBuilder: (context, index) {
            if (loading) {
              return Center(child: CircularProgressIndicator());
            }
            return Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      listAct[index].toogleState();
                    });
                  },
                  child: ListTile(
                    leading: Checkbox(
                      value: listAct[index].state,
                      onChanged: (value) {
                        setState(() {
                          listAct[index].state = value;
                        });
                      },
                    ),
                    title: Text(
                      listAct[index].name,
                      style: TextStyle(
                        decoration: listAct[index].state
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(listAct[index].date.toString()),
                  ),
                ),
              ],
            );
          },
          itemCount: listAct.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(builder: (context) => AgregaTarea()),
          )
              .then((value) {
            if (value != null) {
              setState(() {
                listAct.add(
                  Tareas(value),
                );
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AgregaTarea extends StatefulWidget {
  @override
  _AgregaTareaState createState() => _AgregaTareaState();
}

class _AgregaTareaState extends State<AgregaTarea> {
  TextEditingController controller;
  @override
  void initState() {
    controller = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Tarea"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: TextField(
                      controller: controller,
                      onSubmitted: (value) {
                        Navigator.of(context).pop(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          controller.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                },
                child: Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
