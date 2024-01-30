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
  List _listaTarefas = [];
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();

    _controllerTarefa.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  Widget criarItemLista(context, index) {
    final item = _listaTarefas[index]["titulo"];

    return Dismissible(
      key: Key(item),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        //Remove item da lista
        setState(() {
          _listaTarefas.removeAt(index);
        });
        _salvarArquivo();

        // Mostra um Snackbar informando que o item foi excluído
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarefa excluída!'),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]['titulo']),
        value: _listaTarefas[index]['realizada'],
        onChanged: (valorAlterado) {
          setState(() {
            _listaTarefas[index]['realizada'] = valorAlterado;
          });

          _salvarArquivo();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //_salvarArquivo();
    print("itens: " + _listaTarefas.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de tarefas",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Sobre'),
                  value: 'Sobre',
                ),
                // Adicione mais itens do menu conforme necessário
              ];
            },
            onSelected: (value) {
              // Implemente aqui o que deseja fazer com a opção selecionada
              if (value == 'Sobre') {
                // Ação para a opção 1
                _exibirInfo(context);
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            color: Colors.white,
          ),
        ],
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white, // Define a cor do ícone como branco
        ),
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Adicionar Tarefa"),
                content: TextField(
                  controller: _controllerTarefa,
                  decoration: InputDecoration(labelText: "Digite sua tarefa"),
                  onChanged: (text) {},
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () {
                      // salvar
                      _salvarTarefa();
                      Navigator.pop(context);
                    },
                    child: Text("Salvar"),
                  ),
                ],
              );
            },
          );
        },
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: criarItemLista,
            ),
          )
        ],
      ),
    );
  }
}

// Adicione esta função para exibir o AlertDialog
void _exibirInfo(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Sobre o Aplicativo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Este é um aplicativo de lista de tarefas."),
            SizedBox(height: 10),
            Text("Desenvolvido por: Ruan Victor Figueredo"),
            Text("Versão: 1.0.0"),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fechar"),
          ),
        ],
      );
    },
  );
}
