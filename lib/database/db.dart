import 'package:path/path.dart'; //Responsavel pelo acesso aos diretorios do dispositivo
import 'package:sqflite_common/sqflite.dart'; //Banco

Future<Database> getDatabase() async {
  final String caminhoBanco = join(await getDatabasesPath(), 'aluno.db');
  return openDatabase(
    caminhoBanco,
    onCreate: (db, version) {
      //Comando para criar as tabelas do banco.
      db.execute('''CREATE TABLE alunos(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT,
      telefone TEXT,
      matricula TEXT
    )''');
    },
    version: 1,
  );
}
