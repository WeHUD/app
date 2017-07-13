package esgi.project.wehud.network;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

/**
 * Helper class to make webservice requests.
 *
 * @author Olivier Gonçalves
 */
public final class ServerRequest {

    // HTTP Connection object
    private HttpURLConnection mConnection;

    // HTTP Methods
    public final static String GET = "GET";
    public final static String POST = "POST";
    public final static String PUT = "PUT";
    public final static String DELETE = "DELETE";

    // Connection timeout
    private final static int DEFAULT_READ_TIMEOUT = 5000; // 5 seconds
    private final static int DEFAULT_CONNECT_TIMEOUT = 5000; // 5 seconds
    private int mReadTimeout = DEFAULT_READ_TIMEOUT;
    private int mConnectTimeout = DEFAULT_CONNECT_TIMEOUT;

    // Connection encoding and security
    private final static String ENCODING = "UTF-8";
    private boolean mSecure = true;

    // HTTP setup
    private String mType;
    private String mUrl;
    private String mBody;
    private Map<String, String> mHeaders;
    private Map<String, String> mParameters;

    private ServerRequest() {
    }

    public ServerRequest(String type, String url) {
        this(type, url, null, new HashMap<String, String>());
    }

    public ServerRequest(String type, String url, String body) {
        this(type, url, body, new HashMap<String, String>());
    }

    public ServerRequest(String type, String url, String body, Map<String, String> headers) {
        this(type, url, body, headers, new HashMap<String, String>());
    }

    public ServerRequest(String type, String url, String body, Map<String, String> headers, Map<String, String> parameters) {
        this.mParameters = parameters;
        this.mHeaders = headers;
        this.mBody = body;
        this.mType = type;
        this.mUrl = url;
    }

    private URL getFormattedURL() throws IOException {
        String baseURL = (mSecure ? "https://" : "http://") + mUrl;
        if (mParameters != null) {
            int i = 0;
            for (Map.Entry<String, String> entry : mParameters.entrySet()) {
                baseURL += (i == 0) ? "?" : "&";
                baseURL += URLEncoder.encode(entry.getKey(), ENCODING) + "=" +
                        URLEncoder.encode(entry.getValue(), ENCODING);
                i++;
            }
        }

        return new URL(baseURL);
    }

    private void initRequest(URL url) throws IOException {
        mConnection = (HttpURLConnection) url.openConnection();
        mConnection.setReadTimeout(mReadTimeout);
        mConnection.setConnectTimeout(mConnectTimeout);
        mConnection.setRequestMethod(mType);
        mConnection.setDoInput(true);
        mConnection.setUseCaches(false);

        if (mHeaders != null) {
            for (Map.Entry<String, String> entry : mHeaders.entrySet()) {
                mConnection.setRequestProperty(entry.getKey(), entry.getValue());
            }
        }

        if (mType.equals(POST) || mType.equals(PUT) && mBody != null) {
            mConnection.setDoOutput(true);
        }
    }

    private void wrapContent() throws IOException {
        if (mType.equals(POST) || mType.equals(PUT) && mBody != null) {
            DataOutputStream os = new DataOutputStream(mConnection.getOutputStream());
            if (mBody != null) {
                os.writeBytes(mBody);
            }

            os.flush();
            os.close();
        }
    }

    private ServerResponse getResponse() throws IOException {
        ServerResponse response = null;
        try {
            InputStream inputStream = mConnection.getInputStream();
            if (inputStream != null) {
                response = new ServerResponse(mConnection.getResponseCode(), this.readResponse(inputStream));
            }
        } catch (IOException inputStreamException) {
            InputStream errorStream = mConnection.getErrorStream();
            if (errorStream != null) {
                response = new ServerResponse(mConnection.getResponseCode(), this.readResponse(errorStream));
            }
        }

        return response;
    }

    /**
     * Send the request and retrieve the response
     *
     * @return the server's response or null
     */
    public ServerResponse send() {
        ServerResponse serverResponse = null;
        try {
            URL formattedURL = this.getFormattedURL();
            this.initRequest(formattedURL);
            this.wrapContent();
            serverResponse = this.getResponse();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return serverResponse;
    }

    /**
     * Read the InputStream and returns the server's response as a string
     *
     * @param is the InputStream to read from
     * @return the server's reponse
     * @throws IOException an exception
     */
    private String readResponse(InputStream is) throws IOException {
        if (is == null)
            return null;
        BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
        StringBuilder builder = new StringBuilder();
        try {
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line);
            }
        } finally {
            is.close();
            reader.close();
        }
        return builder.toString();
    }

    public void setReadTimeout(int readTimeout) {
        mReadTimeout = readTimeout;
    }

    public void setConnectTimeout(int connectTimeout) {
        mConnectTimeout = connectTimeout;
    }

    public void addHeader(String header, String value) {
        mHeaders.put(header, value);
    }

    public void setHeaders(Map<String, String> headers) {
        mHeaders = headers;
    }

    public void addParameter(String parameter, String value) {
        mParameters.put(parameter, value);
    }

    public void setParameters(Map<String, String> parameters) {
        mParameters = parameters;
    }

    public void setBody(String body) {
        mBody = body;
    }

    public void setSecure(boolean secure) {
        mSecure = secure;
    }
}
