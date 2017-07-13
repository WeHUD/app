package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import org.json.JSONException;
import org.json.JSONObject;

import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;

/**
 * This {@link AsyncTask} class is used to publish a comment.
 *
 * @author Olivier Gonçalves
 */
public final class WBPublishComment extends AsyncTask<String, Void, ServerResponse> {

    private IPublishComment mListener;

    public void setIPublishComment(IPublishComment listener) {
        mListener = listener;
    }

    @Override
    protected ServerResponse doInBackground(String... params) {
        String token = params[0];
        String body = params[1];

        ServerRequest request = new ServerRequest(ServerRequest.POST, APIUtils.COMMENTS, body);
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
                String id = null;
                try {
                    JSONObject jsonResponse = new JSONObject(response.getContent());
                    id = jsonResponse.getString("_id");
                } catch (JSONException x) {
                    x.printStackTrace();
                }
                mListener.onPublishCommentSuccess(id);
            } else {
                mListener.onPublishCommentFail(response.getStatus());
            }
        } else if (mListener != null) {
            mListener.onPublishCommentFail(APIUtils.NO_HTTP);
        }
    }

    public interface IPublishComment {
        void onPublishCommentSuccess(String id);

        void onPublishCommentFail(int status);
    }
}
