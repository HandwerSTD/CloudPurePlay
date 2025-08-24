
export class MemStore {
  private static instance: MemStore;
  private _objects: Map<string, Object>;

  private constructor() {
    this._objects = new Map<string, Object>();
  }

  public static getContext(): MemStore {
    if (!MemStore.instance) {
      MemStore.instance = new MemStore();
    }
    return MemStore.instance;
  }

  getObject(key: string): Object | undefined {
    return this._objects.get(key);
  }

  setObject(key: string, objectClass: Object): void {
    this._objects.set(key, objectClass);
  }

  deleteObject(key: string): void {
    this._objects.delete(key);
  }
}