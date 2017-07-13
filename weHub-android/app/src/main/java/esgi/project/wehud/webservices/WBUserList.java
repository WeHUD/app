package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.List;

import esgi.project.wehud.model.User;
import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.GSONUtils;

/**
 * This {@link AsyncTask} class is used to retrieve users.
 *
 * @author Olivier Gonçalves
 */
public final class WBUserList extends AsyncTask<String, Void, ServerResponse> {

    private IGetUserList mListener;

    public void setIGetUserList(IGetUserList listener) {
        mListener = listener;
    }

    @Override
    protected ServerResponse doInBackground(String... params) {
        String token = params[0];

        ServerRequest request = new ServerRequest(ServerRequest.GET, APIUtils.USERS);
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
                Type userListType = new TypeToken<List<User>>(){}.getType();
                List<User> userList = GSONUtils.getInstance().fromJson(response.getContent(), userListType);
                mListener.onUserListReceived(userList);
            } else {
                mListener.onUserListFail(response.getStatus());
            }
        } else if (mListener != null) {
            mListener.onUserListFail(APIUtils.NO_HTTP);
        }
    }

    public interface IGetUserList {
        void onUserListReceived(List<User> userList);

        void onUserListFail(int status);
    }

}
