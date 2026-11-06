import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


  Map<int, String> bookNames = {
  1: 'Genesis',
  2: 'Exodo',
  3: 'Levitico',
  4: 'Numeros',
  5: 'Deuteronomio',
  6: 'Josue',
  7: 'Jueces',
  8: 'Rut',
  9: '1 Samuel',
  10: '2 Samuel',
  11: '1 Reyes',
  12: '2 Reyes',
  13: '1 Cronicas',
  14: '2 Cronicas',
  15: 'Esdras',
  16: 'Nehemias',
  17: 'Ester',
  18: 'Job',
  19: 'Salmos',
  20: 'Proverbios',
  21: 'Eclesiastes',
  22: 'Cantares',
  23: 'Isaias',
  24: 'Jeremias',
  25: 'Lamentaciones',
  26: 'Ezequiel',
  27: 'Daniel',
  28: 'Oseas',
  29: 'Joel',
  30: 'Amos',
  31: 'Abdias',
  32: 'Jonas',
  33: 'Miqueas',
  34: 'Nahum',
  35: 'Habacuc',
  36: 'Sofonias',
  37: 'Hageo',
  38: 'Zacarias',
  39: 'Malaquias',

  40: 'Mateo',
  41: 'Marcos',
  42: 'Lucas',
  43: 'Juan',
  44: 'Hechos',
  45: 'Romanos',
  46: '1 Corintios',
  47: '2 Corintios',
  48: 'Galatas',
  49: 'Efesios',
  50: 'Filipenses',
  51: 'Colosenses',
  52: '1 Tesalonicenses',
  53: '2 Tesalonicenses',
  54: '1 Timoteo',
  55: '2 Timoteo',
  56: 'Tito',
  57: 'Filemon',
  58: 'Hebreos',
  59: 'Santiago',
  60: '1 Pedro',
  61: '2 Pedro',
  62: '1 Juan',
  63: '2 Juan',
  64: '3 Juan',
  65: 'Judas',
  66: 'Apocalipsis',
};


/// Parses one book file: "#chapter" lines open a chapter, others are "verse TAB text".
Map<int, Map<int, String>> _parseBookText(String raw) {
  final chapters = <int, Map<int, String>>{};
  Map<int, String>? current;
  for (final line in raw.split('\n')) {
    if (line.isEmpty) continue;
    if (line.codeUnitAt(0) == 0x23) {
      current = chapters[int.tryParse(line.substring(1).trim()) ?? -1] = {};
      continue;
    }
    final tab = line.indexOf('\t');
    if (tab < 0 || current == null) continue;
    final v = int.tryParse(line.substring(0, tab));
    if (v == null) continue;
    current[v] = line.substring(tab + 1).trim().replaceAll('\u017F', 's');
  }
  return chapters;
}

String _norm(String s) => s
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u')
    .replaceAll('ñ', 'n')
    .replaceAll('.', '')
    .trim();

// Spanish Bible abbreviations -> normalized book name key
const _aliases = <String, String>{
  'gn': 'genesis', 'gen': 'genesis',
  'ex': 'exodo', 'exod': 'exodo', 'exo': 'exodo',
  'lv': 'levitico', 'lev': 'levitico',
  'nm': 'numeros', 'num': 'numeros',
  'dt': 'deuteronomio', 'deut': 'deuteronomio',
  'jos': 'josue',
  'jue': 'jueces',
  '1s': '1 samuel', '1sam': '1 samuel',
  '2s': '2 samuel', '2sam': '2 samuel',
  '1r': '1 reyes', '1re': '1 reyes',
  '2r': '2 reyes', '2re': '2 reyes',
  '1cr': '1 cronicas',
  '2cr': '2 cronicas',
  'esd': 'esdras',
  'neh': 'nehemias',
  'est': 'ester',
  'sal': 'salmos', 'ps': 'salmos', 'psalm': 'salmos', 'salmo': 'salmos',
  'pr': 'proverbios', 'prov': 'proverbios',
  'ec': 'eclesiastes', 'ecl': 'eclesiastes',
  'cant': 'cantares', 'cnt': 'cantares',
  'is': 'isaias', 'isa': 'isaias',
  'jer': 'jeremias',
  'lam': 'lamentaciones',
  'ez': 'ezequiel', 'eze': 'ezequiel',
  'dn': 'daniel', 'dan': 'daniel',
  'os': 'oseas', 'hos': 'oseas',
  'am': 'amos',
  'abd': 'abdias',
  'jon': 'jonas',
  'miq': 'miqueas', 'mic': 'miqueas',
  'nah': 'nahum',
  'hab': 'habacuc',
  'sof': 'sofonias', 'zeph': 'sofonias',
  'hag': 'hageo',
  'zac': 'zacarias', 'zech': 'zacarias',
  'mal': 'malaquias',
  'mt': 'mateo', 'mat': 'mateo',
  'mr': 'marcos', 'mc': 'marcos',
  'lc': 'lucas', 'lk': 'lucas',
  'jn': 'juan', 'joh': 'juan',
  'hch': 'hechos', 'act': 'hechos',
  'ro': 'romanos', 'rom': 'romanos',
  '1co': '1 corintios', '1cor': '1 corintios',
  '2co': '2 corintios', '2cor': '2 corintios',
  'gl': 'galatas', 'gal': 'galatas',
  'ef': 'efesios', 'efe': 'efesios', 'eph': 'efesios',
  'fil': 'filipenses', 'php': 'filipenses',
  'col': 'colosenses',
  '1ts': '1 tesalonicenses', '1tes': '1 tesalonicenses',
  '2ts': '2 tesalonicenses', '2tes': '2 tesalonicenses',
  '1ti': '1 timoteo', '1tim': '1 timoteo',
  '2ti': '2 timoteo', '2tim': '2 timoteo',
  'tt': 'tito', 'tit': 'tito',
  'flm': 'filemon', 'phlm': 'filemon',
  'heb': 'hebreos',
  'stg': 'santiago', 'jas': 'santiago',
  '1p': '1 pedro', '1pe': '1 pedro', '1ped': '1 pedro',
  '2p': '2 pedro', '2pe': '2 pedro', '2ped': '2 pedro',
  '1jn': '1 juan', '1jo': '1 juan',
  '2jn': '2 juan', '2jo': '2 juan',
  '3jn': '3 juan', '3jo': '3 juan',
  'jud': 'judas',
  'ap': 'apocalipsis', 'apo': 'apocalipsis', 'rev': 'apocalipsis',
};

class BibleVersion {
  final String id;
  final String name;
  const BibleVersion(this.id, this.name);
}

const kBibleVersions = [
  BibleVersion('RVR1960', 'Reina-Valera 1960'),
  BibleVersion('NVI', 'Nueva Versión Internacional'),
  BibleVersion('NTV', 'Nueva Traducción Viviente'),
  BibleVersion('DHH', 'Dios Habla Hoy'),
  BibleVersion('TLA', 'Traducción en Lenguaje Actual'),
  BibleVersion('PDT', 'Palabra de Dios para Todos'),
  BibleVersion('BDO', 'Biblia del Oso'),
];

const kDefaultBibleVersion = 'RVR1960';

String bibleVersionName(String id) => kBibleVersions
    .firstWhere((v) => v.id == id, orElse: () => kBibleVersions.first)
    .name;

class BibleService {
  static final BibleService _instance = BibleService._();
  factory BibleService() => _instance;
  BibleService._();

  // "version:book" -> chapters. Only books actually read are kept in memory.
  final _books = <String, Map<int, Map<int, String>>>{};
  final _loading = <String, Future<Map<int, Map<int, String>>>>{};
  final _copyright = <String, String>{};
  late final Map<String, int> _bookNumbers = {
    for (final e in bookNames.entries) _norm(e.value): e.key,
  };

  Future<Map<int, Map<int, String>>> _loadBook(String version, int book) {
    final key = '$version:$book';
    final cached = _books[key];
    if (cached != null) return Future.value(cached);
    return _loading[key] ??= () async {
      try {
        final raw = await rootBundle.loadString('assets/bible/$version/$book.txt');
        final parsed = await compute(_parseBookText, raw);
        _books[key] = parsed;
        return parsed;
      } finally {
        _loading.remove(key);
      }
    }();
  }

  Future<String> copyright(String version) async {
    final cached = _copyright[version];
    if (cached != null) return cached;
    try {
      final t = (await rootBundle.loadString('assets/bible/$version/meta.txt')).trim();
      return _copyright[version] = t;
    } catch (_) {
      return '';
    }
  }

  /// Returns [(verseNumber, text)] for a reference (e.g. "Juan 3:16", "Salmos 23:1-4").
  Future<List<(int, String)>> lookupReference(
    String reference, {
    String version = kDefaultBibleVersion,
  }) async {
    final ref = _parseRef(reference.trim());
    if (ref == null) return [];

    final bookNum = _findBookNumber(_norm(ref.$1));
    if (bookNum == null) return [];

    final chapter = (await _loadBook(version, bookNum))[ref.$2];
    if (chapter == null) return [];

    final end = ref.$4 ?? ref.$3;
    final out = <(int, String)>[];
    for (var v = ref.$3; v <= end; v++) {
      final text = chapter[v];
      if (text != null) out.add((v, text));
    }
    return out;
  }

  // Returns (bookName, chapter, verseStart, verseEnd?)
  // Handles "Juan 3:16", "Salmos 23:1-4", and "Marcos 8:7 al 9"
  (String, int, int, int?)? _parseRef(String s) {
    final m = RegExp(r'^(.+?)\s+(\d+):(\d+)(?:(?:\s+al\s+|-\s*)(\d+))?').firstMatch(s);
    if (m == null) return null;
    return (
      m.group(1)!.trim(),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      m.group(4) != null ? int.parse(m.group(4)!) : null,
    );
  }

  int? _findBookNumber(String key) {
    final direct = _bookNumbers[key] ?? _bookNumbers[_aliases[key]];
    if (direct != null) return direct;
    for (final entry in _bookNumbers.entries) {
      if (entry.key.startsWith(key) || key.startsWith(entry.key)) return entry.value;
    }
    return null;
  }
}
