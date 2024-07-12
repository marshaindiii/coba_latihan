import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', cameras: cameras),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final List<CameraDescription> cameras;

  const MyHomePage({super.key, required this.title, required this.cameras});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _navigateToPermissionsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PermissionsPage(cameras: widget.cameras)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: _navigateToPermissionsPage,
              child: const Text('Go to Permissions Page'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PermissionsPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const PermissionsPage({super.key, required this.cameras});

  @override
  _PermissionsPageState createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool _cameraPermission = false;
  CameraController? _cameraController;

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      if (await Permission.camera.request().isGranted) {
        setState(() {
          _cameraPermission = true;
          _showCameraSuggestion();
        });
      }
    } else {
      setState(() {
        _cameraPermission = true;
        _showCameraSuggestion();
      });
    }
  }

  void _showCameraSuggestion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Suggestion'),
          content: const Text('You have enabled camera permission. Do you want to open the camera now?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Camera'),
              onPressed: () {
                Navigator.of(context).pop();
                _openCamera();
              },
            ),
          ],
        );
      },
    );
  }

  void _openCamera() {
    if (_cameraPermission) {
      _cameraController = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      _cameraController?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraPreviewScreen(controller: _cameraController!),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Camera Permission'),
            value: _cameraPermission,
            onChanged: (bool value) {
              if (value) {
                _requestCameraPermission();
              }
            },
          ),
        ],
      ),
    );
  }
}

class CameraPreviewScreen extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera Preview'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Preview'),
      ),
      body: CameraPreview(controller),
    );
  }
}
