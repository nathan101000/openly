import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../digest_auth_client.dart'; // <-- Import the custom DigestAuthClient

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _imageBase64;
  bool _loading = false;
  String? _error;
  String? _savedUsername;
  String? _savedPassword;

  Future<void> _fetchSnapshot({String? username, String? password}) async {
    setState(() {
      _loading = true;
      _error = null;
      _imageBase64 = null;
    });
    try {
      final user = username ?? _savedUsername ?? _usernameController.text;
      final pass = password ?? _savedPassword ?? _passwordController.text;
      final digestClient = DigestAuthClient(username: user, password: pass);
      final uri = Uri.parse(
          'http://spencertower.araknisdns.com:8088/api/camera/snapshot?width=1920&height=1080&fps=15');
      // Add timeout for debugging stuck requests
      final response =
          await digestClient.get(uri).timeout(const Duration(seconds: 10));
      final contentType = response.headers['content-type'];
      print('📸 Response status: ${response.statusCode}');
      print('📸 Content-Type: $contentType');
      print('📸 Body length: ${response.bodyBytes.length}');

      if (response.statusCode == 200 &&
          contentType != null &&
          contentType.startsWith('image/')) {
        final bytes = response.bodyBytes;

        // Safety check for image size
        if (bytes.length < 1000) {
          print('⚠️ Image data too small, possible error response');
          try {
            print('🧾 Body (utf8): ${utf8.decode(bytes)}');
          } catch (_) {
            print('🧾 Body not valid UTF8');
          }
          setState(() => _error = 'Camera returned invalid image');
          return;
        }

        setState(() {
          _imageBase64 = base64Encode(bytes);
          _savedUsername = user;
          _savedPassword = pass;
        });
      } else {
        print('❌ Not an image response');
        try {
          print('🧾 Error body (utf8): ${utf8.decode(response.bodyBytes)}');
        } catch (_) {
          print('❌ Failed to decode error body');
        }

        setState(() {
          _error = 'Invalid image or error response: $contentType';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _loading ? null : () => _fetchSnapshot(),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Login & Show Snapshot'),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (_imageBase64 == null) return const SizedBox.shrink();
    try {
      return AspectRatio(
        aspectRatio: 3 / 2,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            base64Decode(_imageBase64!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } catch (e) {
      print('🛑 Image render failed: $e');
      return const Text('Failed to show snapshot');
    }
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_imageBase64 != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildImage(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Snapshot'),
              onPressed: () => _fetchSnapshot(),
            ),
          ),
        ],
      );
    }
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          _buildLoginForm(),
        ],
      );
    }
    return _buildLoginForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }
}
