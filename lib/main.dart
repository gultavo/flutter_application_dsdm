import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/dao/aluno.dart';
import 'package:flutter_application_1/model/aluno.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MaterialApp(home: PaginaInicial(), debugShowCheckedModeBanner: false));
}

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(children: [Text("Yuri")]),
    );
  }
}

class Detalhes extends StatelessWidget {
  final Aluno aluno;

  const Detalhes(this.aluno, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes"),
        backgroundColor: Colors.greenAccent,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(40, 50, 40, 16),
        children: [
          Image.asset("images/toyota.png"),
          Text(
            "Nome: ${aluno.nome}\n",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          Text(
            "Matrícula: ${aluno.matricula}\n",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(
            "Telefone: ${aluno.telefone}\n",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Image.network(
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR68vwmxLehqx4RzXnMM0c0OteqPkSjZwWqMQ&s",
          ),
        ],
      ),
    );
  }
}

class _PaginaInicialState extends State<PaginaInicial> {
  Future<List<Map<String, dynamic>>> alunosFuture = findByName("");
  TextEditingController filtro = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Settings()),
            );
          },
          icon: Icon(Icons.settings),
        ),
        title: Text("data"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SearchBar(
            leading: Icon(Icons.search),
            hintText: "Digite o nome do aluno",
            controller: filtro,
            onChanged: (value) {
              setState(() {
                alunosFuture = findByName(filtro.text);
              });
            },
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            initialData: const [],
            future: alunosFuture,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                case ConnectionState.done:
                  final alunos = snapshot.data as List<Map<String, dynamic>>;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: alunos.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR68vwmxLehqx4RzXnMM0c0OteqPkSjZwWqMQ&s',
                          ),
                        ),
                        title: Text(
                          "Aluno: ${alunos[index]['nome']} - ${alunos[index]['telefone']}",
                        ),
                        subtitle: Text(
                          "Matrícula: ${alunos[index]['matricula']}",
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            deleteById(alunos[index]['id']).then((_) {
                              setState(() {
                                alunosFuture = findByName(filtro.text);
                              });
                            });
                          },
                          icon: Icon(Icons.delete),
                        ),
                      );
                    },
                  );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormularioCadastro()),
          ).then((_) {
            setState(() {
              alunosFuture = findByName(filtro.text);
            });
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class FormularioCadastro extends StatelessWidget {
  const FormularioCadastro({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController nome = TextEditingController();
    TextEditingController telefone = TextEditingController();
    TextEditingController matricula = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Formulário"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: EdgeInsets.all(30.0),
        children: [
          TextField(
            controller: nome,
            decoration: InputDecoration(
              labelText: "Nome",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: telefone,
            decoration: InputDecoration(
              labelText: "Telefone",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: matricula,
            decoration: InputDecoration(
              labelText: "Matrícula",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (nome.text.isNotEmpty &&
                  telefone.text.isNotEmpty &&
                  matricula.text.isNotEmpty) {
                insert(
                  Aluno(
                    nome: nome.text,
                    telefone: telefone.text,
                    matricula: matricula.text,
                  ),
                );
                Navigator.pop(context);
              } else {
                debugPrint("Preencha todos os campos");
              }
            },
            child: Text("Enviar"),
          ),
        ],
      ),
    );
  }
}