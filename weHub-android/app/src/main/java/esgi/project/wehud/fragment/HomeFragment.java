package esgi.project.wehud.fragment;


import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import esgi.project.wehud.R;
import esgi.project.wehud.activity.PublishActivity;
import esgi.project.wehud.adapter.VPAdapter;
import esgi.project.wehud.utils.AppUtils;

/**
 * A fragment containing several different lists of posts and games.
 *
 * @author Olivier Gonçalves
 */
public class HomeFragment extends Fragment implements ViewPager.OnPageChangeListener {

    private static int mCurrentPage; // The current page.
    private Context mContext;

    public static HomeFragment newInstance() {
        return new HomeFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        setHasOptionsMenu(true);

        View view = inflater.inflate(R.layout.fragment_home, container, false);
        mContext = view.getContext();

        AppUtils.setToolbar(this, view, getString(R.string.title_home));

        TabLayout tabs = (TabLayout) view.findViewById(android.R.id.tabs);
        ViewPager pager = (ViewPager) view.findViewById(R.id.pager);

        VPAdapter adapter = new VPAdapter(getChildFragmentManager());
        adapter.add(PostListFragment.newInstance(), getString(R.string.tab_myFeeds));
        adapter.add(PopularListFragment.newInstance(), getString(R.string.tab_popular));
        adapter.add(GameListFragment.newInstance(), getString(R.string.tab_games));

        pager.setAdapter(adapter);
        pager.setOffscreenPageLimit(3); // We have 3 tabs
        pager.setCurrentItem(mCurrentPage);
        pager.addOnPageChangeListener(this);
        tabs.setupWithViewPager(pager);

        return view;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.menu_home, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.item_publish:
                Intent intent = new Intent(mContext, PublishActivity.class);
                startActivity(intent);
                break;
            case R.id.item_logout:
                this.logout();
                break;
            default:
                return false;
        }
        return true;
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
        mCurrentPage = position;
    }

    @Override
    public void onPageScrollStateChanged(int state) {

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
}
