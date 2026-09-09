import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Uma linha lida da planilha, após o parsing
class ImportedPatientRow {
  final String name;
  final DateTime birthDate;
  final String? cpf;


  const ImportedPatientRow({
    required this.name,
    required this.birthDate,
    this.cpf,
  });
}

/// Resultado completo de uma operação de leitura de arquivo
class ImportResult {
  final List<ImportedPatientRow> rows;
  final List<String> skippedReasons; 
  final String fileName;

  const ImportResult({
    required this.rows,
    required this.skippedReasons,
    required this.fileName,
  });

  bool get isEmpty => rows.isEmpty;
  int get validCount => rows.length;
  int get skippedCount => skippedReasons.length;
}

/// Mapeamento de quais colunas foram detectadas na planilha
class ColumnMapping {
  final int nameColumn;
  final int dateColumn;
  final int? cpfColumn; // Ex: Responsável (criança) ou Observações

  const ColumnMapping({
    required this.nameColumn,
    required this.dateColumn,
    this.cpfColumn,
  });
}

class ImportService {
  // Formatos de data suportados (do mais específico para o mais genérico)
  static final _dateFormats = [
    DateFormat('dd/MM/yyyy'),
    DateFormat('d/M/yyyy'),
    DateFormat('dd-MM-yyyy'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('dd/MM/yy'),
    DateFormat('MM/dd/yyyy'), // Formato americano
  ];

  static const _nameKeywords = ['nome', 'name', 'paciente', 'crianca', 'mulher', 'beneficiario'];

  static const _dateKeywords = [
    'data', 'nascimento', 'nasc', 'birth', 'dn', 'datanasc', 'data_nasc',
    'dt_nasc', 'dtnasc'
  ];

  static const _cpfKeywords = ['cpf', 'documento', 'rg', 'id'];

  static bool _hasKeyword(String normalizedText, List<String> keywords) {
    return keywords.any((k) =>
        RegExp(r'\b' + RegExp.escape(k) + r'\b').hasMatch(normalizedText));
    }
  // ── ABRIR ARQUIVO ──────────────────────────────────────────────────────────

  /// Abre o seletor de arquivos e retorna o resultado do parsing.
  /// Retorna `null` se o usuário cancelar.
  static Future<ImportResult?> pickAndParse() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
      withData: true, // Importante: lê bytes em memória (funciona em Android/iOS)
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final fileName = file.name;
    final bytes = file.bytes;

    if (bytes == null) {
      throw Exception('Não foi possível ler o arquivo.');
    }

    debugPrint('📂 Arquivo selecionado: $fileName (${bytes.length} bytes)');

    final ext = fileName.split('.').last.toLowerCase();

    if (ext == 'csv') {
      return _parseCsv(bytes, fileName);
    } else if (ext == 'xlsx' || ext == 'xls') {
      return _parseExcel(bytes, fileName);
    } else {
      throw Exception('Formato não suportado: .$ext');
    }
  }

  // ── PARSING CSV ────────────────────────────────────────────────────────────

  static ImportResult _parseCsv(Uint8List bytes, String fileName) {
    // Tenta decodificar como UTF-8, com fallback para latin1 (comum em planilhas BR)
    String content;
    try {
      content = const Utf8Decoder().convert(bytes);
    } catch (_) {
      content = String.fromCharCodes(bytes); // Latin1 fallback
    }

    // Detecta delimitador automaticamente (vírgula ou ponto-e-vírgula)
    final delimiter = content.contains(';') ? ';' : ',';

    final rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(content, fieldDelimiter: delimiter);

    return _processRows(rows, fileName);
  }

  // ── PARSING EXCEL ──────────────────────────────────────────────────────────

  static ImportResult _parseExcel(Uint8List bytes, String fileName) {
    final excel = Excel.decodeBytes(bytes);

    // Usa a primeira planilha não vazia
    Sheet? targetSheet;
    for (final sheetName in excel.tables.keys) {
      final sheet = excel.tables[sheetName]!;
      if (sheet.maxRows > 0) {
        targetSheet = sheet;
        break;
      }
    }

    if (targetSheet == null) {
      throw Exception('Planilha vazia ou sem abas.');
    }

    // Converte para List<List<dynamic>> (mesmo formato do CSV)
    final rows = <List<dynamic>>[];
    for (final row in targetSheet.rows) {
      final cells = row.map((cell) => cell?.value?.toString() ?? '').toList();
      if (cells.any((c) => c.isNotEmpty)) {
        rows.add(cells);
      }
    }

    return _processRows(rows, fileName);
  }

  // ── LÓGICA CENTRAL DE PROCESSAMENTO ───────────────────────────────────────

  static ImportResult _processRows(List<List<dynamic>> rows, String fileName) {
  if (rows.isEmpty) {
    return ImportResult(
      rows: [],
      skippedReasons: [],
      fileName: fileName,
    );
  }

  // Detecta colunas
  final mapping = _detectColumns(rows.first);

  // Detecta cabeçalho
  final hasHeader = _rowLooksLikeHeader(rows.first);
  final dataRows = hasHeader ? rows.skip(1).toList() : rows;

  final validRows = <ImportedPatientRow>[];
  final skipped = <String>[];

  for (int i = 0; i < dataRows.length; i++) {
    final row = dataRows[i];
    final lineNum = i + (hasHeader ? 2 : 1);

    // Ignora linhas vazias
    if (row.every((c) => c.toString().trim().isEmpty)) continue;

    // Nome
    final rawName = _getCellValue(row, mapping.nameColumn);

    if (rawName.isEmpty) {
      skipped.add('Linha $lineNum: nome em branco.');
      continue;
    }

    // Data nascimento
    final rawDate = _getCellValue(row, mapping.dateColumn);
    final birthDate = _parseDate(rawDate);

    if (birthDate == null) {
      skipped.add(
        'Linha $lineNum ($rawName): data inválida "$rawDate".',
      );
      continue;
    }

    // Data futura
    if (birthDate.isAfter(DateTime.now())) {
      skipped.add(
        'Linha $lineNum ($rawName): data de nascimento no futuro.',
      );
      continue;
    }

    // CPF opcional
    final cpf = mapping.cpfColumn != null
        ? _getCellValue(row, mapping.cpfColumn!)
        : null;

    validRows.add(
      ImportedPatientRow(
        name: _capitalizeName(rawName),
        birthDate: birthDate,
        cpf: cpf?.trim().isEmpty ?? true ? null : cpf,
      ),
    );
  }

  debugPrint(
    '✅ Import: ${validRows.length} válidas, ${skipped.length} ignoradas',
  );

  return ImportResult(
    rows: validRows,
    skippedReasons: skipped,
    fileName: fileName,
  );
}
  // ── DETECÇÃO DE COLUNAS ────────────────────────────────────────────────────

  static ColumnMapping _detectColumns(List<dynamic> headerRow) {
    int nameCol = 0;
    int dateCol = 1;
    int? cpfCol;

    // Tenta encontrar pelas palavras-chave
    for (int i = 0; i < headerRow.length; i++) {
      final cell = headerRow[i].toString().toLowerCase().trim();
      final normalized = _removeDiacritics(cell);

      if (_hasKeyword(normalized, _nameKeywords) && nameCol == 0) {
        nameCol = i;
      } else if (_hasKeyword(normalized, _dateKeywords) && dateCol == 1) {
        dateCol = i;
      } else if (_hasKeyword(normalized, _cpfKeywords)) {
        cpfCol = i;
      }
    }

    // Garantia: nome e data não podem ser a mesma coluna
    if (nameCol == dateCol) dateCol = nameCol == 0 ? 1 : 0;

    return ColumnMapping(
      nameColumn: nameCol,
      dateColumn: dateCol,
      cpfColumn: cpfCol,
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────

  static String _getCellValue(List<dynamic> row, int index) {
    if (index >= row.length) return '';
    return row[index].toString().trim();
  }

  static DateTime? _parseDate(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return null;

    for (final fmt in _dateFormats) {
      try {
        return fmt.parseStrict(cleaned);
      } catch (_) {}
    }

    // Último recurso: tenta parse direto do Dart
    try {
      return DateTime.parse(cleaned);
    } catch (_) {}

    return null;
  }

  static bool _rowLooksLikeHeader(List<dynamic> row) {
    // Se alguma célula da primeira linha parece texto descritivo, é header
    return row.any((cell) {
      final text = cell.toString().toLowerCase();
      return _nameKeywords.any(text.contains) ||
          _dateKeywords.any(text.contains);
    });
  }

  static String _capitalizeName(String name) {
    // "MARIA SILVA" ou "maria silva" → "Maria Silva"
    return name
        .toLowerCase()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static String _removeDiacritics(String text) {
    // Remove acentos para comparação
    const withDiacritics = 'áàãâäéèêëíìîïóòõôöúùûüç';
    const withoutDiacritics = 'aaaaaeeeeiiiioooooouuuuc';
    String result = text;
    for (int i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return result;
  }
}