package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import esgi.project.wehud.model.Game;
import esgi.project.wehud.model.User;
import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.GSONUtils;

/**
 * This {@link AsyncTask} class is used to retrieve users and games.
 *
 * @author Olivier Gonçalves
 */
public final class WBUserGameList extends AsyncTask<String, Void, List<ServerResponse>> {

    private IUserGameList mListener;

    public void setIUserGameList(IUserGameList listener) {
        mListener = listener;
    }

    @Override
    protected List<ServerResponse> doInBackground(String... params) {
        String token = params[0];

        List<ServerResponse> responses = new ArrayList<>();

        ServerRequest userRequest = new ServerRequest(ServerRequest.GET, APIUtils.USERS);
        userRequest.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        userRequest.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);
        userRequest.addParameter(APIUtils.P_ACCESS_TOKEN, token);

        ServerRequest gameRequest = new ServerRequest(ServerRequest.GET, APIUtils.GAMES);
        gameRequest.addHeader(APIUtils.H_CONTENT_TYPE, APIUtils.CONTENT_TYPE_JSON);
        gameRequest.addHeader(APIUtils.H_ACCEPT, APIUtils.ACCEPT);
        gameRequest.addParameter(APIUtils.P_ACCESS_TOKEN, token);

        responses.add(userRequest.send());
        responses.add(gameRequest.send());

        return responses;
    }

    @Override
    protected void onPostExecute(List<ServerResponse> responses) {
        if (responses != null && mListener != null) {
            for (ServerResponse response : responses) {
                if (response != null) {
                    int statusCode = response.getStatus();
                    if (statusCode != APIUtils.HTTP_OK) {
                        mListener.onUserGameListError(response.getStatus());
                        return;
                    }
                }
            }

            Type userListType = new TypeToken<List<User>>(){}.getType();
            Type gameListType = new TypeToken<List<Game>>(){}.getType();

            List<User> userList = GSONUtils.getInstance().fromJson(responses.get(0).getContent(), userListType);
            List<Game> gameList = GSONUtils.getInstance().fromJson(responses.get(1).getContent(), gameListType);

            mListener.onUserGameListReceived(userList, gameList);
        } else if (mListener != null) {
            mListener.onUserGameListError(APIUtils.NO_HTTP);
        }
    }

    public interface IUserGameList {
        void onUserGameListReceived(List<User> userList, List<Game> gameList);

        void onUserGameListError(int status);
    }

}
