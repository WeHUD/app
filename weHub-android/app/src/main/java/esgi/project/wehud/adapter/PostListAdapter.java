package esgi.project.wehud.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RatingBar;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.activity.CommentActivity;
import esgi.project.wehud.activity.UserActivity;
import esgi.project.wehud.model.Game;
import esgi.project.wehud.model.Post;
import esgi.project.wehud.model.User;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;

/**
 * This {@link android.support.v7.widget.RecyclerView.Adapter} subclass
 * is used for displaying a list of {@link Post} objects.
 *
 * @author Olivier Gonçalves
 */
public final class PostListAdapter extends RecyclerView.Adapter<PostListAdapter.PostListVH> {

    private static final String KEY_POST = "post";
    private static final String KEY_USER = "user";

    private List<Post> mPostList;
    private boolean isMessage = false;

    private OnAdapterItemClickListener mListener;

    public PostListAdapter(List<Post> postList) {
        mPostList = postList;
    }

    public void setOnAdapterItemClickListener(OnAdapterItemClickListener listener) {
        mListener = listener;
    }

    @Override
    public PostListVH onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.post, parent, false);
        return new PostListVH(view);
    }

    public void setMessage() {
        this.isMessage = true;
    }

    @SuppressLint("InflateParams")
    @Override
    public void onBindViewHolder(final PostListVH holder, int position) {
        final Post post = mPostList.get(position);
        final User user = post.getUser();

        if (user != null) {
            if (!TextUtils.isEmpty(user.getAvatar())) {
                Picasso.with(holder.context).load(user.getAvatar()).resize(256, 256).into(holder.postAvatar);
            } else {
                holder.postAvatar.setImageResource(R.mipmap.ic_launcher);
            }

            holder.postUsername.setText(user.getUsername());
            holder.postUsername.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent intent = new Intent(holder.context, UserActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putParcelable(KEY_USER, post.getUser());
                    intent.putExtras(bundle);
                    holder.context.startActivity(intent);
                }
            });

            holder.postScreenName.setText(user.getReply());
        }

        this.addContentIfNeeded(holder, post);

        holder.postCreatedAt.setText(post.getCreatedAt());
        holder.postText.setText(post.getText());

        if (!isMessage) {
            final String currentUserId = SharedPreferencesUtils.getSharedPreferenceByKey(holder.context,
                    APIUtils.SP_KEY_ID);
            holder.postLikes.setText(String.valueOf(post.getLikes().size()));
            holder.postLikes.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    int likes = post.getLikes().size();
                    if (hasCurrentUserLiked(post, currentUserId)) {
                        if (likes > 0) {
                            holder.postLikes.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_nolike, 0, 0, 0);
                            holder.postLikes.setText(String.valueOf(likes - 1));
                        }
                    } else {
                        holder.postLikes.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_like, 0, 0, 0);
                        holder.postLikes.setText(String.valueOf(likes + 1));
                    }

                    mListener.onAdapterItemClick(holder.postLikes, post);
                }
            });

            if (this.hasCurrentUserLiked(post, currentUserId)) {
                holder.postLikes.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_like, 0, 0, 0);
            } else {
                holder.postLikes.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_nolike, 0, 0, 0);
            }

            holder.postComments.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent intent = new Intent(holder.context, CommentActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putParcelable(KEY_POST, post);
                    bundle.putParcelable(KEY_USER, post.getUser());
                    intent.putExtras(bundle);
                    holder.context.startActivity(intent);
                }
            });
        } else {
            View postFooter = holder.view.findViewById(R.id.post_footer);
            postFooter.setVisibility(View.GONE);
        }
    }

    @Override
    public int getItemCount() {
        return mPostList.size();
    }

    private boolean hasCurrentUserLiked(Post post, String currentUserId) {
        for (String userId : post.getLikes()) {
            if (userId.equals(currentUserId)) {
                return true;
            }
        }

        return false;
    }

    private void addContentIfNeeded(final PostListVH holder, Post post) {

        // Playing with visibilities is needed
        // here to display additional content correctly.
        holder.postAdditional.setVisibility(View.GONE);
        final String youtubeID = post.getVideo();
        final String gameId = post.getGameId();
        if (post.hasFlagOpinion() || !TextUtils.isEmpty(youtubeID) || !TextUtils.isEmpty(gameId)) {
            boolean isPostAdditionalGone = holder.postAdditional.getVisibility() == View.GONE;

            TextView game = (TextView) holder.postAdditional.findViewById(R.id.post_game);
            RatingBar mark = (RatingBar) holder.postAdditional.findViewById(R.id.post_mark);
            ImageView videoThumbnail = (ImageView) holder.postAdditional.findViewById(R.id.post_video);

            game.setVisibility(View.GONE);
            mark.setVisibility(View.GONE);
            videoThumbnail.setVisibility(View.GONE);

            Game postGame = post.getGame();
            if (!TextUtils.isEmpty(gameId) && postGame != null) {
                game.setVisibility(View.VISIBLE);
                game.setText(postGame.getName());
            }

            if (post.hasFlagOpinion() && post.getMark() > 0) {
                mark.setVisibility(View.VISIBLE);
                mark.setRating(post.getMark());

                if (isPostAdditionalGone) {
                    holder.postAdditional.setVisibility(View.VISIBLE);
                } else {
                    // Add a margin because a game was added
                    float d = holder.context.getResources().getDisplayMetrics().density;
                    int marginTop = (int) (8 * d);
                    LinearLayout.MarginLayoutParams margins = new LinearLayout.MarginLayoutParams(videoThumbnail.getLayoutParams());
                    margins.setMargins(0, marginTop, 0, 0);
                    LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(margins);

                    // Apply margin to rating
                    mark.setLayoutParams(params);
                }
            }

            if (!TextUtils.isEmpty(youtubeID)) {
                AppUtils.setupYouTubeVideo(holder.context, youtubeID, videoThumbnail);
                videoThumbnail.setVisibility(View.VISIBLE);

                if (isPostAdditionalGone) {
                    holder.postAdditional.setVisibility(View.VISIBLE);
                } else {

                    // Add a margin because a rating was added.
                    float d = holder.context.getResources().getDisplayMetrics().density;
                    int marginTop = (int) (8 * d);
                    LinearLayout.MarginLayoutParams margins = new LinearLayout.MarginLayoutParams(videoThumbnail.getLayoutParams());
                    margins.setMargins(0, marginTop, 0, 0);
                    LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(margins);

                    // Apply margin to image.
                    videoThumbnail.setLayoutParams(params);
                }
            }
        }
    }

    public interface OnAdapterItemClickListener {
        void onAdapterItemClick(View view, Post post);
    }

    static class PostListVH extends RecyclerView.ViewHolder {
        private Context context;
        private View view;
        private ImageView postAvatar;
        private TextView postUsername;
        private TextView postScreenName;
        private TextView postCreatedAt;
        private TextView postText;
        private ViewGroup postAdditional;
        private TextView postLikes;
        private TextView postComments;

        PostListVH(View v) {
            super(v);
            view = v;
            context = v.getContext();
            postAvatar = (ImageView) v.findViewById(R.id.post_avatar);
            postUsername = (TextView) v.findViewById(R.id.post_username);
            postScreenName = (TextView) v.findViewById(R.id.post_screenName);
            postCreatedAt = (TextView) v.findViewById(R.id.post_createdAt);
            postText = (TextView) v.findViewById(R.id.post_text);
            postAdditional = (ViewGroup) v.findViewById(R.id.post_additional);
            postLikes = (TextView) v.findViewById(R.id.post_likes);
            postComments = (TextView) v.findViewById(R.id.post_comments);
        }
    }

}
