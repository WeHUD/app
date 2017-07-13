package esgi.project.wehud.adapter;

import android.net.Uri;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import java.text.DateFormat;
import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.model.Comment;
import esgi.project.wehud.model.User;

/**
 * This {@link android.support.v7.widget.RecyclerView.Adapter} subclass
 * is used for displaying a list of {@link Comment} objects.
 *
 * @author Olivier Gonçalves
 */
public final class CommentListAdapter extends RecyclerView.Adapter<CommentListAdapter.CommentListVH> {

    private List<Comment> mCommentList;

    public CommentListAdapter(List<Comment> commentList) {
        mCommentList = commentList;
    }

    @Override
    public CommentListVH onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.comment, parent, false);
        return new CommentListVH(view);
    }

    @Override
    public void onBindViewHolder(CommentListVH holder, int position) {
        final DateFormat formatter = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT);

        Comment comment = mCommentList.get(position);
        User user = comment.getUser();

        if (user != null) {
            if (!TextUtils.isEmpty(user.getAvatar())) {
                holder.commentAvatar.setImageURI(Uri.parse(user.getAvatar()));
            } else {
                holder.commentAvatar.setImageResource(R.mipmap.ic_launcher);
            }

            holder.commentUsername.setText(user.getUsername());
            holder.commentScreenName.setText(user.getReply());
        }

        holder.commentCreatedAt.setText(formatter.format(comment.getDatetimeCreated()));
        holder.commentText.setText(comment.getText());
    }

    @Override
    public int getItemCount() {
        return mCommentList.size();
    }

    static class CommentListVH extends RecyclerView.ViewHolder {
        private ImageView commentAvatar;
        private TextView commentUsername;
        private TextView commentScreenName;
        private TextView commentCreatedAt;
        private TextView commentText;

        CommentListVH(View view) {
            super(view);
            commentAvatar = (ImageView) view.findViewById(R.id.comment_avatar);
            commentUsername = (TextView) view.findViewById(R.id.comment_username);
            commentScreenName = (TextView) view.findViewById(R.id.comment_screenName);
            commentCreatedAt = (TextView) view.findViewById(R.id.comment_createdAt);
            commentText = (TextView) view.findViewById(R.id.comment_text);
        }
    }
}
