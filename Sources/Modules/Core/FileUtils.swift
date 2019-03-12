import Foundation

public final class FileUtils {
    private init() {}

    public static let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
}
