package esgi.project.wehud.model;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.Date;
import java.util.List;

/**
 * This model class represents a user in the application.
 *
 * @author Olivier Gonçalves
 */
public final class User implements Parcelable {
    @SerializedName("_id")
    private String id;

    private String email;
    private String username;
    private String reply;
    private String password;
    private Date dateOfBirth;
    private String avatar;
    private double latitude;
    private double longitude;
    private List<String> followedUsers;
    private List<String> followedGames;
    private int score;
    private boolean connected;

    // For practical reasons, this variable is used in Parcels
    // instead of datetimeCreated
    @Expose(serialize = false, deserialize = false)
    private String dob;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getReply() {
        return reply;
    }

    public void setReply(String reply) {
        this.reply = reply;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(float latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(float longitude) {
        this.longitude = longitude;
    }

    public List<String> getFollowedUsers() {
        return followedUsers;
    }

    public void setFollowedUsers(List<String> followedUsers) {
        this.followedUsers = followedUsers;
    }

    public List<String> getFollowedGames() {
        return followedGames;
    }

    public void setFollowedGames(List<String> followedGames) {
        this.followedGames = followedGames;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public boolean isConnected() {
        return connected;
    }

    public void setConnected(boolean connected) {
        this.connected = connected;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public String getDob() {
        return dob;
    }

    public void setDob(String dob) {
        this.dob = dob;
    }

    public void followGame(String gameId) {
        this.followedGames.add(gameId);
    }

    public void unfollowGame(String gameId) {
        this.followedGames.remove(gameId);
    }

    public void followUser(String userId) {
        this.followedUsers.add(userId);
    }

    public void unfollowUser(String userId) {
        this.followedUsers.remove(userId);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        User user = (User) o;

        return id.equals(user.id);

    }

    @Override
    public int hashCode() {
        return id.hashCode();
    }

    public User() {}

    protected User(Parcel in) {
        id = in.readString();
        avatar = in.readString();
        email = in.readString();
        username = in.readString();
        reply = in.readString();
        password = in.readString();
        dateOfBirth = new Date(in.readLong());
        latitude = in.readDouble();
        longitude = in.readDouble();
        followedUsers = in.createStringArrayList();
        followedGames = in.createStringArrayList();
        score = in.readInt();
        connected = in.readByte() != 0;
    }

    public static final Creator<User> CREATOR = new Creator<User>() {
        @Override
        public User createFromParcel(Parcel in) {
            return new User(in);
        }

        @Override
        public User[] newArray(int size) {
            return new User[size];
        }
    };

    @Override
    public String toString() {
        return username + " (" + reply + ')';
    }

    @Override
    public int describeContents() {
        return 0;
    }

    // The writing order MUST be the same as the reading order.
    @Override
    public void writeToParcel(Parcel parcel, int i) {
        parcel.writeString(id);
        parcel.writeString(avatar);
        parcel.writeString(email);
        parcel.writeString(username);
        parcel.writeString(reply);
        parcel.writeString(password);
        parcel.writeLong(dateOfBirth.getTime());
        parcel.writeDouble(latitude);
        parcel.writeDouble(longitude);
        parcel.writeStringList(followedUsers);
        parcel.writeStringList(followedGames);
        parcel.writeInt(score);
        parcel.writeByte((byte) (connected ? 1 : 0));
    }
}
