package esgi.project.wehud.utils;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.Map;

/**
 * Helper class to manage simple JSON-related operations.
 *
 * @author Olivier Gonçalves
 */
public final class JSONUtils {

    /**
     * Transforms a basic Map into a valid JSON object
     *
     * @param map the Map to turn into JSON
     * @return a valid JSON string
     */
    public static String getJSONFromMap(Map<String, ?> map) {
        String json = "{";
        if (map != null && map.size() > 0) {
            for (Map.Entry<String, ?> argument : map.entrySet()) {
                json += "\"" + argument.getKey() + "\":" + wrap(argument.getValue()) + ",";
            }
            // Removing the last comma that sneaks in at the end
            json = json.substring(0, json.length() - 1);
        }
        json += "}";

        return json;
    }

    /**
     * Wraps up values according to their type so that
     * they can be safely inserted into a JSON string.
     *
     * @param o the {@link Object} to wrap up
     * @return the {@link Object} wrapped up
     */
    private static Object wrap(Object o) {
        if (o == null) {
            return null;
        }
        if (o instanceof JSONArray || o instanceof JSONObject) {
            return o;
        }
        if (o instanceof String) {
            return "\"" + o + "\"";
        }
        try {
            if (o instanceof Boolean ||
                    o instanceof Byte ||
                    o instanceof Character ||
                    o instanceof Double ||
                    o instanceof Float ||
                    o instanceof Integer ||
                    o instanceof Long ||
                    o instanceof Short) {
                return o;
            }
            if (o.getClass().getPackage().getName().startsWith("java.")) {
                return o.toString();
            }
        } catch (Exception ignored) {
        }
        return null;
    }
}
