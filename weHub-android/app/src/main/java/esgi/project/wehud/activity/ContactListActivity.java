package esgi.project.wehud.activity;

import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import java.util.ArrayList;
import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.adapter.ContactListAdapter;
import esgi.project.wehud.model.User;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBUserList;

/**
 * This class represents a list of {@link User} objects
 * displaying their connection status.
 *
 * @author Olivier Gonçalves
 */
public class ContactListActivity extends AppCompatActivity
        implements SwipeRefreshLayout.OnRefreshListener, WBUserList.IGetUserList {

    private static final String KEY_CONTACTS = "contacts";

    private View mEmptyLayout;
    private SwipeRefreshLayout mSwipeLayout;
    private RecyclerView mContactListView;

    private ArrayList<User> mContactList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_contact_list);

        mEmptyLayout = findViewById(R.id.empty_list);
        mSwipeLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_layout);

        mContactListView = (RecyclerView) findViewById(android.R.id.list);
        mContactListView.setLayoutManager(new LinearLayoutManager(this));
        mContactListView.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.HORIZONTAL));

        // Show the "list is empty" layout
        // until we have retrieved the user list.
        mEmptyLayout.setVisibility(View.VISIBLE);
        mSwipeLayout.setVisibility(View.GONE);

        mSwipeLayout.setOnRefreshListener(this);

        // If we saved an instance of the user list before,
        // retrieve it and make the list appear.
        if (savedInstanceState != null) {
            mContactList = savedInstanceState.getParcelableArrayList(KEY_CONTACTS);
            mContactListView.setAdapter(new ContactListAdapter(mContactList));
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }
    }

    /**
     * This method is part of the Android Activity lifecycle and is called just after onStart(),
     * which is itself called after onCreate(savedInstanceState). It is used to check if a user
     * list had been retrieved. If not, then we must call a webservice to obtain the user list.
     */
    @Override
    protected void onResume() {
        super.onResume();
        if (mContactList == null) {
            mSwipeLayout.setRefreshing(true);
            this.fetchData();
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        outState.putParcelableArrayList(KEY_CONTACTS, mContactList);
    }

    /**
     * This method is called when swiping down from the top of the user list.
     */
    @Override
    public void onRefresh() {
        this.fetchData();
    }

    /**
     * This method is called when the {@link WBUserList} webservice returns successfully.
     *
     * @param userList a list of {@link User} objects
     */
    @Override
    public void onUserListReceived(List<User> userList) {
        String currentUserId = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_ID);
        ArrayList<User> contacts = new ArrayList<>();
        if (!userList.isEmpty()) {
            for (User contact : userList) {

                // We should not display ourselves in the list.
                if (contact.getId().equals(currentUserId)) {
                    continue;
                }
                contacts.add(contact);
            }
            mContactList = contacts;
            mContactListView.setAdapter(new ContactListAdapter(mContactList));
            mEmptyLayout.setVisibility(View.GONE);
            mSwipeLayout.setVisibility(View.VISIBLE);
        }

        mSwipeLayout.setRefreshing(false);
    }

    /**
     * This method is called when the {@link WBUserList} webservice returns
     * with an error.
     * @param status the HTTP response code of the webservice response
     */
    @Override
    public void onUserListFail(int status) {
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
     * Calls a {@link WBUserList} variable to retrieve a list of {@link User} objects.
     */
    private void fetchData() {

        // Each request to the server needs a valid token to be carried out
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);

        WBUserList task = new WBUserList();
        task.setIGetUserList(this);
        task.execute(token);
    }
}
