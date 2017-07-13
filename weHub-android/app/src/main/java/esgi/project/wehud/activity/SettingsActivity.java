package esgi.project.wehud.activity;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;

import esgi.project.wehud.R;
import esgi.project.wehud.dialog.DatePickerDialogFragment;
import esgi.project.wehud.dialog.EditDialogFragment;
import esgi.project.wehud.dialog.ImagePickerDialogFragment;
import esgi.project.wehud.model.User;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.GSONUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBDeleteUser;
import esgi.project.wehud.webservices.WBUpdateUser;
import esgi.project.wehud.webservices.WBUserByToken;

/**
 * This class represents a screen where the user can
 * change their settings.
 *
 * @author Olivier Gonçalves
 */
public class SettingsActivity extends AppCompatActivity
        implements View.OnClickListener, EditDialogFragment.OnEditListener,
        DatePickerDialogFragment.OnDatePickListener, ImagePickerDialogFragment.OnImagePickListener,
        WBUserByToken.IUserByToken, WBUpdateUser.IUpdateUser, WBDeleteUser.IDeleteUser {

    private static final String KEY_USER = "user";
    private static final String KEY_VIEW_ID = "id";
    private static final String KEY_HINT = "hint";
    private static final String KEY_TEXT = "text";
    private static final String KEY_PASSWORD = "password";

    private ImageView mAvatarView;
    private TextView mUsernameView;
    private TextView mDateOfBirthView;
    private TextView mEmailView;
    private TextView mPasswordView;

    private User mUser;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);

        mAvatarView = (ImageView) findViewById(R.id.settings_avatar);
        mUsernameView = (TextView) findViewById(R.id.settings_username);
        mDateOfBirthView = (TextView) findViewById(R.id.settings_dateOfBirth);
        mEmailView = (TextView) findViewById(R.id.settings_email);
        mPasswordView = (TextView) findViewById(R.id.settings_password);
        Button changeProfileImageButton = (Button) findViewById(R.id.settings_changeProfileImageButton);
        Button updateButton = (Button) findViewById(R.id.settings_updateButton);
        Button deleteButton = (Button) findViewById(R.id.settings_deleteButton);

        mAvatarView.setOnClickListener(this);
        mUsernameView.setOnClickListener(this);
        mDateOfBirthView.setOnClickListener(this);
        mEmailView.setOnClickListener(this);
        mPasswordView.setOnClickListener(this);
        changeProfileImageButton.setOnClickListener(this);
        updateButton.setOnClickListener(this);
        deleteButton.setOnClickListener(this);

        if (savedInstanceState != null) {
            mUser = savedInstanceState.getParcelable(KEY_USER);
            this.populateUser();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mUser == null) {
            this.fetchData();
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putParcelable(KEY_USER, mUser);
    }

    @Override
    public void onClick(View view) {
        int textId;
        String title;
        String text;
        boolean isPassword = false;
        switch (view.getId()) {
            case R.id.settings_email:
                textId = R.id.settings_email;
                title = getString(R.string.hint_email);
                text = mEmailView.getText().toString();
                break;
            case R.id.settings_username:
                textId = R.id.settings_username;
                title = getString(R.string.hint_username);
                text = mUsernameView.getText().toString();
                break;
            case R.id.settings_password:
                textId = R.id.settings_password;
                title = getString(R.string.hint_password);
                text = mPasswordView.getText().toString();
                isPassword = true;
                break;
            case R.id.settings_dateOfBirth:
                this.generateDatePickerDialog();
                return;
            case R.id.settings_changeProfileImageButton:
                this.changeProfileImage();
                return;
            case R.id.settings_updateButton:
                this.update();
                return;
            case R.id.settings_deleteButton:
                this.generateDeleteDialog();
                return;
            default:
                return;
        }

        this.generateEditDialog(textId, title, text, isPassword);
    }

    @Override
    public void onDatePick(int year, int month, int day) {
        final Calendar c = Calendar.getInstance();
        c.set(year, month, day);
        Date newDate = c.getTime();
        DateFormat formatter = DateFormat.getDateInstance(DateFormat.SHORT);
        mDateOfBirthView.setText(formatter.format(newDate));
    }

    @Override
    public void onEdit(int textId, String text) {
        TextView textView = (TextView) findViewById(textId);
        if (textView != null) {
            if (textId == R.id.settings_password) {
                String dotPassword = text.replaceAll("(?s).", "*");
                textView.setTag(text);
                textView.setText(dotPassword);
            } else if (textId == R.id.settings_username) {
                String reply = '@' + text;
                textView.setTag(reply);
                textView.setText(text);
            } else {
                textView.setText(text);
            }
        }
    }

    @Override
    public void onUserObtained(User user) {
        final DateFormat formatter = DateFormat.getDateInstance(DateFormat.SHORT);

        user.setDob(formatter.format(user.getDateOfBirth()));
        mUser = user;
        this.populateUser();
    }

    @Override
    public void onUserError(int status) {
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

    private void generateDatePickerDialog() {
        DatePickerDialogFragment datePickerDialog = DatePickerDialogFragment.newInstance();
        datePickerDialog.setOnDatePickListener(this);
        datePickerDialog.show(getSupportFragmentManager(), getClass().getName());
    }

    @SuppressLint("InflateParams")
    private void generateEditDialog(int id, String title, String text, boolean isPassword) {

        Bundle bundle = new Bundle();
        bundle.putInt(KEY_VIEW_ID, id);
        bundle.putString(KEY_HINT, title);
        bundle.putString(KEY_TEXT, text);
        bundle.putBoolean(KEY_PASSWORD, isPassword);

        EditDialogFragment editDialog = EditDialogFragment.newInstance();
        editDialog.setArguments(bundle);
        editDialog.setOnEditListener(this);
        editDialog.show(getSupportFragmentManager(), getClass().getName());
    }

    @Override
    public void onUpdateUserSuccess() {
        AppUtils.toast(this, getString(R.string.message_updateSuccess));

        finish();
    }

    @Override
    public void onUpdateUserFail(int status) {
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

    @Override
    public void onDeleteSuccess() {
        AppUtils.toast(this, getString(R.string.message_accountDeleted));
        Intent intent = new Intent(this, LoginActivity.class);
        startActivity(intent);
        finish();
    }

    @Override
    public void onDeleteFail(int status) {
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

    @Override
    public void onImagePick(String imageUrl) {
        mUser.setAvatar(imageUrl);
        AppUtils.loadImage(this, imageUrl, mAvatarView, APIUtils.SIZE);
    }

    private void populateUser() {
        String username = mUser.getUsername();
        String reply = mUser.getReply();
        String dateOfBirth = mUser.getDob();
        String dob = mUser.getDob();
        String email = mUser.getEmail();
        String password = mUser.getPassword();

        String avatar = mUser.getAvatar();
        if (!TextUtils.isEmpty(avatar)) {
            AppUtils.loadImage(this, avatar, mAvatarView, APIUtils.SIZE);
        } else {
            mAvatarView.setImageResource(R.mipmap.ic_launcher);
        }

        mUsernameView.setText(username);
        mUsernameView.setTag(reply);
        mDateOfBirthView.setText(dateOfBirth);
        mDateOfBirthView.setTag(dob);
        mEmailView.setText(email);
        mPasswordView.setText(password.replaceAll("(?s).", "*"));
        mPasswordView.setTag(password);
    }

    private void update() {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);
        String currentUserId = mUser.getId();

        String id = mUser.getId();
        String avatar = mUser.getAvatar();
        String username = mUsernameView.getText().toString();
        String reply = mUsernameView.getTag().toString();
        String email = mEmailView.getText().toString();
        String dob = mDateOfBirthView.getText().toString();
        Date dateOfBirth = AppUtils.getISODate(dob);
        String password = mPasswordView.getTag().toString();

        User updatedUser = new User();
        updatedUser.setId(id);
        updatedUser.setAvatar(avatar);
        updatedUser.setUsername(username);
        updatedUser.setReply(reply);
        updatedUser.setEmail(email);
        updatedUser.setDateOfBirth(dateOfBirth);
        updatedUser.setDob(dob);
        updatedUser.setPassword(password);

        String body = GSONUtils.getInstance().toJson(updatedUser, User.class);

        WBUpdateUser task = new WBUpdateUser();
        task.setIUpdateUser(this);
        task.execute(token, currentUserId, body);
    }

    private void changeProfileImage() {
        ImagePickerDialogFragment dialog = new ImagePickerDialogFragment();
        dialog.setOnImagePickListener(this);
        dialog.show(getSupportFragmentManager(), getClass().getName());
    }

    private void generateDeleteDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(R.string.dialog_deleteAccountTitle);
        builder.setMessage(R.string.dialog_deleteAccount);
        builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                delete();
                dialog.dismiss();
            }
        });
        builder.setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                dialog.dismiss();
            }
        });
        builder.create().show();
    }

    private void delete() {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);
        String currentUserId = mUser.getId();

        WBDeleteUser task = new WBDeleteUser();
        task.setIDeleteUser(this);
        task.execute(token, currentUserId);
    }

    private void fetchData() {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);

        WBUserByToken task = new WBUserByToken();
        task.setIUserByToken(this);
        task.execute(token);
    }
}
