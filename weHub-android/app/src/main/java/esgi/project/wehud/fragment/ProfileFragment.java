package esgi.project.wehud.fragment;


import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import esgi.project.wehud.R;
import esgi.project.wehud.activity.ContactListActivity;
import esgi.project.wehud.activity.MessageListActivity;
import esgi.project.wehud.activity.SettingsActivity;
import esgi.project.wehud.activity.UserActivity;
import esgi.project.wehud.model.User;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBUserByToken;

public class ProfileFragment extends Fragment implements View.OnClickListener, WBUserByToken.IUserByToken {

    private static final String KEY_USER = "user";

    private Context mContext;
    private ImageView mProfileUserAvatar;
    private TextView mProfileUsername;
    private TextView mProfileMessages;
    private TextView mProfileContacts;
    private TextView mProfileSettings;
    private TextView mProfileSignOut;

    private User mCurrentUser;

    public static ProfileFragment newInstance() {
        return new ProfileFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_profile, container, false);
        mContext = view.getContext();

        AppUtils.setToolbar(this, view, getString(R.string.title_profile));

        mProfileUserAvatar = (ImageView) view.findViewById(R.id.profile_userAvatar);
        mProfileUsername = (TextView) view.findViewById(R.id.profile_username);
        mProfileMessages = (TextView) view.findViewById(R.id.profile_messages);
        mProfileContacts = (TextView) view.findViewById(R.id.profile_contacts);
        mProfileSettings = (TextView) view.findViewById(R.id.profile_settings);
        mProfileSignOut = (TextView) view.findViewById(R.id.profile_logout);

        mProfileUsername.setOnClickListener(this);
        mProfileMessages.setOnClickListener(this);
        mProfileContacts.setOnClickListener(this);
        mProfileSettings.setOnClickListener(this);
        mProfileSignOut.setOnClickListener(this);

        if (savedInstanceState != null) {
            mCurrentUser = savedInstanceState.getParcelable(KEY_USER);
        }

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mCurrentUser == null) {
            this.fetchData();
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putParcelable(KEY_USER, mCurrentUser);
    }

    @Override
    public void onClick(View view) {
        Intent intent = null;
        switch (view.getId()) {
            case R.id.profile_username:
                intent = new Intent(mContext, UserActivity.class);
                Bundle bundle = new Bundle();
                bundle.putParcelable(KEY_USER, mCurrentUser);
                intent.putExtras(bundle);
                break;
            case R.id.profile_messages:
                intent = new Intent(mContext, MessageListActivity.class);
                break;
            case R.id.profile_contacts:
                intent = new Intent(mContext, ContactListActivity.class);
                break;
            case R.id.profile_settings:
                mCurrentUser = null;
                intent = new Intent(mContext, SettingsActivity.class);
                break;
            case R.id.profile_logout:
                this.logout();
                break;
            default:
                break;
        }

        if (intent != null) {
            startActivity(intent);
        }
    }

    @Override
    public void onUserObtained(User user) {
        mCurrentUser = user;
        String avatar = mCurrentUser.getAvatar();
        String username = mCurrentUser.getUsername();

        if (!TextUtils.isEmpty(avatar)) {
            Picasso.with(mContext).load(avatar).resize(256, 256).into(mProfileUserAvatar);
        } else {
            mProfileUserAvatar.setImageResource(R.mipmap.ic_launcher);
        }
        mProfileUsername.setText(username);
    }

    @Override
    public void onUserError(int status) {
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

    private void logout() {
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
        builder.setTitle(R.string.dialog_logoutTitle);
        builder.setMessage(R.string.dialog_logoutMessage);
        builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                dialog.dismiss();
                getActivity().finish();
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

    private void fetchData() {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(mContext, APIUtils.SP_KEY_TOKEN);

        WBUserByToken task = new WBUserByToken();
        task.setIUserByToken(this);
        task.execute(token);
    }
}
