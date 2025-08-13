export class ResUtil {
  static getString(context: Context, res: Resource) {
    return context.resourceManager.getStringValue(res)
  }
}