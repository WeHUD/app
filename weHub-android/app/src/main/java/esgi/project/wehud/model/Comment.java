package esgi.project.wehud.model;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.Date;

/**
 * This model class represents a comment in the application.
 *
 * @author Olivier Gonçalves
 */
public final class Comment implements Parcelable {
    @SerializedName("_id")
    private String id;

    private String userId;
    private String postId;
    private String text;
    private String video;
    private Date datetimeCreated;

    @Expose(serialize = false, deserialize = false)
    private User user;

    @Expose(serialize = false, deserialize = false)
    private Post post;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getPostId() {
        return postId;
    }

    public void setPostId(String postId) {
        this.postId = postId;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getVideo() {
        return video;
    }

    public void setVideo(String video) {
        this.video = video;
    }

    public Date getDatetimeCreated() {
        return datetimeCreated;
    }

    public void setDatetimeCreated(Date datetimeCreated) {
        this.datetimeCreated = datetimeCreated;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Post getPost() {
        return post;
    }

    public void setPost(Post post) {
        this.post = post;
    }

    protected Comment(Parcel in) {
        id = in.readString();
        userId = in.readString();
        postId = in.readString();
        text = in.readString();
        video = in.readString();
        datetimeCreated = new Date(in.readLong());
        user = in.readParcelable(User.class.getClassLoader());
        post = in.readParcelable(Post.class.getClassLoader());
    }

    public static final Creator<Comment> CREATOR = new Creator<Comment>() {
        @Override
        public Comment createFromParcel(Parcel in) {
            return new Comment(in);
        }

        @Override
        public Comment[] newArray(int size) {
            return new Comment[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    // The writing order MUST be the same as the reading order.
    @Override
    public void writeToParcel(Parcel parcel, int flags) {
        parcel.writeString(id);
        parcel.writeString(userId);
        parcel.writeString(postId);
        parcel.writeString(text);
        parcel.writeString(video);
        parcel.writeLong(datetimeCreated.getTime());
        parcel.writeParcelable(user, flags);
        parcel.writeParcelable(post, flags);
    }
}
