package esgi.project.wehud.activity;

import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.View;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.adapter.PostListAdapter;
import esgi.project.wehud.model.Game;
import esgi.project.wehud.model.Post;
import esgi.project.wehud.model.User;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBPostList;

/**
 * This class displays a list of posts destined to the connected user
 * in the application.
 *
 * @author Olivier Gonçalves
 */
public class MessageListActivity extends AppCompatActivity
        implements SwipeRefreshLayout.OnRefreshListener, WBPostList.IPostList {

    private static final String KEY_MESSAGES = "messages";

    private View mEmptyLayout;
    private SwipeRefreshLayout mSwipeLayout;
    private RecyclerView mMessageListView;

    private ArrayList<Post> mPostList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_message_list);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        setTitle(getString(R.string.title_messages));

        mEmptyLayout = findViewById(R.id.empty_list);
        mSwipeLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_layout);

        mMessageListView = (RecyclerView) findViewById(android.R.id.list);
        mMessageListView.setLayoutManager(new LinearLayoutManager(this));
        mMessageListView.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));

        mEmptyLayout.setVisibility(View.VISIBLE);
        mSwipeLayout.setVisibility(View.GONE);

        mSwipeLayout.setOnRefreshListener(this);

        if (savedInstanceState != null) {
            mPostList = savedInstanceState.getParcelableArrayList(KEY_MESSAGES);
            PostListAdapter adapter = new PostListAdapter(mPostList);
            adapter.setMessage();

            mMessageListView.setAdapter(adapter);
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mPostList == null) {
            mSwipeLayout.setRefreshing(true);
            this.fetchData();
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putParcelableArrayList(KEY_MESSAGES, mPostList);
    }

    @Override
    public void onRefresh() {
        this.fetchData();
    }

    /**
     * A method called when the {@link WBPostList} webservice retuns successfully.
     *
     * @param postList the list of retrieved {@link Post} objects
     * @param userList a list of {@link User} objects to associate to the posts
     * @param gameList a list of {@link Game} objects to associate to the posts
     * @param currentUser the connected {@link User} in the application
     */
    @Override
    public void onPostListReceived(List<Post> postList, List<User> userList, List<Game> gameList,
                                   User currentUser) {
        if (!postList.isEmpty()) {

            // Dates are of format ISO8601
            // We want them in the 'dd/MM/yyyy HH:mm' format
            final DateFormat formatter = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT);
            ArrayList<Post> posts = new ArrayList<>();

            String currentUserId = currentUser.getId();
            for (Post post : postList) {
                String receiverId = post.getReceiverId();

                // Taking out all posts not addressed to the connected user
                if (TextUtils.isEmpty(receiverId) || !receiverId.equals(currentUserId)) {
                    continue;
                }

                String formattedDate = formatter.format(post.getDatetimeCreated());

                // Since the server only gives us IDs, we have to associate
                // those IDs with actual models in order to access their properties,
                // e.g. the username and reply in the post
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

                // If there is a video, it will be given as a YouTube URL,
                // so we extract the ID and set it to the post
                String video = post.getVideo();
                if (!TextUtils.isEmpty(video)) {
                    String videoId = AppUtils.extractYouTubeVideoId(video);
                    post.setVideo(videoId);
                }

                // Set the formatted date
                post.setCreatedAt(formattedDate);
                posts.add(post);
            }

            mPostList = posts;
            PostListAdapter adapter = new PostListAdapter(mPostList);
            adapter.setMessage();

            mMessageListView.setAdapter(adapter);
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }

        mSwipeLayout.setRefreshing(false);
    }

    /**
     * This method is called when the {@link WBPostList} webservice fails and returns an error.
     *
     * @param status the HTTP status code of the error
     */
    @Override
    public void onPostListError(int status) {
        switch (status) {
            case APIUtils.NO_HTTP:
                AppUtils.toast(this, getString(R.string.error_noResponse));
                break;
            case APIUtils.HTTP_NOT_FOUND:
                AppUtils.toast(this, getString(R.string.error_notFound));
                break;
            case APIUtils.HTTP_SERVER_ERROR:
                AppUtils.toast(this, getString(R.string.error_server));
                break;
            default:
                break;
        }
    }

    /**
     * This method calls the {@link WBPostList} webservice to retrieve the list of posts.
     */
    private void fetchData() {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);

        WBPostList task = new WBPostList();
        task.setIPostList(this);
        task.execute(token);
    }
}
