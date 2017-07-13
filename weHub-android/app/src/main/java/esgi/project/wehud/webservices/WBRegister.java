package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;

/**
 * This {@link AsyncTask} class is used to create a new user account.
 *
 * @author Olivier Gonçalves
 */
public final class WBRegister extends AsyncTask<String, Void, ServerResponse> {

    private IRegister mListener;

    public void setIRegister(IRegister listener) {
        mListener = listener;
    }

    @Override
    protected ServerResponse doInBackground(String... params) {
        String body = params[0];

        ServerRequest request = new ServerRequest(ServerRequest.POST, APIUtils.USERS, body);
        request.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        request.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);

        return request.send();
    }

    @Override
    protected void onPostExecute(ServerResponse response) {
        if (response != null && mListener != null) {
            int statusCode = response.getStatus();
            if (statusCode == APIUtils.HTTP_CREATED) {
                // Register was a success
                mListener.onRegisterSuccess();
            } else {
                // Register failed
                mListener.onRegisterFail(response.getStatus());
            }
        } else if (mListener != null) {
            mListener.onRegisterFail(APIUtils.NO_HTTP);
        }
    }

    public interface IRegister {
        void onRegisterSuccess();

        void onRegisterFail(int status);
    }
}
