import 'dart:collection';


/// Base class for implementing a [Map].
///
/// A basic Map class can be implemented by extending this class
/// and implementing the [delegate].
abstract class DelegatingMapBase<K, V>
    with MapBase<K, V>, MapBaseDelegate<K, V> {}


/// Combine this with [MapBase] mixin to implement all of the
/// members of [Map].
mixin MapBaseDelegate<K, V> implements MapBase<K, V> {

  Map<K, V> get delegate;

  @override
  V? operator [](Object? key) => delegate[key];

  @override
  void operator []=(K key, V value) => delegate[key] = value;

  @override
  void clear() => delegate.clear();

  @override
  Iterable<K> get keys => delegate.keys;

  @override
  V? remove(Object? key) => delegate.remove(key);
}


/// Base implementation of [Set].
///
/// This class provides a base implementation of a Set that
/// depends only on the [delegate].
abstract class DelegatingSetBase<E>
    with SetBase<E>, SetBaseDelegate<E> {}


/// Combine this with [SetBase] mixin to implement all of the
/// members of [Set].
mixin SetBaseDelegate<E> implements SetBase<E> {

  Set<E> get delegate;

  @override
  bool add(E value) => delegate.add(value);

  @override
  bool contains(Object? element) => delegate.contains(element);

  @override
  Iterator<E> get iterator => delegate.iterator;

  @override
  int get length => delegate.length;

  @override
  E? lookup(Object? element) => delegate.lookup(element);

  @override
  bool remove(Object? value) => delegate.remove(value);

  @override
  Set<E> toSet() => delegate.toSet();
}
