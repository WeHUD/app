package esgi.project.wehud.fragment;


import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import esgi.project.wehud.R;
import esgi.project.wehud.adapter.PostListAdapter;
import esgi.project.wehud.model.Game;
import esgi.project.wehud.model.Post;
import esgi.project.wehud.model.User;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.GSONUtils;
import esgi.project.wehud.utils.JSONUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBPostList;
import esgi.project.wehud.webservices.WBUpdatePost;
import esgi.project.wehud.webservices.WBUpdateUser;

public class PostListFragment extends Fragment
        implements SwipeRefreshLayout.OnRefreshListener, WBPostList.IPostList,
        WBUpdateUser.IUpdateUser, WBUpdatePost.IUpdatePost, PostListAdapter.OnAdapterItemClickListener {

    private static final String KEY_POSTS = "posts";
    private static final String KEY_CONNECTED = "connected";
    private static final String KEY_LIKES = "likes";

    private Context mContext;
    private View mEmptyLayout;
    private SwipeRefreshLayout mSwipeLayout;
    private RecyclerView mPostListView;
    private ArrayList<Post> mPostList;
    private User mCurrentUser;

    public static PostListFragment newInstance() {
        return new PostListFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_post_list, container, false);
        mContext = view.getContext();

        mEmptyLayout = view.findViewById(R.id.empty_list);
        mSwipeLayout = (SwipeRefreshLayout) view.findViewById(R.id.swipe_layout);

        mPostListView = (RecyclerView) view.findViewById(android.R.id.list);
        mPostListView.setLayoutManager(new LinearLayoutManager(mContext));
        mPostListView.addItemDecoration(new DividerItemDecoration(mContext, DividerItemDecoration.HORIZONTAL));

        mEmptyLayout.setVisibility(View.VISIBLE);
        mSwipeLayout.setVisibility(View.GONE);

        mSwipeLayout.setOnRefreshListener(this);

        if (savedInstanceState != null) {
            mPostList = savedInstanceState.getParcelableArrayList(KEY_POSTS);
            PostListAdapter adapter = new PostListAdapter(mPostList);
            adapter.setOnAdapterItemClickListener(this);
            mPostListView.setAdapter(adapter);
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mPostList == null) {
            mSwipeLayout.setRefreshing(true);
            this.fetchData();
        }
    }

    // Implementing this to save items on orientation change.
    // Bundle needs Parcelable model object.
    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putParcelableArrayList(KEY_POSTS, mPostList);
    }

    @Override
    public void onRefresh() {
        this.fetchData();
    }

    @Override
    public void onPostListReceived(List<Post> postList, List<User> userList, List<Game> gameList, User currentUser) {
        if (!postList.isEmpty()) {
            ArrayList<Post> posts = new ArrayList<>();
            final DateFormat formatter = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT);
            for (Post post : postList) {
                // Taking out all posts destined to the connected user,
                // those are messages
                String receiverId = post.getReceiverId();
                if (!TextUtils.isEmpty(receiverId) && receiverId.equals(currentUser.getId())) {
                    continue;
                }

                String formattedDate = formatter.format(post.getDatetimeCreated());
                post.setCreatedAt(formattedDate);

                boolean moreUsersThanGames = userList.size() > gameList.size();

                if (moreUsersThanGames) {
                    for (int i = 0; i < userList.size(); ++i) {
                        if (i < gameList.size()) {
                            Game game = gameList.get(i);
                            String postGameId = post.getGameId();
                            if (!TextUtils.isEmpty(postGameId) && postGameId.equals(game.getId())) {
                                post.setGame(game);
                            }
                        }
                        User user = userList.get(i);
                        if (post.getUserId().equals(user.getId())) {
                            post.setUser(user);
                        }
                    }
                } else {
                    for (int i = 0; i < gameList.size(); ++i) {
                        if (i < userList.size()) {
                            User user = userList.get(i);
                            if (post.getUserId().equals(user.getId())) {
                                post.setUser(user);
                            }
                        }
                        Game game = gameList.get(i);
                        String postGameId = post.getGameId();
                        if (!TextUtils.isEmpty(postGameId) && postGameId.equals(game.getId())) {
                            post.setGame(game);
                        }
                    }
                }

                String video = post.getVideo();
                if (!TextUtils.isEmpty(video)) {
                    String videoId = AppUtils.extractYouTubeVideoId(video);
                    post.setVideo(videoId);
                }

                posts.add(post);
            }

            SharedPreferencesUtils.putSharedPreference(mContext, APIUtils.SP_KEY_ID, currentUser.getId());
            SharedPreferencesUtils.putSharedPreference(mContext, APIUtils.SP_KEY_USERNAME, currentUser.getUsername());

            mCurrentUser = currentUser;
            mPostList = posts;
            PostListAdapter adapter = new PostListAdapter(mPostList);
            adapter.setOnAdapterItemClickListener(this);
            mPostListView.setAdapter(adapter);
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);

            String token = SharedPreferencesUtils.getSharedPreferenceByKey(mContext, APIUtils.SP_KEY_TOKEN);
            Map<String, Object> map = new HashMap<>();
            map.put(KEY_CONNECTED, true);
            String body = JSONUtils.getJSONFromMap(map);

            // Set "isConnected" flag to true
            WBUpdateUser task = new WBUpdateUser();
            task.setIUpdateUser(this);
            task.execute(token, currentUser.getId(), body);
        }

        mSwipeLayout.setRefreshing(false);
    }

    @Override
    public void onPostListError(int status) {
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

    @Override
    public void onUpdateUserSuccess() {

    }

    @Override
    public void onUpdateUserFail(int status) {
        switch (status) {
            case APIUtils.NO_HTTP:
                AppUtils.toast(mContext, getString(R.string.error_noResponse));
                break;
            case APIUtils.HTTP_SERVER_ERROR:
                AppUtils.toast(mContext, getString(R.string.error_server));
                break;
            default:
                break;
        }
    }

    @Override
    public void onAdapterItemClick(View view, Post post) {
        List<String> likes = new ArrayList<>();
        if (post.getLikes() != null && !post.getLikes().isEmpty()) {
            likes.addAll(post.getLikes());
        }
        if (likes.contains(mCurrentUser.getId())) {
            likes.remove(mCurrentUser.getId());
        } else {
            likes.add(mCurrentUser.getId());
        }
        post.setLikes(likes);

        Map<String, List<String>> map = new HashMap<>();
        map.put(KEY_LIKES, likes);

        String token = SharedPreferencesUtils.getSharedPreferenceByKey(mContext, APIUtils.SP_KEY_TOKEN);
        String postId = post.getId();
        String body = GSONUtils.getInstance().toJson(map);

        WBUpdatePost task = new WBUpdatePost();
        task.setIUpdatePost(this);
        task.execute(token, postId, body);
    }

    @Override
    public void onUpdatePostSuccess() {
        AppUtils.toast(mContext, getString(R.string.message_updateSuccess));
    }

    @Override
    public void onUpdatePostFail(int status) {
        switch (status) {
            case APIUtils.NO_HTTP:
                AppUtils.toast(mContext, getString(R.string.error_noResponse));
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

        WBPostList task = new WBPostList();
        task.setIPostList(this);
        task.execute(token);
    }
}
