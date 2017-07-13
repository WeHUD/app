package esgi.project.wehud.services;

import android.Manifest;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Binder;
import android.os.Bundle;
import android.os.IBinder;
import android.os.PowerManager;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;

import java.util.ArrayList;
import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.model.User;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBUserList;

/**
 * This {@link Service} subclass gets active when the user allows
 * geolocation on their phone and updates regularly the user's position.
 *
 * @author Olivier Gonçalves
 *
 */
public final class WHLocationService extends Service implements
        GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener,
        LocationListener,
        WBUserList.IGetUserList {

    private static final String TAG = "Geolocation";

    IBinder mBinder = new LocalBinder();

    private GoogleApiClient mGoogleApiClient;
    private PowerManager.WakeLock mWakeLock;
    private LocationRequest mLocationRequest;
    private Location mLastKnownLocation;

    // Flag indicating if a request is underway
    private boolean mInProgress;

    // Flag indicating if Google Play Services is available.
    private boolean mServicesAvailable = false;

    // A list of users close to the connected user
    private ArrayList<User> mUserList;

    @Override
    public void onCreate() {
        super.onCreate();

        mInProgress = false;

        // Create LocationRequest
        mLocationRequest = LocationRequest.create();

        // Use high accuracy
        mLocationRequest.setPriority(LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);

        // Set update interval to 5 seconds.
        mLocationRequest.setInterval(Constants.UPDATE_FREQ_MILLIS);

        // Set the fastest update interval to 1 second
        mLocationRequest.setFastestInterval(Constants.FAST_UPDATE_FREQ_MILLIS);

        mServicesAvailable = this.isGooglePlayServicesAvailable();

        this.setupLocationClientIfNeeded();
    }

    @Override
    public void onDestroy() {
        // Turn off the request flag
        mInProgress = false;

        if (mServicesAvailable && mGoogleApiClient != null) {
            mGoogleApiClient.unregisterConnectionCallbacks(this);
            mGoogleApiClient.unregisterConnectionFailedListener(this);
            mGoogleApiClient.disconnect();

            // Destroy the current location client
            mGoogleApiClient = null;
        }

        // Destroy the WakeLock
        if (mWakeLock != null) {
            mWakeLock.release();
            mWakeLock = null;
        }

        super.onDestroy();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    /*
     * Called by Location Services when the request to connect the
     * client finishes successfully. At this point, you can
     * request the current location or start periodic updates
     */
    @Override
    public void onConnected(@Nullable Bundle bundle) {
        // Request location updates using static settings
        if (ContextCompat.checkSelfPermission(getApplicationContext(), Manifest.permission.ACCESS_FINE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {
            LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient,
                    mLocationRequest, this);
        }
    }

    /*
     * Called by Location Services if the connection to the
     * location client drops because of an error.
     */
    @Override
    public void onConnectionSuspended(int i) {
        // Turn off the request flag
        mInProgress = false;

        // Destroy the current location client
        mGoogleApiClient = null;
    }

    /*
     * Called by Location Services if the attempt to
     * Location Services fails.
     */
    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
        // Turn off the request flag
        mInProgress = false;
    }

    // Define the callback method that defines location updates
    @Override
    public void onLocationChanged(Location location) {
        // Report to the UI the location was updated
        String msg = Double.toString(location.getLatitude()) + ","
                + Double.toString(location.getLongitude());
        Log.d(TAG, msg);

        mLastKnownLocation = location;
        this.fetchData();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);

        // Maybe use Intent if you have to pass the map bounds for user requests?

        PowerManager manager = (PowerManager) getSystemService(Context.POWER_SERVICE);

        // WakeLock is reference counted so we do not want to create multiple WakeLocks.
        // This will fix the "java.lang.Exception: WakeLock finalized while still held" error
        if (mWakeLock == null) {
            mWakeLock = manager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, Constants.WAKE_LOCK_NAME);
        }

        if (!mWakeLock.isHeld()) {
            mWakeLock.acquire();
        }

        if (!mServicesAvailable || mGoogleApiClient.isConnected() || mInProgress) {
            return START_STICKY;
        }

        this.setupLocationClientIfNeeded();

        if (!mGoogleApiClient.isConnected() || !mGoogleApiClient.isConnecting() || !mInProgress) {
            mInProgress = true;
            mGoogleApiClient.connect();
        }

        return START_STICKY;
    }

    @Override
    public void onUserListReceived(List<User> userList) {
        mUserList = (ArrayList<User>) userList;
        this.sendLocalBroadcast(mLastKnownLocation);
    }

    @Override
    public void onUserListFail(int status) {
        switch (status) {
            case APIUtils.NO_HTTP:
                AppUtils.toast(this, getString(R.string.error_noResponse));
                break;
            case APIUtils.HTTP_NOT_FOUND:
                AppUtils.toast(this, getString(R.string.error_notFound));
                break;
            case APIUtils.HTTP_SERVER_ERROR:
                AppUtils.toast(this, getString(R.string.error_server));
                break;
            default:
                break;
        }

        // Even if no one is near me, I should at least get my position :(
        this.sendLocalBroadcast(mLastKnownLocation);
    }

    private void fetchData() {
        String token = SharedPreferencesUtils.getSharedPreferenceByKey(this, APIUtils.SP_KEY_TOKEN);

        WBUserList task = new WBUserList();
        task.setIGetUserList(this);
        task.execute(token);
    }

    // Checks whether or not Google Play Services is available
    private boolean isGooglePlayServicesAvailable() {
        int resultCode = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(this);
        return resultCode == ConnectionResult.SUCCESS;
    }

    /*
     * Create a new location client, using the enclosing class to
     * handle callbacks.
     */
    protected synchronized void buildGoogleApiClient() {
        GoogleApiClient.Builder builder = new GoogleApiClient.Builder(this);
        builder.addConnectionCallbacks(this);
        builder.addOnConnectionFailedListener(this);
        builder.addApi(LocationServices.API);

        mGoogleApiClient = builder.build();
    }

    private void setupLocationClientIfNeeded() {
        if (mGoogleApiClient == null) {
            this.buildGoogleApiClient();
        }
    }

    private void sendLocalBroadcast(Location location) {
        Intent intent = new Intent(Constants.LOCATION_FILTER);
        Bundle bundle = new Bundle();
        bundle.putParcelable(Constants.KEY_LOCATION, location);
        bundle.putParcelableArrayList(Constants.KEY_USERS_LOCATION, mUserList);
        intent.putExtra(Constants.KEY_LOCATION, bundle);
        LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
    }

    private final class LocalBinder extends Binder {
        public WHLocationService getInstance() {
            return WHLocationService.this;
        }
    }

    private final class Constants {

        // Milliseconds per second
        private static final int MILLIS_PER_SEC = 1000;

        // Update frequency in seconds
        private static final int UPDATE_FREQ_SECS = 60;

        // Update frequency in milliseconds
        private static final int UPDATE_FREQ_MILLIS = MILLIS_PER_SEC * UPDATE_FREQ_SECS;

        // The fastest update frequency, in seconds
        private static final int FAST_UPDATE_FREQ_SECS = 30;

        // The fastest update frequency, in milliseconds
        private static final int FAST_UPDATE_FREQ_MILLIS = MILLIS_PER_SEC * FAST_UPDATE_FREQ_SECS;

        public static final String WAKE_LOCK_NAME = "WHWakeLock";

        public static final String LOCATION_FILTER = "LocationBroadcast";

        public static final String KEY_LOCATION = "Location";

        public static final String KEY_USERS_LOCATION = "UsersLocation";

        /**
         * Suppress default constructor for non-instability.
         */
        private Constants() {
            throw new AssertionError();
        }
    }
}
