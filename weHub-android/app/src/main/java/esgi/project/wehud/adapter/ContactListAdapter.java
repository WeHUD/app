package esgi.project.wehud.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.model.Comment;
import esgi.project.wehud.model.User;

/**
 * This {@link android.support.v7.widget.RecyclerView.Adapter} subclass
 * is used for displaying a list of {@link User} objects.
 *
 * @author Olivier Gonçalves
 */
public final class ContactListAdapter extends RecyclerView.Adapter<ContactListAdapter.ContactListVH> {

    private List<User> mContactList;

    public ContactListAdapter(List<User> contactList) {
        mContactList = contactList;
    }

    @Override
    public ContactListVH onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.contact, parent, false);
        return new ContactListVH(view);
    }

    @Override
    public void onBindViewHolder(ContactListVH holder, int position) {
        User contact = mContactList.get(position);
        String avatar = contact.getAvatar();
        String username = contact.getUsername();
        String reply = contact.getReply();
        boolean connected = contact.isConnected();

        if (!TextUtils.isEmpty(avatar)) {
            Picasso.with(holder.context).load(avatar).resize(256, 256).into(holder.userAvatar);
        } else {
            holder.userAvatar.setImageResource(R.mipmap.ic_launcher);
        }
        holder.username.setText(username);
        holder.userReply.setText(reply);

        if (connected) {
            holder.userIsConnected.setImageResource(R.drawable.ic_connected);
        } else {
            holder.userIsConnected.setImageResource(R.drawable.ic_not_connected);
        }
    }

    @Override
    public int getItemCount() {
        return mContactList.size();
    }

    static class ContactListVH extends RecyclerView.ViewHolder {
        private Context context;
        private ImageView userAvatar;
        private TextView username;
        private TextView userReply;
        private ImageView userIsConnected;

        public ContactListVH(View view) {
            super(view);
            context = view.getContext();
            userAvatar = (ImageView) view.findViewById(R.id.contact_userAvatar);
            username = (TextView) view.findViewById(R.id.contact_username);
            userReply = (TextView) view.findViewById(R.id.contact_userReply);
            userIsConnected = (ImageView) view.findViewById(R.id.contact_userConnected);
        }
    }
}
