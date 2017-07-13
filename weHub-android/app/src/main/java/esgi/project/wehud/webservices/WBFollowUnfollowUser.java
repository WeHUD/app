package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;

/**
 * This {@link AsyncTask} class is used to follow or unfollow a user.
 *
 * @author Olivier Gonçalves
 */
public final class WBFollowUnfollowUser extends AsyncTask<String, Void, ServerResponse> {

    private IUpdateUser mListener;

    public void setIUpdateUser(IUpdateUser listener) {
        mListener = listener;
    }

    @Override
    protected ServerResponse doInBackground(String... params) {
        String token = params[0];
        String userId = params[1];
        String body = params[2];

        ServerRequest request = new ServerRequest(ServerRequest.PUT, APIUtils.UPDATE_USER.replace(":userId", userId), body);
        request.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        request.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);
        request.addParameter(APIUtils.P_ACCESS_TOKEN, token);

        return request.send();
    }

    @Override
    protected void onPostExecute(ServerResponse response) {
        if (response != null && mListener != null) {
            int status = response.getStatus();
            if (status == APIUtils.HTTP_OK) {
                mListener.onUserUpdateSuccess();
            } else {
                mListener.onUserUpdateFail(response.getStatus());
            }
        } else if (mListener != null) {
            mListener.onUserUpdateFail(APIUtils.NO_HTTP);
        }
    }

    public interface IUpdateUser {
        void onUserUpdateSuccess();

        void onUserUpdateFail(int status);
    }
}
