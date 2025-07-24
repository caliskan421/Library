abstract class BaseDbRepo<T> {
  Future<int> insert(T item);
  Future<T?> get(int id);
  Future<List<T>> getAll();
  Future<int> update(T item);
  Future<void> delete(int id);
  Future<void> deleteAll();
}
