package esgi.project.wehud.activity;

import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import esgi.project.wehud.R;
import esgi.project.wehud.adapter.CommentListAdapter;
import esgi.project.wehud.dialog.EditDialogFragment;
import esgi.project.wehud.model.Comment;
import esgi.project.wehud.model.Post;
import esgi.project.wehud.model.User;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.JSONUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBCommentList;
import esgi.project.wehud.webservices.WBPublishComment;

/**
 * This Activity subclass is used to present the user with a list of comments.
 *
 * @author Olivier Gonçalves
 */
public class CommentActivity extends AppCompatActivity
        implements SwipeRefreshLayout.OnRefreshListener,
        WBCommentList.ICommentList, EditDialogFragment.OnEditListener, WBPublishComment.IPublishComment {

    private static final String KEY_USER_ID = "userId";
    private static final String KEY_POST_ID = "postId";
    private static final String KEY_TEXT = "text";
    private static final String KEY_TITLE = "title";
    private static final String KEY_HINT = "hint";
    private static final String KEY_COMMENTS = "comments";
    private static final String KEY_POST = "post";
    private static final String KEY_USER = "user";

    private View mEmptyLayout;
    private SwipeRefreshLayout mSwipeLayout;
    private RecyclerView mCommentListView;
    private ArrayList<Comment> mCommentList;

    private Post mPost;
    private User mPostUser;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_comment);

        // Set up the Toolbar.
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        setTitle(getString(R.string.title_comments));

        mEmptyLayout = findViewById(R.id.empty_list);
        mSwipeLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_layout);

        mCommentListView = (RecyclerView) findViewById(android.R.id.list);
        mCommentListView.setLayoutManager(new LinearLayoutManager(this));
        mCommentListView.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));

        // At first,
        mEmptyLayout.setVisibility(View.VISIBLE);
        mSwipeLayout.setVisibility(View.GONE);

        mSwipeLayout.setOnRefreshListener(this);

        // If we saved instance objects in a Bundle,
        // we take them back here.
        if (savedInstanceState != null) {
            mPost = savedInstanceState.getParcelable(KEY_POST);
            mPostUser = savedInstanceState.getParcelable(KEY_USER);
            this.populatePost();
            mCommentList = savedInstanceState.getParcelableArrayList(KEY_COMMENTS);
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        // Checking if mPost and mCommentList are null
        // (e.g. in case a configuration change happens)
        if (mPost == null) {
            Bundle extras = getIntent().getExtras();
            mPost = extras.getParcelable(KEY_POST);
            mPostUser = extras.getParcelable(KEY_USER);
            this.populatePost();
        }
        if (mCommentList == null) {
            mSwipeLayout.setRefreshing(true);
            this.fetchData();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_publish, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.item_publish:
                this.showNewCommentDialog();
                break;
            default:
                return false;
        }

        return true;
    }

    /**
     * This method is called before {@link CommentActivity} is destroyed.
     *
     * @param outState a {@link Bundle} object containing variables to save
     */
    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putParcelable(KEY_POST, mPost);
        outState.putParcelable(KEY_USER, mPostUser);
        outState.putParcelableArrayList(KEY_COMMENTS, mCommentList);
    }

    /**
     * This method is called when we are refreshing the comment list.
     */
    @Override
    public void onRefresh() {
        this.fetchData();
    }

    /**
     * This method is called when a {@link WBCommentList} object has
     * successfully terminated.
     *
     * @param commentList the list of {@link Comment} objects
     * @param userList the list of {@link User} objects
     */
    @Override
    public void onCommentListReceived(List<Comment> commentList, List<User> userList) {
        if (!commentList.isEmpty()) {

            // Finding Users that published each Comment.
            for (Comment comment : commentList) {
                comment.setPost(mPost);
                for (User user : userList) {
                    if (user.getId().equals(comment.getUserId())) {
                        comment.setUser(user);
                        break;
                    }
                }
            }

            mCommentList = (ArrayList<Comment>) commentList;
            mCommentListView.setAdapter(new CommentListAdapter(commentList));
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }

        mSwipeLayout.setRefreshing(false);
    }

    /**
     * This method is called when {@link WBCommentList} fails and
     * no comment can be retrieved.
     * @param status the HTTP status code of the error
     */
    @Override
    public void onCommentListError(int status) {
        switch (status) {
            case APIUtils.NO_HTTP:
                AppUtils.toast(this, getString(R.string.error_noResponse));
                break;
            case APIUtils.HTTP_NOT_FOUND:
                AppUtils.toast(this, getString(R.string.error_notFound));
                break;
            default:
                break;
        }
        mSwipeLayout.setRefreshing(false);
    }

    /**
     * This method is called when the dialog for writing a new comment is dismissed.
     * In this case, it is used to upload a {@link Comment} using a
     * {@link WBPublishComment} webservice.
     *
     * @param textId the unique identifier of the dialog's EditText
     * @param text the text entered in the dialog's EditText
     */
    @Override
    public void onEdit(int textId, String text) {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);
        String userId = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_ID);

        Map<String, String> map = new HashMap<>();
        map.put(KEY_POST_ID, mPost.getId());
        map.put(KEY_USER_ID, userId);
        map.put(KEY_TEXT, text);

        String body = JSONUtils.getJSONFromMap(map);

        WBPublishComment task = new WBPublishComment();
        task.setIPublishComment(this);
        task.execute(token, body);
    }

    /**
     * This method is called when the {@link WBPublishComment} webservice
     * terminates with success.
     *
     * @param id the unique identifier of the connected user
     */
    @Override
    public void onPublishCommentSuccess(String id) {
        mPost.addComment(id);
        AppUtils.toast(this, getString(R.string.message_commentSuccess));
        finish();
    }

    /**
     * This method is called when the {@link WBPublishComment} webservice fails.
     *
     * @param status the HTTP status code of the error
     */
    @Override
    public void onPublishCommentFail(int status) {
        AppUtils.toast(this, getString(R.string.error_noResponse));
    }

    /**
     * Shows a dialog where the user can enter a comment.
     */
    private void showNewCommentDialog() {
        Bundle bundle = new Bundle();
        bundle.putString(KEY_TITLE, getString(R.string.dialog_newCommentTitle));
        bundle.putString(KEY_HINT, getString(R.string.hint_text));

        EditDialogFragment dialog = EditDialogFragment.newInstance();
        dialog.setArguments(bundle);
        dialog.setOnEditListener(this);
        dialog.show(getSupportFragmentManager(), getClass().getName());
    }

    /**
     * Fills all fields related to the post we want to comment.
     */
    private void populatePost() {
        ImageView postAvatar = (ImageView) findViewById(R.id.post_avatar);
        TextView postUsername = (TextView) findViewById(R.id.post_username);
        TextView postReply = (TextView) findViewById(R.id.post_screenName);
        TextView postCreatedAt = (TextView) findViewById(R.id.post_createdAt);
        TextView postText = (TextView) findViewById(R.id.post_text);
        RatingBar postMark = (RatingBar) findViewById(R.id.post_mark);
        ImageView postVideo = (ImageView) findViewById(R.id.post_video);
        TextView postLikes = (TextView) findViewById(R.id.post_likes);
        TextView postComments = (TextView) findViewById(R.id.post_comments);

        if (mPostUser != null) {
            AppUtils.loadImage(this, mPostUser.getAvatar(), postAvatar, APIUtils.SIZE);
            postUsername.setText(mPostUser.getUsername());
            postReply.setText(mPostUser.getReply());
        }

        postCreatedAt.setText(mPost.getCreatedAt());
        postText.setText(mPost.getText());

        // Mark is 0 by default, in that case
        // we do not show it.
        if (mPost.getMark() > 0) {
            postMark.setRating(mPost.getMark());
        } else {
            postMark.setVisibility(View.GONE);
        }

        // We store YouTube videos using their IDs.
        // To be able to play them, we must
        // have the full URL of the video, this
        // can be easily obtained as the pattern is
        // always the same (https://youtube.com/watch?v=<videoID>)
        String youTubeID = mPost.getVideo();
        if (!TextUtils.isEmpty(youTubeID)) {
            AppUtils.setupYouTubeVideo(this, youTubeID, postVideo);
        } else {
            postVideo.setVisibility(View.GONE);
        }

        if (this.hasCurrentUserLiked()) {
            postLikes.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_like, 0, 0, 0);
        } else {
            postLikes.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_nolike, 0, 0, 0);
        }
        postLikes.setText(String.valueOf(mPost.getLikes().size()));

        // Since we already are seeing the comments for that post here,
        // this view is completely unused.
        postComments.setVisibility(View.GONE);
    }

    /**
     * Checks to see whether or not the connected {@link User}
     * already has liked the content of not.
     *
     * @return a flag indicating if the {@link User} liked the comment.
     */
    private boolean hasCurrentUserLiked() {
        String currentUserId = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_ID);
        for (String userId : mPost.getLikes()) {
            if (userId.equals(currentUserId)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Calls the {@link WBCommentList} webservice to retrieve the list of {@link Comment} objects.
     */
    private void fetchData() {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);
        String id = mPost.getId();

        WBCommentList task = new WBCommentList();
        task.setICommentList(this);
        task.execute(token, id);
    }
}
