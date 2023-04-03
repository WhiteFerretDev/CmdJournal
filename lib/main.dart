import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final Command _commandRoot = Command("", (List<String> args){print("command not found");}, [
    Command("new", (List<String> args){print("new command");}, [
      Command("dump", (List<String> args){print("dump command");}, []),
      Command("idea", (List<String> args){print("idea command");}, []),
    ]),
  ]);

  void _handleCommand(String command){
    List<String> commands = command.split(' ');
    _commandRoot.execute(commands);
  }
  
  @override
  Widget build(BuildContext context) {
    return 
      MaterialApp(
        title: 'Journal',
        theme: ThemeData.dark().copyWith(
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                scaffoldBackgroundColor: Colors.black,
                textTheme: ThemeData.dark().textTheme.apply(fontFamily: "Consolas")
              ),
        builder: (context, child) {
          return Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => BaseWidget(child: child!, handleCommand: _handleCommand),
              ),
            ],
          );
        },
        home: HomePage(),
                  
    );
  }

  void handleCommand(String command) {
    List<String> commands = command.split(' ');
      switch (commands[0]) {
        case 'new':
          //pass all comands except the first one to handleCommandNew
          handleCommandNew(commands.sublist(1));
      print('Command entered: $command');
    }
  }

  void handleCommandNew(List<String> commands) {
    switch (commands[0]) {
      case 'dump':
        //navigate to braindump page
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const BrainDumpPage()));
    }
  }
}

class HomePage extends StatefulWidget {

  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archive'),
        actions: [],
      ),
      body:
      Center(
        child: Text(
          'Empty your mind...',
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
      
     floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("page changed");
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BrainDumpPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class BaseWidget extends StatefulWidget {
  final Widget child;
  final Function(String) handleCommand;
  const BaseWidget({required this.child, required this.handleCommand});

  @override
  State<BaseWidget> createState() => _BaseWidgetState();
}

class _BaseWidgetState extends State<BaseWidget> {

  bool _isCommandVisible = false;

  late final TextEditingController _commandController;
  late final FocusNode _commandPromptFocusNode;
  late final FocusNode _keyboardListenerFocusNode;


  void _showCommandPrompt(){
    setState(() {
      _isCommandVisible = true;
    });
    _commandPromptFocusNode.requestFocus();
  }


  @override
  void initState() {
    super.initState();
    _commandController = TextEditingController();
    _commandPromptFocusNode = FocusNode();
    _keyboardListenerFocusNode = FocusNode();
    _keyboardListenerFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _commandController.dispose();
    _commandPromptFocusNode.dispose();
    _keyboardListenerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      
      Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.keyP, control: true) :
              OpenCommandIntent(),
        },
        child: Actions(
          dispatcher: const ActionDispatcher(),
          actions: <Type, Action<Intent>>{
            OpenCommandIntent: CallbackAction<OpenCommandIntent>(
              onInvoke: (OpenCommandIntent intent) {
                _showCommandPrompt();
              },
            )
          },
          child: RawKeyboardListener(
            focusNode: _keyboardListenerFocusNode,
            autofocus: true,
            onKey: (RawKeyEvent event) {
              if (_isCommandVisible) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  // Handle command input here
                  String command = _commandController.text;
                  print('Command entered: $command');
                  widget.handleCommand(command);
                  // Hide the command text field
                  setState(() {
                    _isCommandVisible = false;
                  });
                  // Clear the text field
                  _commandController.clear();
                  _keyboardListenerFocusNode.requestFocus();
                }
              }
            },
            child:
              Stack(
                children: [
                  widget.child,
                  if (_isCommandVisible)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black,
                      child: TextField(
                        controller: _commandController,
                        focusNode: _commandPromptFocusNode,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type command and press enter',
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}

class BrainDumpPage extends StatefulWidget {
  const BrainDumpPage({Key? key}) : super(key: key);

  @override
  _BrainDumpPageState createState() => _BrainDumpPageState();
}

class _BrainDumpPageState extends State<BrainDumpPage> {
  late String _text;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _text = '';
    _textEditingController = TextEditingController();
    _textEditingController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_handleTextChanged);
    _textEditingController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    String newText = _textEditingController.text;
    if (newText.length > _text.length) {
      // New text has been added, so update the _text variable.
      _text = newText;
    } else {
      // User tried to delete text, so reset the text to the previous value.
      _textEditingController.value = TextEditingValue(
        text: _text,
        selection: TextSelection.collapsed(offset: _text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Braindump'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 64.0),
                    child: AppTextField(controller: _textEditingController),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _textEditingController.text += ' ';
                        _textEditingController.selection = TextSelection.collapsed(offset: _textEditingController.text.length);
                      });
                    },
                    icon: Icon(Icons.check),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OpenCommandIntent extends Intent {
  const OpenCommandIntent();
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;

  AppTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(fontSize: 18.0, fontFamily: "Consolas", color: Colors.white),
      maxLines: null,
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Type fast and dont look back...',
        hintStyle: TextStyle(fontSize: 18.0, color: Colors.white54),
        border: InputBorder.none,
      ),
      cursorColor: Colors.white,
      onChanged: (_) {
        controller.selection = TextSelection.collapsed(offset: controller.text.length);
      },
    );
  }
}


class Command{
  final String keyword;
  final Function(List<String>) command;
  final List<Command> subCommands;

  Command(this.keyword, this.command, this.subCommands);

  void execute(List<String> args){
    // only do if lenght of arg is greater than 1
    if (args.length > 0){
      for (Command subCommand in subCommands){
        if (subCommand.keyword == args[0]){
          subCommand.execute(args.sublist(1));
          return;
        }
      }
    }
    command(args);

  }
}