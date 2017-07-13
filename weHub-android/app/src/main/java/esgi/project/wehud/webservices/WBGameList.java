package esgi.project.wehud.webservices;

import android.os.AsyncTask;

import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.List;

import esgi.project.wehud.model.Game;
import esgi.project.wehud.network.ServerRequest;
import esgi.project.wehud.network.ServerResponse;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.GSONUtils;

/**
 * This {@link AsyncTask} class is used to retrieve games.
 *
 * @author Olivier Gonçalves
 */
public final class WBGameList extends AsyncTask<String, Void, ServerResponse> {

    private IGameList mListener;

    public void setIGameList(IGameList listener) {
        mListener = listener;
    }

    @Override
    protected ServerResponse doInBackground(String... params) {
        String token = params[0];

        ServerRequest request = new ServerRequest(ServerRequest.GET, APIUtils.GAMES);
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
                Type gameListType = new TypeToken<List<Game>>(){}.getType();
                List<Game> gameList = GSONUtils.getInstance().fromJson(response.getContent(), gameListType);
                mListener.onGameListReceived(gameList);
            } else {
                mListener.onGameListError(response.getStatus());
            }
        } else if (mListener != null) {
            mListener.onGameListError(APIUtils.NO_HTTP);
        }
    }

    public interface IGameList {
        void onGameListReceived(List<Game> gameList);

        void onGameListError(int status);
    }

}
