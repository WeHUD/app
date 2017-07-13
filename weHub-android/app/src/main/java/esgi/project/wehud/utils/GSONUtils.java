package esgi.project.wehud.utils;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * Singleton class to handle using the {@link Gson} library.
 *
 * @author Olivier Gonçalves
 */
public final class GSONUtils {

    private static Gson mInstance;

    private GSONUtils() {
    }

    public static Gson getInstance() {
        if (mInstance == null) {
            mInstance = new GsonBuilder().create();
        }

        return mInstance;
    }

}
