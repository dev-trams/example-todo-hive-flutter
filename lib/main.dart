import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_hive/hive_helper.dart';
import 'package:todo_hive/task.dart';

void main() async {
  await Hive.initFlutter(); // Hive에서 Flutter을 사용할 때 준비할 수 있게 초기화 함.
  Hive.registerAdapter(TaskAdapter());
  await HiveHelper().openBox();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Task'),
          content: TextField(
            autofocus: true,
            onSubmitted: (String text) {
              setState(() {
                HiveHelper().create(Task(text));
              });
              Navigator.of(context).pop();
            },
            textInputAction: TextInputAction.send,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
        future: HiveHelper().read(),
        builder: (context, snapshot) {
          List<Task> _tasks = snapshot.data ?? [];
          return Scaffold(
            appBar: AppBar(title: const Text('To do')),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _showMyDialog();
              },
            ),

            ///ListView와 비슷한 ListView위젯
            ///* proxyDecorator - 리스트뷰를 롱클릭할 시 이동할 수있는 상태를 적용할 수있음
            ///* onReorder - 이전 상태(oldList)와 현재 상태(newList)를 받아와 위치를 변경했을 때 적용하는 메소드
            body: ReorderableListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
                return TaskTile(task: _tasks[index], onDeleted: () {});
              },
              children: <Widget>[
                for (int index = 0; index < _tasks.length; index += 1)
                  Padding(
                    key: Key('$index'),
                    padding: const EdgeInsets.all(8.0),
                    child: TaskTile(
                      task: _tasks[index],
                      onDeleted: () {
                        setState(() {});
                      },
                    ),
                  )
              ],
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Task item = _tasks.removeAt(oldIndex);
                  _tasks.insert(newIndex, item);
                });
              },
            ),
          );
        });
  }
}

class TaskTile extends StatefulWidget {
  const TaskTile({
    Key? key,
    required this.task,
    required this.onDeleted,
  }) : super(key: key);

  final Task task;
  final Function onDeleted;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color evenItemColor = colorScheme.primary;
    return Material(
      child: AnimatedContainer(
        constraints: const BoxConstraints(minHeight: 60),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.task.finished ? Colors.grey : evenItemColor,
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        child: Row(
          children: [
            Checkbox(
              key: widget.key,
              value: widget.task.finished,
              onChanged: (checked) {
                widget.task.finished = checked!;
                widget.task.save();
                setState(() {});
              },
            ),
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  decoration: widget.task.finished
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () {
                widget.task.delete();
                widget.onDeleted;
              },
            )
          ],
        ),
      ),
    );
  }
}
