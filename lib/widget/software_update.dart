import 'dart:io';

import 'package:flutter/material.dart';

class Sofwate_update extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Update the software'),
          centerTitle: true,
        ),
        body: GitBuildWidget(),
      ),
    );
  }
}

class GitBuildWidget extends StatefulWidget {
  @override
  _GitBuildWidgetState createState() => _GitBuildWidgetState();
}

class _GitBuildWidgetState extends State<GitBuildWidget> {
  String _output = "";
  bool _isLoading = false;

  void _runBuild() async {
    setState(() {
      _isLoading = true;
      _output = "";
    });

    try {
      // Run git stash
      ProcessResult stashResult =
          await Process.run('git', ['stash'], workingDirectory: '/home/pi/h1/');
      _appendOutput(stashResult.stdout);
      _appendOutput(stashResult.stderr);

      // Run git pull
      ProcessResult pullResult =
          await Process.run('git', ['pull'], workingDirectory: '/home/pi/h1/');
      _appendOutput(pullResult.stdout);
      _appendOutput(pullResult.stderr);

      // Run flutter build linux
      ProcessResult buildResult = await Process.run(
          '/home/pi/flutter/bin/flutter', ['build', 'linux'],
          workingDirectory: '/home/pi/h1/',  environment: {
      'DISPLAY': ':0',
      'XDG_RUNTIME_DIR': '/run/user/1000',
      'HOME': '/home/pi'
    },);
      _appendOutput(buildResult.stdout);
      _appendOutput(buildResult.stderr);

      setState(() {
        _output += "\nBuild completed successfully!";
      });
    } catch (e) {
      setState(() {
        _output += "\nError: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  

  void _appendOutput(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _output += text + '\n';
      });
    }
  }

  void _runRaspiConfig() async {
    setState(() {
      _output = "Running raspi-config...";
    });

    try {
      ProcessResult result = await Process.run('sudo',
    ['raspi-config'],
    runInShell: true,);
      _appendOutput(result.stdout);
      _appendOutput(result.stderr);
    } catch (e) {
      setState(() {
        _output += "\nError: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensures the column shrinks to its content
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _runBuild,style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.teal)),
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 43, 43, 83)),
                    )
                  : Text(
                      'Build & Update',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
          ElevatedButton(
            onPressed: _runRaspiConfig,
            child: Text('Get Config'),
          ),
          
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 600, // Limit the width for better readability
                  maxHeight: 300, // Limit height to prevent overflow
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output,
                    style: TextStyle(fontFamily: 'monospace', color: Colors.teal),
                    textAlign: TextAlign
                        .center, // Align text in the center horizontally
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
