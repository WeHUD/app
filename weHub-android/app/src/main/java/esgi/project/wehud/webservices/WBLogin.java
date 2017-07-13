package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import org.json.JSONException;
import org.json.JSONObject;

import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;

/**
 * This {@link AsyncTask} class is used to authenticate a user.
 *
 * @author Olivier Gonçalves
 */
public final class WBLogin extends AsyncTask<String, Void, ServerResponse> {

    private ILogin mListener;

    public void setILogin(ILogin listener) {
        mListener = listener;
    }

    @Override
    protected ServerResponse doInBackground(String... params) {
        // Get login information
        String body = params[0];

        // Build up the request
        ServerRequest request = new ServerRequest(ServerRequest.POST, APIUtils.LOGIN, body);
        request.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_URL);
        request.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);
        request.addHeader(APIUtils.H_AUTHORIZATION, APIUtils.AUTHORIZATION);

        return request.send();
    }

    @Override
    protected void onPostExecute(ServerResponse response) {
        if (response != null && mListener != null) {
            int statusCode = response.getStatus();
            if (statusCode == APIUtils.HTTP_OK) {
                // Login was a success
                try {
                    JSONObject jsonResponse = new JSONObject(response.getContent());
                    String token = jsonResponse.getString(APIUtils.P_ACCESS_TOKEN);

                    mListener.onLoginSuccess(token);
                } catch (JSONException x) {
                    x.printStackTrace();
                }

            } else {
                // Login failed, we get an error message
                mListener.onLoginFail(response.getStatus());
            }
        } else if (mListener != null) {
            mListener.onLoginFail(APIUtils.NO_HTTP);
        }
    }

    public interface ILogin {
        void onLoginSuccess(String token);

        void onLoginFail(int status);
    }

}
