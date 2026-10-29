import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ChillChampApp());

const games = <GameInfo>[
  GameInfo('Riflessi', 'Tocca il pulsante il più velocemente possibile.', Icons.bolt),
  GameInfo('Memoria lampo', 'Memorizza e ripeti la sequenza.', Icons.psychology_alt),
  GameInfo('Numero segreto', 'Indovina il numero da 1 a 20.', Icons.numbers),
  GameInfo('Tap veloce', 'Completa la serie di tocchi.', Icons.touch_app),
  GameInfo('Vero o falso', 'Rispondi correttamente alla domanda.', Icons.fact_check),
  GameInfo('Sequenza', 'Ricostruisci la sequenza mostrata.', Icons.grid_view),
  GameInfo('Calcolo sprint', 'Scegli il risultato corretto.', Icons.calculate),
  GameInfo('Parole al volo', 'Trova la parola scritta correttamente.', Icons.spellcheck),
  GameInfo('Occhio fino', 'Trova il simbolo diverso.', Icons.visibility),
  GameInfo('Scelta rapida', 'Rispondi a una domanda a scelta multipla.', Icons.quiz),
];

class GameInfo {
  final String name;
  final String description;
  final IconData icon;
  const GameInfo(this.name, this.description, this.icon);
}

class ChillChampApp extends StatefulWidget {
  const ChillChampApp({super.key});
  @override
  State<ChillChampApp> createState() => _ChillChampAppState();
}

class _ChillChampAppState extends State<ChillChampApp> {
  bool dark = false;
  bool chillStyle = true;
  int tab = 0;
  bool enteredDemo = false;
  final List<LocalGroup> groups = [];
  final List<int> demoScores = [];
  String notice = '';

  Color get accent => chillStyle ? const Color(0xFF6575D8) : const Color(0xFF087F8C);

  ThemeData makeTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF11131A)
          : const Color(0xFFF7F8FC),
      cardTheme: CardThemeData(
        elevation: 0,
        color: brightness == Brightness.dark ? const Color(0xFF1C202B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .55)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: brightness == Brightness.dark ? const Color(0xFF202431) : Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChillChamp',
      debugShowCheckedModeBanner: false,
      theme: makeTheme(Brightness.light),
      darkTheme: makeTheme(Brightness.dark),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: enteredDemo
          ? HomeScreen(
              groups: groups,
              tab: tab,
              onTab: (v) => setState(() => tab = v),
              onCreate: _createGroup,
              onJoin: _joinGroup,
              onOpenGroup: _openGroup,
              onSettings: () => setState(() => tab = 2),
              onToggleDark: (v) => setState(() => dark = v),
              dark: dark,
              chillStyle: chillStyle,
              onStyle: (v) => setState(() => chillStyle = v),
              scores: demoScores,
              accent: accent,
            )
          : WelcomeScreen(
              onContinue: () => setState(() => enteredDemo = true),
              accent: accent,
            ),
    );
  }

  Future<void> _createGroup() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _NameDialog(),
    );
    if (result == null || result.trim().length < 2) return;
    final code = _makeCode();
    setState(() {
      groups.add(LocalGroup(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: result.trim(),
        inviteCode: code,
        createdAt: DateTime.now(),
        owner: true,
        members: 1,
      ));
      notice = 'Gruppo creato in modalità demo. Codice: $code';
    });
    if (mounted) _showNotice(notice);
  }

  Future<void> _joinGroup() async {
    final code = await showDialog<String>(
      context: context,
      builder: (context) => const _CodeDialog(),
    );
    if (code == null || code.trim().isEmpty) return;
    final matches = groups.where((g) => g.inviteCode == code.trim().toUpperCase());
    final LocalGroup? found = matches.isEmpty ? null : matches.first;
    if (found == null) {
      _showNotice('Questo prototipo trova solo gruppi creati su questo dispositivo. Firebase non è ancora collegato.');
    } else {
      _showNotice('Hai già accesso al gruppo ${found.name} in questa demo.');
    }
  }

  void _openGroup(LocalGroup group) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GroupScreen(
        group: group,
        accent: accent,
        onScore: (score) {
          setState(() => demoScores.add(score));
          _showNotice('Prova terminata: $score punti (demo locale, non in classifica).');
        },
      ),
    ));
  }

  String _makeCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void _showNotice(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final Color accent;
  const WelcomeScreen({super.key, required this.onContinue, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(color: accent.withValues(alpha: .13), borderRadius: BorderRadius.circular(24)),
                child: Icon(Icons.sports_esports_rounded, color: accent, size: 42),
              ),
              const SizedBox(height: 26),
              Text('ChillChamp', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.4)),
              const SizedBox(height: 10),
              Text('Piccole sfide, grandi rivalità.', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 22),
              const Text('Crea un gruppo, sfida i tuoi amici e scala la classifica in 21 giorni.'),
              const Spacer(),
              FilledButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Esplora la demo'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Accesso demo locale. Google Sign-In e sincronizzazione online verranno collegati con Firebase in una fase successiva.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<LocalGroup> groups;
  final int tab;
  final ValueChanged<int> onTab;
  final VoidCallback onCreate;
  final VoidCallback onJoin;
  final ValueChanged<LocalGroup> onOpenGroup;
  final VoidCallback onSettings;
  final ValueChanged<bool> onToggleDark;
  final bool dark;
  final bool chillStyle;
  final ValueChanged<bool> onStyle;
  final List<int> scores;
  final Color accent;

  const HomeScreen({
    super.key,
    required this.groups,
    required this.tab,
    required this.onTab,
    required this.onCreate,
    required this.onJoin,
    required this.onOpenGroup,
    required this.onSettings,
    required this.onToggleDark,
    required this.dark,
    required this.chillStyle,
    required this.onStyle,
    required this.scores,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final pages = [
      _groupsPage(context),
      _statsPage(context),
      _settingsPage(context),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChillChamp', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.4)),
        actions: [
          IconButton(tooltip: 'Impostazioni', onPressed: onSettings, icon: const Icon(Icons.tune_rounded)),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(child: IndexedStack(index: tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: onTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.groups_rounded), label: 'Gruppi'),
          NavigationDestination(icon: Icon(Icons.emoji_events_rounded), label: 'Statistiche'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Impostazioni'),
        ],
      ),
    );
  }

  Widget _groupsPage(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Text('La tua crew', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text('21 giorni per diventare il campione.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: FilledButton.icon(onPressed: onCreate, icon: const Icon(Icons.add_rounded), label: const Text('Crea gruppo'))),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(onPressed: onJoin, icon: const Icon(Icons.key_rounded), label: const Text('Inserisci codice'))),
        ]),
        const SizedBox(height: 20),
        if (groups.isEmpty)
          _EmptyCard(
            icon: Icons.groups_2_rounded,
            title: 'Ancora nessun gruppo',
            message: 'Crea un gruppo demo oppure preparati a entrare in quello dei tuoi amici.',
          )
        else ...[
          Row(children: [
            Text('I tuoi gruppi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${groups.length}', style: Theme.of(context).textTheme.labelLarge),
          ]),
          const SizedBox(height: 10),
          ...groups.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GroupCard(group: g, accent: accent, onTap: () => onOpenGroup(g)),
          )),
        ],
        const SizedBox(height: 14),
        const _DemoNotice(),
      ],
    );
  }

  Widget _statsPage(BuildContext context) {
    final best = scores.isEmpty ? 0 : scores.reduce(max);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Statistiche', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        const Text('I tuoi risultati su questo dispositivo.'),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _MetricCard(label: 'Prove', value: '${scores.length}', icon: Icons.sports_esports_rounded)),
          const SizedBox(width: 10),
          Expanded(child: _MetricCard(label: 'Record demo', value: '$best', icon: Icons.emoji_events_rounded)),
        ]),
        const SizedBox(height: 18),
        const _DemoNotice(),
        const SizedBox(height: 18),
        Text('Minigiochi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...games.asMap().entries.map((entry) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(backgroundColor: accent.withValues(alpha: .12), child: Icon(entry.value.icon, color: accent)),
          title: Text(entry.value.name),
          subtitle: Text('Disponibile nella demo'),
          trailing: const Icon(Icons.chevron_right_rounded),
        )),
      ],
    );
  }

  Widget _settingsPage(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Impostazioni', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        Card(child: Column(children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Tema scuro'),
            subtitle: const Text('Aspetto chiaro o scuro'),
            value: dark,
            onChanged: onToggleDark,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            secondary: const Icon(Icons.palette_outlined),
            title: const Text('Stile Chill'),
            subtitle: Text(chillStyle ? 'Colori morbidi e rilassati' : 'Stile Basic, essenziale'),
            value: chillStyle,
            onChanged: onStyle,
          ),
        ])),
        const SizedBox(height: 14),
        const Card(child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Account', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Sei nella demo locale. Il login Google verrà attivato quando collegheremo Firebase.'),
          ]),
        )),
        const SizedBox(height: 14),
        const _DemoNotice(),
        const SizedBox(height: 14),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.volume_off_outlined),
          title: Text('Audio e vibrazioni'),
          subtitle: Text('Disattivati per scelta di progetto'),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.phone_iphone_rounded),
          title: Text('Multipiattaforma'),
          subtitle: Text('Un unico codice Flutter per Android e iOS'),
        ),
      ],
    );
  }
}

class GroupScreen extends StatelessWidget {
  final LocalGroup group;
  final Color accent;
  final ValueChanged<int> onScore;
  const GroupScreen({super.key, required this.group, required this.accent, required this.onScore});

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(group.createdAt).inDays;
    final day = (elapsed + 1).clamp(1, 21);
    return Scaffold(
      appBar: AppBar(title: Text(group.name), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.flag_rounded, color: accent, size: 28),
                const SizedBox(width: 10),
                Expanded(child: Text('Campionato di 21 giorni', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
              ]),
              const SizedBox(height: 14),
              Text('Giorno $day di 21 · ${group.members} ${group.members == 1 ? 'giocatore' : 'giocatori'}'),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: day / 21, minHeight: 7, borderRadius: BorderRadius.circular(8)),
              const SizedBox(height: 10),
              const Text('Per la competizione online servirà collegare tutti i partecipanti tramite Firebase.'),
            ]),
          )),
          if (group.owner) ...[
            const SizedBox(height: 12),
            Card(child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Codice invito demo', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                SelectableText(group.inviteCode, style: Theme.of(context).textTheme.headlineMedium?.copyWith(letterSpacing: 3, fontWeight: FontWeight.w800, color: accent)),
                const SizedBox(height: 6),
                const Text('Il codice è locale a questa demo. La scadenza e la condivisione tra dispositivi saranno gestite dal backend.'),
                Align(alignment: Alignment.centerRight, child: TextButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La condivisione online non è ancora attiva.'))),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Condividi'),
                )),
              ]),
            )),
          ],
          const SizedBox(height: 20),
          Text('Minigiochi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...games.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Card(child: ListTile(
              leading: CircleAvatar(backgroundColor: accent.withValues(alpha: .12), child: Icon(entry.value.icon, color: accent)),
              title: Text(entry.value.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(entry.value.description),
              trailing: const Icon(Icons.play_arrow_rounded),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MiniGameScreen(index: entry.key, onScore: onScore),
              )),
            )),
          )),
          const _DemoNotice(),
        ],
      ),
    );
  }
}

class MiniGameScreen extends StatefulWidget {
  final int index;
  final ValueChanged<int> onScore;
  const MiniGameScreen({super.key, required this.index, required this.onScore});
  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  final answerController = TextEditingController();
  int score = 0;
  int taps = 0;
  bool finished = false;
  final int target = Random().nextInt(20) + 1;

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  void finish(int value) {
    setState(() {
      score = value;
      finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = games[widget.index];
    return Scaffold(
      appBar: AppBar(title: Text(game.name)),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(game.icon, size: 54, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 18),
          Text(game.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(game.description),
          const SizedBox(height: 24),
          if (!finished) ..._gameControls(context),
          if (finished) ...[
            Card(child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(children: [
                const Icon(Icons.emoji_events_rounded, size: 42),
                const SizedBox(height: 8),
                const Text('Prova completata'),
                Text('$score punti', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Punteggio demo locale: non viene inviato a una classifica online.'),
              ]),
            )),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                widget.onScore(score);
                Navigator.of(context).pop();
              },
              child: const Text('Salva risultato demo'),
            ),
            TextButton(onPressed: () => setState(() { finished = false; score = 0; taps = 0; answerController.clear(); }), child: const Text('Riprova')),
          ],
        ],
      ),
    );
  }

  List<Widget> _gameControls(BuildContext context) {
    switch (widget.index) {
      case 0:
        return [
          const Text('Fai 10 tocchi. Ogni tocco vale 10 punti.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() { taps++; if (taps >= 10) finish(100); }),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(100)),
            child: Text('TOCCA!  $taps / 10', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ),
        ];
      case 1:
      case 5:
        return [
          const Text('Memorizza: 2 · 4 · 1 · 3'),
          const SizedBox(height: 12),
          TextField(controller: answerController, decoration: const InputDecoration(labelText: 'Scrivi la sequenza')),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => finish(answerController.text.replaceAll(' ', '') == '2413' ? 100 : 0), child: const Text('Verifica')),
        ];
      case 2:
        return [
          const Text('Indovina il numero segreto da 1 a 20.'),
          const SizedBox(height: 12),
          TextField(controller: answerController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Numero')),
          const SizedBox(height: 12),
          FilledButton(onPressed: () {
            final n = int.tryParse(answerController.text);
            finish(n == null ? 0 : n == target ? 100 : max(0, 100 - (n - target).abs() * 5));
          }, child: const Text('Conferma')),
        ];
      case 3:
        return [
          Text('Tocchi: $taps / 20'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() { taps++; if (taps >= 20) finish(100); }),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(90)),
            child: const Text('TAP!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ),
        ];
      case 4:
        return [
          const Text('Il sole è una stella.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => finish(100), child: const Text('Vero')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => finish(0), child: const Text('Falso')),
        ];
      case 6:
        return _options(['54', '56', '64', '48'], 'Quanto fa 7 × 8?', '56');
      case 7:
        return _options(['Aquilone', 'Aquilonee', 'Acquilone', 'Aquiloni'], 'Quale parola è scritta correttamente?', 'Aquilone');
      case 8:
        return _options(['8', '3', '8', '8'], 'Trova il numero diverso: 8 · 8 · 8 · 3 · 8', '3');
      default:
        return _options(['Venere', 'Marte', 'Mercurio', 'Terra'], 'Qual è il pianeta più vicino al Sole?', 'Mercurio');
    }
  }

  List<Widget> _options(List<String> options, String question, String correct) => [
    Text(question),
    const SizedBox(height: 12),
    ...options.map((option) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () => finish(option == correct ? 100 : 0),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        child: Text(option),
      ),
    )),
  ];
}

class _NameDialog extends StatefulWidget {
  const _NameDialog();
  @override
  State<_NameDialog> createState() => _NameDialogState();
}
class _NameDialogState extends State<_NameDialog> {
  final controller = TextEditingController();
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Crea un gruppo'),
    content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Nome del gruppo'), textCapitalization: TextCapitalization.words),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
      FilledButton(onPressed: () { if (controller.text.trim().length >= 2) Navigator.pop(context, controller.text.trim()); }, child: const Text('Crea')),
    ],
  );
}

class _CodeDialog extends StatefulWidget {
  const _CodeDialog();
  @override
  State<_CodeDialog> createState() => _CodeDialogState();
}
class _CodeDialogState extends State<_CodeDialog> {
  final controller = TextEditingController();
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Entra con un codice'),
    content: TextField(controller: controller, autofocus: true, maxLength: 8, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Codice invito')),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
      FilledButton(onPressed: () => Navigator.pop(context, controller.text.toUpperCase().trim()), child: const Text('Continua')),
    ],
  );
}

class LocalGroup {
  final String id;
  final String name;
  final String inviteCode;
  final DateTime createdAt;
  final bool owner;
  final int members;
  LocalGroup({required this.id, required this.name, required this.inviteCode, required this.createdAt, required this.owner, required this.members});
}

class _GroupCard extends StatelessWidget {
  final LocalGroup group;
  final Color accent;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.accent, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            height: 54, width: 54,
            decoration: BoxDecoration(color: accent.withValues(alpha: .13), borderRadius: BorderRadius.circular(17)),
            child: Icon(Icons.groups_rounded, color: accent, size: 29),
          ),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(group.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Giorno 1 di 21 · ${group.members} giocatore${group.members == 1 ? '' : 'i'}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 9),
            const LinearProgressIndicator(value: 1 / 21, minHeight: 5),
          ])),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 25, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 14),
      Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]),
  ));
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyCard({required this.icon, required this.title, required this.message});
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(children: [
      Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 10),
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]),
  ));
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline_rounded),
      SizedBox(width: 10),
      Expanded(child: Text('Prototipo locale: gruppi, inviti e punteggi non sono ancora sincronizzati tra telefoni. Firebase e le regole competitive server-side verranno integrati dopo la validazione della struttura.')),
    ]),
  );
}
