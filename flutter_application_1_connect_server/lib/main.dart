import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barang Barang Dapur', // Ubah nama aplikasi di sini
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ImageUploader()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Ganti dengan path logo yang sesuai
                width: 100, // Sesuaikan ukuran logo
                height: 100,
              ),
              const SizedBox(height: 16),
              CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Barang Barang Dapur',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageUploader extends StatefulWidget {
  const ImageUploader({Key? key}) : super(key: key);

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  File? _image;
  bool isUploading = false;
  String responseMessage = '';
  bool isLoading = true;
  int splashScreenDuration = 2;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: splashScreenDuration), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Ganti dengan path logo yang sesuai
                width: 100, // Sesuaikan ukuran logo
                height: 100,
              ),
              const SizedBox(height: 16),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.of(context).pop();
                final image =
                    await ImagePicker().getImage(source: ImageSource.gallery);
                _handleImage(image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Gunakan Kamera'),
              onTap: () async {
                Navigator.of(context).pop();
                final image =
                    await ImagePicker().getImage(source: ImageSource.camera);
                _handleImage(image);
              },
            ),
          ],
        );
      },
    );
  }

  void _handleImage(PickedFile? image) {
    setState(() {
      if (image != null) {
        _image = File(image.path);
        responseMessage = '';
      } else {
        debugPrint('No image selected.');
      }
    });
  }

  Future uploadImage() async {
    if (_image == null) {
      debugPrint('No image selected.');
      return;
    }

    setState(() {
      isUploading = true;
    });

    final uri = Uri.parse("http://192.168.1.3:5000/upload");
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      debugPrint('Image uploaded');
      String responseBody = await response.stream.bytesToString();
      setState(() {
        responseMessage = responseBody;
      });

      showColoredDialog('Hasil Klasifikasi', responseMessage, Colors.cyan);

      resetImage();
    } else {
      debugPrint('Image not uploaded');

      showColoredDialog('Error', 'Image not uploaded', Colors.red);
    }

    setState(() {
      isUploading = false;
    });
  }

  void resetImage() {
    setState(() {
      _image = null;
      responseMessage = '';
    });
  }

  Future<void> showColoredDialog(
      String title, String content, Color backgroundColor) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            content,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: backgroundColor,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildMainScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Barang Barang Dapur ',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: _image != null
                        ? AspectRatio(
                            aspectRatio: 1.0,
                            child: Image.file(
                              _image!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey,
                            child: Center(
                              child: Text(
                                'No image selected.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Visibility(
                    visible: _image != null && !isUploading,
                    child: ElevatedButton(
                      onPressed: uploadImage,
                      child: const Text('Upload Foto'),
                    ),
                  ),
                  Visibility(
                    visible: isUploading,
                    child: const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: getImage,
                    child: const Text('Pilih Foto'),
                  ),
                  const SizedBox(height: 16),
                  Visibility(
                    visible: responseMessage.isNotEmpty,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Hasil Klasifikasi:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          responseMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? _buildSplashScreen() : buildMainScreen();
  }
}
