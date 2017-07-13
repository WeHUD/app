package esgi.project.wehud.fragment;


import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.adapter.GameListAdapter;
import esgi.project.wehud.model.Game;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBGameList;

/**
 * This fragment represents a list of games
 * displayed in a grid.
 *
 * @author Olivier Gonçalves
 */
public class GameListFragment extends Fragment
        implements SwipeRefreshLayout.OnRefreshListener, WBGameList.IGameList {

    private static final String KEY_GAMES = "games";

    private Context mContext;
    private View mEmptyLayout;
    private SwipeRefreshLayout mSwipeLayout;
    private RecyclerView mGameListView;
    private ArrayList<Game> mGameList;

    public static GameListFragment newInstance() {
        return new GameListFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_game_list, container, false);
        mContext = view.getContext();

        mEmptyLayout = view.findViewById(R.id.empty_list);
        mSwipeLayout = (SwipeRefreshLayout) view.findViewById(R.id.swipe_layout);

        mGameListView = (RecyclerView) view.findViewById(android.R.id.list);
        mGameListView.setLayoutManager(new GridLayoutManager(mContext, 2));
        mGameListView.addItemDecoration(new DividerItemDecoration(mContext, DividerItemDecoration.HORIZONTAL));

        mEmptyLayout.setVisibility(View.VISIBLE);
        mSwipeLayout.setVisibility(View.GONE);

        mSwipeLayout.setOnRefreshListener(this);

        if (savedInstanceState != null) {
            mGameList = savedInstanceState.getParcelableArrayList(KEY_GAMES);
            if (mGameList != null) {
                mGameListView.setAdapter(new GameListAdapter(mGameList));
            }
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mGameList == null) {
            mSwipeLayout.setRefreshing(true);
            this.fetchData();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        mGameList = null;
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putParcelableArrayList(KEY_GAMES, mGameList);
    }

    @Override
    public void onRefresh() {
        this.fetchData();
    }

    @Override
    public void onGameListReceived(List<Game> gameList) {
        if (!gameList.isEmpty()) {
            final DateFormat formatter = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT);
            for (Game game : gameList) {
                final String formattedDate = formatter.format(game.getDatetimeCreated());
                game.setReleasedAt(formattedDate);
            }

            mGameList = (ArrayList<Game>) gameList;
            mGameListView.setAdapter(new GameListAdapter(gameList));
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }

        mSwipeLayout.setRefreshing(false);
    }

    @Override
    public void onGameListError(int status) {
        mSwipeLayout.setRefreshing(false);
        switch (status) {
            case APIUtils.NO_HTTP:
                AppUtils.toast(mContext, getString(R.string.error_noResponse));
                break;
            case APIUtils.HTTP_NOT_FOUND:
                AppUtils.toast(mContext, getString(R.string.error_notFound));
                break;
            case APIUtils.HTTP_SERVER_ERROR:
                AppUtils.toast(mContext, getString(R.string.error_server));
                break;
            default:
                break;
        }
    }

    private void fetchData() {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(mContext, APIUtils.SP_KEY_TOKEN);

        WBGameList task = new WBGameList();
        task.setIGameList(this);
        task.execute(token);
    }

}
