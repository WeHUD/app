package esgi.project.wehud.model;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.Date;
import java.util.List;

/**
 * This model class represents a game published in
 * the application.
 *
 * @author Olivier Gonçalves
 */
public final class Game implements Parcelable {
    @SerializedName("_id")
    private String id;

    private String name;
    private String developer;
    private String editor;
    private String synopsis;
    private String website;
    private String boxart;
    private List<String> categories;
    private List<String> platforms;
    private List<String> followersId;
    private Date datetimeCreated;
    private boolean solo;
    private boolean multiplayer;
    private boolean cooperative;

    @Expose(serialize = false, deserialize = false)
    private String releasedAt;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDeveloper() {
        return developer;
    }

    public void setDeveloper(String developer) {
        this.developer = developer;
    }

    public String getEditor() {
        return editor;
    }

    public void setEditor(String editor) {
        this.editor = editor;
    }

    public String getSynopsis() {
        return synopsis;
    }

    public void setSynopsis(String synopsis) {
        this.synopsis = synopsis;
    }

    public String getWebsite() {
        return website;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    public String getBoxart() {
        return boxart;
    }

    public void setBoxart(String boxart) {
        this.boxart = boxart;
    }

    public List<String> getCategories() {
        return categories;
    }

    public void setCategories(List<String> categories) {
        this.categories = categories;
    }

    public List<String> getPlatforms() {
        return platforms;
    }

    public void setPlatforms(List<String> platforms) {
        this.platforms = platforms;
    }

    public List<String> getFollowersId() {
        return followersId;
    }

    public void setFollowersId(List<String> followersId) {
        this.followersId = followersId;
    }

    public Date getDatetimeCreated() {
        return datetimeCreated;
    }

    public void setDatetimeCreated(Date datetimeCreated) {
        this.datetimeCreated = datetimeCreated;
    }

    public boolean isSolo() {
        return solo;
    }

    public void setSolo(boolean solo) {
        this.solo = solo;
    }

    public boolean isMultiplayer() {
        return multiplayer;
    }

    public void setMultiplayer(boolean multiplayer) {
        this.multiplayer = multiplayer;
    }

    public boolean isCooperative() {
        return cooperative;
    }

    public void setCooperative(boolean cooperative) {
        this.cooperative = cooperative;
    }

    public void follow(String followerId) {
        this.followersId.add(followerId);
    }

    public void unfollow(String followerId) {
        this.followersId.remove(followerId);
    }

    public String getReleasedAt() {
        return releasedAt;
    }

    public void setReleasedAt(String releasedAt) {
        this.releasedAt = releasedAt;
    }

    @Override
    public String toString() {
        return name;
    }

    protected Game(Parcel in) {
        id = in.readString();
        name = in.readString();
        developer = in.readString();
        editor = in.readString();
        synopsis = in.readString();
        website = in.readString();
        boxart = in.readString();
        categories = in.createStringArrayList();
        platforms = in.createStringArrayList();
        followersId = in.createStringArrayList();
        datetimeCreated = new Date(in.readLong());
        solo = in.readByte() != 0;
        multiplayer = in.readByte() != 0;
        cooperative = in.readByte() != 0;
    }

    public static final Creator<Game> CREATOR = new Creator<Game>() {
        @Override
        public Game createFromParcel(Parcel in) {
            return new Game(in);
        }

        @Override
        public Game[] newArray(int size) {
            return new Game[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    // The writing order MUST be the same as the reading order.
    @Override
    public void writeToParcel(Parcel parcel, int i) {
        parcel.writeString(id);
        parcel.writeString(name);
        parcel.writeString(developer);
        parcel.writeString(editor);
        parcel.writeString(synopsis);
        parcel.writeString(website);
        parcel.writeString(boxart);
        parcel.writeStringList(categories);
        parcel.writeStringList(platforms);
        parcel.writeStringList(followersId);
        parcel.writeLong(datetimeCreated.getTime());
        parcel.writeByte((byte) (solo ? 1 : 0));
        parcel.writeByte((byte) (multiplayer ? 1 : 0));
        parcel.writeByte((byte) (cooperative ? 1 : 0));
    }
}
