// lib/utils/list_filter_service.dart
import 'package:flutter/foundation.dart';

enum SortType {
  nameAZ,
  nameZA,
  ageYoungest, 
  ageOldest,   
  statusWorstFirst, 
}

class SelectionController<T> extends ChangeNotifier {
  final Set<T> _selectedIds = {}; 
  bool _isSelectionMode = false;

  bool get isSelectionMode => _isSelectionMode;
  int get count => _selectedIds.length;
  Set<T> get selectedIds => Set.unmodifiable(_selectedIds);
  bool get isEmpty => _selectedIds.isEmpty;

  bool isSelected(T id) => _selectedIds.contains(id);

  void toggle(T id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    
    if (_selectedIds.isEmpty && _isSelectionMode) {
       _isSelectionMode = false; 
    } else if (!_isSelectionMode && _selectedIds.isNotEmpty) {
      _isSelectionMode = true;
    }
    notifyListeners();
  }

  void toggleMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) clear();
    notifyListeners();
  }

  void clear() {
    _selectedIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }
}

class ListFilterService {
  ListFilterService._();

  /// Remove acentos e converte para minúsculo
  static String normalize(String text) {
    if (text.isEmpty) return '';
    const withAccents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutAccents = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';
    
    var normalized = text.toLowerCase();
    for (int i = 0; i < withAccents.length; i++) {
      normalized = normalized.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return normalized;
  }

  static List<T> filter<T>({
    required List<T> items,
    required String query,
    required List<String?> Function(T item) selectors,
  }) {
    if (query.isEmpty) return items;
    
    // Normaliza e quebra a busca em palavras (tokens)
    final normalizedQuery = normalize(query);
    final queryTokens = normalizedQuery.split(' ').where((t) => t.isNotEmpty).toList();

    if (queryTokens.isEmpty) return items;

    return items.where((item) {
      // Concatena todos os campos pesquisáveis do item em uma única string
      final itemFields = selectors(item)
          .where((s) => s != null)
          .map((s) => normalize(s!))
          .join(' ');
      return queryTokens.every((token) => itemFields.contains(token));
    }).toList();
  }

  static List<T> sort<T>({
    required List<T> items,
    required SortType sortType,
    // Seletores para extrair os dados do objeto T
    required String Function(T) getName,
    required int Function(T) getAge,
    // Opcional: só necessário se usar ordenação por status
    int Function(T)? getStatusWeight, 
  }) {
    final sorted = List<T>.from(items);

    sorted.sort((a, b) {
      switch (sortType) {
        case SortType.nameAZ:
          return getName(a).toLowerCase().compareTo(getName(b).toLowerCase());
        
        case SortType.nameZA:
          return getName(b).toLowerCase().compareTo(getName(a).toLowerCase());
        
        case SortType.ageYoungest: // Menor idade (recém nascido) primeiro
          return getAge(a).compareTo(getAge(b));
          
        case SortType.ageOldest: // Maior idade primeiro
          return getAge(b).compareTo(getAge(a));

        case SortType.statusWorstFirst:
          if (getStatusWeight == null) return 0;
          // Compara peso: Peso maior (ex: atrasado) vem primeiro
          // Se empatar no status, desempata por nome
          final statusCompare = getStatusWeight(b).compareTo(getStatusWeight(a));
          if (statusCompare != 0) return statusCompare;
          return getName(a).toLowerCase().compareTo(getName(b).toLowerCase());
      }
    });

    return sorted;
  }
}