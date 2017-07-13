package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;

/**
 * This {@link AsyncTask} class is used to update a post in the application.
 *
 * @author Olivier Gonçalves
 */
public final class WBUpdatePost extends AsyncTask<String, Void, ServerResponse> {

    private IUpdatePost mListener;

    public void setIUpdatePost(IUpdatePost listener) {
        mListener = listener;
    }

    @Override
    protected ServerResponse doInBackground(String... params) {
        String token = params[0];
        String postId = params[1];
        String body = params[2];

        ServerRequest request = new ServerRequest(ServerRequest.PUT, APIUtils.UPDATE_POST.replace(":postId", postId), body);
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
                mListener.onUpdatePostSuccess();
            } else {
                mListener.onUpdatePostFail(response.getStatus());
            }
        } else if (mListener != null) {
            mListener.onUpdatePostFail(APIUtils.NO_HTTP);
        }
    }

    public interface IUpdatePost {
        void onUpdatePostSuccess();

        void onUpdatePostFail(int status);
    }
}
