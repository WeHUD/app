package esgi.project.wehud.activity;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.PersistableBundle;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.MenuItem;

import java.util.HashMap;
import java.util.Map;

import esgi.project.wehud.R;
import esgi.project.wehud.fragment.GeolocationFragment;
import esgi.project.wehud.fragment.HomeFragment;
import esgi.project.wehud.fragment.ProfileFragment;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.JSONUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBUpdateUser;

/**
 * This class represents a screen containing several fragments.
 *
 * @author Olivier Gonçalves
 */
public class MainActivity extends AppCompatActivity
        implements BottomNavigationView.OnNavigationItemSelectedListener, WBUpdateUser.IUpdateUser {

    private static final String KEY_CONNECTED = "connected";
    private static final String KEY_PAGE = "page";
    private int mPageId = R.id.item_home;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        BottomNavigationView bottomNav = (BottomNavigationView) findViewById(R.id.nav_bottom);
        bottomNav.setOnNavigationItemSelectedListener(this);

        if (savedInstanceState != null) {
            mPageId = savedInstanceState.getInt(KEY_PAGE);
        }

        this.showPage(mPageId);
    }

    @Override
    public void onSaveInstanceState(Bundle outState, PersistableBundle outPersistentState) {
        outState.putInt(KEY_PAGE, mPageId);
    }

    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        this.showPage(item.getItemId());
        return true;
    }

    @Override
    public void onBackPressed() {
        this.logout();
    }

    @Override
    public void onUpdateUserSuccess() {
        SharedPreferencesUtils.clearPreferences(this);
        AppUtils.toast(this, getString(R.string.message_logout));
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

    private void showPage(int pageId) {
        Fragment fragment = null;
        switch (pageId) {
            case R.id.item_home:
                mPageId = R.id.item_home;
                fragment = HomeFragment.newInstance();
                break;
            case R.id.item_geolocation:
                mPageId = R.id.item_geolocation;
                fragment = GeolocationFragment.newInstance();
                break;
            case R.id.item_profile:
                fragment = ProfileFragment.newInstance();
                mPageId = R.id.item_profile;
                break;
            default:
                break;
        }

        if (fragment != null) {
            FragmentManager manager = getSupportFragmentManager();
            FragmentTransaction transaction = manager.beginTransaction();
            transaction.replace(R.id.container, fragment);
            transaction.commit();
        }
    }

    private void logout() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(R.string.dialog_logoutTitle);
        builder.setMessage(R.string.dialog_logoutMessage);
        builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                String token = SharedPreferencesUtils.getSharedPreferenceByKey(MainActivity.this, APIUtils.SP_KEY_TOKEN);
                String userId = SharedPreferencesUtils.getSharedPreferenceByKey(MainActivity.this, APIUtils.SP_KEY_ID);

                Map<String, Object> map = new HashMap<>();
                map.put(KEY_CONNECTED, false);
                String body = JSONUtils.getJSONFromMap(map);

                WBUpdateUser task = new WBUpdateUser();
                task.setIUpdateUser(MainActivity.this);
                task.execute(token, userId, body);

                dialog.dismiss();
                finish();
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
}
