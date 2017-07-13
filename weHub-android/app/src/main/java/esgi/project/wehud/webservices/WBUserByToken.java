package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import esgi.project.wehud.model.User;
import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.GSONUtils;

/**
 * This {@link AsyncTask} class is used to retrieve a user using their access token.
 *
 * @author Olivier Gonçalves
 */
public final class WBUserByToken extends AsyncTask<String, Void, ServerResponse> {

    private IUserByToken mListener;

    public void setIUserByToken(IUserByToken listener) {
        mListener = listener;
    }

    @Override
    protected ServerResponse doInBackground(String... params) {
        String token = params[0];

        ServerRequest request = new ServerRequest(ServerRequest.GET, APIUtils.TOKEN.replace(":token", token));
        request.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        request.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);

        return request.send();
    }

    @Override
    protected void onPostExecute(ServerResponse response) {
        if (response != null && mListener != null) {
            int status = response.getStatus();
            if (status == APIUtils.HTTP_OK) {
                User currentUser = GSONUtils.getInstance().fromJson(response.getContent(), User.class);
                mListener.onUserObtained(currentUser);
            } else {
                mListener.onUserError(response.getStatus());
            }
        } else if (mListener != null) {
            mListener.onUserError(APIUtils.NO_HTTP);
        }
    }

    public interface IUserByToken {
        void onUserObtained(User user);

        void onUserError(int status);
    }
}
