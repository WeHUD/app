package esgi.project.wehud.activity;

import android.app.ProgressDialog;
import android.support.design.widget.AppBarLayout;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.Menu;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

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
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBPostListByUser;
import esgi.project.wehud.webservices.WBFollowUnfollowUser;

/**
 * This class represents a user profile.
 *
 * @author Olivier Gonçalves
 */
public class UserActivity extends AppCompatActivity
        implements View.OnClickListener, AppBarLayout.OnOffsetChangedListener,
        SwipeRefreshLayout.OnRefreshListener, WBPostListByUser.IPostListByUser,
        WBFollowUnfollowUser.IUpdateUser {

    private static final String KEY_POST_LIST = "posts";
    private static final String KEY_USER = "user";
    private static final String KEY_FOLLOWERS = "followedUsers";

    private ImageView mUserInfoAvatar;
    private TextView mUserInfoUsername;
    private TextView mUserInfoReply;
    private TextView mUserFollowers;
    private TextView mUserFollowerCount;

    private ProgressDialog mProgress;
    private AppBarLayout mAppBarLayout;
    private Toolbar mToolbar;
    private View mEmptyLayout;
    private SwipeRefreshLayout mSwipeLayout;
    private RecyclerView mPostListView;
    private ArrayList<Post> mPostList;

    private User mUser;
    private Button mUserInfoFollowUnfollowButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user);

        // Set UI components
        mAppBarLayout = (AppBarLayout) findViewById(R.id.appBar);
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mUserInfoAvatar = (ImageView) findViewById(R.id.userInfo_avatar);
        mUserInfoUsername = (TextView) findViewById(R.id.userInfo_username);
        mUserInfoReply = (TextView) findViewById(R.id.userInfo_reply);
        mUserFollowers = (TextView) findViewById(R.id.userInfo_followers);
        mUserFollowerCount = (TextView) findViewById(R.id.userInfo_followerCount);
        mEmptyLayout = findViewById(R.id.empty_list);
        mSwipeLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_layout);
        mPostListView = (RecyclerView) findViewById(android.R.id.list);
        mPostListView.setLayoutManager(new LinearLayoutManager(this));
        mPostListView.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));
        mUserInfoFollowUnfollowButton = (Button) findViewById(R.id.userInfo_followUnfollowButton);

        mEmptyLayout.setVisibility(View.VISIBLE);
        mSwipeLayout.setVisibility(View.GONE);

        mAppBarLayout.addOnOffsetChangedListener(this);
        mSwipeLayout.setOnRefreshListener(this);
        mUserInfoFollowUnfollowButton.setOnClickListener(this);

        // In case of configuration changes, savedInstanceState
        // contains information about the user and the list of posts.
        if (savedInstanceState != null) {
            mUser = savedInstanceState.getParcelable(KEY_USER);
            this.populateUser();

            mPostList = savedInstanceState.getParcelableArrayList(KEY_POST_LIST);
            mPostListView.setAdapter(new PostListAdapter(mPostList));
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        // We can get passed a Bundle object from:
        //      {@link GeolocationFragment}
        //      {@link ProfileFragment}
        if (mUser == null) {
            Bundle bundle = getIntent().getExtras();
            mUser = bundle.getParcelable(KEY_USER);
            this.populateUser();
        }

        if (mPostList == null) {
            mSwipeLayout.setRefreshing(true);
            this.fetchData();
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putParcelable(KEY_USER, mUser);
        outState.putParcelableArrayList(KEY_POST_LIST, mPostList);
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.userInfo_followUnfollowButton) {
            this.followUnfollowUser(mUserInfoFollowUnfollowButton.getTag().toString());
        }
    }

    @Override
    public void onOffsetChanged(AppBarLayout appBarLayout, int verticalOffset) {
        String username = mUserInfoUsername.getText().toString();
        Menu menu = mToolbar.getMenu();
        boolean collapsed = Math.abs(verticalOffset) == mAppBarLayout.getTotalScrollRange();
        mToolbar.setTitle(collapsed ? username : getString(R.string.user_profile));
        for (int i = 0; i < menu.size(); ++i) {
            menu.getItem(i).setVisible(collapsed);
        }
    }

    @Override
    public void onRefresh() {
        this.fetchData();
    }

    @Override
    public void onPostListReceived(List<Post> postList, List<User> userList, List<Game> gameList) {
        if (!postList.isEmpty()) {
            final DateFormat formatter = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT);
            for (Post post : postList) {
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
            }

            mPostList = (ArrayList<Post>) postList;
            mPostListView.setAdapter(new PostListAdapter(postList));
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }

        mSwipeLayout.setRefreshing(false);
    }

    @Override
    public void onPostListError(int status) {
        mSwipeLayout.setRefreshing(false);
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

    @Override
    public void onUserUpdateSuccess() {
        mProgress.dismiss();
        AppUtils.toast(this, getString(R.string.message_updateSuccess));

        this.updateButtonText();
    }

    @Override
    public void onUserUpdateFail(int status) {
        mProgress.dismiss();
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

    private void followUnfollowUser(String tag) {
        String currentUserId = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_ID);
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);
        List<String> currentFollowers = mUser.getFollowedUsers();

        String followUnfollow = getString(R.string.follow);
        if (mUserInfoFollowUnfollowButton.getText().toString().equals(getString(R.string.unfollow))) {
            followUnfollow = getString(R.string.unfollow);
        }

        List<String> followersId = new ArrayList<>();
        if (currentFollowers != null) {
            followersId.addAll(currentFollowers);
        }
        if (tag.equals(getString(R.string.follow))) {
            followersId.add(currentUserId);
        } else {
            followersId.remove(currentUserId);
        }

        Map<String, List<String>> map = new HashMap<>();
        map.put(KEY_FOLLOWERS, followersId);

        String body = GSONUtils.getInstance().toJson(map);
        mUser.setFollowedUsers(followersId);

        mProgress = new ProgressDialog(this);
        mProgress.setTitle(getString(R.string.title_connection));
        mProgress.setMessage(getString(R.string.message_update));
        mProgress.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        mProgress.setCancelable(false);
        mProgress.show();

        WBFollowUnfollowUser task = new WBFollowUnfollowUser();
        task.setIUpdateUser(this);
        task.execute(token, mUser.getId(), body);

        mUserInfoFollowUnfollowButton.setText(followUnfollow);
    }

    private void populateUser() {
        String avatar = mUser.getAvatar();
        String username = mUser.getUsername();
        String reply = mUser.getReply();

        if (!TextUtils.isEmpty(avatar)) {
            Picasso.with(this).load(avatar).resize(256, 256).into(mUserInfoAvatar);
        } else {
            mUserInfoAvatar.setImageResource(R.mipmap.ic_launcher);
        }

        mUserInfoUsername.setText(username);
        mUserInfoReply.setText(reply);

        this.updateButtonText();
    }

    private void updateButtonText() {
        String currentUserId = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_ID);
        List<String> followers = mUser.getFollowedUsers();

        if (followers != null && followers.contains(currentUserId)) {
            mUserInfoFollowUnfollowButton.setText(getString(R.string.unfollow));
            mUserInfoFollowUnfollowButton.setTag(getString(R.string.unfollow));
        } else {
            mUserInfoFollowUnfollowButton.setText(getString(R.string.follow));
            mUserInfoFollowUnfollowButton.setTag(getString(R.string.follow));
        }

        int count = mUser.getFollowedUsers().size();
        if (count == 1) {
            mUserFollowers.setText(R.string.gameInfo_follower);
        } else {
            mUserFollowers.setText(R.string.gameInfo_followers);
        }

        mUserFollowerCount.setText(String.valueOf(followers.size()));

        if (mUser.getId().equals(currentUserId)) {
            mUserInfoFollowUnfollowButton.setVisibility(View.GONE);
        }
    }

    private void fetchData() {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);
        String userId = mUser.getId();

        WBPostListByUser task = new WBPostListByUser();
        task.setIPostList(this);
        task.execute(token, userId);
    }
}
