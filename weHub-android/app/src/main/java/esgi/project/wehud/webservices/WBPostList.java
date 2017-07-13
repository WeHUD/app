package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import esgi.project.wehud.model.Game;
import esgi.project.wehud.model.Post;
import esgi.project.wehud.model.User;
import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.GSONUtils;

/**
 * This {@link AsyncTask} class is used to retrieve posts.
 *
 * @author Olivier Gonçalves
 */
public final class WBPostList extends AsyncTask<String, Void, List<ServerResponse>> {

    private IPostList mListener;

    public void setIPostList(IPostList listener) {
        mListener = listener;
    }

    @Override
    protected List<ServerResponse> doInBackground(String... params) {
        String token = params[0];

        List<ServerResponse> responses = new ArrayList<>();

        ServerRequest postRequest = new ServerRequest(ServerRequest.GET, APIUtils.POSTS);
        ServerRequest userRequest = new ServerRequest(ServerRequest.GET, APIUtils.USERS);
        ServerRequest gameRequest = new ServerRequest(ServerRequest.GET, APIUtils.GAMES);
        ServerRequest userByTokenRequest = new ServerRequest(ServerRequest.GET, APIUtils.TOKEN.replace(":token", token));

        postRequest.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        postRequest.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);
        postRequest.addParameter(APIUtils.P_ACCESS_TOKEN, token);

        userRequest.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        userRequest.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);
        userRequest.addParameter(APIUtils.P_ACCESS_TOKEN, token);

        gameRequest.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        gameRequest.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);
        gameRequest.addParameter(APIUtils.P_ACCESS_TOKEN, token);

        userByTokenRequest.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        userByTokenRequest.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);

        responses.add(postRequest.send());
        responses.add(userRequest.send());
        responses.add(gameRequest.send());
        responses.add(userByTokenRequest.send());

        return responses;
    }

    @Override
    protected void onPostExecute(List<ServerResponse> responses) {
        if (responses != null && mListener != null) {

            // Check any errors in requests
            for (ServerResponse response : responses) {
                if (response != null) {
                    int statusCode = response.getStatus();
                    if (statusCode != APIUtils.HTTP_OK) {
                        mListener.onPostListError(response.getStatus());
                        return;
                    }
                }
            }

            Type postListType = new TypeToken<List<Post>>(){}.getType();
            Type userListType = new TypeToken<List<User>>(){}.getType();
            Type gameListType = new TypeToken<List<Game>>(){}.getType();

            List<Post> postList = GSONUtils.getInstance().fromJson(responses.get(0).getContent(), postListType);
            List<User> userList = GSONUtils.getInstance().fromJson(responses.get(1).getContent(), userListType);
            List<Game> gameList = GSONUtils.getInstance().fromJson(responses.get(2).getContent(), gameListType);
            User currentUser = GSONUtils.getInstance().fromJson(responses.get(3).getContent(), User.class);

            Collections.reverse(postList);

            mListener.onPostListReceived(postList, userList, gameList, currentUser);

        } else if (mListener != null) {
            mListener.onPostListError(APIUtils.NO_HTTP);
        }
    }

    public interface IPostList {
        void onPostListReceived(List<Post> postList, List<User> userList, List<Game> gameList, User currentUser);
        void onPostListError(int status);
    }
}
