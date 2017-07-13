package esgi.project.wehud.adapter;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

import java.util.ArrayList;
import java.util.List;

import esgi.project.wehud.model.User;

/**
 * This {@link FragmentPagerAdapter} subclass
 * is used with a {@link android.support.v4.view.ViewPager}.
 *
 * @author Olivier Gonçalves
 */
public final class VPAdapter extends FragmentPagerAdapter {

    private List<Fragment> mFragments;
    private List<String> mTitles;
    private Bundle mBundle;

    public VPAdapter(FragmentManager fm) {
        super(fm);
        mFragments = new ArrayList<>();
        mTitles = new ArrayList<>();
    }

    public void add(Fragment fragment, String title) {
        mFragments.add(fragment);
        mTitles.add(title);
    }

    public void setBundle(Bundle bundle) {
        mBundle = bundle;
    }

    @Override
    public Fragment getItem(int position) {
        Fragment fragment = mFragments.get(position);
        if (mBundle != null) {
            fragment.setArguments(mBundle);
        }
        return mFragments.get(position);
    }

    @Override
    public int getCount() {
        return mFragments.size();
    }

    @Override
    public CharSequence getPageTitle(int position) {
        return mTitles.get(position);
    }
}
