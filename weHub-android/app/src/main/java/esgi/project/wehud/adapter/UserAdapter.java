package esgi.project.wehud.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.model.User;

/**
 * This {@link BaseAdapter} subclass
 * is used for displaying a list of {@link User} objects.
 *
 * @author Olivier Gonçalves
 */
public final class UserAdapter extends BaseAdapter implements Filterable {

    private ItemFilter mFilter;
    private LayoutInflater mInflater;
    private List<User> mOriginalData;
    private List<User> mFilteredData;

    public UserAdapter(Context context) {
        mInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        mFilteredData = new ArrayList<>();
    }

    public void setUserList(List<User> userList) {
        mOriginalData = userList;
        mFilteredData = userList;
        mFilter = new ItemFilter();
    }

    @Override
    public int getCount() {
        return mFilteredData.size();
    }

    @Override
    public Object getItem(int position) {
        return mFilteredData.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        UserVH holder;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.new_post_receiver, parent, false);
            holder = new UserVH(convertView);
            convertView.setTag(holder);
        } else {
            holder = (UserVH) convertView.getTag();
        }
        User user = mFilteredData.get(position);

        String username = user.getUsername();
        String userId = user.getId();

        holder.username.setText(username);
        holder.username.setTag(userId);

        return convertView;
    }

    @Override
    public Filter getFilter() {
        return mFilter;
    }

    private class ItemFilter extends Filter {
        @Override
        protected FilterResults performFiltering(CharSequence constraint) {

            String filterString = constraint.toString().toLowerCase();

            FilterResults results = new FilterResults();

            final List<User> list = mOriginalData;

            int count = list.size();
            final ArrayList<String> nList = new ArrayList<>(count);

            String filterableString;

            for (int i = 0; i < count; i++) {
                filterableString = list.get(i).toString();
                if (filterableString.toLowerCase().contains(filterString)) {
                    nList.add(filterableString);
                }
            }

            results.values = nList;
            results.count = nList.size();

            return results;
        }

        @SuppressWarnings("unchecked")
        @Override
        protected void publishResults(CharSequence constraint, FilterResults results) {
            mFilteredData = (ArrayList<User>) results.values;
            notifyDataSetChanged();
        }

    }

    private class UserVH {
        private TextView username;

        UserVH(View view) {
            this.username = (TextView) view.findViewById(android.R.id.text1);
        }
    }
}
