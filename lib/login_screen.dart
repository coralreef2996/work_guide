import 'package:flutter/material.dart';
import 'main.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  final String appName;
  final Widget?
  originalHome; // Option to pass the original home screen for reference/debugging

  const LoginScreen({super.key, required this.appName, this.originalHome});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<bool> _isSelected = [true, false]; // [利用者, 管理者]
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _autoLogin = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _isSelected[1];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFBCBCE8)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('${widget.appName} - ログイン'),
          centerTitle: true,
          backgroundColor: Colors.white.withOpacity(0.8),
          elevation: 0,
        ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アプリ名表示
              Text(
                widget.appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF04044C),
                ),
              ),
              const SizedBox(height: 32),

              // 「利用者」と「管理者」の切り替えスイッチ
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ToggleButtons(
                  isSelected: _isSelected,
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < _isSelected.length; i++) {
                        _isSelected[i] = i == index;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  constraints: const BoxConstraints(minWidth: 120, minHeight: 45),
                  selectedColor: Colors.white,
                  fillColor: const Color(0xFF04044C),
                  children: const [
                    Text(
                      '利用者',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '管理者',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ID入力
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'アカウント名/メールアドレス',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'アカウント名またはメールアドレスを入力',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),

              // パスワード入力
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'パスワード',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'パスワードを入力',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),

              // 自動ログイン
              Row(
                children: [
                  Checkbox(
                    value: _autoLogin,
                    activeColor: const Color(0xFF04044C),
                    onChanged: (bool? value) {
                      setState(() {
                        _autoLogin = value ?? false;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _autoLogin = !_autoLogin;
                      });
                    },
                    child: const Text('自動ログインをする'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ログインボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF04044C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (isAdmin) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminHomeScreen(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainNavigationScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'ログイン',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // パスワードを忘れた場合
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF04044C),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('パスワード再設定メールを送信しました（ダミー）')),
                  );
                },
                child: const Text('パスワードを忘れた方はこちら'),
              ),

              // デバッグ用：元の画面を表示するボタン
              if (widget.originalHome != null) ...[
                const SizedBox(height: 24),
                const Divider(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF04044C),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => widget.originalHome!,
                      ),
                    );
                  },
                  icon: const Icon(Icons.developer_mode),
                  label: const Text('元の画面を表示 (デバッグ用)'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF04044C),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminManagementScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text('下書き管理画面'),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
}

