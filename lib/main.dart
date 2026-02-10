import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1DB954);
    const backgroundGrey = Color(0xFFF3F4F6);

    return MaterialApp(
      title: 'Login Demo Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          background: backgroundGrey,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundGrey,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          elevation: 6,
          margin: EdgeInsets.all(16),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class AppUser {
  final String username;
  final String passwordHash;

  const AppUser({
    required this.username,
    required this.passwordHash,
  });
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  // Usuários de exemplo, com senhas armazenadas como hash SHA-256.
  // admin / abacaxi
  // maria / laranja
  // joao / banana
  static const List<AppUser> _users = [
    AppUser(
      username: 'admin',
      passwordHash:
          '89619cc6b8a3fa6c38e7bd1661b4c70d10ed5049e6d27abb1bbd00673285a611',
    ),
    AppUser(
      username: 'maria',
      passwordHash:
          '7595ad35b6d1dc21956d0a9357353af0cdb5b21ef02593c228854e55423d7bad',
    ),
    AppUser(
      username: 'joao',
      passwordHash:
          'b493d48364afe44d11c0165cf470a4164d1e2609911ef998be868d46ade3de4e',
    ),
  ];

  bool _checkPassword(String plainPassword, String storedHash) {
    final bytes = utf8.encode(plainPassword);
    final digest = sha256.convert(bytes);
    return digest.toString() == storedHash;
  }

  void _doLogin() {
    final username = _userController.text.trim();
    final password = _passwordController.text;

    final user = _users.firstWhere(
      (u) => u.username == username,
      orElse: () => const AppUser(username: '', passwordHash: ''),
    );

    if (user.username.isNotEmpty &&
        _checkPassword(password, user.passwordHash)) {
      setState(() {
        _errorMessage = null;
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatPage(currentUser: user, allUsers: _users),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Usuário ou senha inválidos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bem-vindo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Faça login para continuar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: 'Usuário',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _doLogin,
                      child: const Text('Entrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final AppUser from;
  final AppUser to;
  final String text;

  const ChatMessage({
    required this.from,
    required this.to,
    required this.text,
  });
}

class ChatPage extends StatefulWidget {
  final AppUser currentUser;
  final List<AppUser> allUsers;

  const ChatPage({
    super.key,
    required this.currentUser,
    required this.allUsers,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late AppUser _selectedRecipient;
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _selectedRecipient = widget.allUsers.firstWhere(
      (u) => u.username != widget.currentUser.username,
      orElse: () => widget.currentUser,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.currentUser.username}'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('Conversar com: '),
                    const SizedBox(width: 8),
                    DropdownButton<AppUser>(
                      value: _selectedRecipient,
                      items: widget.allUsers
                          .where(
                              (u) => u.username != widget.currentUser.username)
                          .map(
                            (u) => DropdownMenuItem<AppUser>(
                              value: u,
                              child: Text(u.username),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedRecipient = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe =
                        msg.from.username == widget.currentUser.username;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${msg.from.username} → ${msg.to.username}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Digite uma mensagem...',
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          from: widget.currentUser,
          to: _selectedRecipient,
          text: text,
        ),
      );
      _messageController.clear();
    });
  }
}
