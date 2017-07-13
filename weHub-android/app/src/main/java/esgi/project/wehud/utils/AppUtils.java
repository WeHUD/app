package esgi.project.wehud.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.ImageView;
import android.widget.Toast;

import com.google.android.youtube.player.YouTubeStandalonePlayer;
import com.squareup.picasso.Picasso;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import esgi.project.wehud.R;

/**
 * Helper class containing various methods used in the application.
 *
 * @author Olivier Gonçalves
 */
public final class AppUtils {

    // This key is used to play YouTube videos using an {@link Intent}.
    private static final String YOUTUBE_API_KEY = "AIzaSyBjCXz8m3Jtpx4WY-etB_zFFRH5HmTCyM8";

    private static final String YOUTUBE_VID_URL_HEAD = "https://youtube.com/watch?v=";
    private static final String YOUTUBE_IMG_URL_HEAD = "https://img.youtube.com/vi/";
    private static final String YOUTUBE_IMG_URL_FOOT = "/maxresdefault.jpg";

    private static final String ISO_8601_PATTERN = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    private static final String UTF8 = "UTF-8";

    /**
     * Private constructor makes initializing this class by its default constructor impossible.
     */
    private AppUtils() {
    }

    /**
     * Displays a {@link Toast} on the screen.
     *
     * @param context the {@link Context} of the application
     * @param message the {@link String} to display as a message in the Toast.
     */
    public static void toast(Context context, String message) {
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
    }

    /**
     * Configure the {@link Toolbar} object.
     *
     * @param fragment the {@link Fragment} in which is declared the toolbar
     * @param view the {@link View} in the fragment containing the toolbar
     * @param title the {@link String} to display in the toolbar
     * @return the configured toolbar
     */
    public static Toolbar setToolbar(Fragment fragment, View view, String title) {
        AppCompatActivity container = (AppCompatActivity) fragment.getActivity();
        Toolbar toolbar = (Toolbar) view.findViewById(R.id.toolbar);
        container.setSupportActionBar(toolbar);
        container.setTitle(title);
        return toolbar;
    }

    /**
     * Retrieves a URL-encoded {@link String} from a {@link Map} object.
     *
     * @param params
     * @return
     */
    public static String getURLFormEncodedFromMap(Map<String, Object> params) {
        StringBuilder result = new StringBuilder();
        boolean first = true;
        for (Map.Entry<String, Object> entry : params.entrySet()) {
            if (first) {
                first = false;
            } else {
                result.append('&');
            }

            try {
                result.append(URLEncoder.encode(entry.getKey(), UTF8));
                result.append('=');
                result.append(URLEncoder.encode(wrap(entry.getValue()), UTF8));
            } catch (UnsupportedEncodingException x) {
                x.printStackTrace();
            }
        }

        return result.toString();
    }

    /**
     * Gets a YouTube video ID from its full URL.
     *
     * @param videoURL the URL of the YouTube video
     * @return the YouTube video ID
     */
    public static String extractYouTubeVideoId(String videoURL) {
        String pattern = "(?<=watch\\?v=|/videos/|embed\\/|youtu.be\\/|\\/v\\/|\\/e\\/|watch\\?v%3D|watch\\?feature=player_embedded&v=|%2Fvideos%2F|embed%\u200C\u200B2F|youtu.be%2F|%2Fv%2F)[^#\\&\\?\\n]*";

        Pattern compiledPattern = Pattern.compile(pattern);

        //videoURL is YouTube's URL from which to extract the id.
        Matcher matcher = compiledPattern.matcher(videoURL);
        if (matcher.find()) {
            return matcher.group();
        }

        return videoURL;
    }

    /**
     * Makes a full YouTube video URL.
     *
     * @param id the video ID of the YouTube video
     * @return the full YouTube URL of the video
     */
    public static String buildYouTubeVideoURL(String id) {
        return YOUTUBE_VID_URL_HEAD + id;
    }

    /**
     * Configures a YouTube video in the application.
     *
     * @param context the context of the application
     * @param youTubeID the ID of the YouTube video
     * @param imageView an {@link ImageView} that will contain a thumbnail of the video
     */
    public static void setupYouTubeVideo(final Context context, final String youTubeID, final ImageView imageView) {
        String youTubeURL = buildYouTubeThumbnailURL(youTubeID);
        Picasso.with(context).load(youTubeURL).into(imageView);
        imageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent youTubeIntent = YouTubeStandalonePlayer.createVideoIntent(
                        (Activity) context, YOUTUBE_API_KEY, youTubeID, 100, true, true
                );
                context.startActivity(youTubeIntent);
            }
        });
    }

    /**
     * Get a {@link Date} object in the ISO8901 format.
     *
     * @param input a {@link String} object representing a date in the dd/MM/yyyy format
     * @return a {@link Date} object in the ISO8601 format
     */
    public static Date getISODate(String input) {
        DateFormat shortFormatter = DateFormat.getDateInstance(DateFormat.SHORT);
        try {
            Date d = shortFormatter.parse(input);
            SimpleDateFormat isoFormatter = new SimpleDateFormat(ISO_8601_PATTERN, Locale.getDefault());
            String parsedDate = isoFormatter.format(d);
            return isoFormatter.parse(parsedDate);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Helper method to call the Picasso static instance to load images.
     * @param context the {@link Context} of the application
     * @param imgUrl a {@link String} object representing the URL of the image
     * @param iv an {@link ImageView} in which to load the image
     * @param s a value in pixels used to resize the image
     */
    public static void loadImage(Context context, String imgUrl, ImageView iv, int s) {
        Picasso.with(context).load(imgUrl).resize(s, s).into(iv);
    }

    /**
     * Build up a YouTube thumbnail URL from a video ID.
     *
     * @param id the unique identifier of the YouTube video
     * @return the full URL of the thumbnail image
     */
    private static String buildYouTubeThumbnailURL(String id) {
        return YOUTUBE_IMG_URL_HEAD + id + YOUTUBE_IMG_URL_FOOT;
    }

    /**
     * Helper method to wrap up values in the getURLFormEncodedFromMap method.
     * @param o the {@link Object} to wrap up
     * @return a {@link String} containing the object
     */
    private static String wrap(Object o) {
        if (o instanceof String) {
            return o.toString();
        } else {
            return String.valueOf(o);
        }
    }
}
