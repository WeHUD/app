package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;

/**
 * This {@link AsyncTask} class is used to publish a post.
 *
 * @author Olivier Gonçalves
 */
public final class WBPublishPost extends AsyncTask<String, Void, ServerResponse> {

    private IPublishPost mListener;

    public void setIPublishPost(IPublishPost listener) {
        mListener = listener;
    }

    @Override
    protected ServerResponse doInBackground(String... params) {
        String token = params[0];
        String body = params[1];

        ServerRequest request = new ServerRequest(ServerRequest.POST, APIUtils.POSTS, body);
        request.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        request.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);
        request.addParameter(APIUtils.P_ACCESS_TOKEN, token);

        return request.send();
    }

    @Override
    protected void onPostExecute(ServerResponse response) {
        if (response != null && mListener != null) {
            int status = response.getStatus();
            if (status == APIUtils.HTTP_CREATED) {
                mListener.onPublishPostSuccess();
            } else {
                mListener.onPublishPostFail(response.getStatus());
            }
        } else if (mListener != null) {
            mListener.onPublishPostFail(APIUtils.NO_HTTP);
        }
    }

    public interface IPublishPost {
        void onPublishPostSuccess();
        void onPublishPostFail(int status);
    }
}
