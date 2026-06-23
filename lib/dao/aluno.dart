import 'package:flutter/cupertino.dart';

import '../database/db.dart';
import '../model/aluno.dart';
import 'package:sqflite_common/sqflite.dart';

Future<int> insert(Aluno aluno) async {
  final Database db = await getDatabase();

  return db.insert(
    'alunos',
    aluno.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Map<String, dynamic>>> findAll() async {
  final Database db = await getDatabase();
  final List<Map<String, dynamic>> result = await db.query("alunos");
  return result;
}

Future<int> deleteById(int id) async {
  final Database db = await getDatabase();
  return db.delete("alunos", where: "id = ?", whereArgs: [id]);
}

Future<List<Map<String, dynamic>>> findByName(String name) async {
  final Database db = await getDatabase();
  return await db.query("alunos", where: "nome LIKE ?", whereArgs: ['%$name%']);
}

