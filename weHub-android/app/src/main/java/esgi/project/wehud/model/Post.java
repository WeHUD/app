package esgi.project.wehud.model;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.Date;
import java.util.List;

/**
 * This model class represent a post in the application.
 *
 * @author Olivier Gonçalves
 */
public final class Post implements Parcelable {
    @SerializedName("_id")
    private String id;

    private String userId;
    private String gameId;
    private String author;
    private String text;
    private String receiverId;
    private List<String> likes;
    private List<String> comments;
    private boolean flagOpinion;
    private String video;
    private Date datetimeCreated;
    private float mark;

    // For practical reasons, this variable is used in Parcels
    // instead of datetimeCreated
    @Expose(serialize = false, deserialize = false)
    private String createdAt;

    @Expose(serialize = false, deserialize = false)
    private User user;

    @Expose(serialize = false, deserialize = false)
    private Game game;

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

    public String getGameId() {
        return gameId;
    }

    public void setGameId(String gameId) {
        this.gameId = gameId;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(String receiverId) {
        this.receiverId = receiverId;
    }

    public List<String> getLikes() {
        return likes;
    }

    public void setLikes(List<String> likes) {
        this.likes = likes;
    }

    public List<String> getComments() {
        return comments;
    }

    public void setComments(List<String> comments) {
        this.comments = comments;
    }

    public boolean hasFlagOpinion() {
        return flagOpinion;
    }

    public void setFlagOpinion(boolean flagOpinion) {
        this.flagOpinion = flagOpinion;
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

    public float getMark() {
        return mark;
    }

    public void setMark(float mark) {
        this.mark = mark;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Game getGame() {
        return game;
    }

    public void setGame(Game game) {
        this.game = game;
    }

    public void like(String userId) {
        likes.add(userId);
    }

    public void dislike(String userId) {
        likes.remove(userId);
    }

    public void addComment(String commentId) {
        comments.add(commentId);
    }

    public void removeComment(String commentId) {
        comments.remove(commentId);
    }

    private Post(Parcel in) {
        id = in.readString();
        userId = in.readString();
        gameId = in.readString();
        author = in.readString();
        text = in.readString();
        receiverId = in.readString();
        likes = in.createStringArrayList();
        comments = in.createStringArrayList();
        flagOpinion = in.readByte() != 0;
        video = in.readString();
        mark = in.readFloat();
        createdAt = in.readString();
        user = in.readParcelable(User.class.getClassLoader());
        game = in.readParcelable(Game.class.getClassLoader());
    }

    public static final Creator<Post> CREATOR = new Creator<Post>() {
        @Override
        public Post createFromParcel(Parcel in) {
            return new Post(in);
        }

        @Override
        public Post[] newArray(int size) {
            return new Post[size];
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
        parcel.writeString(gameId);
        parcel.writeString(author);
        parcel.writeString(text);
        parcel.writeString(receiverId);
        parcel.writeStringList(likes);
        parcel.writeStringList(comments);
        parcel.writeByte((byte) (flagOpinion ? 1 : 0));
        parcel.writeString(video);
        parcel.writeFloat(mark);
        parcel.writeString(createdAt);
        parcel.writeParcelable(user, flags);
        parcel.writeParcelable(game, flags);
    }
}
