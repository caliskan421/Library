// [?] Metotlarin tanimlanmassi disinde icerik ile ilgili hicbir sey yapmadigimizdan gercekten yeterince kisaltiyor muyuz ???

abstract class BaseDbRepo<T> {
  Future<int> insert(T item);
  Future<T?> get(int id);
  Future<List<T>> getAll();
  Future<int> update(T item);
  Future<void> delete(int id);
  Future<void> deleteAll();
}
