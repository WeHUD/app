package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.model.Comment;
import esgi.project.wehud.model.User;
import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.GSONUtils;

/**
 * This {@link AsyncTask} class is used to retrieve comments.
 *
 * @author Olivier Gonçalves
 */
public final class WBCommentList extends AsyncTask<String, Void, List<ServerResponse>> {

    private ICommentList mListener;

    public void setICommentList(ICommentList listener) {
        mListener = listener;
    }

    @Override
    protected List<ServerResponse> doInBackground(String... params) {
        String token = params[0];
        String id = params[1];

        List<ServerResponse> responses = new ArrayList<>();

        ServerRequest commentRequest = new ServerRequest(ServerRequest.GET,
                APIUtils.COMMENTS_BY_POST.replace(":postId", id));
        commentRequest.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        commentRequest.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);
        commentRequest.addParameter(APIUtils.P_ACCESS_TOKEN, token);

        ServerRequest userRequest = new ServerRequest(ServerRequest.GET, APIUtils.USERS);
        userRequest.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        userRequest.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);
        userRequest.addParameter(APIUtils.P_ACCESS_TOKEN, token);

        responses.add(commentRequest.send());
        responses.add(userRequest.send());

        return responses;
    }

    @Override
    protected void onPostExecute(List<ServerResponse> responses) {
        if (responses != null && mListener != null) {
            for (ServerResponse response : responses) {
                if (response != null) {
                    int status = response.getStatus();
                    if (status != APIUtils.HTTP_OK) {
                        mListener.onCommentListError(status);
                        return;
                    }
                } else if (mListener != null) {
                    mListener.onCommentListError(APIUtils.NO_HTTP);
                }
            }

            Type commentListType = new TypeToken<List<Comment>>(){}.getType();
            Type userListType = new TypeToken<List<User>>(){}.getType();

            List<Comment> commentList = GSONUtils.getInstance().fromJson(responses.get(0).getContent(), commentListType);
            List<User> userList = GSONUtils.getInstance().fromJson(responses.get(1).getContent(), userListType);

            mListener.onCommentListReceived(commentList, userList);
        }
    }

    public interface ICommentList {
        void onCommentListReceived(List<Comment> commentList, List<User> userList);

        void onCommentListError(int status);
    }

}
