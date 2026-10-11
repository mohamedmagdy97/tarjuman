import 'package:equatable/equatable.dart';
import 'package:tarjuman/core/result/result.dart';

class ListedLink extends Equatable {
  const ListedLink({required this.title, required this.url});
  final String title;
  final String url;

  @override
  List<Object?> get props => [title, url];
}

class LinkListing extends Equatable {
  const LinkListing({required this.title, required this.entries});
  final String title;
  final List<ListedLink> entries;

  @override
  List<Object?> get props => [title, entries];
}

/// Expands a playlist or channel link into the videos it contains.
abstract interface class LinkLister {
  /// Cheap check on the address only (no network).
  bool supports(Uri url);

  Future<Result<LinkListing>> list(Uri url, {int limit = 50});
}
