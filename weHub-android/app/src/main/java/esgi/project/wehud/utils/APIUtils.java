package esgi.project.wehud.utils;

/**
 * Helper class to access URLs used in webservices of the application.
 *
 * @author Olivier Gonçalves
 */
public final class APIUtils {

    private static final String BASE_URL = "g-zone.herokuapp.com";

    public static final String USERS = BASE_URL + "/users";
    public static final String GAMES = BASE_URL + "/games";
    public static final String POSTS = BASE_URL + "/posts";
    public static final String COMMENTS = BASE_URL + "/comments";

    public static final String TOKEN = USERS + "/token/:token";

    public static final String UPDATE_USER = USERS + "/:userId";
    public static final String UPDATE_GAME = GAMES + "/:gameId";
    public static final String UPDATE_POST = POSTS + "/:postId";

    public static final String POSTS_BY_USER = POSTS + "/user/:userId";
    public static final String POSTS_BY_LIKES = POSTS + "/likes/top";
    public static final String COMMENTS_BY_POST = COMMENTS + "/post/:postId";

    public static final String LOGIN = BASE_URL + "/oauth/token";

    // Headers in all requests
    public static final String H_CONTENT_TYPE = "Content-Type";
    public static final String CONTENT_TYPE_JSON = "application/json";
    public static final String CONTENT_TYPE_URL = "application/x-www-form-urlencoded";
    public static final String H_ACCEPT = "Accept";
    public static final String ACCEPT = "application/json";

    // Header in login request
    public static final String H_AUTHORIZATION = "Authorization";
    public static final String AUTHORIZATION = "Basic bnM0ZlFjMTRaZzRoS0ZDTmFTekFyVnV3c3pYOTVYOlpJakZ5VHNOZ1FOeXhJ";

    // Parameter in all requests
    public static final String P_ACCESS_TOKEN = "access_token";

    // SharedPreferences keys
    public static final String SP_KEY_TOKEN = "token";
    public static final String SP_KEY_FIREBASE_TOKEN = "firebase_token";
    public static final String SP_KEY_ID = "id";
    public static final String SP_KEY_USERNAME = "username";

    // Profile images URLs
    public static final String[] IMAGES = {
            "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile01.png",
            "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile02.png",
            "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile03.png",
            "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile04.png",
    };
    public static final int SIZE = 256;

    // HTTP Response Codes
    public static final int HTTP_OK = 200;
    public static final int HTTP_CREATED = 201;
    public static final int HTTP_FORBIDDEN = 403;
    public static final int HTTP_NOT_FOUND = 404;
    public static final int HTTP_SERVER_ERROR = 500;
    public static final int NO_HTTP = -100;

}
