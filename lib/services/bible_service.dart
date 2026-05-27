import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';


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


Map<String, Map<int, Map<int, String>>> _parseBibleXml(String raw) {
  final doc = XmlDocument.parse(raw);
  final result = <String, Map<int, Map<int, String>>>{};

  const bookTags = {'BIBLEBOOK', 'BOOK', 'B'};
  const chapterTags = {'CHAPTER', 'C'};
  const verseTags = {'VERS', 'VERSE', 'V'};

  for (final el in doc.descendants.whereType<XmlElement>()) {
    if (!bookTags.contains(el.name.local.toUpperCase())) continue;

    // 🔥 CAMBIO CLAVE: usar number en lugar de name
    final bookNumber = int.tryParse(_attr(el, ['number']) ?? '');
    if (bookNumber == null) continue;

    final bookName = bookNames[bookNumber] ?? 'Libro_$bookNumber';
    final bookKey = _norm(bookName);

    result[bookKey] = {};

    for (final ch in el.childElements) {
      if (!chapterTags.contains(ch.name.local.toUpperCase())) continue;

      final chNum = int.tryParse(_attr(ch, ['number']) ?? '');
      if (chNum == null) continue;

      result[bookKey]![chNum] = {};

      for (final v in ch.childElements) {
        if (!verseTags.contains(v.name.local.toUpperCase())) continue;

        final vNum = int.tryParse(_attr(v, ['number']) ?? '');
        if (vNum == null) continue;

        result[bookKey]![chNum]![vNum] = v.innerText.trim();
      }
    }
  }

  return result;
}

String? _attr(XmlElement el, List<String> names) {
  for (final n in names) {
    final v = el.getAttribute(n);
    if (v != null && v.isNotEmpty) return v;
  }
  return null;
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

class BibleService {
  static final BibleService _instance = BibleService._();
  factory BibleService() => _instance;
  BibleService._();

  Map<String, Map<int, Map<int, String>>>? _bible;
  Future<void>? _loadFuture;


  Future<void> _ensureLoaded() {
    _loadFuture ??= _load();
    return _loadFuture!;
  }

  

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/SpanishRVR1960Bible.xml');
    _bible = await compute(_parseBibleXml, raw);
  }

  /// Returns [(verseNumber, text)] for the given reference (e.g. "Juan 3:16" or "Salmos 23:1-4").
  Future<List<(int, String)>> lookupReference(String reference) async {
    await _ensureLoaded();
    final ref = _parseRef(reference.trim());
    if (ref == null || _bible == null) return [];

    final book = _findBook(_norm(ref.$1));
    if (book == null) return [];

    final chapter = book[ref.$2];
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
  (String, int, int, int?)? _parseRef(String s) {
    final m = RegExp(r'^(.+?)\s+(\d+):(\d+)(?:-(\d+))?').firstMatch(s);
    if (m == null) return null;
    return (
      m.group(1)!.trim(),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      m.group(4) != null ? int.parse(m.group(4)!) : null,
    );
  }

  Map<int, Map<int, String>>? _findBook(String key) {
    if (_bible!.containsKey(key)) return _bible![key];
    final via = _aliases[key];
    if (via != null && _bible!.containsKey(via)) return _bible![via];
    for (final entry in _bible!.entries) {
      if (entry.key.startsWith(key) || key.startsWith(entry.key)) return entry.value;
    }
    return null;
  }
}
