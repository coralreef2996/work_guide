import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'main.dart';

// ==========================================
// 管理者用画面 (作業手順)
// ==========================================

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  static const Color iconColor = Color(0xFF04044C);
  static const Color gradientBaseColor = Color(0xFFBCBCE8);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final GlobalKey<_PersonalDataTabState> _personalDataTabKey =
      GlobalKey<_PersonalDataTabState>();
  final GlobalKey<_AnalysisTabState> _analysisTabKey =
      GlobalKey<_AnalysisTabState>();

  void _handleBack() {
    if (_personalDataTabKey.currentState?.handleBack() == true) {
      return;
    }
    if (_analysisTabKey.currentState?.handleBack() == true) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(
          appName: '作業手順',
          originalHome: MainNavigationScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: DefaultTabController(
        length: 4,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, AdminHomeScreen.gradientBaseColor],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.white.withOpacity(0.9),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AdminHomeScreen.iconColor),
                tooltip: '戻る',
                onPressed: _handleBack,
              ),
              title: Text(
                '作業手順',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AdminHomeScreen.iconColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              bottom: TabBar(
                labelColor: AdminHomeScreen.iconColor,
                unselectedLabelColor: Colors.black54,
                indicatorColor: AdminHomeScreen.iconColor,
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 10,
                height: 1.1,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.people_alt_outlined),
                  child: Text(
                    '個人データ\n一覧',
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  icon: Icon(Icons.analytics_outlined),
                  child: Text(
                    '分析\n職員用メモ',
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  icon: Icon(Icons.app_settings_alt_outlined),
                  child: Text(
                    '機能編集\n管理',
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  icon: Icon(Icons.import_export_outlined),
                  child: Text(
                    '外部出力\n連携',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _PersonalDataTab(key: _personalDataTabKey, iconColor: AdminHomeScreen.iconColor),
              _AnalysisTab(key: _analysisTabKey, iconColor: AdminHomeScreen.iconColor),
              const _AppEditTab(iconColor: AdminHomeScreen.iconColor),
              const _ExportTab(iconColor: AdminHomeScreen.iconColor),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _AdminSubHeader extends StatelessWidget {
  final Color iconColor;
  const _AdminSubHeader({required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左上：「設定」ボタン
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: iconColor,
              side: BorderSide(color: iconColor.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
            ),
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('設定'),
          ),

          // 右上：「使い方」プルダウンメニューボタン
          PopupMenuButton<String>(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            onSelected: (String value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: iconColor,
                  content: Text(
                    '$value が選択されました',
                    style: const TextStyle(color: Colors.white),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: '使い方１',
                child: Text('使い方１', style: TextStyle(color: iconColor)),
              ),
              PopupMenuItem<String>(
                value: '使い方２',
                child: Text('使い方２', style: TextStyle(color: iconColor)),
              ),
              PopupMenuItem<String>(
                value: '使い方３',
                child: Text('使い方３', style: TextStyle(color: iconColor)),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: iconColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 18,
                    color: iconColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '使い方',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: iconColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Mock User Data for Work Guide
class GuideUser {
  final String name;
  final int totalSp;
  final List<String> trophies;
  final List<Map<String, dynamic>> stepupGoals; // title, isCompleted
  final List<String> completedTimeline;
  final String instructionNote;
  final String aptitudeResult;
  final String? todayTask;

  GuideUser({
    required this.name,
    required this.totalSp,
    required this.trophies,
    required this.stepupGoals,
    required this.completedTimeline,
    required this.instructionNote,
    required this.aptitudeResult,
    this.todayTask,
  });
}

// ==========================================
// 1. 個人データ一覧 タブ
// ==========================================
class _PersonalDataTab extends StatefulWidget {
  final Color iconColor;
  const _PersonalDataTab({super.key, required this.iconColor});

  @override
  State<_PersonalDataTab> createState() => _PersonalDataTabState();
}

class _PersonalDataTabState extends State<_PersonalDataTab> {
  GuideUser? _selectedUser;

  final List<GuideUser> _users = [
    GuideUser(
      name: '田中 太郎',
      totalSp: 1200,
      trophies: ['銅のハサミ (紙切りマスター)', '銀のペン (イラスト初級)', '金のバトン (他者連携)'],
      stepupGoals: [
        {'title': '梱包作業マニュアルの完全自立', 'isCompleted': true},
        {'title': '作業時間の5分短縮', 'isCompleted': false},
        {'title': 'バトンタッチ連携の実践', 'isCompleted': true},
      ],
      completedTimeline: [
        '本日 10:15 - 「梱包作業」目標をクリアしました！',
        '昨日 14:00 - 「バトンタッチ手順」を完全に習得しました！',
        '先週 11:00 - 「イラスト基本作成」トロフィーを獲得！',
      ],
      instructionNote: 'マニュアルを見ながら進めることで安定。図解多めの指示書がフィットする。',
      aptitudeResult: '視覚的・創造的作業への適性：A判定 (skill_finder より自動同期)',
      todayTask: '３Dモデリング',
    ),
    GuideUser(
      name: '佐藤 花子',
      totalSp: 850,
      trophies: ['銅の耳 (DTM基本)', '銀のハサミ (紙切り上級)'],
      stepupGoals: [
        {'title': 'DTM音源カット作業の完了', 'isCompleted': true},
        {'title': '手順書を見ずに入力を終える', 'isCompleted': false},
      ],
      completedTimeline: [
        '昨日 15:30 - 「DTM切り出し」目標をクリアしました！',
        '2日前 10:45 - 「音響編集」のチェックリストを全達成！',
      ],
      instructionNote: '作業手順を確認するスピードが早い。マルチタスクよりシングルタスク優先。',
      aptitudeResult: '聴覚的・分析的作業への適性：A判定 (skill_finder より自動同期)',
      todayTask: '動画編集',
    ),
    GuideUser(
      name: '鈴木 一郎',
      totalSp: 950,
      trophies: ['銅のシャベル (力仕事初級)', '金のバトン (他者連携)'],
      stepupGoals: [
        {'title': '3Dモデリング基本パーツ作成', 'isCompleted': false},
        {'title': '重い部材の安全運搬完了', 'isCompleted': true},
      ],
      completedTimeline: [
        '昨日 11:20 - 「部材の運搬」トロフィーを獲得！',
        '3日前 14:00 - 「整理整頓ステップ」をクリアしました！',
      ],
      instructionNote: '時々手順をショートカットしがち。声かけでの最終確認が有効。',
      aptitudeResult: '空間・実務力学作業への適性：B判定 (skill_finder より自動同期)',
      todayTask: 'データ入力',
    ),
  ];

  bool handleBack() {
    if (_selectedUser != null) {
      setState(() {
        _selectedUser = null;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return _selectedUser != null
        ? _buildUserDetailMode(_selectedUser!)
        : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AdminSubHeader(iconColor: widget.iconColor),

        // 利用者一覧
        Row(
          children: [
            Icon(Icons.people, color: widget.iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              '登録利用者一覧',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: widget.iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ..._users.map((u) {
          return Card(
            color: Colors.white.withOpacity(0.9),
            margin: const EdgeInsets.symmetric(vertical: 4),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: widget.iconColor.withOpacity(0.1),
                child: Icon(Icons.stars, color: widget.iconColor),
              ),
              title: Row(
                children: [
                  Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (u.todayTask != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        u.todayTask!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('累計獲得SP： ${u.totalSp}SP'),
                  const SizedBox(height: 2),
                  Text('獲得トロフィー： ${u.trophies.length}個'),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (u.totalSp / 1500).clamp(0.0, 1.0),
                      backgroundColor: Colors.indigo.shade50,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lv,${(u.totalSp / 120).toInt()}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const Text(
                        '1500SP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                setState(() {
                  _selectedUser = u;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUserHeaderCard(GuideUser user) {
    final int totalSp = user.totalSp;
    const int nextLevelSp = 500;
    final int currentLevelSp = totalSp % nextLevelSp;
    final double progress = currentLevelSp / nextLevelSp;
    final int neededSp = nextLevelSp - currentLevelSp;

    String titleName = '実力派クリエイター';
    if (user.name == '田中 太郎') {
      titleName = '新進気鋭イラストレーター';
    } else if (user.name == '佐藤 花子') {
      titleName = '次世代サウンドクリエイター';
    } else if (user.name == '鈴木 一郎') {
      titleName = '3Dジェネラリスト';
    }

    final int level = (totalSp / 120).toInt();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Lv. $level',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      Text(
                        '利用者: ${user.name}',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '総獲得ポイント: $totalSp SP',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 36,
                    width: double.infinity,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '次のレベル（Lv. ${level + 1}）まであと $neededSp SP ($currentLevelSp / $nextLevelSp)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
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

  // 個人メニュー読み取り (閲覧モード)
  Widget _buildUserDetailMode(GuideUser user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: widget.iconColor),
              onPressed: () {
                setState(() {
                  _selectedUser = null;
                });
              },
            ),
            Text(
              '${user.name} - 個人メニュー読み取り',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildUserHeaderCard(user),
        const SizedBox(height: 16),

        // 1. スキルトロフィー表示
        Card(
          color: Colors.white.withOpacity(0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('■ 獲得スキルトロフィー一覧', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user.trophies.map((tr) {
                    IconData tIcon = Icons.workspace_premium;
                    Color tColor = Colors.orangeAccent;
                    if (tr.startsWith('銅')) {
                      tColor = Colors.brown;
                    } else if (tr.startsWith('銀')) {
                      tColor = Colors.grey;
                    } else if (tr.startsWith('金')) {
                      tColor = Colors.amber;
                    }
                    return Chip(
                      avatar: Icon(tIcon, color: tColor, size: 18),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: widget.iconColor.withOpacity(0.2)),
                      label: Text(tr, style: const TextStyle(fontSize: 11)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. できたこと (ステップアップ目標)
        Card(
          color: Colors.white.withOpacity(0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('■ できたこと (ステップアップ目標の進捗)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...user.stepupGoals.map((g) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(g['title'], style: const TextStyle(fontSize: 12)),
                      activeColor: widget.iconColor,
                      value: g['isCompleted'],
                      onChanged: null, // 閲覧用
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. できたことタイムライン (獲得履歴)
        Card(
          color: Colors.white.withOpacity(0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('■ できたことタイムライン (獲得履歴)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...user.completedTimeline.map((tl) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.military_tech_outlined, color: Colors.orangeAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(tl, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. 分析・職員用メモ タブ
// ==========================================
class _AnalysisTab extends StatefulWidget {
  final Color iconColor;
  const _AnalysisTab({super.key, required this.iconColor});

  @override
  State<_AnalysisTab> createState() => _AnalysisTabState();
}

class _AnalysisTabState extends State<_AnalysisTab> {
  bool _showAdminMemos = false;

  bool handleBack() {
    if (_showAdminMemos) {
      setState(() {
        _showAdminMemos = false;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_showAdminMemos) {
      return AdminWorkMemosScreen(
        iconColor: widget.iconColor,
        onBack: () {
          setState(() {
            _showAdminMemos = false;
          });
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AdminSubHeader(iconColor: widget.iconColor),

        // 管理者用メモ（最優先・データ分析の要）
        Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: widget.iconColor.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.iconColor.withValues(alpha: 0.08),
                  Colors.white,
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.analytics_outlined, color: widget.iconColor, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '管理者用メモ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: widget.iconColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '分析の要',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'AI分析・個別支援データ蓄積と記録',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.iconColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _showAdminMemos = true;
                    });
                  },
                  icon: const Icon(Icons.note_alt_outlined, size: 20),
                  label: const Text(
                    '作業メモ表示',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 「案内ひろば」AI分析のヒント（管理者用メモの真下に配置）
        _buildSupportHubPromptCard(
          context: context,
          iconColor: widget.iconColor,
          crossAppPrompts: [
            '作業自立度が高かった日と、体調（HP）・前日の日報評価の共通点を教えて',
            '適性診断（skill_finder）の連携結果と日々の作業手順達成度を照合し、現在の作業適性判定とおすすめの新作業を教えて',
            '個別支援計画書用に、「できたこと・成長点」の直近3ヶ月の実績を箇条書きでまとめて',
          ],
          singleAppPrompts: [
            '作業別の自立度スコア（単独完遂率）の推移と、成長している作業を教えて',
            '作業中につまづきやすいステップ（手順忘れ、道具の扱い等）と効果的な指導方法をまとめて',
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSupportHubPromptCard({
    required BuildContext context,
    required Color iconColor,
    required List<String> crossAppPrompts,
    required List<String> singleAppPrompts,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: iconColor.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.lightbulb_outline, color: Colors.amber.shade900, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '「案内ひろば」AI分析のヒント',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 11, color: Colors.blue.shade800),
                            const SizedBox(width: 3),
                            Text(
                              'Gemini連携',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'マスターアプリ「案内ひろば」のAIにこう聞いてみよう！（タップでコピー）',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.link, size: 15, color: iconColor),
                const SizedBox(width: 4),
                Text(
                  '他のデータと掛け合わせて分析',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...crossAppPrompts.map((prompt) => _buildPromptItem(context, prompt, iconColor)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.search, size: 15, color: iconColor),
                const SizedBox(width: 4),
                Text(
                  'このアプリのデータを深掘り分析',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...singleAppPrompts.map((prompt) => _buildPromptItem(context, prompt, iconColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptItem(BuildContext context, String prompt, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Material(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Clipboard.setData(ClipboardData(text: prompt));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '質問文をコピーしました！「案内ひろば」で貼り付けて使えます',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF1E293B),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Icon(Icons.chat_bubble_outline, size: 14, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prompt,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.copy_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. 機能編集・管理 タブ
// ==========================================
class _AppEditTab extends StatefulWidget {
  final Color iconColor;
  const _AppEditTab({required this.iconColor});

  @override
  State<_AppEditTab> createState() => _AppEditTabState();
}

class _AppEditTabState extends State<_AppEditTab> {
  final TextEditingController _newTaskNameController = TextEditingController();
  final TextEditingController _newTaskTimeController = TextEditingController();
  final TextEditingController _newTaskSpController = TextEditingController();
  String _selectedTask = 'イラスト制作';
  String _selectedSpTask = 'イラスト制作';

  @override
  void dispose() {
    _newTaskNameController.dispose();
    _newTaskTimeController.dispose();
    _newTaskSpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // tasksDataのキー一覧をプルダウン用リストとして取得
    final taskNames = MainNavigationScreen.tasksData.keys.toList();
    // _selectedTaskが存在しない場合は先頭を選択
    if (!taskNames.contains(_selectedTask) && taskNames.isNotEmpty) {
      _selectedTask = taskNames.first;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AdminSubHeader(iconColor: widget.iconColor),

        // 新規作業の追加
        Card(
          color: Colors.white.withOpacity(0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.playlist_add, color: widget.iconColor),
                    const SizedBox(width: 8),
                    const Text(
                      '新規作業の追加',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newTaskNameController,
                  decoration: const InputDecoration(
                    labelText: '新規作業名',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newTaskTimeController,
                        decoration: const InputDecoration(
                          labelText: '目標設定時間 (分)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _newTaskSpController,
                        decoration: const InputDecoration(
                          labelText: '付与SP (例: 100 SP)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.iconColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final newName = _newTaskNameController.text.trim();
                        if (newName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('作業名を入力してください。')),
                          );
                          return;
                        }
                        if (MainNavigationScreen.tasksData.containsKey(newName)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('「$newName」は既に存在します。')),
                          );
                          return;
                        }
                        // 新しい作業を tasksData に追加
                        MainNavigationScreen.tasksData[newName] = {
                          'checklist': <Map<String, dynamic>>[],
                          'overview': {
                            'situation': '',
                            'overview': '',
                            'details': '',
                            'purpose': '',
                          },
                          'timeline': <Map<String, String>>[],
                          'flowchart': <Map<String, String>>[],
                          'chatbot': {'response': ''},
                          'skillTracking': <Map<String, dynamic>>[],
                        };
                        setState(() {
                          _selectedTask = newName;
                          _newTaskNameController.clear();
                          _newTaskTimeController.clear();
                          _newTaskSpController.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('「$newName」を追加しました。')),
                        );
                      },
                      child: const Text('マニュアルを新規作成'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 作業手順マニュアルの編集
        Card(
          color: Colors.white.withOpacity(0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note, color: widget.iconColor),
                    const SizedBox(width: 8),
                    const Text(
                      '作業マニュアル編集',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // プルダウンメニューで作業を選択
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF04044C), width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTask,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF04044C)),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF04044C),
                      ),
                      items: taskNames.map((String name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedTask = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.check_box, color: Color(0xFF04044C)),
                  title: const Text('チェックリスト'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final taskData = MainNavigationScreen.tasksData[_selectedTask];
                    if (taskData == null) return;
                    final checklist = taskData['checklist'] as List;
                    final initialData = checklist.map((g) => Map<String, dynamic>.from(g as Map)).toList();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditChecklistScreen(initialData: initialData),
                      ),
                    );
                    if (result != null) {
                      MainNavigationScreen.tasksData[_selectedTask]!['checklist'] = result;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('チェックリストを保存しました')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description, color: Color(0xFF04044C)),
                  title: const Text('業務概要'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final taskData = MainNavigationScreen.tasksData[_selectedTask];
                    if (taskData == null) return;
                    final overview = taskData['overview'];
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditOverviewScreen(initialData: overview),
                      ),
                    );
                    if (result != null) {
                      MainNavigationScreen.tasksData[_selectedTask]!['overview'] = result;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('業務概要を保存しました')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule, color: Color(0xFF04044C)),
                  title: const Text('スケジュール'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final taskData = MainNavigationScreen.tasksData[_selectedTask];
                    if (taskData == null) return;
                    final timeline = taskData['timeline'] as List;
                    final initialData = timeline.map((g) => Map<String, String>.from((g as Map).map((k, v) => MapEntry(k.toString(), v.toString())))).toList();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTimelineScreen(initialData: initialData),
                      ),
                    );
                    if (result != null) {
                      MainNavigationScreen.tasksData[_selectedTask]!['timeline'] = result;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('スケジュールを保存しました')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_tree, color: Color(0xFF04044C)),
                  title: const Text('フローチャート'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final taskData = MainNavigationScreen.tasksData[_selectedTask];
                    if (taskData == null) return;
                    final flowchart = taskData['flowchart'] as List;
                    final initialData = flowchart.map((g) => Map<String, String>.from((g as Map).map((k, v) => MapEntry(k.toString(), v.toString())))).toList();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditFlowchartScreen(initialData: initialData),
                      ),
                    );
                    if (result != null) {
                      MainNavigationScreen.tasksData[_selectedTask]!['flowchart'] = result;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('フローチャートを保存しました')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.question_answer, color: Color(0xFF04044C)),
                  title: const Text('Q & A'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final taskData = MainNavigationScreen.tasksData[_selectedTask];
                    if (taskData == null) return;
                    final chatbot = taskData['chatbot'];
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditChatbotScreen(initialData: chatbot),
                      ),
                    );
                    if (result != null) {
                      MainNavigationScreen.tasksData[_selectedTask]!['chatbot'] = result;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Q&Aを保存しました')),
                        );
                      }
                    }
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      'この作業を削除する',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('確認'),
                          content: const Text('削除されると復元ができません。削除しますか？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('いいえ'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('はい', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        MainNavigationScreen.tasksData.remove(_selectedTask);
                        final taskNames = MainNavigationScreen.tasksData.keys.toList();
                        setState(() {
                          _selectedTask = taskNames.isNotEmpty ? taskNames.first : '';
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('作業を削除しました。')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // SP編集
        Card(
          color: Colors.white.withOpacity(0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars, color: widget.iconColor),
                    const SizedBox(width: 8),
                    const Text(
                      'SP編集',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // SP編集対象作業のプルダウン
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF04044C), width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: taskNames.contains(_selectedSpTask) ? _selectedSpTask : (taskNames.isNotEmpty ? taskNames.first : null),
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF04044C)),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF04044C),
                      ),
                      items: taskNames.map((String name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSpTask = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // SP（スキルポイント）編集 ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF04044C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.emoji_events, size: 20),
                    label: const Text(
                      'SP（スキルポイント）編集',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onPressed: () async {
                      final spTaskName = taskNames.contains(_selectedSpTask) ? _selectedSpTask : (taskNames.isNotEmpty ? taskNames.first : '');
                      final taskData = MainNavigationScreen.tasksData[spTaskName];
                      if (taskData == null) return;
                      final spData = Map<String, dynamic>.from(
                        taskData['spData'] as Map? ?? {
                          'titleName': 'ビギナー',
                          'totalLevel': 1,
                          'skillsSp': {'画力': 0, '創造性': 0, '構成力': 0, '表現力': 0, '集中力': 0, '効率性': 0},
                        },
                      );
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditSpScreen(
                            selectedTask: spTaskName,
                            initialSpData: spData,
                          ),
                        ),
                      );
                      if (result != null) {
                        MainNavigationScreen.tasksData[spTaskName]!['spData'] = result;
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('SP設定を保存しました')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // 評価基準の編集
        Card(
          color: Colors.white.withOpacity(0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.gavel, color: widget.iconColor),
                    const SizedBox(width: 8),
                    const Text(
                      '評価（トロフィー獲得）基準の編集',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('• 銅トロフィー：手順理解度が80%以上で付与\n• 銀トロフィー：時間内達成が連続3回達成で付与\n• 金トロフィー：他メンバーへの「バトンタッチ」協力で付与', style: TextStyle(fontSize: 12, height: 1.5)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.iconColor,
                        side: BorderSide(color: widget.iconColor),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('評価基準設定の編集画面を開きます。')),
                        );
                      },
                      child: const Text('基準値を編集する'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 4. 外部出力・連携 タブ
// ==========================================
class _ExportTab extends StatefulWidget {
  final Color iconColor;
  const _ExportTab({required this.iconColor});

  @override
  State<_ExportTab> createState() => _ExportTabState();
}

class _ExportTabState extends State<_ExportTab> {
  String _selectedUser = '田中 太郎';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AdminSubHeader(iconColor: widget.iconColor),

        // 適正診断連携エクスポート
        Card(
          color: Colors.white.withOpacity(0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.share_arrival_time_outlined, color: widget.iconColor),
                    const SizedBox(width: 8),
                    const Text(
                      '適性診断（skill_finder）データ連携出力',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('適性診断と実際の作業達成度を掛け合わせた、適性合致度診断レポートを出力します。', style: TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.iconColor,
                          side: BorderSide(color: widget.iconColor),
                        ),
                        icon: const Icon(Icons.output_outlined),
                        label: const Text('適性合致度報告書を出力'),
                        onPressed: () => _showExportSuccess('適性診断統合報告書'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 実績データ出力 (csv, pdf)
        Card(
          color: Colors.white.withOpacity(0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.download_for_offline_outlined, color: widget.iconColor),
                    const SizedBox(width: 8),
                    const Text(
                      '作業実績データ エクスポート',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('出力対象者: ', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedUser,
                      dropdownColor: Colors.white,
                      style: TextStyle(color: widget.iconColor, fontWeight: FontWeight.bold),
                      items: <String>['田中 太郎', '佐藤 花子', '鈴木 一郎'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedUser = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.iconColor,
                          side: BorderSide(color: widget.iconColor),
                        ),
                        icon: const Icon(Icons.file_present),
                        label: const Text('CSV実績データ出力'),
                        onPressed: () => _showExportSuccess('CSV'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.iconColor,
                          side: BorderSide(color: widget.iconColor),
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('PDFトロフィー実績書'),
                        onPressed: () => _showExportSuccess('PDF実績書'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showExportSuccess(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: widget.iconColor,
        content: Text('$_selectedUser の作業実績データを $type 形式で出力しました。'),
      ),
    );
  }
}

// ==========================================
// 作業手順 管理者用メモ画面
// ==========================================

class WorkMemo {
  final String id;
  final String userName;
  final DateTime dateTime;
  final String targetTask;
  final String independenceLevel;
  final String growthPoint;
  final String struggleHint;
  final String notes;

  WorkMemo({
    required this.id,
    required this.userName,
    required this.dateTime,
    required this.targetTask,
    required this.independenceLevel,
    required this.growthPoint,
    required this.struggleHint,
    required this.notes,
  });
}

class AdminWorkMemosScreen extends StatefulWidget {
  final Color iconColor;
  final VoidCallback onBack;

  const AdminWorkMemosScreen({
    super.key,
    required this.iconColor,
    required this.onBack,
  });

  @override
  State<AdminWorkMemosScreen> createState() => _AdminWorkMemosScreenState();
}

class _AdminWorkMemosScreenState extends State<AdminWorkMemosScreen> {
  static final List<WorkMemo> _memos = [
    WorkMemo(
      id: '1',
      userName: '田中 太郎',
      dateTime: DateTime.now().subtract(const Duration(hours: 1)),
      targetTask: '梱包作業',
      independenceLevel: '完全独力（ミスゼロ）',
      growthPoint: '正確性アップ',
      struggleHint: '特になし（順調）',
      notes: 'チェックリストを見ながら梱包工程をミスなく完遂。作業スピードも前回比15%向上。',
    ),
    WorkMemo(
      id: '2',
      userName: '佐藤 花子',
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      targetTask: 'シール貼り',
      independenceLevel: '見守りのみ',
      growthPoint: '手順書の自己確認',
      struggleHint: '道具の扱い・手元の疲れ',
      notes: 'シール貼り位置の微調整にやや慎重。次回ガイド枠を設置することでさらに負担軽減予定。',
    ),
  ];

  String? _selectedFilterUser;

  String _inputUserName = '田中 太郎';
  String _selectedTargetTask = '梱包作業';
  String _selectedIndependenceLevel = '完全独力（ミスゼロ）';
  String _selectedGrowthPoint = '正確性アップ';
  String _selectedStruggleHint = '特になし（順調）';
  final TextEditingController _notesController = TextEditingController();
  DateTime _inputDateTime = DateTime.now();

  static const List<String> _userList = [
    '田中 太郎',
    '佐藤 花子',
    '鈴木 一郎',
    '髙橋 美咲',
  ];

  static const List<String> _targetTasks = [
    '梱包作業',
    'シール貼り',
    'ピッキング',
    '清掃・その他',
  ];

  static const List<String> _independenceLevels = [
    '完全独力（ミスゼロ）',
    '見守りのみ',
    '一部指示・支援',
    '全面介助',
  ];

  static const List<String> _growthPoints = [
    'スピード向上',
    '手順書の自己確認',
    '正確性アップ',
    '自発的な質問/報告',
  ];

  static const List<String> _struggleHints = [
    '特になし（順調）',
    '部品の取り違え・配置ミス',
    '指示の理解・順序の迷い',
    '道具の扱い・手元の疲れ',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilterUser == null
        ? _memos
        : _memos.where((m) => m.userName == _selectedFilterUser).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ヘッダー（戻るボタン）
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: widget.iconColor),
              onPressed: widget.onBack,
            ),
            Text(
              '【管理】作業メモ (閲覧/代理記録)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 新規メモ作成カード
        Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note, color: widget.iconColor),
                    const SizedBox(width: 8),
                    Text(
                      '作業メモを記録する',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: widget.iconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // メモ対象者
                DropdownButtonFormField<String>(
                  value: _inputUserName,
                  decoration: const InputDecoration(
                    labelText: 'メモ対象者',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: _userList
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _inputUserName = val);
                  },
                ),
                const SizedBox(height: 16),

                // 対象作業
                DropdownButtonFormField<String>(
                  value: _selectedTargetTask,
                  decoration: const InputDecoration(
                    labelText: '対象作業',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items: _targetTasks
                      .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTargetTask = val);
                  },
                ),
                const SizedBox(height: 16),

                // 本日の自立度
                const Text(
                  '本日の自立度レベル',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _independenceLevels.map((l) {
                    final isSelected = _selectedIndependenceLevel == l;
                    return ChoiceChip(
                      label: Text(l, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                      selected: isSelected,
                      selectedColor: widget.iconColor,
                      onSelected: (val) {
                        if (val) setState(() => _selectedIndependenceLevel = l);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // できたこと・成長点
                const Text(
                  'できたこと・成長点',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _growthPoints.map((g) {
                    final isSelected = _selectedGrowthPoint == g;
                    return ChoiceChip(
                      label: Text(g, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                      selected: isSelected,
                      selectedColor: widget.iconColor,
                      onSelected: (val) {
                        if (val) setState(() => _selectedGrowthPoint = g);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // つまづき・ヒント
                DropdownButtonFormField<String>(
                  value: _selectedStruggleHint,
                  decoration: const InputDecoration(
                    labelText: 'つまづき・改善のヒント',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _struggleHints
                      .map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStruggleHint = val);
                  },
                ),
                const SizedBox(height: 16),

                // 補足メモ
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: '具体的な成果・次回への工夫メモ（任意）',
                    hintText: '例：図解マニュアルを追加したことでスピードアップ',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // 日時選択 ＆ 保存ボタン
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _inputDateTime,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (pickedDate != null) {
                            if (!context.mounted) return;
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_inputDateTime),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _inputDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: Text(
                          _formatDateTime(_inputDateTime),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.iconColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        final newMemo = WorkMemo(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userName: _inputUserName,
                          dateTime: _inputDateTime,
                          targetTask: _selectedTargetTask,
                          independenceLevel: _selectedIndependenceLevel,
                          growthPoint: _selectedGrowthPoint,
                          struggleHint: _selectedStruggleHint,
                          notes: _notesController.text,
                        );
                        setState(() {
                          _memos.insert(0, newMemo);
                          _notesController.clear();
                          _inputDateTime = DateTime.now();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: widget.iconColor,
                            content: Text('$_inputUserName の作業メモを保存しました'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('保存する'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),

        // 絞り込みフィルター
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: _selectedFilterUser,
                decoration: const InputDecoration(
                  labelText: '利用者で絞り込む',
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.filter_list),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('すべての利用者'),
                  ),
                  ..._userList.map(
                    (u) => DropdownMenuItem<String?>(
                      value: u,
                      child: Text(u),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedFilterUser = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 過去メモ一覧
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                '記録されたメモはありません',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...filtered.map((memo) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white.withValues(alpha: 0.95),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 18, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text(
                              '${memo.userName}（${memo.targetTask}）',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              _memos.removeWhere((m) => m.id == memo.id);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('メモを削除しました')),
                            );
                          },
                          tooltip: '削除',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: widget.iconColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            memo.independenceLevel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: widget.iconColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '成長: ${memo.growthPoint}',
                            style: const TextStyle(fontSize: 11, color: Colors.green),
                          ),
                        ),
                        if (memo.struggleHint != '特になし（順調）')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ヒント: ${memo.struggleHint}',
                              style: const TextStyle(fontSize: 11, color: Colors.deepOrange),
                            ),
                          ),
                      ],
                    ),
                    if (memo.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        memo.notes,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(memo.dateTime),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

