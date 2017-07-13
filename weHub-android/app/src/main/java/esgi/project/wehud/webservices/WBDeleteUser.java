package esgi.project.wehud.webservices;

import android.os.AsyncTask;
import android.util.Log;

import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;

/**
 * This {@link AsyncTask} class is used to delete a user.
 *
 * @author Olivier Gonçalves
 */
public final class WBDeleteUser extends AsyncTask<String, Void, ServerResponse> {

    private IDeleteUser mListener;

    public void setIDeleteUser(IDeleteUser listener) {
        mListener = listener;
    }

    @Override
    protected ServerResponse doInBackground(String... params) {
        String token = params[0];
        String userId = params[1];

        ServerRequest request = new ServerRequest(ServerRequest.DELETE, APIUtils.USERS.replace(":userId", userId));
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
                // Register was a success
                mListener.onDeleteSuccess();
            } else {
                // Register failed
                mListener.onDeleteFail(status);
            }
        } else if (mListener != null) {
            mListener.onDeleteFail(APIUtils.NO_HTTP);
        }
    }

    public interface IDeleteUser {
        void onDeleteSuccess();

        void onDeleteFail(int status);
    }
}
