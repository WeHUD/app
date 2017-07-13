package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;

/**
 * This {@link AsyncTask} class is used to update a user in the application.
 *
 * @author Olivier Gonçalves
 */
public final class WBUpdateUser extends AsyncTask<String, Void, ServerResponse> {

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
            int statusCode = response.getStatus();
            if (statusCode == APIUtils.HTTP_OK) {
                mListener.onUpdateUserSuccess();
            } else {
                mListener.onUpdateUserFail(response.getStatus());
            }
        } else if (mListener != null) {
            mListener.onUpdateUserFail(APIUtils.NO_HTTP);
        }
    }

    public interface IUpdateUser {
        void onUpdateUserSuccess();

        void onUpdateUserFail(int status);
    }
}
