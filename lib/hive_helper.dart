import 'package:hive/hive.dart';
import 'package:todo_hive/task.dart';

const String TASK_BOX = 'TASK_BOX';

///HiveHelper
///* Singleton Patten
class HiveHelper {
  static final HiveHelper _singleton = HiveHelper._internal();

  factory HiveHelper() {
    return _singleton;
  }
  HiveHelper._internal();

  Box<Task>? tasksBox;

  Future openBox() async {
    tasksBox = await Hive.openBox(TASK_BOX);
  }

  // * CURD

  Future create(Task newTask) async {
    return tasksBox!.add(newTask);
  }

  Future<List<Task>> read() async {
    return tasksBox!.values.toList();
  }

  Future update(int index, Task updatedTask) async {
    tasksBox!.putAt(index, updatedTask);
  }

  Future delete(int index) async {
    tasksBox!.deleteAt(index);
  }
}
