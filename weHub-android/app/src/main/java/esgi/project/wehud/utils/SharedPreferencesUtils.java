package esgi.project.wehud.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

/**
 * Helper class to manage SharedPreferences in the application.
 *
 * @author Olivier Gonçalves
 */
public final class SharedPreferencesUtils {

    /**
     * Private constructor makes directly initializing this class not possible.
     */
    private SharedPreferencesUtils() {
    }

    /**
     * Retrieves the application's default SharedPreferences file.
     *
     * @param context the context of the application
     * @return a SharedPreferences instance
     */
    private static SharedPreferences getSharedPreferences(Context context) {
        return PreferenceManager.getDefaultSharedPreferences(context);
    }

    /**
     * Put a value into the SharedPreferences file.
     *
     * @param context the context of the application
     * @param key a {@link String} used as a key to store the value
     * @param value an {@link Object} used as a value to be stored with a key
     */
    public static void putSharedPreference(Context context, String key, Object value) {
        SharedPreferences.Editor editor = getSharedPreferences(context).edit();

        if (value instanceof String) {
            editor.putString(key, value.toString());
        } else if (value instanceof Integer) {
            editor.putInt(key, (int) value);
        } else if (value instanceof Double) {
            editor.putFloat(key, Double.doubleToRawLongBits((double) value));
        } else if (value instanceof Float) {
            editor.putFloat(key, (float) value);
        } else if (value instanceof Boolean) {
            editor.putBoolean(key, (boolean) value);
        } else if (value instanceof Short) {
            editor.putInt(key, (int) value);
        } else if (value instanceof Long) {
            editor.putLong(key, (long) value);
        } else if (value instanceof Character) {
            editor.putInt(key, (char) value);
        }

        editor.apply();
    }

    /**
     * Retrieve the SharedPreferences file using a {@link String} as key.
     *
     * @param context the context of the application
     * @param key a {@link String} used as a key
     * @return the value stored for the key, or null if no such key exists in SharedPreferences
     */
    public static String getSharedPreferenceByKey(Context context, String key) {
        return getSharedPreferences(context).getString(key, "");
    }

    /**
     * Retrieve the {@link SharedPreferences} file using a {@link String} as key, and providing an access mode.
     *
     * @param context the context of the application
     * @param s the key used for getting the SharedPreferences file
     * @param mode an integer used to specify a particular mode for opening the file
     * @return the {@link SharedPreferences} file.
     */
    private static SharedPreferences getSharedPreferences(Context context, String s, int mode) {
        return context.getSharedPreferences(s, mode);
    }

    /**
     * Deletes the SharedPreferences file.
     *
     * @param context the context of the application
     */
    public static void clearPreferences(Context context) {
        SharedPreferences.Editor editor = getSharedPreferences(context).edit();
        editor.clear();
        editor.apply();
    }
}
