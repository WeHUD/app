package esgi.project.wehud.activity;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.MultiAutoCompleteTextView;
import android.widget.RatingBar;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import esgi.project.wehud.R;
import esgi.project.wehud.adapter.GameAdapter;
import esgi.project.wehud.adapter.UserAdapter;
import esgi.project.wehud.model.Game;
import esgi.project.wehud.model.User;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.JSONUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBPublishPost;
import esgi.project.wehud.webservices.WBUserGameList;

/**
 * This class represents the screen where the user publishes content.
 *
 * @author Olivier Gonçalves
 */
public class PublishActivity extends AppCompatActivity implements
        View.OnClickListener,
        CompoundButton.OnCheckedChangeListener,
        WBUserGameList.IUserGameList,
        WBPublishPost.IPublishPost {

    private static final String KEY_USER_ID = "userId";
    private static final String KEY_AUTHOR = "author";
    private static final String KEY_VIDEO = "video";
    private static final String KEY_GAME_ID = "gameId";
    private static final String KEY_RECEIVER_ID = "receiverId";
    private static final String KEY_OPINION = "flagOpinion";
    private static final String KEY_MARK = "mark";
    private static final String KEY_TEXT = "text";

    private static final int CHECK_OPINION = 10;

    private EditText mNewPostVideo;
    private MultiAutoCompleteTextView mNewPostText;
    private CheckBox mNewPostIsOpinion;
    private RatingBar mNewPostMark;
    private AutoCompleteTextView mNewPostGame;
    private AutoCompleteTextView mNewPostReceiver;

    private List<User> mUserList;
    private List<Game> mGameList;
    private UserAdapter mUserAdapter;
    private GameAdapter mGameAdapter;

    private ProgressDialog mProgress;

    private boolean mFirstTimeOpinion = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_publish);

        this.fetchData();

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        setTitle(getString(R.string.title_publish));

        mNewPostVideo = (EditText) findViewById(R.id.newPost_video);
        mNewPostText = (MultiAutoCompleteTextView) findViewById(R.id.newPost_text);
        mNewPostIsOpinion = (CheckBox) findViewById(R.id.newPost_isOpinion);
        mNewPostMark = (RatingBar) findViewById(R.id.newPost_mark);
        mNewPostGame = (AutoCompleteTextView) findViewById(R.id.newPost_game);
        mNewPostReceiver = (AutoCompleteTextView) findViewById(R.id.newPost_receiver);
        Button newPostPublishButton = (Button) findViewById(R.id.newPost_publishButton);

        mNewPostGame.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean focused) {
                if (focused) {
                    mNewPostGame.setAdapter(mGameAdapter);
                    ((ViewGroup) view.getParent()).setFocusableInTouchMode(true);
                    ((ViewGroup) view.getParent()).requestFocus();
                    mNewPostGame.showDropDown();
                }
            }
        });

        mNewPostReceiver.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean b) {
                mNewPostReceiver.setAdapter(mUserAdapter);
                ((ViewGroup) view.getParent()).setFocusableInTouchMode(true);
                ((ViewGroup) view.getParent()).requestFocus();
                mNewPostReceiver.showDropDown();
            }
        });

        mNewPostIsOpinion.setOnCheckedChangeListener(this);
        newPostPublishButton.setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.newPost_publishButton:
                this.attemptPublish();
                break;
            default:
                break;
        }
    }

    @Override
    public void onCheckedChanged(CompoundButton checkbox, boolean checked) {
        switch (checkbox.getId()) {
            case R.id.newPost_isOpinion:
                if (mFirstTimeOpinion) {
                    this.showOpinionDialog();
                    mFirstTimeOpinion = false;
                } else {
                    this.updateUI(CHECK_OPINION, checked);
                }
                break;
            default:
                break;
        }
    }

    @Override
    public void onUserGameListReceived(List<User> userList, List<Game> gameList) {
        if (!userList.isEmpty() && !gameList.isEmpty()) {
            this.setupGameAdapter(gameList);
            this.setupUserAdapter(userList);

            mUserList = userList;
            mGameList = gameList;
        }
    }

    @Override
    public void onUserGameListError(int status) {
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
    public void onPublishPostSuccess() {
        mProgress.dismiss();
        AppUtils.toast(this, getString(R.string.message_publishSuccess));
        finish();
    }

    @Override
    public void onPublishPostFail(int status) {
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

    private void showOpinionDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage(R.string.dialog_isOpinion);
        builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {
                updateUI(CHECK_OPINION, true);
                dialog.dismiss();
            }
        });
        builder.setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {
                mNewPostIsOpinion.setChecked(false);
                dialog.dismiss();
            }
        });
        builder.create().show();
    }

    private void setupGameAdapter(List<Game> gameList) {
        mGameAdapter = new GameAdapter(this);
        mGameAdapter.setGameList(gameList);
    }

    private void setupUserAdapter(List<User> userList) {
        mUserAdapter = new UserAdapter(this);
        mUserAdapter.setUserList(userList);
    }

    private void updateUI(int check, boolean checked) {
        switch (check) {
            case CHECK_OPINION:
                mNewPostMark.setVisibility(checked ? View.VISIBLE : View.GONE);
                mNewPostGame.setHint(checked ?
                        getString(R.string.newPost_gameRequired) :
                        getString(R.string.newPost_gameOptional));
                break;
            default:
                break;
        }
    }

    private void fetchData() {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);

        WBUserGameList task = new WBUserGameList();
        task.setIUserGameList(this);
        task.execute(token);
    }

    private void clearErrorsOnFields() {
        mNewPostText.setError(null);
        mNewPostGame.setError(null);
        mNewPostReceiver.setError(null);
    }

    private String prepareBody() {
        boolean isOpinion = mNewPostIsOpinion.isChecked();

        String userId = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_ID);
        String author = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_USERNAME);

        String videoId = mNewPostVideo.getText().toString();
        String text = mNewPostText.getText().toString();
        String game = mNewPostGame.getText().toString();
        String receiver = mNewPostReceiver.getText().toString();
        float mark = mNewPostMark.getRating();

        if (TextUtils.isEmpty(text)) {
            mNewPostText.setError(getString(R.string.error_field_required));
            return null;
        }
        if (isOpinion && (TextUtils.isEmpty(game) || mark == 0)) {
            mNewPostGame.setError(getString(R.string.error_field_required));
            return null;
        }

        Map<String, Object> map = new HashMap<>();
        map.put(KEY_USER_ID, userId);
        map.put(KEY_AUTHOR, author);
        if (!TextUtils.isEmpty(videoId)) {
            map.put(KEY_VIDEO, AppUtils.buildYouTubeVideoURL(videoId));
        }
        if (!TextUtils.isEmpty(game)) {
            String gameId = this.getGameId(game);
            map.put(KEY_GAME_ID, gameId);
        }
        if (!TextUtils.isEmpty(receiver)) {
            String receiverId = this.getReceiverId(receiver);
            map.put(KEY_RECEIVER_ID, receiverId);
        }
        if (isOpinion) {
            map.put(KEY_OPINION, true);
            map.put(KEY_MARK, mark);
        }
        map.put(KEY_TEXT, text);

        return JSONUtils.getJSONFromMap(map);
    }

    private String getReceiverId(String receiverName) {
        for (User user : mUserList) {
            if (user.toString().equals(receiverName)) {
                return user.getId();
            }
        }

        return null;
    }

    private String getGameId(String gameName) {
        for (Game game : mGameList) {
            if (game.getName().equals(gameName)) {
                return game.getId();
            }
        }

        return null;
    }

    private void attemptPublish() {
        this.clearErrorsOnFields();

        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);
        String body = this.prepareBody();

        if (body != null) {
            mProgress = new ProgressDialog(this);
            mProgress.setTitle(getString(R.string.title_publish));
            mProgress.setMessage(getString(R.string.message_publish));
            mProgress.setProgressStyle(ProgressDialog.STYLE_SPINNER);
            mProgress.setCancelable(false);
            mProgress.show();

            WBPublishPost task = new WBPublishPost();
            task.setIPublishPost(this);
            task.execute(token, body);
        }
    }
}
