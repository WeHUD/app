package esgi.project.wehud.activity;

import android.app.ProgressDialog;
import android.os.PersistableBundle;
import android.support.design.widget.AppBarLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.Menu;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import esgi.project.wehud.R;
import esgi.project.wehud.model.Game;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.GSONUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBFollowUnfollowGame;

/**
 * This class represents a screen in which is displayed a {@link Game} object.
 *
 * @author Olivier Gonçalves
 */
public class GameActivity extends AppCompatActivity
        implements AppBarLayout.OnOffsetChangedListener, View.OnClickListener,
        WBFollowUnfollowGame.IUpdateGame {

    // The keys for storing data in this Activity.
    private static final String KEY_GAME = "game";
    private static final String KEY_FOLLOWERS = "followersId";

    // The UI components.
    private AppBarLayout mAppBarLayout;
    private Toolbar mToolbar;

    private ImageView mGameImage;
    private TextView mGameName;
    private TextView mGamePlatforms;
    private TextView mGameFollowers;
    private TextView mGameFollowerCount;
    private TextView mGameEditor;
    private TextView mGameDeveloper;
    private TextView mGameCategories;
    private TextView mGameReleasedAt;
    private TextView mGameSynopsis;
    private TextView mGameWebsite;
    private TextView mGameIsSolo;
    private TextView mGameIsMultiplayer;
    private TextView mGameIsCooperative;
    private Button mGameInfoFollowUnfollowButton;

    private ProgressDialog mProgress;

    private Game mCurrentGame;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_game);

        mAppBarLayout = (AppBarLayout) findViewById(R.id.appBar);
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mGameImage = (ImageView) findViewById(R.id.game_image);
        mGameName = (TextView) findViewById(R.id.game_name);
        mGamePlatforms = (TextView) findViewById(R.id.game_platforms);
        mGameFollowers = (TextView) findViewById(R.id.game_followers);
        mGameFollowerCount = (TextView) findViewById(R.id.game_followerCount);
        mGameEditor = (TextView) findViewById(R.id.game_editor);
        mGameDeveloper = (TextView) findViewById(R.id.game_developer);
        mGameCategories = (TextView) findViewById(R.id.game_categories);
        mGameReleasedAt = (TextView) findViewById(R.id.game_releasedAt);
        mGameSynopsis = (TextView) findViewById(R.id.game_synopsis);
        mGameWebsite = (TextView) findViewById(R.id.game_website);
        mGameIsSolo = (TextView) findViewById(R.id.game_isSolo);
        mGameIsMultiplayer = (TextView) findViewById(R.id.game_isMultiplayer);
        mGameIsCooperative = (TextView) findViewById(R.id.game_isCooperative);
        mGameInfoFollowUnfollowButton = (Button) findViewById(R.id.game_followUnfollowButton);

        mAppBarLayout.addOnOffsetChangedListener(this);
        mGameInfoFollowUnfollowButton.setOnClickListener(this);

        // If we saved an instance of the game before,
        // retrieve it and make the game's information appear.
        if (savedInstanceState != null) {
            mCurrentGame = savedInstanceState.getParcelable(KEY_GAME);
            this.populateGame();
        }
    }

    /**
     * This method is part of the Android Activity lifecycle and is called just after onStart(),
     * which is itself called after onCreate(savedInstanceState). It is used to check if a {@link Game}
     * had been retrieved. If not, then we must retrieve a {@link Bundle} to obtain the game.
     */
    @Override
    protected void onResume() {
        super.onResume();
        if (mCurrentGame == null) {
            Bundle extras = getIntent().getExtras();
            if (extras != null) {
                mCurrentGame = extras.getParcelable(KEY_GAME);
                this.populateGame();
            }
        }
    }

    /**
     * This method of the Android Activity lifecycle is used to force fetching data when
     * a user returns to this Activity.
     */
    @Override
    protected void onStop() {
        super.onStop();
        mCurrentGame = null;
    }


    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putParcelable(KEY_GAME, mCurrentGame);
    }

    /**
     * This method is called when the collapsible toolbar changes size.
     *
     * @param appBarLayout the layout containing the {@link Toolbar}
     * @param verticalOffset the vertical offset of the collapsible toolbar
     */
    @Override
    public void onOffsetChanged(AppBarLayout appBarLayout, int verticalOffset) {
        String gameName = mGameName.getText().toString();
        Menu menu = mToolbar.getMenu();
        boolean collapsed = Math.abs(verticalOffset) == mAppBarLayout.getTotalScrollRange();
        mToolbar.setTitle(collapsed ? gameName : getString(R.string.game_profile));
        for (int i = 0; i < menu.size(); ++i) {
            menu.getItem(i).setVisible(collapsed);
        }
    }

    /**
     * A method that handles button clicks.
     *
     * @param view the clicked view
     */
    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.game_followUnfollowButton) {
            this.followUnfollowGame(view.getTag().toString());
        }
    }

    /**
     * This method is called when the {@link WBFollowUnfollowGame} webservice
     * returns successfully.
     */
    @Override
    public void onGameUpdateSuccess() {
        mProgress.dismiss();
        AppUtils.toast(this, getString(R.string.message_updateSuccess));

        this.updateButtonText();
    }

    /**
     * This method is called when the {@link WBFollowUnfollowGame} webservice
     * returns an error.
     *
     * @param status the HTTP status code of the error
     */
    @Override
    public void onGameUpdateFail(int status) {
        mProgress.dismiss();
        switch (status) {
            case APIUtils.NO_HTTP:
                AppUtils.toast(this, getString(R.string.error_noResponse));
                break;
            case APIUtils.HTTP_SERVER_ERROR:
                AppUtils.toast(this, getString(R.string.error_server));
                break;
            default:
                break;
        }
    }

    /**
     * Fills the game profile screen with information about a game
     */
    private void populateGame() {
        String boxart = mCurrentGame.getBoxart();
        String name = mCurrentGame.getName();
        String editor = mCurrentGame.getEditor();
        String developer = mCurrentGame.getDeveloper();
        String synopsis = mCurrentGame.getSynopsis();
        String website = mCurrentGame.getWebsite();
        String releasedAt = mCurrentGame.getReleasedAt();
        List<String> platforms = mCurrentGame.getPlatforms();
        List<String> categories = mCurrentGame.getCategories();

        if (!TextUtils.isEmpty(boxart)) {
            Picasso.with(this).load(boxart).into(mGameImage);
        }
        mGameName.setText(name);
        mGameEditor.setText(editor);
        mGameDeveloper.setText(developer);
        mGameSynopsis.setText(synopsis);
        mGameWebsite.setText(website);
        mGameReleasedAt.setText(releasedAt);
        for (String platform : platforms) {
            platform += " ";
            mGamePlatforms.append(platform);
        }
        for (String category : categories) {
            category += " ";
            mGameCategories.append(category);
        }

        if (mCurrentGame.isSolo()) {
            mGameIsSolo.setVisibility(View.VISIBLE);
        }
        if (mCurrentGame.isMultiplayer()) {
            mGameIsMultiplayer.setVisibility(View.VISIBLE);
        }
        if (mCurrentGame.isCooperative()) {
            mGameIsCooperative.setVisibility(View.VISIBLE);
        }

        this.updateButtonText();
    }

    /**
     * Calls an instance of the {@link WBFollowUnfollowGame} webservice to update
     * the follower count of the game.
     *
     * @param tag a tag containing the text to set to the Follow/Unfollow button
     */
    private void followUnfollowGame(String tag) {
        String currentUserId = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_ID);
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);
        List<String> currentFollowers = mCurrentGame.getFollowersId();

        String followUnfollow = getString(R.string.follow);
        if (mGameInfoFollowUnfollowButton.getText().toString().equals(getString(R.string.unfollow))) {
            followUnfollow = getString(R.string.unfollow);
        }

        // Creating a list of followers
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

        // Gson automatically constructs a JSON string.
        // It can handle many Java types like {@link Map}
        String body = GSONUtils.getInstance().toJson(map);
        mCurrentGame.setFollowersId(followersId);

        // Show the progress dialog.
        mProgress = new ProgressDialog(this);
        mProgress.setTitle(getString(R.string.title_connection));
        mProgress.setMessage(getString(R.string.message_update));
        mProgress.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        mProgress.setCancelable(false);
        mProgress.show();

        // Start the webservice task.
        WBFollowUnfollowGame task = new WBFollowUnfollowGame();
        task.setIUpdateGame(this);
        task.execute(token, mCurrentGame.getId(), body);

        // Update the text of the button accordingly.
        mGameInfoFollowUnfollowButton.setText(followUnfollow);
    }

    /**
     * Update the text of mGameInfoFollowUnfollowButton.
     */
    private void updateButtonText() {
        String currentUserId = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_ID);
        List<String> followers = mCurrentGame.getFollowersId();

        if (followers != null && followers.contains(currentUserId)) {
            mGameInfoFollowUnfollowButton.setText(getString(R.string.unfollow));
            mGameInfoFollowUnfollowButton.setTag(getString(R.string.unfollow));
        } else {
            mGameInfoFollowUnfollowButton.setText(getString(R.string.follow));
            mGameInfoFollowUnfollowButton.setTag(getString(R.string.follow));
        }

        int count = mCurrentGame.getFollowersId().size();
        if (count == 1) {
            mGameFollowers.setText(R.string.gameInfo_follower);
        } else {
            mGameFollowers.setText(R.string.gameInfo_followers);
        }

        if (followers != null) {
            mGameFollowerCount.setText(String.valueOf(followers.size()));
        }
    }
}
