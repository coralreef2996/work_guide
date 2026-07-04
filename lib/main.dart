import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';

// ==========================================
// メインエントリーポイント
// ==========================================
// アプリケーションの開始地点です。
// main()関数が最初に実行されます。
void main() {
  runApp(const JobExplanationApp());
}

// ==========================================
// アプリケーション全体の構成
// ==========================================
// アプリ全体のテーマや初期画面を設定するウィジェットです。
// StatelessWidgetは、状態を持たない（変化しない）ウィジェットです。
class JobExplanationApp extends StatelessWidget {
  const JobExplanationApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialAppは、Flutterアプリの基本となるデザイン設定を提供します。
    return MaterialApp(
      title: '作業手順', // アプリのタイトル
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // テーマカラーの設定
        useMaterial3: true, // 最新のデザインシステム（Material 3）を使用
      ),
      home: const LoginScreen(
        appName: '作業手順',
        originalHome: MainNavigationScreen(),
      ), // 最初に表示する画面
    );
  }
}

// ==========================================
// メインナビゲーション画面
// ==========================================
// 複数の画面（チェックリスト、概要など）を切り替えるための画面です。
// StatefulWidgetは、状態を持つ（変化する）ウィジェットです。
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // PageControllerは、ページ切り替えを制御するためのコントローラーです。
  final PageController _pageController = PageController();
  int _currentPage = 0; // 現在表示しているページの番号（0から始まります）

  // 現在選択されている作業（初期値は'イラスト制作'）
  String _currentTask = 'イラスト制作';

  // バトンタッチが送られたかどうかを管理する状態
  bool _isBatonPassed = false;

  // バトンを送信した瞬間のデータを一時的に保持するためのスナップショット
  List<Map<String, dynamic>>? _batonSnapshot;
  // バトンタッチ時にアップロードされた画像のパスを保持します（追加）
  String? _batonImagePath;

  // アプリ全体で使う全てのデータをここで管理しています（Mapという形式で、名前とデータのペアを作っています）。
  // staticとすることで、ログイン・ログアウトを繰り返してもデータがメモリ上に維持されます。
  static final Map<String, Map<String, dynamic>> _tasksData = {
    'イラスト制作': {
      'checklist': [
        {
          'title': 'キャンバスの設定と解像度の確認 (A4 / 350dpi)',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/canvas/600/400',
        },
        {
          'title': '構図案の決定と大まかなアタリの描画',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/composition/600/400',
        },
        {
          'title': 'ラフ画（カラーラフ）の作成とポーズ確認',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/rough/600/400',
        },
        {
          'title': '線画のクリンナップとパーツ分け',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/lineart/600/400',
        },
        {
          'title': '下塗りと配色バランスの決定',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/basecolor/600/400',
        },
        {
          'title': '影1（乗算）と環境光の追加',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/shadow/600/400',
        },
        {
          'title': 'ハイライトと反射光の回り込み処理',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/highlight/600/400',
        },
        {
          'title': 'オーバーレイ・スクリーンレイヤーでのエフェクト調整',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/effects/600/400',
        },
        {
          'title': '色収差とボケ効果による空気感の追加',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/finish/600/400',
        },
        {
          'title': 'PNGおよびPSD形式でのエクスポートと納品チェック',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/export_ill/600/400',
        },
      ],
      'overview': {
        'situation': '【用意するもの】\n・ペンタブレット / 液晶タブレット\n・ペイントツール (Clip Studio, Photoshop等)\n・参考資料の収集フォルダ\n\n【推奨解像度】\n・A4サイズ: 2894 x 4093 pixel\n・カラーモード: RGB (印刷用はCMYKに後で変換)',
        'overview': '【イラスト制作概要】\n本日のイラスト制作は、キャラクター1体のファンタジー風立ち絵の制作です。躍動感のあるポーズと光の演出を強調し、背景は簡単なエフェクトのみとします。',
        'details': '【キャラクター詳細仕様】\n・テーマ: 「光の魔法使い」\n・衣装: 白と金を基調としたローブ\n・ポーズ: 魔法の杖を掲げているポーズ\n・構図: ニーアップ（膝上カット）',
        'purpose': '【本日の目標】\n・17:00までに完成版のエクスポートを完了する。\n・ラフ段階でクライアントの中間チェックを受ける。\n・レイヤー整理を行い、後からの修正に対応しやすくする。',
      },
      'timeline': [
        {'time': '09:00', 'task': '資料確認・アタリ開始'},
        {'time': '10:00', 'task': 'ラフ画作成・カラーラフ検討'},
        {'time': '11:30', 'task': 'ラフの中間確認・修正'},
        {'time': '13:00', 'task': '線画クリンナップ'},
        {'time': '14:30', 'task': 'ベース配色と下塗り'},
        {'time': '15:30', 'task': '陰影・仕上げ処理'},
        {'time': '16:30', 'task': 'エフェクト・クオリティアップ'},
        {'time': '17:00', 'task': 'エクスポート・最終納品'},
      ],
      'flowchart': [
        {'question': 'ポージングに違和感はありませんか？', 'instruction': '3Dデッサン人形や鏡を使って比率を再確認し、ラフを調整してください。'},
        {'question': '影のレイヤーはパーツごとに分かれていますか？', 'instruction': '後々の色変更に対応するため、肌・髪・服で乗算レイヤーを切り分けてください。'},
      ],
      'chatbot': {'response': 'イラストの解像度はどう設定すればいいですか？ / A4サイズ印刷用の場合は、350dpi（2894×4093ピクセル）を推奨します。ウェブ用は72dpiで十分です。'},
      'skillTracking': [
        {'title': 'アタリ・構図', 'doneCount': 10, 'predictedTime': 60, 'actualTime': 55},
        {'title': 'ラフ・着色設計', 'doneCount': 8, 'predictedTime': 90, 'actualTime': 85},
        {'title': '線画清書', 'doneCount': 5, 'predictedTime': 120, 'actualTime': 130},
        {'title': '下塗り・陰影', 'doneCount': 7, 'predictedTime': 120, 'actualTime': 110},
        {'title': 'エフェクト仕上げ', 'doneCount': 9, 'predictedTime': 60, 'actualTime': 65},
      ],
    },
    '3Dモデリング': {
      'checklist': [
        {
          'title': '三面図（正面・側面・背面）の下絵をBlenderに配置',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/blender_setup/600/400',
        },
        {
          'title': 'プリミティブ立方体からの粗モデリング（Blockout）',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/blockout/600/400',
        },
        {
          'title': 'トポロジー（ポリゴンの流れ）を意識したループカット配置',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/topology/600/400',
        },
        {
          'title': 'サブディビジョンサーフェスを用いた形状の滑らかさ調整',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/subsurf/600/400',
        },
        {
          'title': 'シーム（縫い目）のマークとUV展開（unwrap）',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/uv_unwrap/600/400',
        },
        {
          'title': 'Substance Painter等へのFBX出力とインポート',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/substance/600/400',
        },
        {
          'title': 'ノーマルマップのベイクとディテールの追加',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/bake/600/400',
        },
        {
          'title': 'ベースカラーとラフネス、メタルネスのペイント',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/texturing/600/400',
        },
        {
          'title': '骨組み（ボーン）の作成とスキンウェイト調整',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/rigging/600/400',
        },
        {
          'title': 'GLTF / FBX形式でのエクスポートとゲームエンジン（Unity等）連携確認',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/export_3d/600/400',
        },
      ],
      'overview': {
        'situation': '【使用ソフト】\n・Blender 4.0\n・Substance Painter\n\n【ターゲット仕様】\n・ポリゴン数: 15,000 tris 以内\n・テクスチャサイズ: 2048 x 2048 (1枚におさめる)',
        'overview': '【3Dモデリング概要】\n本日はゲーム用ローポリゴン小物のモデリングおよびテクスチャリングです。アセットとしての再利用性を考慮し、トポロジーとUVの効率的な配置を意識します。',
        'details': '【モデル詳細仕様】\n・対象物: ファンタジー風の宝箱 (Chest)\n・ギミック: 蓋が開閉可能（ボーン1本仕込む）\n・質感: 手描き風（Stylized）',
        'purpose': '【本日の目標】\n・トポロジーを整理し、無駄な頂点を削減する。\n・UVのテクスチャスペースの無駄な余白を10%以下にする。\n・Unityでシェーダーが正しく適用できるか確認する。',
      },
      'timeline': [
        {'time': '09:00', 'task': '下絵配置・Blockout（粗モデル）'},
        {'time': '10:30', 'task': 'ディテール追加・ディテールモデリング'},
        {'time': '12:00', 'task': 'トポロジー整理とUV展開'},
        {'time': '14:00', 'task': 'テクスチャペイント（ベース・影・光）'},
        {'time': '15:30', 'task': 'ボーン配置とウェイトペイント'},
        {'time': '16:30', 'task': 'ゲームエンジン出力・最終テスト'},
      ],
      'flowchart': [
        {'question': 'メッシュに裏返ったポリゴン（面の向き）はありませんか？', 'instruction': 'フェイスの向き（面法線）を表示し、赤い面があれば「法線の再計算 (Shift+N)」を行ってください。'},
        {'question': 'UVが重なっている、または歪んでいませんか？', 'instruction': 'チェッカーテクスチャを貼り、歪んでいる部分はシームを追加して再展開してください。'},
      ],
      'chatbot': {'response': 'ポリゴン数を減らすコツは？ / 不要なエッジループの削除、カメラから見えない部分の面削除、および細かいディテールはメッシュではなくノーマルマップ（法線）で表現すると効果的です。'},
      'skillTracking': [
        {'title': 'Blockoutモデリング', 'doneCount': 6, 'predictedTime': 60, 'actualTime': 65},
        {'title': 'UV展開・整理', 'doneCount': 8, 'predictedTime': 45, 'actualTime': 40},
        {'title': 'テクスチャリング', 'doneCount': 4, 'predictedTime': 120, 'actualTime': 130},
        {'title': 'リギング・ウェイト', 'doneCount': 3, 'predictedTime': 60, 'actualTime': 70},
      ],
    },
    'DTM': {
      'checklist': [
        {
          'title': 'DAWプロジェクトの新規作成とBPM（テンポ）とキーの設定',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/daw_setup/600/400',
        },
        {
          'title': 'コード進行を入力し、基本ピアノで全体の構成を確認',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/chords/600/400',
        },
        {
          'title': 'ドラムパターン（キック、スネア、ハイハット）の打ち込み',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/drums/600/400',
        },
        {
          'title': 'ベースラインの作成と低音のルート補強',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/bassline/600/400',
        },
        {
          'title': 'ガイドメロディの作成とフック（サビ）の構築',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/melody/600/400',
        },
        {
          'title': 'シンセサイザーなどのメイン楽器の音色作りとレイヤー処理',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/synth/600/400',
        },
        {
          'title': 'ギターやピアノのバッキングによる中音域の厚み付け',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/backing/600/400',
        },
        {
          'title': 'ホワイトノイズやインパクト音などFX音素材の配置',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/effects_sound/600/400',
        },
        {
          'title': 'EQ・コンプレッサーによる音域の整理とパンニングによる定位設定',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/mixing/600/400',
        },
        {
          'title': 'マスタリング（音圧調整）とWAV / MP3形式での書き出し',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/mastering/600/400',
        },
      ],
      'overview': {
        'situation': '【使用DAW】\n・Logic Pro / Cubase\n・ヘッドホン / モニタースピーカー\n\n【楽曲仕様】\n・ジャンル: Future Bass\n・BPM: 140\n・構成: Intro - A - B - Drop - Outro',
        'overview': '【DTM楽曲制作概要】\n本日はポップス楽曲のFuture Bass風インストロメンタル音源の制作です。低音（サブベース）と高音のシンセリードのバランスを良く保ち、ドロップでの音圧を確保します。',
        'details': '【使用音源リスト】\n・Serum (シンセベース, リード)\n・Battery 4 (ドラムサンプラー)\n・Spire (コード・パッド鍵盤)\n・Splice (FXおよびボーカルカット用サンプラー)',
        'purpose': '【本日の目標】\n・2分30秒のショートVer.音源を完成させる。\n・各トラックの周波数帯域が被らないようEQ調整を徹底する。\n・ダイナミクスを潰しすぎないように音圧を最大値まで上げる。',
      },
      'timeline': [
        {'time': '09:00', 'task': 'プロジェクト立ち上げ・コード進行確定'},
        {'time': '10:00', 'task': 'ドラム・リズム隊の打ち込み'},
        {'time': '11:00', 'task': 'ベース・メインリードの音作り'},
        {'time': '13:00', 'task': 'ドロップの展開作成・レイヤー'},
        {'time': '14:30', 'task': '構成のつなぎ目（トランジション）作成'},
        {'time': '15:30', 'task': 'ミキシング・音域整理'},
        {'time': '16:30', 'task': 'マスタリング・書き出し'},
      ],
      'flowchart': [
        {'question': '低音が濁って聴こえませんか？', 'instruction': 'ベース以外の不要なトラックの低域（100Hz以下）を、ローカットEQで綺麗に削ってください。'},
        {'question': 'ドロップ（サビ）で盛り上がりが足りないですか？', 'instruction': 'Bセクション（ビルドアップ）で徐々にピッチが上がるライザーFX音や、1小節 of ブレイク（無音）を挿入してください。'},
      ],
      'chatbot': {'response': '音圧を上げるための第一歩は？ / ミキシング段階で各トラックの不要な帯域をカットし、クリッピング（音割れ）しないように全体の音量バランス（フェーダー）を整理することです。'},
      'skillTracking': [
        {'title': 'コード・構成打ち込み', 'doneCount': 5, 'predictedTime': 60, 'actualTime': 50},
        {'title': '音色メイキング', 'doneCount': 8, 'predictedTime': 90, 'actualTime': 95},
        {'title': 'アレンジ・展開作り', 'doneCount': 4, 'predictedTime': 120, 'actualTime': 115},
        {'title': 'ミキシング作業', 'doneCount': 6, 'predictedTime': 90, 'actualTime': 100},
      ],
    },
    '動画編集': {
      'checklist': [
        {
          'title': '動画素材の仕分けとフォルダ構造作成',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/setup/600/400',
        },
        {
          'title': 'Premier Pro等のタイムラインへの取り込みとシーケンス設定',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/import_mov/600/400',
        },
        {
          'title': '不要な間や噛んでしまったセリフをすべてカット（荒編集）',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/cut_mov/600/400',
        },
        {
          'title': 'メインのトークに合わせ、BGMを選定・挿入し適正音量に設定',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/bgm/600/400',
        },
        {
          'title': '重要なキーワードへのテロップ（字幕）の追加',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/caption/600/400',
        },
        {
          'title': 'テロップのデザイン調整（境界線やシャドウ、フォントサイズ変更）',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/design/600/400',
        },
        {
          'title': 'アニメーションや画面切り替え効果（トランジション）の適用',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/transition/600/400',
        },
        {
          'title': '要所への効果音（SE）の配置と全体の音量バランス調整',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/se/600/400',
        },
        {
          'title': 'カラーグレーディングによる映像の明るさ・色味の補正',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/color/600/400',
        },
        {
          'title': '最終プレビュー確認とH.264 / MP4形式での動画書き出し',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/export/600/400',
        },
      ],
      'overview': {
        'situation': '【使用機材】\n・Adobe Premiere Pro\n・動画素材フォルダ\n・BGM/SEの素材サイトへのアクセスキー\n\n【推奨書き出し設定】\n・解像度: 1920x1080 (Full HD)\n・フレームレート: 29.97 fps / VBR 2パス',
        'overview': '【動画編集概要】\n本日はYouTube向けインタビュー動画（約10分）の編集です。話し手のテンポを良くし、退屈させないタイミングでのテロップ配置と効果音によるアクセントを意識します。',
        'details': '【動画仕様】\n・テーマ: 「起業家インタビュー」\n・トーン: 清潔感、ビジネス向け、信頼感\n・テロップカラー: 青、ゴールド、白をベースにする',
        'purpose': '【本日の目標】\n・18:00までにクライアント提出用の初稿を書き出す。\n・無駄な無音箇所（沈黙）を完全に排除する。\n・音量バランス（声: -6dB、BGM: -24dB前後）を厳守する。',
      },
      'timeline': [
        {'time': '09:00', 'task': '動画素材の取り込み・確認'},
        {'time': '09:30', 'task': 'カット編集（セリフ整理・無音カット）'},
        {'time': '12:00', 'task': 'テロップ作成とデザイン設定'},
        {'time': '14:30', 'task': 'BGM・効果音（SE）の挿入'},
        {'time': '16:00', 'task': 'エフェクト・色調補正（カラー）の調整'},
        {'time': '17:00', 'task': '全体の書き出しとプレビュー再生'},
        {'time': '18:00', 'task': 'クライアントへの初稿提出'},
      ],
      'flowchart': [
        {'question': '動画の声が聞き取りづらいですか？', 'instruction': '声のトラックに「エッセンシャルサウンド」の「会話」を適用し、BGM of ダッキング（自動音量下げ）を設定してください。'},
        {'question': 'テロップの量が多すぎて画面が見づらいですか？', 'instruction': '重要なキーワードのみを表示し、一画面に表示される文字数を20文字以内に収めてください。'},
      ],
      'chatbot': {'response': '動画を滑らかに書き出す最適な設定は？ / コーデックは H.264、コンテナ形式は MP4 を選び、ターゲットビットレートは 10〜15 Mbps に設定すると綺麗で軽量な動画になります。'},
      'skillTracking': [
        {'title': 'カット編集（荒編集）', 'doneCount': 12, 'predictedTime': 90, 'actualTime': 85},
        {'title': 'テロップ・フォント編集', 'doneCount': 9, 'predictedTime': 120, 'actualTime': 130},
        {'title': 'BGM・効果音処理', 'doneCount': 10, 'predictedTime': 60, 'actualTime': 55},
        {'title': '色調補正・書き出し', 'doneCount': 8, 'predictedTime': 45, 'actualTime': 50},
      ],
    },
    'データ入力': {
      'checklist': [
        {
          'title': '入力指示書とオリジナル原稿ファイルの確認',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/documents/600/400',
        },
        {
          'title': 'Googleスプレッドシートへの入力用の列・ヘッダー作成',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/spreadsheet/600/400',
        },
        {
          'title': '住所データの入力と郵便番号からの自動補完テスト',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/address/600/400',
        },
        {
          'title': '顧客ID・名前・電話番号などの個人情報の厳密な入力',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/customer_info/600/400',
        },
        {
          'title': '全角半角の統一（英数字は半角、カナは全角などの規約確認）',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/check_format/600/400',
        },
        {
          'title': '重複データのチェック（UNIQUE関数や条件付き書式の活用）',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/cleanup/600/400',
        },
        {
          'title': '空欄や入力漏れのセルがないかフィルタリングして確認',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/filter/600/400',
        },
        {
          'title': '数式（VLOOKUP, SUM等）が崩れていないかのセル再計算',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/recalc/600/400',
        },
        {
          'title': '最終件数と入力元原稿の総件数が一致しているかの照合',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/total_count/600/400',
        },
        {
          'title': 'CSV形式での書き出し、または共有リンク設定と完了報告の作成',
          'isChecked': false,
          'imagePath': 'https://picsum.photos/seed/submit/600/400',
        },
      ],
      'overview': {
        'situation': '【使用ソフト】\n・Googleスプレッドシート / Excel\n・入力用原稿PDF\n\n【入力ルール】\n・電話番号のハイフンは除く\n・英字はすべて大文字で統一\n・日付形式は YYYY/MM/DD',
        'overview': '【データ入力概要】\n本日は新規会員登録申し込み書（紙媒体のスキャンデータ計200名分）のスプレッドシートへのデータ入力です。誤字脱字を防ぐため、確認リストと照合しながら行います。',
        'details': '【入力項目リスト】\n・会員番号（半角英数字8桁）\n・氏名（漢字）＆フリガナ（全角カタカナ）\n・生年月日（西暦形式）\n・メールアドレスおよび連絡先電話番号',
        'purpose': '【本日の目標】\n・15:00までに入力およびダブルチェックを完了する。\n・誤入力率を0.1%未満（200件中ミス1件以内）にする。\n・セキュリティ厳守のため、個人情報ファイルをデスクトップに残さない。',
      },
      'timeline': [
        {'time': '09:00', 'task': '入力原稿ファイルのダウンロード・確認'},
        {'time': '09:15', 'task': 'スプレッドシートの入力規則・フォーマット整備'},
        {'time': '09:30', 'task': 'データ入力（1件〜100件目）'},
        {'time': '11:30', 'task': '中間チェックと入力速度調整'},
        {'time': '13:00', 'task': 'データ入力（101件〜200件目）'},
        {'time': '14:30', 'task': '全件の照合・重複排除・フォーマットチェック'},
        {'time': '15:00', 'task': 'CSV出力・共有設定・完了報告'},
      ],
      'flowchart': [
        {'question': '原稿の文字が潰れていて読めない箇所はありますか？', 'instruction': '勝手に推測せず、セルを黄色でハイライトした上でメモに「判読不能」と残し、管理者に確認してください。'},
        {'question': '同じ名前の会員がすでに登録されていませんか？', 'instruction': '同姓同名がある場合は、生年月日や電話番号を照合し、同一人物の重複登録を防ぐ処理をしてください。'},
      ],
      'chatbot': {'response': '入力ミスを減らす方法は？ / テンキー入力をブラインドで行えるように練習することと、入力後に元の原稿と件数を照合し、フィルタ機能で空白や異常値がないか確認することです。'},
      'skillTracking': [
        {'title': 'スピードタイピング', 'doneCount': 15, 'predictedTime': 120, 'actualTime': 115},
        {'title': 'データクレンジング', 'doneCount': 10, 'predictedTime': 45, 'actualTime': 40},
        {'title': '整合性確認（ダブルチェック）', 'doneCount': 12, 'predictedTime': 30, 'actualTime': 25},
      ],
    },
  };

  // ----------------------------------------------------------------------
  // 以下はデータを操作（追加・変更・保存）するための仕組みです。
  // setState()を呼び出すことで、Flutterが「画面を書き換える必要がある」ことを検知します。
  // ----------------------------------------------------------------------

  // 新しい作業（例：掃除、受付）を追加するための関数
  void _addTask(String taskName) {
    setState(() {
      _tasksData[taskName] = {
        'checklist': [
          {'title': '新しい手順', 'isChecked': false},
        ],
        'overview': {
          'situation': '【用意するもの】\n',
          'overview': '【本日の作業概要】\n',
          'details': '【詳細】\n',
          'purpose': '【目的】\n',
        },
        'timeline': [
          {'time': '00:00', 'task': 'タスク'},
        ],
        'flowchart': [
          {'question': '質問', 'instruction': '指示'},
        ],
        'chatbot': {'response': 'Q&A'},
        'skillTracking': [
          {
            'title': '作業タイトル',
            'doneCount': 0,
            'predictedTime': 0,
            'actualTime': 0,
          },
        ],
      };
      _currentTask = taskName; // 追加した作業を現在選択中の状態にする
    });
  }

  // 表示する作業を切り替えるための関数
  void _changeTask(String taskName) {
    setState(() {
      _currentTask = taskName;
    });
  }

  // 子画面から「データを保存したい」と呼ばれたときに実行されるコールバック関数たち
  // それぞれ編集された新しいデータ（newData）を受け取り、_tasksDataを更新します。

  void _saveChecklist(List<Map<String, dynamic>> newData) {
    setState(() {
      _tasksData[_currentTask]!['checklist'] = newData;
    });
  }

  void _saveOverview(Map<String, String> newData) {
    setState(() {
      _tasksData[_currentTask]!['overview'] = newData;
    });
  }

  void _saveTimeline(List<Map<String, String>> newData) {
    setState(() {
      _tasksData[_currentTask]!['timeline'] = newData;
    });
  }

  void _saveFlowchart(List<Map<String, String>> newData) {
    setState(() {
      _tasksData[_currentTask]!['flowchart'] = newData;
    });
  }

  void _saveChatbot(Map<String, dynamic> newData) {
    setState(() {
      _tasksData[_currentTask]!['chatbot'] = newData;
    });
  }

  // バトンタッチが実行された時に呼ばれる関数
  void _handleBatonPassed(String? imagePath) {
    setState(() {
      _isBatonPassed = true;
      _batonImagePath = imagePath; // 画像パスを保存
      // 送信した瞬間のチェックリストの状態をスナップショットとして保存します（ディープコピー）。
      _batonSnapshot =
          _tasksData[_currentTask]!['checklist']
              .map<Map<String, dynamic>>(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();
    });
  }

  // バトンタッチを受け取った時に呼ばれる関数（リセット用）
  void _handleBatonReceived() {
    setState(() {
      _isBatonPassed = false;
      if (_batonSnapshot != null) {
        // スナップショットの内容を現在の作業データに上書きします。
        _tasksData[_currentTask]!['checklist'] =
            _batonSnapshot!
                .map<Map<String, dynamic>>(
                  (item) => Map<String, dynamic>.from(item),
                )
                .toList();
        // スナップショットと画像パスをクリアします。
        _batonSnapshot = null;
        _batonImagePath = null;
      }
    });
  }

  // 特定のページに直接ジャンプする処理
  void _jumpToPage(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _currentPage = index;
    });
  }

  @override
  void dispose() {
    // 画面が破棄されるときにコントローラーも破棄してメモリリーク（不要なメモリ消費）を防ぎます。
    _pageController.dispose();
    super.dispose();
  }

  // 次のページ（右側）に進むアニメーション処理
  void _nextPage() {
    if (_currentPage < 6 - 1) {
      // 最後のページでなければ進む
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300), // 0.3秒かけて動く
        curve: Curves.easeInOut, // 滑らかな動きの加減
      );
    }
  }

  // 前のページ（左側）に戻るアニメーション処理
  void _previousPage() {
    if (_currentPage > 0) {
      // 最初のページでなければ戻る
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffoldは、アプリの基本的なレイアウト（ヘッダーやボディなど）を構成するためのウィジェットです。
    return Scaffold(
      // Stackはウィジェットを奥から手前へ順番に重ねて表示します。
      body: Stack(
        children: [
          // 画面全体を占めるコンテンツ（スライドできるページ部分）
          PageView(
            controller: _pageController,
            physics:
                const NeverScrollableScrollPhysics(), // 指でのスワイプによる移動を禁止（ボタンのみで移動するため）
            onPageChanged: (index) {
              setState(() {
                _currentPage = index; // ページが切り替わったら現在の番号を記録
              });
            },
            children: [
              // 各ページの内容を順番に定義しています。
              // data（表示するデータ）と onSave（データを書き換える手段）を渡しています。
              TaskSelectionScreen(
                tasks: _tasksData.keys.toList(),
                selectedTask: _currentTask,
                onTaskChanged: _changeTask,
                onTaskAdded: _addTask,
                currentData: _tasksData[_currentTask]!,
                onSaveChecklist: _saveChecklist,
                onSaveOverview: _saveOverview,
                onSaveTimeline: _saveTimeline,
                onSaveFlowchart: _saveFlowchart,
                onSaveChatbot: _saveChatbot,
                onStart: () => _jumpToPage(1),
              ),
              ChecklistScreen(
                data: _tasksData[_currentTask]!['checklist'],
                onSave: _saveChecklist,
                isBatonPassed: _isBatonPassed,
                onBatonPassed: _handleBatonPassed,
                onBatonReceived: _handleBatonReceived,
                onNavigateToChecklist: () => _jumpToPage(1),
                batonSnapshot: _batonSnapshot,
                batonImagePath: _batonImagePath, // 追加
                onBack: () => _jumpToPage(0), // 追加
              ),
              TabbedOverviewScreen(
                data: _tasksData[_currentTask]!['overview'],
                onSave: _saveOverview,
                isBatonPassed: _isBatonPassed,
                onBatonPassed: _handleBatonPassed,
                onBatonReceived: _handleBatonReceived,
                checklistData: _tasksData[_currentTask]!['checklist'],
                onNavigateToChecklist: () => _jumpToPage(1),
                batonSnapshot: _batonSnapshot,
                batonImagePath: _batonImagePath, // 追加
              ),
              TimelineScreen(
                data: _tasksData[_currentTask]!['timeline'],
                onSave: _saveTimeline,
                isBatonPassed: _isBatonPassed,
                onBatonPassed: _handleBatonPassed,
                onBatonReceived: _handleBatonReceived,
                checklistData: _tasksData[_currentTask]!['checklist'],
                onNavigateToChecklist: () => _jumpToPage(1),
                batonSnapshot: _batonSnapshot,
                batonImagePath: _batonImagePath, // 追加
              ),
              FlowchartScreen(
                data: _tasksData[_currentTask]!['flowchart'],
                onSave: _saveFlowchart,
                isBatonPassed: _isBatonPassed,
                onBatonPassed: _handleBatonPassed,
                onBatonReceived: _handleBatonReceived,
                checklistData: _tasksData[_currentTask]!['checklist'],
                onNavigateToChecklist: () => _jumpToPage(1),
                batonSnapshot: _batonSnapshot,
                batonImagePath: _batonImagePath, // 追加
              ),
              ChatbotScreen(
                data: _tasksData[_currentTask]!['chatbot'],
                onSave: _saveChatbot,
                isBatonPassed: _isBatonPassed,
                onBatonPassed: _handleBatonPassed,
                onBatonReceived: _handleBatonReceived,
                checklistData: _tasksData[_currentTask]!['checklist'],
                onNavigateToChecklist: () => _jumpToPage(1),
                batonSnapshot: _batonSnapshot,
                batonImagePath: _batonImagePath, // 追加
              ),
            ],
          ),
          // ------------------------------------------------------------------
          // ページめくり用のボタン（コンテンツの上に重なって表示されます）
          // ------------------------------------------------------------------

          // 2ページ目以降なら左側の「戻る」ボタンを表示
          // ※ _currentPage == 1（作業チェックリスト）の左ボタンは非表示にするため、_currentPage > 1 とする
          if (_currentPage > 1)
            HoverNavButton(
              direction: NavButtonDirection.left,
              onPressed: _previousPage,
            ),
          // 最後のページ以外なら右側「進む」ボタンを表示
          // ※ _currentPage == 0（作業手順）の右ボタンは非表示にするため、_currentPage != 0 とする
          if (_currentPage < 6 - 1 && _currentPage != 0)
            HoverNavButton(
              direction: NavButtonDirection.right,
              onPressed: _nextPage,
            ),
        ],
      ),
    );
  }
}

// ==========================================
// ナビゲーションボタン（カスタムウィジェット）
// ==========================================
// 画面の左右に表示される「＜」「＞」ボタンです。
enum NavButtonDirection { left, right }

class HoverNavButton extends StatefulWidget {
  final NavButtonDirection direction;
  final VoidCallback onPressed; // ボタンが押されたときの処理
  final bool isRed; // 赤色にするかどうかのフラグ

  const HoverNavButton({
    super.key,
    required this.direction,
    required this.onPressed,
    this.isRed = false,
  });

  @override
  State<HoverNavButton> createState() => _HoverNavButtonState();
}

class _HoverNavButtonState extends State<HoverNavButton> {
  @override
  Widget build(BuildContext context) {
    final isLeft = widget.direction == NavButtonDirection.left;
    const double buttonWidth = 40.0; // ボタンの幅

    // Positionedを使って、画面の特定の位置（左右の端）に重ねて配置します。
    return Positioned(
      left: isLeft ? 0 : null, // 左ボタンなら左端（0）に配置
      right: !isLeft ? 0 : null, // 右ボタンなら右端（0）に配置
      top: 0,
      bottom: 0,
      width: buttonWidth,
      child: Center(
        child: GestureDetector(
          onTap: widget.onPressed, // 指でタップされたときに処理を実行
          child: Container(
            width: buttonWidth,
            height: 120, // 押しやすいように高さを120に設定
            alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            decoration: BoxDecoration(
              color:
                  widget.isRed
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.blue.withValues(
                        alpha: 0.3,
                      ), // 背景色（赤または青、不透明度30%）
              borderRadius: BorderRadius.horizontal(
                right: isLeft ? const Radius.circular(16) : Radius.zero,
                left: !isLeft ? const Radius.circular(16) : Radius.zero,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: isLeft ? 0 : 10,
                right: isLeft ? 10 : 0,
              ),
              child: Text(
                isLeft ? '＜' : '＞', // 左向きなら「＜」、右向きなら「＞」を全角で表示
                style: const TextStyle(
                  color: Colors.white, // 文字色は白
                  fontSize: 24, // サイズを24に変更
                  fontWeight: FontWeight.bold, // 強調
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 0. 作業手順画面
// ==========================================
// どの仕事（イラスト制作、動画編集など）を表示するか選び、内容を編集するための入り口となる画面です。
class TaskSelectionScreen extends StatefulWidget {
  // 親（MainNavigationScreenState）から渡されるデータや関数です。
  final List<String> tasks; // 作業名のリスト（['イラスト制作', '動画編集', ... ]）
  final String selectedTask; // 現在選ばれている作業名
  final Function(String) onTaskChanged; // 作業を切り替えたときに呼ぶ関数
  final Function(String) onTaskAdded; // 新しい作業を追加したときに呼ぶ関数
  final Map<String, dynamic> currentData; // 現在の作業の全てのデータ
  final Function(List<Map<String, dynamic>>) onSaveChecklist;
  final Function(Map<String, String>) onSaveOverview;
  final Function(List<Map<String, String>>) onSaveTimeline;
  final Function(List<Map<String, String>>) onSaveFlowchart;
  final Function(Map<String, dynamic>) onSaveChatbot;
  final VoidCallback onStart;

  const TaskSelectionScreen({
    super.key,
    required this.tasks,
    required this.selectedTask,
    required this.onTaskChanged,
    required this.onTaskAdded,
    required this.currentData,
    required this.onSaveChecklist,
    required this.onSaveOverview,
    required this.onSaveTimeline,
    required this.onSaveFlowchart,
    required this.onSaveChatbot,
    required this.onStart,
  });

  @override
  State<TaskSelectionScreen> createState() => _TaskSelectionScreenState();
}

class _TaskSelectionScreenState extends State<TaskSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作業手順'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(
                    appName: '作業手順',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 背景にグラデーション（白から薄い紫）をつけています。
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFBCBCE8)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '作業選択はこちら',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // 作業を切り替えるためのドロップダウンメニュー
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: DropdownButton<String>(
                  value: widget.selectedTask,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  // 登録されている作業名をリストにしてメニュー項目を作ります。
                  items:
                      widget.tasks.map((String task) {
                        return DropdownMenuItem<String>(
                          value: task,
                          child: Text(task),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      widget.onTaskChanged(newValue); // 選んだ作業名を親に伝える
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 「開始する」ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: const Text(
                    '開始する',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40), // プログレスバーとの間隔

              // 現在の自分のレベルとSP（スキルポイント）の総プログレスバー
              Builder(
                builder: (context) {
                  final spData = getTaskSpData(widget.selectedTask);
                  final skillsSp = Map<String, int>.from(spData['skillsSp']);
                  final int totalSp = skillsSp.values.reduce((a, b) => a + b);
                  final int currentLevel = spData['totalLevel'] as int;
                  const int nextLevelSp = 500;
                  final int currentLevelSp = totalSp % nextLevelSp;
                  final double progress = currentLevelSp / nextLevelSp;
                  final int neededSp = nextLevelSp - currentLevelSp;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '現在のレベル: Lv. $currentLevel',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '総獲得SP: $totalSp',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                              // 未達成エリア（灰色背景）
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // 中のバー（明るいオレンジ）
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
                              // 中央のパーセンテージテキスト
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
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '次のレベル（Lv. ${currentLevel + 1}）まであと $neededSp SP ($currentLevelSp / $nextLevelSp)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
              const SizedBox(height: 24),

              // 「できたこと実績」ボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpAchievementsScreen(
                          selectedTask: widget.selectedTask,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo,
                    side: const BorderSide(color: Colors.indigo, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  icon: const Icon(Icons.emoji_events, color: Colors.amber),
                  label: const Text(
                    'できたこと実績',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 1. 作業チェックリスト画面
// ==========================================
// やるべきことを順番に確認し、チェックを付けるための画面です。
class ChecklistScreen extends StatefulWidget {
  final List<Map<String, dynamic>> data; // 項目名とチェック状態のリスト
  final Function(List<Map<String, dynamic>>) onSave; // 変更を保存するための関数
  final bool isBatonPassed;
  final Function(String?) onBatonPassed;
  final VoidCallback onBatonReceived;
  final VoidCallback onNavigateToChecklist;
  final List<Map<String, dynamic>>? batonSnapshot;
  final String? batonImagePath; // 追加
  final VoidCallback onBack; // 追加

  const ChecklistScreen({
    super.key,
    required this.data,
    required this.onSave,
    required this.isBatonPassed,
    required this.onBatonPassed,
    required this.onBatonReceived,
    required this.onNavigateToChecklist,
    this.batonSnapshot,
    this.batonImagePath, // 追加
    required this.onBack, // 追加
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
        title: const Text(
          '作業チェックリスト',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // バトンタッチを送るボタン
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BatonTouchPage(
                              checklistData: widget.data,
                              onBatonPassed: widget.onBatonPassed,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'バトンタッチを送る',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                // バトンタッチを受け取るボタン
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BatonReceivePage(
                              checklistData:
                                  widget.batonSnapshot ?? widget.data,
                              batonImagePath: widget.batonImagePath,
                              onBatonReceived: widget.onBatonReceived,
                              onStartWork: widget.onNavigateToChecklist,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.isBatonPassed ? Colors.red : Colors.white,
                    foregroundColor:
                        widget.isBatonPassed ? Colors.white : Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'バトンタッチを受け取る',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // 背景のグラデーション設定
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // 上部は白
              Color(0xFFBCBCE8), // 下部は薄紫
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
          itemCount: widget.data.length, // リストの数だけ繰り返す
          itemBuilder: (context, index) {
            final item = widget.data[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // チェックリスト項目のタイル
                Container(
                  margin: const EdgeInsets.only(bottom: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: CheckboxListTile(
                    title: Text(item['title']),
                    value: item['isChecked'],
                    onChanged: (bool? value) {
                      setState(() {
                        item['isChecked'] = value!;
                        widget.onSave(widget.data);
                      });
                    },
                  ),
                ),
                // 「画像を表示」ボタン専用のタイル（右寄せ・最小サイズ）
                if (item['imagePath'] != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: EdgeInsets.zero, // 余白を削る
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          _showImageDialog(
                            context,
                            item['title'],
                            item['imagePath'],
                          );
                        },
                        borderRadius: BorderRadius.circular(4.0),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                '画像を表示',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (item['imagePath'] == null)
                  const SizedBox(height: 8.0), // 画像がない場合の余白
              ],
            );
          },
        ),
      ),
    );
  }

  // 画像を表示するためのダイアログ
  void _showImageDialog(BuildContext context, String title, String imagePath) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child:
                      imagePath.startsWith('http')
                          ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Text('画像を読み込めませんでした'),
                                  ),
                                ),
                          )
                          : Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Text('ローカル画像を読み込めませんでした'),
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

// ==========================================
// 2. 業務概要画面（タブ切り替え）
// ==========================================
class TabbedOverviewScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, String>) onSave;
  final bool isBatonPassed;
  final Function(String?) onBatonPassed;
  final VoidCallback onBatonReceived;
  final List<Map<String, dynamic>> checklistData;
  final VoidCallback onNavigateToChecklist;
  final List<Map<String, dynamic>>? batonSnapshot;
  final String? batonImagePath; // 追加

  const TabbedOverviewScreen({
    super.key,
    required this.data,
    required this.onSave,
    required this.isBatonPassed,
    required this.onBatonPassed,
    required this.onBatonReceived,
    required this.checklistData,
    required this.onNavigateToChecklist,
    this.batonSnapshot,
    this.batonImagePath, // 追加
  });

  @override
  State<TabbedOverviewScreen> createState() => _TabbedOverviewScreenState();
}

class _TabbedOverviewScreenState extends State<TabbedOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    // DefaultTabControllerを使うと、タブ切り替えの表示と中身の連動を自動で行ってくれます。
    // length: 4 は、タブが全部で4つあることを指定しています。
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 120, // ボタンを表示するために高さを広げます
          centerTitle: true,
          title: Column(
            children: [
              const Text('業務概要'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // バトンタッチを送るボタン
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BatonTouchPage(
                                checklistData: widget.checklistData,
                                onBatonPassed: widget.onBatonPassed,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'バトンタッチを送る',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // バトンタッチを受け取るボタン
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BatonReceivePage(
                                checklistData:
                                    widget.batonSnapshot ??
                                    widget.checklistData,
                                batonImagePath: widget.batonImagePath, // 追加
                                onBatonReceived: widget.onBatonReceived,
                                onStartWork: widget.onNavigateToChecklist,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.isBatonPassed ? Colors.red : Colors.white,
                      foregroundColor:
                          widget.isBatonPassed ? Colors.white : Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text(
                      'バトンタッチを受け取る',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: Colors.white,
          // bottomプロパティを使って、ヘッダー（AppBar）の下にタブを配置します。
          bottom: const TabBar(
            // タブのラベル（ボタンの名前）を順番に設定します。
            tabs: [
              Tab(text: '状況'),
              Tab(text: '概要'),
              Tab(text: '詳細'),
              Tab(text: '目的'),
            ],
            labelColor: Colors.blue, // 選ばれているタブの文字色
            unselectedLabelColor: Colors.grey, // 選んでいないタブの文字色
            indicatorColor: Colors.blue, // 選ばれているタブの下に出る線の色
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFBCBCE8)],
            ),
          ),
          // TabBarViewは、それぞれのタブが選ばれたときに表示する「中身」をリストで指定します。
          child: TabBarView(
            children: [
              // 状況タブの中身
              _buildTabContent('状況', widget.data['situation'] ?? ''),
              // 概要タブの中身
              _buildTabContent('概要', widget.data['overview'] ?? ''),
              // 詳細タブの中身
              _buildTabContent('詳細', widget.data['details'] ?? ''),
              // 目的タブの中身
              _buildTabContent('目的', widget.data['purpose'] ?? ''),
            ],
          ),
        ),
      ),
    );
  }

  // タブの中身を作成するヘルパーメソッド
  Widget _buildTabContent(String title, String content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 32.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
                height: 1.6, // 行間を少し広げて読みやすく
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. 本日のスケジュール画面
// ==========================================
class TimelineScreen extends StatefulWidget {
  final List<Map<String, String>> data;
  final Function(List<Map<String, String>>) onSave;
  final bool isBatonPassed;
  final Function(String?) onBatonPassed;
  final VoidCallback onBatonReceived;
  final List<Map<String, dynamic>> checklistData;
  final VoidCallback onNavigateToChecklist;
  final List<Map<String, dynamic>>? batonSnapshot;
  final String? batonImagePath; // 追加

  const TimelineScreen({
    super.key,
    required this.data,
    required this.onSave,
    required this.isBatonPassed,
    required this.onBatonPassed,
    required this.onBatonReceived,
    required this.checklistData,
    required this.onNavigateToChecklist,
    this.batonSnapshot,
    this.batonImagePath, // 追加
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120, // ボタンを表示するために高さを広げます
        centerTitle: true,
        title: Column(
          children: [
            const Text('本日のスケジュール'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // バトンタッチを送るボタン
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BatonTouchPage(
                              checklistData: widget.checklistData,
                              onBatonPassed: widget.onBatonPassed,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'バトンタッチを送る',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                // バトンタッチを受け取るボタン
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BatonReceivePage(
                              checklistData:
                                  widget.batonSnapshot ?? widget.checklistData,
                              batonImagePath: widget.batonImagePath, // 追加
                              onBatonReceived: widget.onBatonReceived,
                              onStartWork: widget.onNavigateToChecklist,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.isBatonPassed ? Colors.red : Colors.white,
                    foregroundColor:
                        widget.isBatonPassed ? Colors.white : Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'バトンタッチを受け取る',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFBCBCE8)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 32.0),
          itemCount: widget.data.length,
          itemBuilder: (context, index) {
            // IntrinsicHeightは、子の高さに合わせて自分（行）の高さを調整するウィジェットです。
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. 時間を表示する部分（左側）
                  SizedBox(
                    width: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.data[index]['time']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 2. タイムラインの「縦線」と「丸」を描く部分（中央）
                  Column(
                    children: [
                      // 上に伸びる線（最初の項目以外で表示）
                      Expanded(
                        child: Container(
                          width: 2,
                          color: index == 0 ? Colors.transparent : Colors.grey,
                        ),
                      ),
                      // 青い丸（現在のポイント）
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      // 下に伸びる線（最後の項目以外で表示）
                      Expanded(
                        child: Container(
                          width: 2,
                          color:
                              index == widget.data.length - 1
                                  ? Colors.transparent
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // 3. 具体的なタスクの内容を表示する部分（右側）
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        widget.data[index]['task']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// 業務概要編集画面
class EditOverviewScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditOverviewScreen({super.key, required this.initialData});

  @override
  State<EditOverviewScreen> createState() => _EditOverviewScreenState();
}

class _EditOverviewScreenState extends State<EditOverviewScreen> {
  late TextEditingController _situationController;
  late TextEditingController _overviewController;
  late TextEditingController _detailsController;
  late TextEditingController _purposeController;

  @override
  void initState() {
    super.initState();
    _situationController = TextEditingController(
      text: widget.initialData['situation'],
    );
    _overviewController = TextEditingController(
      text: widget.initialData['overview'],
    );
    _detailsController = TextEditingController(
      text: widget.initialData['details'],
    );
    _purposeController = TextEditingController(
      text: widget.initialData['purpose'],
    );
  }

  @override
  void dispose() {
    _situationController.dispose();
    _overviewController.dispose();
    _detailsController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('業務概要編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final newData = {
                'situation': _situationController.text,
                'overview': _overviewController.text,
                'details': _detailsController.text,
                'purpose': _purposeController.text,
              };
              Navigator.pop(context, newData);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '状況',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _situationController,
            maxLines: 10,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          const Text(
            '概要',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _overviewController,
            maxLines: 10,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          const Text(
            '詳細',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _detailsController,
            maxLines: 10,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          const Text(
            '目的',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _purposeController,
            maxLines: 10,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}

// スケジュール編集画面
class EditTimelineScreen extends StatefulWidget {
  final List<Map<String, String>> initialData;

  const EditTimelineScreen({super.key, required this.initialData});

  @override
  State<EditTimelineScreen> createState() => _EditTimelineScreenState();
}

class _EditTimelineScreenState extends State<EditTimelineScreen> {
  late List<Map<String, String>> _timeline;
  final List<TextEditingController> _timeControllers = [];
  final List<TextEditingController> _taskControllers = [];

  @override
  void initState() {
    super.initState();
    _timeline =
        widget.initialData
            .map((item) => Map<String, String>.from(item))
            .toList();
    for (var item in _timeline) {
      _timeControllers.add(TextEditingController(text: item['time']));
      _taskControllers.add(TextEditingController(text: item['task']));
    }
  }

  @override
  void dispose() {
    for (var controller in _timeControllers) {
      controller.dispose();
    }
    for (var controller in _taskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              for (int i = 0; i < _timeline.length; i++) {
                _timeline[i]['time'] = _timeControllers[i].text;
                _timeline[i]['task'] = _taskControllers[i].text;
              }
              Navigator.pop(context, _timeline);
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _timeline.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _timeControllers[index],
                    decoration: const InputDecoration(
                      labelText: '時間',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _taskControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'タスク',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _timeControllers[index].dispose();
                      _taskControllers[index].dispose();
                      _timeControllers.removeAt(index);
                      _taskControllers.removeAt(index);
                      _timeline.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _timeline.add({'time': '', 'task': ''});
            _timeControllers.add(TextEditingController());
            _taskControllers.add(TextEditingController());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==========================================
// 編集画面群
// ==========================================

// チェックリスト編集画面
// チェックリスト編集画面
class EditChecklistScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialData;

  const EditChecklistScreen({super.key, required this.initialData});

  @override
  State<EditChecklistScreen> createState() => _EditChecklistScreenState();
}

class _EditChecklistScreenState extends State<EditChecklistScreen> {
  // TextEditingControllerは、入力フォームの文字を読み取ったり書き込んだりするための仕組みです。
  final List<TextEditingController> _controllers = [];
  late List<Map<String, dynamic>> _steps;

  @override
  void initState() {
    super.initState();
    // データのコピー（_steps）を作成します。
    // こうすることで、編集をキャンセルしたときに勝手に保存されるのを防げます。
    _steps =
        widget.initialData
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

    // データ（ステップ数）の分だけコントローラーを準備します。
    for (var step in _steps) {
      _controllers.add(TextEditingController(text: step['title']));
    }
  }

  @override
  void dispose() {
    // 画面を離れるときにコントローラーも削除して、メモリの無駄遣いを防ぎます。
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チェックリスト編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // コントローラーの値をデータに反映
              for (int i = 0; i < _steps.length; i++) {
                _steps[i]['title'] = _controllers[i].text;
              }
              // データを返して画面を閉じる
              Navigator.pop(context, _steps);
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          labelText: '手順${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _controllers[index].dispose();
                          _controllers.removeAt(index);
                          _steps.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
                // 右下に「画像を追加」ボタンを配置
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_steps[index]['imagePath'] != null)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => _pickImage(index),
                      icon: const Icon(Icons.add_a_photo, size: 16),
                      label: const Text(
                        '画像をアップロード',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _steps.add({'title': '', 'isChecked': false, 'imagePath': null});
            _controllers.add(TextEditingController());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 画像をスマートフォンから選択（アップロード）するための処理
  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();
    // ギャラリーから画像を選択します
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _steps[index]['imagePath'] = image.path;
      });
    }
  }
}

// 業務概要編集画面

// ==========================================
// 4. 準備フローチャート画面
// ==========================================
class FlowchartScreen extends StatefulWidget {
  final List<Map<String, String>> data;
  final Function(List<Map<String, String>>) onSave;
  final bool isBatonPassed;
  final Function(String?) onBatonPassed;
  final VoidCallback onBatonReceived;
  final List<Map<String, dynamic>> checklistData;
  final VoidCallback onNavigateToChecklist;
  final List<Map<String, dynamic>>? batonSnapshot;
  final String? batonImagePath; // 追加

  const FlowchartScreen({
    super.key,
    required this.data,
    required this.onSave,
    required this.isBatonPassed,
    required this.onBatonPassed,
    required this.onBatonReceived,
    required this.checklistData,
    required this.onNavigateToChecklist,
    this.batonSnapshot,
    this.batonImagePath, // 追加
  });

  @override
  State<FlowchartScreen> createState() => _FlowchartScreenState();
}

class _FlowchartScreenState extends State<FlowchartScreen> {
  int _currentQuestionIndex = 0; // 今何番目の質問を表示しているか
  bool _showInstruction = false; // 指示（Qに対して「いいえ」だった場合）を表示中かどうか

  // 「はい」が押されたときの処理
  void _handleYes() {
    setState(() {
      // まだ次の質問があるなら進む
      if (_currentQuestionIndex < widget.data.length - 1) {
        _currentQuestionIndex++;
        _showInstruction = false; // 次の質問に移るときは指示を隠す
      } else {
        // 全ての質問に「はい」と答えたら完了ダイアログを出す
        _showCompletionDialog();
      }
    });
  }

  // 「いいえ」が押されたときの処理
  void _handleNo() {
    setState(() {
      _showInstruction = true; // 指示画面を表示する
    });
  }

  // 指示を確認して「用意しました」などが押されたときの処理
  void _handleInstructionConfirmed() {
    setState(() {
      _showInstruction = false; // 指示画面を閉じ、質問に戻る
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('確認完了'),
            content: const Text('全ての準備が整いました！'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 必要であればここで最初の質問に戻すなどの処理を追加
                  setState(() {
                    _currentQuestionIndex = 0;
                    _showInstruction = false;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Scaffold(body: Center(child: Text('データがありません')));
    }

    final currentQuestion = widget.data[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120, // ボタンを表示するために高さを広げます
        centerTitle: true,
        title: Column(
          children: [
            const Text('準備フローチャート'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // バトンタッチを送るボタン
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BatonTouchPage(
                              checklistData: widget.checklistData,
                              onBatonPassed: widget.onBatonPassed,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'バトンタッチを送る',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                // バトンタッチを受け取るボタン
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BatonReceivePage(
                              checklistData:
                                  widget.batonSnapshot ?? widget.checklistData,
                              batonImagePath: widget.batonImagePath, // 追加
                              onBatonReceived: widget.onBatonReceived,
                              onStartWork: widget.onNavigateToChecklist,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.isBatonPassed ? Colors.red : Colors.white,
                    foregroundColor:
                        widget.isBatonPassed ? Colors.white : Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'バトンタッチを受け取る',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFBCBCE8)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 50.0),
          child: Center(
            child:
                _showInstruction
                    ? _buildInstructionView(
                      currentQuestion['instruction'] ?? '指示がありません',
                    )
                    : _buildQuestionView(
                      currentQuestion['question'] ?? '質問がありません',
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionView(String question) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Q${_currentQuestionIndex + 1} / ${widget.data.length}',
          style: const TextStyle(fontSize: 20, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Text(
          question,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 64),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _handleNo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[900],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('いいえ', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _handleYes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[100],
                foregroundColor: Colors.green[900],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('はい', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructionView(String instruction) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline, size: 64, color: Colors.orange),
        const SizedBox(height: 24),
        Text(
          instruction,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: _handleInstructionConfirmed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          ),
          child: const Text('用意しました', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}

// ==========================================
// 5. Q&Aチャットボット画面
// ==========================================
class ChatbotScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onSave;
  final bool isBatonPassed;
  final Function(String?) onBatonPassed;
  final VoidCallback onBatonReceived;
  final List<Map<String, dynamic>> checklistData;
  final VoidCallback onNavigateToChecklist;
  final List<Map<String, dynamic>>? batonSnapshot;
  final String? batonImagePath; // 追加

  const ChatbotScreen({
    super.key,
    required this.data,
    required this.onSave,
    required this.isBatonPassed,
    required this.onBatonPassed,
    required this.onBatonReceived,
    required this.checklistData,
    required this.onNavigateToChecklist,
    this.batonSnapshot,
    this.batonImagePath, // 追加
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController =
      TextEditingController(); // 文字入力欄のコントローラー
  final List<Map<String, dynamic>> _messages = []; // 画面に表示するメッセージのリスト

  @override
  void initState() {
    super.initState();
    // 画面が開いたときに、ボットからの最初の挨拶（initialMessage）を表示します。
    final initialMsg = widget.data['initialMessage'] ?? '何かお困りですか？';
    final initialOpts =
        widget.data['initialOptions'] != null
            ? List<String>.from(widget.data['initialOptions'])
            : <String>[];
    _addBotMessage(initialMsg, initialOpts);
  }

  void _addBotMessage(String text, [List<String>? options]) {
    setState(() {
      _messages.add({'sender': 'bot', 'text': text, 'options': options});
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });
  }

  // ユーザーが入力して「送信」ボタンを押したときの処理
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return; // 空っぽなら何もしない

    _textController.clear(); // 入力欄を空にする
    _addUserMessage(text); // ユーザーのメッセージを画面に足す

    // 少し待ってから（0.5秒後）、ボットが返事をするようにします。
    Future.delayed(const Duration(milliseconds: 500), () {
      _handleResponse(text);
    });
  }

  // 選択肢ボタン（ActionChip）が押されたときの処理
  void _handleChoiceSelected(String choice) {
    _addUserMessage(choice); // 選んだ言葉をユーザーの発言として表示

    Future.delayed(const Duration(milliseconds: 500), () {
      _handleResponse(choice); // 返事を探す
    });
  }

  void _handleResponse(String text) {
    // 「最初に戻る」の場合
    if (text == '最初に戻る') {
      final initialMsg = widget.data['initialMessage'] ?? '何かお困りですか？';
      final initialOpts =
          widget.data['initialOptions'] != null
              ? List<String>.from(widget.data['initialOptions'])
              : <String>[];
      _addBotMessage(initialMsg, initialOpts);
      return;
    }

    // conversationsから応答を検索
    final conversations = widget.data['conversations'] as Map<String, dynamic>?;
    if (conversations != null && conversations.containsKey(text)) {
      final conversation = conversations[text] as Map<String, dynamic>;
      final response = conversation['response'] ?? 'すみません、応答がありません。';
      final options =
          conversation['options'] != null
              ? List<String>.from(conversation['options'])
              : <String>[];
      _addBotMessage(response, options);
      return;
    }

    // フォールバック
    final fallbackMsg =
        widget.data['fallbackMessage'] ?? '申し訳ありません、その質問には答えられません。';
    final fallbackOpts =
        widget.data['fallbackOptions'] != null
            ? List<String>.from(widget.data['fallbackOptions'])
            : ['最初に戻る'];
    _addBotMessage(fallbackMsg, fallbackOpts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120, // ボタンを表示するために高さを広げます
        centerTitle: true,
        title: Column(
          children: [
            const Text('Q&Aチャットボット'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // バトンタッチを送るボタン
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BatonTouchPage(
                              checklistData: widget.checklistData,
                              onBatonPassed: widget.onBatonPassed,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'バトンタッチを送る',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                // バトンタッチを受け取るボタン
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BatonReceivePage(
                              checklistData:
                                  widget.batonSnapshot ?? widget.checklistData,
                              batonImagePath: widget.batonImagePath, // 追加
                              onBatonReceived: widget.onBatonReceived,
                              onStartWork: widget.onNavigateToChecklist,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.isBatonPassed ? Colors.red : Colors.white,
                    foregroundColor:
                        widget.isBatonPassed ? Colors.white : Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'バトンタッチを受け取る',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFBCBCE8)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60.0,
                  vertical: 16.0,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';
                  final options = message['options'] as List<String>?;

                  return Column(
                    crossAxisAlignment:
                        isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Text(
                          message['text']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      // 選択肢ボタン（ボットからのメッセージの場合）
                      if (!isUser && options != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 16.0,
                          ),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children:
                                options.map((option) {
                                  return ActionChip(
                                    label: Text(option),
                                    onPressed:
                                        () => _handleChoiceSelected(option),
                                  );
                                }).toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'メッセージを入力...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_textController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// スケジュール編集画面

// フローチャート編集画面
class EditFlowchartScreen extends StatefulWidget {
  final List<Map<String, String>> initialData;

  const EditFlowchartScreen({super.key, required this.initialData});

  @override
  State<EditFlowchartScreen> createState() => _EditFlowchartScreenState();
}

class _EditFlowchartScreenState extends State<EditFlowchartScreen> {
  late List<Map<String, String>> _flowchart;
  final List<TextEditingController> _questionControllers = [];
  final List<TextEditingController> _instructionControllers = [];

  @override
  void initState() {
    super.initState();
    _flowchart =
        widget.initialData
            .map((item) => Map<String, String>.from(item))
            .toList();
    for (var item in _flowchart) {
      _questionControllers.add(TextEditingController(text: item['question']));
      _instructionControllers.add(
        TextEditingController(text: item['instruction']),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フローチャート編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              for (int i = 0; i < _flowchart.length; i++) {
                _flowchart[i]['question'] = _questionControllers[i].text;
                _flowchart[i]['instruction'] = _instructionControllers[i].text;
              }
              Navigator.pop(context, _flowchart);
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _flowchart.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ステップ ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _questionControllers[index].dispose();
                          _instructionControllers[index].dispose();
                          _questionControllers.removeAt(index);
                          _instructionControllers.removeAt(index);
                          _flowchart.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _questionControllers[index],
                  decoration: const InputDecoration(
                    labelText: '質問（はい/いいえで答えられるもの）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _instructionControllers[index],
                  decoration: const InputDecoration(
                    labelText: '「いいえ」の場合の指示',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _flowchart.add({'question': '', 'instruction': ''});
            _questionControllers.add(TextEditingController());
            _instructionControllers.add(TextEditingController());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Q&A編集画面
class EditChatbotScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditChatbotScreen({super.key, required this.initialData});

  @override
  State<EditChatbotScreen> createState() => _EditChatbotScreenState();
}

class _EditChatbotScreenState extends State<EditChatbotScreen> {
  late TextEditingController _initialMessageController; // 最初の挨拶用
  late List<String> _initialOptions; // 最初の選択肢リスト
  late Map<String, Map<String, dynamic>> _conversations; // Q&Aの「キーワード」と「返事」のペア
  late TextEditingController _fallbackMessageController; // 分からないときの返事用
  late List<String> _fallbackOptions; // 分からないときの選択肢

  @override
  void initState() {
    super.initState();
    // 編集前のデータをコントローラーやリストにセットします。
    _initialMessageController = TextEditingController(
      text: widget.initialData['initialMessage'] ?? '',
    );
    _initialOptions =
        widget.initialData['initialOptions'] != null
            ? List<String>.from(widget.initialData['initialOptions'])
            : [];
    _conversations =
        widget.initialData['conversations'] != null
            ? Map<String, Map<String, dynamic>>.from(
              (widget.initialData['conversations'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
              ),
            )
            : {};
    _fallbackMessageController = TextEditingController(
      text: widget.initialData['fallbackMessage'] ?? '',
    );
    _fallbackOptions =
        widget.initialData['fallbackOptions'] != null
            ? List<String>.from(widget.initialData['fallbackOptions'])
            : [];
  }

  @override
  void dispose() {
    _initialMessageController.dispose();
    _fallbackMessageController.dispose();
    super.dispose();
  }

  void _addInitialOption(String option) {
    if (option.trim().isNotEmpty && !_initialOptions.contains(option)) {
      setState(() {
        _initialOptions.add(option);
      });
    }
  }

  void _removeInitialOption(int index) {
    setState(() {
      _initialOptions.removeAt(index);
    });
  }

  void _addFallbackOption(String option) {
    if (option.trim().isNotEmpty && !_fallbackOptions.contains(option)) {
      setState(() {
        _fallbackOptions.add(option);
      });
    }
  }

  void _removeFallbackOption(int index) {
    setState(() {
      _fallbackOptions.removeAt(index);
    });
  }

  void _addConversation() {
    showDialog(
      context: context,
      builder: (context) {
        final keyController = TextEditingController();
        final responseController = TextEditingController();
        final optionsController = TextEditingController();

        return AlertDialog(
          title: const Text('会話を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'キーワード（ユーザーの入力）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: responseController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ボットの応答',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: optionsController,
                decoration: const InputDecoration(
                  labelText: '選択肢（カンマ区切り）',
                  border: OutlineInputBorder(),
                  hintText: '例: 戻る, 次へ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final key = keyController.text.trim();
                final response = responseController.text.trim();
                final options =
                    optionsController.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                if (key.isNotEmpty && response.isNotEmpty) {
                  setState(() {
                    _conversations[key] = {
                      'response': response,
                      'options': options,
                    };
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  void _editConversation(String key) {
    final conversation = _conversations[key]!;
    final responseController = TextEditingController(
      text: conversation['response'],
    );
    final options = conversation['options'] as List<dynamic>;
    final optionsController = TextEditingController(text: options.join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('「$key」を編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: responseController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ボットの応答',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: optionsController,
                decoration: const InputDecoration(
                  labelText: '選択肢（カンマ区切り）',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final response = responseController.text.trim();
                final newOptions =
                    optionsController.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                if (response.isNotEmpty) {
                  setState(() {
                    _conversations[key] = {
                      'response': response,
                      'options': newOptions,
                    };
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _deleteConversation(String key) {
    setState(() {
      _conversations.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A会話フロー編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final result = {
                'initialMessage': _initialMessageController.text,
                'initialOptions': _initialOptions,
                'conversations': _conversations,
                'fallbackMessage': _fallbackMessageController.text,
                'fallbackOptions': _fallbackOptions,
              };
              Navigator.pop(context, result);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '初期メッセージ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _initialMessageController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '最初に表示するメッセージ',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '初期選択肢',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._initialOptions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Chip(
                      label: Text(entry.value),
                      onDeleted: () => _removeInitialOption(entry.key),
                    ),
                  ),
                ],
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed: () {
              final controller = TextEditingController();
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('選択肢を追加'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: '選択肢テキスト',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () {
                            _addInitialOption(controller.text);
                            Navigator.pop(context);
                          },
                          child: const Text('追加'),
                        ),
                      ],
                    ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('選択肢を追加'),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '会話フロー',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addConversation,
                icon: const Icon(Icons.add),
                label: const Text('会話を追加'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_conversations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '会話フローが登録されていません。\n「会話を追加」ボタンから追加してください。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ..._conversations.entries.map((entry) {
            final conversation = entry.value;
            final options = conversation['options'] as List<dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('応答: ${conversation['response']}'),
                    if (options.isNotEmpty) Text('選択肢: ${options.join(', ')}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editConversation(entry.key),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteConversation(entry.key),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text(
            'フォールバックメッセージ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _fallbackMessageController,
            maxLines: 2,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '不明な質問に対する返答',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'フォールバック選択肢',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._fallbackOptions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Chip(
                      label: Text(entry.value),
                      onDeleted: () => _removeFallbackOption(entry.key),
                    ),
                  ),
                ],
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed: () {
              final controller = TextEditingController();
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('選択肢を追加'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: '選択肢テキスト',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () {
                            _addFallbackOption(controller.text);
                            Navigator.pop(context);
                          },
                          child: const Text('追加'),
                        ),
                      ],
                    ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('選択肢を追加'),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SP・称号・バッジ編集画面
// ==========================================
class EditSpScreen extends StatefulWidget {
  final String selectedTask;
  final Map<String, dynamic> initialSpData;

  const EditSpScreen({
    super.key,
    required this.selectedTask,
    required this.initialSpData,
  });

  @override
  State<EditSpScreen> createState() => _EditSpScreenState();
}

class _EditSpScreenState extends State<EditSpScreen> {
  int _selectedLevel = 1;
  late Map<int, String> _levelTitles;
  late TextEditingController _titleController;

  late String _selectedGoalCategory;
  int _selectedGoalLevel = 1;
  final Map<String, List<Map<String, dynamic>>> _categoryGoals = {};
  final Map<String, List<TextEditingController>> _goalTitleControllers = {};
  final Map<String, List<TextEditingController>> _goalSpControllers = {};

  String _getGoalKey(String category, int level) => "${category}_Lv$level";

  @override
  void initState() {
    super.initState();

    final currentTitle = widget.initialSpData['titleName'] as String? ?? 'マスター';
    final currentLevel = widget.initialSpData['totalLevel'] as int? ?? 1;

    _levelTitles = {
      1: 'ビギナー',
      2: 'ルーキー',
      3: '見習い',
      4: 'チャレンジャー',
      5: 'アシスタント',
      6: '中級者',
      7: '実力派',
      8: 'エキスパート',
      9: 'ベテラン',
      10: 'スペシャリスト',
      11: 'プロフェッショナル',
      12: 'エース',
      13: 'トップランカー',
      14: 'マスタリー',
      15: '3Dジェネラリスト',
      16: '新進気鋭イラストレーター',
      17: '次世代サウンドクリエイター',
      18: '凄腕ビデオディレクター',
      19: 'データプロフェッショナル',
      20: 'レジェンドマスター',
    };

    if (widget.initialSpData.containsKey('levelTitles')) {
      final savedTitles = widget.initialSpData['levelTitles'] as Map;
      savedTitles.forEach((key, value) {
        final intKey = int.tryParse(key.toString());
        if (intKey != null) {
          _levelTitles[intKey] = value.toString();
        }
      });
    } else if (currentLevel >= 1 && currentLevel <= 20) {
      _levelTitles[currentLevel] = currentTitle;
    }

    _selectedLevel = currentLevel.clamp(1, 20);
    _titleController = TextEditingController(text: _levelTitles[_selectedLevel]);

    _initGoalsData();
  }

  void _initGoalsData() {
    final skillsSp = Map<String, dynamic>.from(widget.initialSpData['skillsSp'] ?? {'画力': 0, '創造性': 0, '構成力': 0, '表現力': 0, '集中力': 0, '効率性': 0});
    final categories = skillsSp.keys.toList();
    _selectedGoalCategory = categories.isNotEmpty ? categories.first : '画力';
    _selectedGoalLevel = _selectedLevel;

    if (widget.initialSpData.containsKey('categoryGoals')) {
      final savedGoals = widget.initialSpData['categoryGoals'] as Map;
      savedGoals.forEach((key, list) {
        if (list is List) {
          _categoryGoals[key.toString()] = list.map((g) => Map<String, dynamic>.from(g as Map)).toList();
        }
      });
    }

    for (var cat in categories) {
      for (int lvl = 1; lvl <= 20; lvl++) {
        final key = _getGoalKey(cat, lvl);
        if (!_categoryGoals.containsKey(key)) {
          _categoryGoals[key] = _generateDefaultGoals(cat, lvl);
        }
      }
    }

    _loadAllGoalControllers();
  }

  List<Map<String, dynamic>> _generateDefaultGoals(String cat, int lvl) {
    if (lvl <= 5) {
      return [
        {'title': '$cat の基本操作と準備を丁寧に行った（初級）', 'sp': 15},
        {'title': '$cat の入門手順を順番通りに実践した（初級）', 'sp': 20},
      ];
    } else if (lvl <= 10) {
      return [
        {'title': '$cat の基礎技術を意識して作業を行った（中級）', 'sp': 25},
        {'title': '$cat の品質向上のための工夫を取り入れた（中級）', 'sp': 30},
      ];
    } else {
      return [
        {'title': '$cat の高度な応用技術を完璧にマスターした（上級）', 'sp': 35},
        {'title': '$cat のプロレベルの仕上がりと効率化を達成した（上級）', 'sp': 40},
      ];
    }
  }

  void _loadAllGoalControllers() {
    _goalTitleControllers.forEach((_, list) => list.forEach((c) => c.dispose()));
    _goalSpControllers.forEach((_, list) => list.forEach((c) => c.dispose()));
    _goalTitleControllers.clear();
    _goalSpControllers.clear();

    _categoryGoals.forEach((key, goals) {
      _goalTitleControllers[key] = [];
      _goalSpControllers[key] = [];
      for (var g in goals) {
        _goalTitleControllers[key]!.add(TextEditingController(text: g['title'] as String? ?? ''));
        _goalSpControllers[key]!.add(TextEditingController(text: (g['sp'] ?? 20).toString()));
      }
    });
  }

  void _syncCurrentControllersToData() {
    final key = _getGoalKey(_selectedGoalCategory, _selectedGoalLevel);
    final goals = _categoryGoals[key] ?? [];
    final tControllers = _goalTitleControllers[key] ?? [];
    final sControllers = _goalSpControllers[key] ?? [];

    for (int i = 0; i < goals.length; i++) {
      if (i < tControllers.length) goals[i]['title'] = tControllers[i].text;
      if (i < sControllers.length) goals[i]['sp'] = int.tryParse(sControllers[i].text) ?? 20;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalTitleControllers.values.forEach((list) => list.forEach((c) => c.dispose()));
    _goalSpControllers.values.forEach((list) => list.forEach((c) => c.dispose()));
    super.dispose();
  }

  void _onLevelChanged(int? newLevel) {
    if (newLevel != null) {
      _levelTitles[_selectedLevel] = _titleController.text;
      setState(() {
        _selectedLevel = newLevel;
        _titleController.text = _levelTitles[_selectedLevel] ?? '';
      });
    }
  }

  void _addGoal() {
    _syncCurrentControllersToData();
    final key = _getGoalKey(_selectedGoalCategory, _selectedGoalLevel);
    setState(() {
      if (!_categoryGoals.containsKey(key)) {
        _categoryGoals[key] = [];
      }
      if (!_goalTitleControllers.containsKey(key)) {
        _goalTitleControllers[key] = [];
      }
      if (!_goalSpControllers.containsKey(key)) {
        _goalSpControllers[key] = [];
      }
      final newGoal = {'title': '', 'sp': 25};
      _categoryGoals[key]!.add(newGoal);
      _goalTitleControllers[key]!.add(TextEditingController(text: ''));
      _goalSpControllers[key]!.add(TextEditingController(text: '25'));
    });
  }

  void _removeGoal(int index) {
    _syncCurrentControllersToData();
    final key = _getGoalKey(_selectedGoalCategory, _selectedGoalLevel);
    setState(() {
      if (_categoryGoals.containsKey(key) && index < _categoryGoals[key]!.length) {
        _categoryGoals[key]!.removeAt(index);
      }
      if (_goalTitleControllers.containsKey(key) && index < _goalTitleControllers[key]!.length) {
        _goalTitleControllers[key]!.removeAt(index).dispose();
      }
      if (_goalSpControllers.containsKey(key) && index < _goalSpControllers[key]!.length) {
        _goalSpControllers[key]!.removeAt(index).dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final skillsSp = Map<String, dynamic>.from(widget.initialSpData['skillsSp'] ?? {'画力': 0, '創造性': 0, '構成力': 0, '表現力': 0, '集中力': 0, '効率性': 0});
    final categories = skillsSp.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('SP編集（${widget.selectedTask}）'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _levelTitles[_selectedLevel] = _titleController.text;

              _categoryGoals.forEach((cat, goals) {
                final tControllers = _goalTitleControllers[cat] ?? [];
                final sControllers = _goalSpControllers[cat] ?? [];
                for (int i = 0; i < goals.length; i++) {
                  if (i < tControllers.length) goals[i]['title'] = tControllers[i].text;
                  if (i < sControllers.length) goals[i]['sp'] = int.tryParse(sControllers[i].text) ?? 20;
                }
              });

              final updatedSpData = Map<String, dynamic>.from(widget.initialSpData);
              updatedSpData['titleName'] = _levelTitles[_selectedLevel];
              updatedSpData['totalLevel'] = _selectedLevel;
              updatedSpData['levelTitles'] = _levelTitles;
              updatedSpData['categoryGoals'] = _categoryGoals;

              Navigator.pop(context, updatedSpData);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'レベル別 称号設定',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '編集したいレベルを選択し、対応する称号名を入力してください。',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          '対象レベル: ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedLevel,
                              items: List.generate(20, (index) => index + 1).map((lvl) {
                                return DropdownMenuItem<int>(
                                  value: lvl,
                                  child: Text('Lv.$lvl', style: const TextStyle(fontWeight: FontWeight.bold)),
                                );
                              }).toList(),
                              onChanged: _onLevelChanged,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Lv.$_selectedLevel の称号名',
                        hintText: '例: 凄腕クリエイター',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.military_tech, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ステップアップ目標編集',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('対象要素: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: categories.contains(_selectedGoalCategory) ? _selectedGoalCategory : (categories.isNotEmpty ? categories.first : null),
                              items: categories.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  _syncCurrentControllersToData();
                                  setState(() {
                                    _selectedGoalCategory = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('対象レベル: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedGoalLevel,
                              items: List.generate(20, (i) => i + 1).map((lvl) {
                                return DropdownMenuItem<int>(
                                  value: lvl,
                                  child: Text('Lv.$lvl', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  _syncCurrentControllersToData();
                                  setState(() {
                                    _selectedGoalLevel = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addGoal,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('目標追加（入力欄を追加）'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '選択した要素とレベルに対応するステップアップ目標の内容と獲得SPを編集します。',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final currentKey = _getGoalKey(_selectedGoalCategory, _selectedGoalLevel);
                        final currentGoals = _categoryGoals[currentKey] ?? [];
                        final tControllers = _goalTitleControllers[currentKey] ?? [];
                        final sControllers = _goalSpControllers[currentKey] ?? [];

                        if (currentGoals.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('目標が登録されていません')),
                          );
                        }

                        return Column(
                          children: List.generate(currentGoals.length, (index) {
                            if (index >= tControllers.length || index >= sControllers.length) {
                              return const SizedBox();
                            }
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.grey.shade50,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text('目標 #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () => _removeGoal(index),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: tControllers[index],
                                      decoration: const InputDecoration(
                                        labelText: 'ステップアップ目標内容',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: sControllers[index],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: '獲得SP',
                                        suffixText: 'SP',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// バトンタッチページ
// ==========================================
// チェックリストの最終確認を行い、次の方へ引き継ぐための画面です。
// バトンタッチページ
// チェックリストの最終確認を行い、次の方へ引き継ぐための画面です。
class BatonTouchPage extends StatefulWidget {
  final List<Map<String, dynamic>> checklistData; // チェックリストのデータ
  final Function(String? imagePath)
  onBatonPassed; // バトンタッチが実行された時のコールバック（画像パスを渡す）

  const BatonTouchPage({
    super.key,
    required this.checklistData,
    required this.onBatonPassed,
  });

  @override
  State<BatonTouchPage> createState() => _BatonTouchPageState();
}

class _BatonTouchPageState extends State<BatonTouchPage> {
  String? _pickedImagePath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // チェックが入っている項目だけを抜き出します。
    final checkedItems =
        widget.checklistData
            .where((item) => item['isChecked'] == true)
            .toList();
    // チェックが入っていない項目を抜き出します。
    final uncheckedItems =
        widget.checklistData
            .where((item) => item['isChecked'] == false)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('バトンタッチ'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFBCBCE8)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // 画面上部に配置される大きな「バトンタッチ」ボタン
              ElevatedButton(
                onPressed: () {
                  // 親画面にバトンタッチ完了を知らせる
                  widget.onBatonPassed(_pickedImagePath);
                  // メッセージを表示
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('次の担当者へバトンタッチしました！')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'バトンタッチを送る',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              // 進捗状況のタイトル
              const Text(
                '現在の進捗',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // 最後にチェックした項目を表示するエリア
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child:
                    checkedItems.isEmpty
                        ? const Center(child: Text('完了した項目はありません'))
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              checkedItems.last['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              'まで完了しました',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 40),
              // 選択した画像のプレビュー
              if (_pickedImagePath != null)
                Column(
                  children: [
                    const Text(
                      'アップロード予定の画像',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_pickedImagePath!),
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              // 「画像アップロード」ボタン
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image, color: Colors.green[800]),
                label: const Text('画像アップロード'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  side: BorderSide(color: Colors.green[800]!),
                ),
              ),
              const SizedBox(height: 16),
              // 「未チェック」を確認するためのボタン
              ElevatedButton.icon(
                onPressed: () {
                  // ポップアップ（ダイアログ）を表示
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('未チェックの確認'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('以下の項目が未チェックです：'),
                              const SizedBox(height: 16),
                              if (uncheckedItems.isEmpty)
                                const Text('全ての項目にチェックが入っています！')
                              else
                                ...uncheckedItems.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text('・ ${item['title']}'),
                                  ),
                                ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                },
                icon: Icon(Icons.list, color: Colors.green[800]),
                label: const Text('未チェック項目を確認する'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  side: BorderSide(color: Colors.green[800]!),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class BatonReceivePage extends StatelessWidget {
  final List<Map<String, dynamic>> checklistData;
  final String? batonImagePath; // バトンタッチで渡された画像パス
  final VoidCallback onBatonReceived;
  final VoidCallback onStartWork;

  const BatonReceivePage({
    super.key,
    required this.checklistData,
    this.batonImagePath,
    required this.onBatonReceived,
    required this.onStartWork,
  });

  @override
  Widget build(BuildContext context) {
    // 完了した項目（チェック済み）と未完了項目を整理します。
    final checkedItems =
        checklistData.where((item) => item['isChecked'] == true).toList();
    final uncheckedItems =
        checklistData.where((item) => item['isChecked'] == false).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('バトンを受け取る'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFBCBCE8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Text(
                '現在の進捗',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // 前の担当者がどこまで進めたかを表示します。
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child:
                    checkedItems.isEmpty
                        ? const Center(child: Text('完了した項目はありません'))
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              checkedItems.last['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              'まで完了しています',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 32),
              const Text(
                'アップロードされた画像',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // アップロードされた画像を表示します。
              Container(
                width: 250,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    batonImagePath != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(batonImagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                        : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'NO IMAGE',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 32),
              // 残りの作業（未チェック項目）を確認できるボタンです。
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('未チェックの確認'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('以下の項目が残っています：'),
                              const SizedBox(height: 16),
                              if (uncheckedItems.isEmpty)
                                const Text('全ての項目が完了しています！')
                              else
                                ...uncheckedItems.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text('・ ${item['title']}'),
                                  ),
                                ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                },
                icon: Icon(Icons.list, color: Colors.green[800]),
                label: const Text('未チェック項目を確認する'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  side: BorderSide(color: Colors.green[800]!),
                ),
              ),
              const SizedBox(height: 32),
              // 実際に仕事を引き受けるための大きなボタンです。
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: () {
                    // バトン受け取りの状態に変更し、チェックリスト画面へ戻ります。
                    onBatonReceived();
                    onStartWork();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    '作業に取り掛かる',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


// ==========================================
// 管理者用：作業手順管理画面
// ==========================================
class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  String _selectedTask = 'イラスト制作';

  @override
  void initState() {
    super.initState();
    // もし _tasksData が空でなければ、存在するものを初期値にする
    if (!_MainNavigationScreenState._tasksData.containsKey(_selectedTask) && _MainNavigationScreenState._tasksData.isNotEmpty) {
      _selectedTask = _MainNavigationScreenState._tasksData.keys.first;
    }
  }

  // 新しい作業（例：掃除、受付）を追加するための関数
  void _addTask(String taskName) {
    setState(() {
      _MainNavigationScreenState._tasksData[taskName] = {
        'checklist': [
          {'title': '新しい手順', 'isChecked': false},
        ],
        'overview': {
          'situation': '【用意するもの】\n',
          'overview': '【本日の作業概要】\n',
          'details': '【詳細】\n',
          'purpose': '【目的】\n',
        },
        'timeline': [
          {'time': '00:00', 'task': 'タスク'},
        ],
        'flowchart': [
          {'question': '質問', 'instruction': '指示'},
        ],
        'chatbot': {'response': 'Q&A'},
        'skillTracking': [
          {
            'title': '作業タイトル',
            'doneCount': 0,
            'predictedTime': 0,
            'actualTime': 0,
          },
        ],
      };
      _selectedTask = taskName; // 追加した作業を現在選択中の状態にする
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作業手順管理'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(
                    appName: '作業手順',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        // 管理者は薄い赤色のグラデーションにして「管理者画面」であることを分かりやすくする
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFFBEAEA)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '管理する作業を選択してください',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  // 作業を切り替えるためのドロップダウンメニュー
                  if (_MainNavigationScreenState._tasksData.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: DropdownButton<String>(
                        value: _MainNavigationScreenState._tasksData.containsKey(_selectedTask) ? _selectedTask : _MainNavigationScreenState._tasksData.keys.first,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                        items: _MainNavigationScreenState._tasksData.keys.map((String task) {
                          return DropdownMenuItem<String>(
                            value: task,
                            child: Text(task),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedTask = newValue;
                            });
                          }
                        },
                      ),
                    )
                  else
                    const Text('登録されている作業がありません'),
                  const SizedBox(height: 40),

                  // 作業内容の「編集」や「追加」を行うためのボタン列
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        onPressed: _MainNavigationScreenState._tasksData.isNotEmpty
                            ? () => _showEditOptionsDialog(context)
                            : null,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.grey, width: 1.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: const Text('作業編集', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          _showAddTaskDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.grey, width: 1.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: const Text('作業追加', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final initialSpData = getTaskSpData(_selectedTask);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditSpScreen(
                                selectedTask: _selectedTask,
                                initialSpData: _MainNavigationScreenState._tasksData[_selectedTask]?['spData'] ?? initialSpData,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              if (!_MainNavigationScreenState._tasksData.containsKey(_selectedTask)) {
                                _MainNavigationScreenState._tasksData[_selectedTask] = {};
                              }
                              _MainNavigationScreenState._tasksData[_selectedTask]!['spData'] = result;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('SP情報を保存しました')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: const Text('SP編集', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 編集メニュー（チェックリスト、業務概要など）を出すための関数
  void _showEditOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedTask,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('編集する内容を選択', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditOption(context, 'チェックリスト', () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditChecklistScreen(
                          initialData: _MainNavigationScreenState._tasksData[_selectedTask]!['checklist'],
                        ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _MainNavigationScreenState._tasksData[_selectedTask]!['checklist'] = result;
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('保存しました')),
                    );
                  }
                }
              }),
              _buildEditOption(context, '業務概要', () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditOverviewScreen(
                          initialData: _MainNavigationScreenState._tasksData[_selectedTask]!['overview'],
                        ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _MainNavigationScreenState._tasksData[_selectedTask]!['overview'] = result;
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('保存しました')),
                    );
                  }
                }
              }),
              _buildEditOption(context, 'スケジュール', () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditTimelineScreen(
                          initialData: _MainNavigationScreenState._tasksData[_selectedTask]!['timeline'],
                        ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _MainNavigationScreenState._tasksData[_selectedTask]!['timeline'] = result;
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('保存しました')),
                    );
                  }
                }
              }),
              _buildEditOption(context, 'フローチャート', () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditFlowchartScreen(
                          initialData: _MainNavigationScreenState._tasksData[_selectedTask]!['flowchart'],
                        ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _MainNavigationScreenState._tasksData[_selectedTask]!['flowchart'] = result;
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('保存しました')),
                    );
                  }
                }
              }),
              _buildEditOption(context, 'Q&A', () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditChatbotScreen(
                          initialData: Map<String, dynamic>.from(
                            _MainNavigationScreenState._tasksData[_selectedTask]!['chatbot'],
                          ),
                        ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _MainNavigationScreenState._tasksData[_selectedTask]!['chatbot'] = Map<String, dynamic>.from(result);
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('保存しました')),
                    );
                  }
                }
              }),
            ],
          ),
        );
      },
    );
  }

  // 「作業名」を入力して新しく追加するためのダイアログ
  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController taskNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('追加する作業'),
          content: TextField(
            controller: taskNameController,
            decoration: const InputDecoration(
              hintText: '作業名を入力（例：掃除）',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (taskNameController.text.trim().isNotEmpty) {
                  final newTaskName = taskNameController.text.trim();
                  Navigator.pop(context);
                  _addTask(newTaskName); // 新しい作業を追加

                  // 追加した後、すぐにその編集メニューを表示して内容を設定できるようにします。
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (context.mounted) {
                      _showEditOptionsDialog(context);
                    }
                  });
                }
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  // 編集ダイアログ内の「1つの選択肢（行）」を作るための部品
  Widget _buildEditOption(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue), // 編集アイコン
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16)), // 項目の名前
          ],
        ),
      ),
    );
  }
}

// 各タスクの SP データ、称号、レベル、バッジ、タイムラインの共通モックデータを取得するヘルパー
Map<String, dynamic> getTaskSpData(String taskName) {
  if (_MainNavigationScreenState._tasksData.containsKey(taskName) &&
      _MainNavigationScreenState._tasksData[taskName]!.containsKey('spData')) {
    return Map<String, dynamic>.from(_MainNavigationScreenState._tasksData[taskName]!['spData']);
  }
  if (taskName == 'イラスト制作') {
    return {
      'skillsSp': {
        '画力': 450,
        '創造性': 320,
        '構成力': 480,
        '表現力': 410,
        '集中力': 350,
        '効率性': 490,
      },
      'titleName': '新進気鋭イラストレーター',
      'totalLevel': 16,
      'timeline': [
        {'time': '今日 16:30', 'task': 'オーバーレイ・スクリーンレイヤーでのエフェクト調整', 'sp': 35, 'type': '表現力 (Lv.16)'},
        {'time': '今日 14:30', 'task': 'ベース配色と下塗りを完了', 'sp': 25, 'type': '画力 (Lv.16)'},
        {'time': '昨日 11:30', 'task': 'ラフの中間確認をクライアントと完了', 'sp': 40, 'type': '構成力 (Lv.16)'},
      ],
    };
  } else if (taskName == '3Dモデリング') {
    return {
      'skillsSp': {
        '造形力': 430,
        '質感表現': 480,
        '空間認識': 460,
        '骨組設計': 350,
        '集中力': 310,
        '作業効率': 400,
      },
      'titleName': '3Dジェネラリスト',
      'totalLevel': 15,
      'timeline': [
        {'time': '今日 15:30', 'task': 'ボーン配置とウェイトペイント完了', 'sp': 45, 'type': '骨組設計 (Lv.15)'},
        {'time': '今日 14:00', 'task': '手描き風テクスチャペイント', 'sp': 35, 'type': '質感表現 (Lv.15)'},
        {'time': '昨日 12:00', 'task': 'トポロジー整理とUV展開を完了', 'sp': 30, 'type': '造形力 (Lv.15)'},
      ],
    };
  } else if (taskName == 'DTM') {
    return {
      'skillsSp': {
        'メロディ感覚': 470,
        '音響デザイン': 420,
        'リズム感': 390,
        '音響調整': 360,
        '集中力': 330,
        '作業効率': 480,
      },
      'titleName': '次世代サウンドクリエイター',
      'totalLevel': 17,
      'timeline': [
        {'time': '今日 15:30', 'task': 'ミキシング・イコライジング処理', 'sp': 35, 'type': '音響調整 (Lv.17)'},
        {'time': '今日 13:00', 'task': 'ドロップのシンセコード・リードの構築', 'sp': 40, 'type': 'メロディ感覚 (Lv.17)'},
        {'time': '昨日 10:00', 'task': 'ドラム・リズム隊の打ち込み', 'sp': 25, 'type': 'リズム感 (Lv.17)'},
      ],
    };
  } else if (taskName == '動画編集') {
    return {
      'skillsSp': {
        'カット技術': 460,
        'テロップデザイン': 430,
        '演出力': 410,
        '音量バランス': 380,
        '集中力': 320,
        '納品効率': 450,
      },
      'titleName': '凄腕ビデオディレクター',
      'totalLevel': 18,
      'timeline': [
        {'time': '今日 16:00', 'task': 'カラーグレーディング・色調補正', 'sp': 30, 'type': '演出力 (Lv.18)'},
        {'time': '今日 12:00', 'task': 'YouTubeインタビュー動画のテロップ挿入', 'sp': 45, 'type': 'テロップデザイン (Lv.18)'},
        {'time': '昨日 09:30', 'task': '動画素材の取り込みとジェットカット完了', 'sp': 35, 'type': 'カット技術 (Lv.18)'},
      ],
    };
  } else {
    return {
      'skillsSp': {
        '入力速度': 490,
        '正確性': 470,
        'データ整理': 450,
        'ツール活用': 430,
        '集中力': 380,
        '情報セキュリティ': 290,
      },
      'titleName': taskName == 'データ入力' ? 'データプロフェッショナル' : '${taskName}マスター',
      'totalLevel': 19,
      'timeline': [
        {'time': '今日 14:30', 'task': '全件の照合・重複排除・フォーマットチェック', 'sp': 40, 'type': '正確性 (Lv.19)'},
        {'time': '今日 09:30', 'task': '顧客データ入力（200件分）', 'sp': 50, 'type': '入力速度 (Lv.19)'},
        {'time': '昨日 15:00', 'task': 'スプレッドシートへの入力フォーマット整備', 'sp': 25, 'type': 'データ整理 (Lv.19)'},
      ],
    };
  }
}

// ==========================================
// 利用者用：できたこと実績画面
// ==========================================
class SpAchievementsScreen extends StatefulWidget {
  final String selectedTask;

  const SpAchievementsScreen({super.key, required this.selectedTask});

  @override
  State<SpAchievementsScreen> createState() => _SpAchievementsScreenState();
}

class _SpAchievementsScreenState extends State<SpAchievementsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // 6つの要素のデータ（モックデータだが、選択タスクに応じて動的に変える）
  late Map<String, int> _skillsSp;
  late List<Map<String, dynamic>> _timeline;
  late String _titleName;
  late int _totalLevel;

  late String _selectedDekikotoCategory;
  int _selectedDekikotoLevel = 1;
  final Map<String, List<Map<String, dynamic>>> _categoryGoals = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _generateData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateData() {
    final data = getTaskSpData(widget.selectedTask);
    _skillsSp = Map<String, int>.from(data['skillsSp']);
    _titleName = data['titleName'] as String;
    _totalLevel = data['totalLevel'] as int;
    _timeline = List<Map<String, dynamic>>.from(data['timeline']);

    _selectedDekikotoCategory = _skillsSp.keys.isNotEmpty ? _skillsSp.keys.first : '画力';
    _selectedDekikotoLevel = _totalLevel.clamp(1, 20);
    _initCategoryGoals(data);
  }

  void _initCategoryGoals(Map<String, dynamic> data) {
    _categoryGoals.clear();

    if (data.containsKey('categoryGoals')) {
      final savedGoals = data['categoryGoals'] as Map;
      savedGoals.forEach((key, list) {
        if (list is List) {
          _categoryGoals[key.toString()] = list.map((g) {
            final mapG = Map<String, dynamic>.from(g as Map);
            if (!mapG.containsKey('done')) mapG['done'] = false;
            return mapG;
          }).toList();
        }
      });
    }

    final categories = _skillsSp.keys.toList();
    for (var cat in categories) {
      for (int lvl = 1; lvl <= 20; lvl++) {
        final key = "${cat}_Lv$lvl";
        if (!_categoryGoals.containsKey(key)) {
          _categoryGoals[key] = _generateDefaultGoals(cat, lvl);
        }
      }
    }
  }

  List<Map<String, dynamic>> _generateDefaultGoals(String cat, int lvl) {
    if (lvl <= 5) {
      return [
        {'title': '$cat の基本操作と準備を丁寧に行った（初級）', 'done': false, 'sp': 15},
        {'title': '$cat の入門手順を順番通りに実践した（初級）', 'done': false, 'sp': 20},
      ];
    } else if (lvl <= 10) {
      return [
        {'title': '$cat の基礎技術を意識して作業を行った（中級）', 'done': false, 'sp': 25},
        {'title': '$cat の品質向上のための工夫を取り入れた（中級）', 'done': false, 'sp': 30},
      ];
    } else {
      return [
        {'title': '$cat の高度な応用技術を完璧にマスターした（上級）', 'done': false, 'sp': 35},
        {'title': '$cat のプロレベルの仕上がりと効率化を達成した（上級）', 'done': false, 'sp': 40},
      ];
    }
  }

  // 6つの要素に応じた異なる色を返す
  Color _getSkillColor(int index) {
    const colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.green,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
    ];
    return colors[index % colors.length];
  }

  int _calculateTotalSp() {
    return _skillsSp.values.reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final totalSp = _calculateTotalSp();
    final skillNames = _skillsSp.keys.toList();
    final skillValues = _skillsSp.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('できたこと実績'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFECEFF1)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 称号タイル
              _buildHeaderCard(totalSp),
              const SizedBox(height: 24),

              // 適性診断アプリ送信ボタン
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('適性診断アプリへデータを送信しました'),
                            backgroundColor: Colors.teal,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded, size: 24),
                      label: const Text(
                        '適性診断アプリに\nデータを送る',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. できたこと（ステップアップ目標）
              _buildDekikotoSection(skillNames),
              const SizedBox(height: 24),

              // 3. できたことタイムライン
              _buildTimelineSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(int totalSp) {
    const int nextLevelSp = 500;
    final int currentLevelSp = totalSp % nextLevelSp;
    final double progress = currentLevelSp / nextLevelSp;
    final int neededSp = nextLevelSp - currentLevelSp;

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
                    _titleName,
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
                          'Lv. $_totalLevel',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      Text(
                        '現在のタスク: ${widget.selectedTask}',
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
                        // 未達成エリア（灰色背景）
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // 中のバー（明るいオレンジ）
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
                        // 中央のパーセンテージテキスト
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
                    '次のレベル（Lv. ${_totalLevel + 1}）まであと $neededSp SP ($currentLevelSp / $nextLevelSp)',
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

  Widget _buildRadarChartSection(List<String> names, List<int> values) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '技能バランス（他アプリと同期中）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 240,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RadarChartPainter(
                      names: names,
                      values: values,
                      animationValue: _animation.value,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBarsSection(List<String> names, List<int> values) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '能力パラメータ（プログレスバー）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(names.length, (index) {
              final name = names[index];
              final sp = values[index];
              final limit = 500; // 次のレベルの基準
              final percent = (sp / limit).clamp(0.0, 1.0);
              final color = _getSkillColor(index);
              final level = (sp / limit * 10).floor() + 1;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$name：Lv.$level',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '$sp / $limit SP',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDekikotoSection(List<String> skillNames) {
    final currentKey = "${_selectedDekikotoCategory}_Lv$_selectedDekikotoLevel";
    final currentGoals = _categoryGoals[currentKey] ?? [];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'できたこと（ステップアップ目標）',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('対象要素: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigo.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: skillNames.contains(_selectedDekikotoCategory)
                              ? _selectedDekikotoCategory
                              : (skillNames.isNotEmpty ? skillNames.first : null),
                          items: skillNames.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDekikotoCategory = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '要素を選択し、達成したステップアップ目標にチェックを入れるとタイムラインに即時反映されます。',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (currentGoals.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('目標が登録されていません'),
              ),
            ...List.generate(currentGoals.length, (index) {
              final goal = currentGoals[index];
              final isDone = goal['done'] as bool? ?? false;
              final title = goal['title'] as String? ?? '';
              final sp = goal['sp'] as int? ?? 20;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isDone ? Colors.green.shade50 : Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isDone ? Colors.green.shade300 : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CheckboxListTile(
                  value: isDone,
                  activeColor: Colors.green,
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.green.shade900 : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '+$sp SP (${_selectedDekikotoCategory})',
                    style: TextStyle(
                      color: isDone ? Colors.green.shade700 : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onChanged: (bool? checked) {
                    if (checked == null) return;
                    setState(() {
                      goal['done'] = checked;
                      if (checked) {
                        final now = DateTime.now();
                        final timeStr = '今日 ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                        _timeline.insert(0, {
                          'time': timeStr,
                          'task': title,
                          'sp': sp,
                          'type': _selectedDekikotoCategory,
                        });
                        _skillsSp[_selectedDekikotoCategory] = (_skillsSp[_selectedDekikotoCategory] ?? 0) + sp;
                      }
                    });
                    if (checked && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('タイムラインに「$title」を追加しました！（+$sp SP）'),
                          backgroundColor: Colors.green.shade700,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'できたことタイムライン（獲得履歴）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _timeline.length,
              itemBuilder: (context, index) {
                final item = _timeline[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.indigo,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (index < _timeline.length - 1)
                            Container(
                              width: 2,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['time'] as String,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${item['sp']} SP (${item['type']})',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['task'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// レーダーチャート用のカスタムペインター
// ==========================================
class RadarChartPainter extends CustomPainter {
  final List<String> names;
  final List<int> values;
  final double animationValue;

  RadarChartPainter({
    required this.names,
    required this.values,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width < size.height ? size.width / 2 : size.height / 2) - 30;
    const sides = 6;
    final angle = (2 * 3.1415926535) / sides;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = Colors.indigo.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var i = 1; i <= 3; i++) {
      final radius = maxRadius * (i / 3);
      final path = Path();
      for (var j = 0; j < sides; j++) {
        final currentAngle = angle * j - (3.1415926535 / 2);
        final x = center.dx + radius * cos(currentAngle);
        final y = center.dy + radius * sin(currentAngle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < sides; i++) {
      final currentAngle = angle * i - (3.1415926535 / 2);
      final destX = center.dx + maxRadius * cos(currentAngle);
      final destY = center.dy + maxRadius * sin(currentAngle);
      canvas.drawLine(center, Offset(destX, destY), axisPaint);

      final labelX = center.dx + (maxRadius + 18) * cos(currentAngle);
      final labelY = center.dy + (maxRadius + 12) * sin(currentAngle);

      textPainter.text = TextSpan(
        text: names[i],
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );
      textPainter.layout();
      
      canvas.save();
      canvas.translate(labelX - textPainter.width / 2, labelY - textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    final chartPath = Path();
    for (var i = 0; i < sides; i++) {
      final currentAngle = angle * i - (3.1415926535 / 2);
      final valuePercent = (values[i] / 500.0).clamp(0.0, 1.0);
      final animatedRadius = maxRadius * valuePercent * animationValue;
      final x = center.dx + animatedRadius * cos(currentAngle);
      final y = center.dy + animatedRadius * sin(currentAngle);

      if (i == 0) {
        chartPath.moveTo(x, y);
      } else {
        chartPath.lineTo(x, y);
      }
    }
    chartPath.close();

    canvas.drawPath(chartPath, fillPaint);
    canvas.drawPath(chartPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
