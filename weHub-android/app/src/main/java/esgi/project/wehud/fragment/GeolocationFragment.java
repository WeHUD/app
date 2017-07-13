package esgi.project.wehud.fragment;


import android.Manifest;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.activity.UserActivity;
import esgi.project.wehud.adapter.InfoWindowAdapter;
import esgi.project.wehud.model.User;
import esgi.project.wehud.services.WHLocationService;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;

/**
 * A fragment displaying a map where the user
 * can locate other users near their position.
 *
 * @author Olivier Gonçalves
 */
public class GeolocationFragment extends Fragment
        implements OnMapReadyCallback, GoogleMap.OnInfoWindowClickListener {

    private static final String TAG = "Geolocation";
    private static final String KEY_USER = "user";

    private boolean mZoomed = false;

    private static final int GRANTED = PackageManager.PERMISSION_GRANTED;
    private static final int LOCATION_CODE = 99;
    private static final int ZOOM_LEVEL = 13;

    private static final String LOCATION_FINE = Manifest.permission.ACCESS_FINE_LOCATION;
    private static final String LOCATION_FILTER = "LocationBroadcast";
    private static final String KEY_LOCATION = "Location";
    private static final String KEY_USERS_LOCATION = "UsersLocation";

    private Context mContext;
    private GoogleMap mMap;
    private Location mLastKnownLocation;

    private List<User> mUserList;

    private BroadcastReceiver mReceiver = new BroadcastReceiver() {

        @Override
        public void onReceive(Context context, Intent intent) {
            Bundle bundle = intent.getBundleExtra(KEY_LOCATION);
            mLastKnownLocation = bundle.getParcelable(KEY_LOCATION);
            mUserList = bundle.getParcelableArrayList(KEY_USERS_LOCATION);
            if (mLastKnownLocation != null && isAdded()) {
                updateMap();
            }
        }
    };

    public static GeolocationFragment newInstance() {
        return new GeolocationFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_geolocation, container, false);
        mContext = view.getContext();

        // Register for local broadcast events from the {@link WHLocationService} class.
        LocalBroadcastManager manager = LocalBroadcastManager.getInstance(mContext);
        manager.registerReceiver(mReceiver, new IntentFilter(LOCATION_FILTER));

        this.setupMapIfNeeded();

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        // Check runtime permission when needed
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(mContext, LOCATION_FINE) != GRANTED) {
                if (ActivityCompat.shouldShowRequestPermissionRationale(getActivity(), LOCATION_FINE)) {
                    AlertDialog rationale = this.buildRationale();
                    rationale.show();
                } else {
                    // No explanation needed, start checking right away
                    ActivityCompat.requestPermissions(getActivity(), new String[]{LOCATION_FINE}, LOCATION_CODE);
                }
            } else {
                // Permission granted
                this.startLocationService();
            }
        } else {
            this.startLocationService();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        if (requestCode == LOCATION_CODE) {
            if (grantResults.length > 0 && grantResults[0] == GRANTED) {
                this.startLocationService();
            }
        }
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        InfoWindowAdapter adapter = new InfoWindowAdapter(mContext);

        mMap = googleMap;
        mMap.getUiSettings().setMyLocationButtonEnabled(true);
        mMap.setInfoWindowAdapter(adapter);
        mMap.setOnInfoWindowClickListener(this);

        // Check for runtime permissions when needed
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(mContext, LOCATION_FINE) == GRANTED) {
                mMap.setMyLocationEnabled(true);
            }
        }
    }

    @Override
    public void onInfoWindowClick(Marker marker) {
        String currentUserId = SharedPreferencesUtils.getSharedPreferenceByKey(mContext, APIUtils.SP_KEY_ID);
        User selectedUser = null;
        for (User user : mUserList) {
            if (user.getUsername().equals(marker.getTitle())) {
                selectedUser = user;
                break;
            }
            if (user.getId().equals(currentUserId)) {
                selectedUser = user;
                break;
            }
        }

        Intent intent = new Intent(mContext, UserActivity.class);
        Bundle bundle = new Bundle();
        bundle.putParcelable(KEY_USER, selectedUser);
        intent.putExtras(bundle);
        mContext.startActivity(intent);
    }

    private void setupMapIfNeeded() {
        if (mMap == null) {
            SupportMapFragment map = (SupportMapFragment) getChildFragmentManager().findFragmentById(R.id.map);
            map.getMapAsync(this);
        }
    }

    private AlertDialog buildRationale() {
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
        builder.setTitle(R.string.rationale_locationTitle);
        builder.setMessage(R.string.rationale_location);
        builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {
                dialog.dismiss();
                ActivityCompat.requestPermissions(getActivity(), new String[]{LOCATION_FINE}, LOCATION_CODE);
            }
        });
        builder.setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {
                dialog.dismiss();
            }
        });

        return builder.create();
    }

    private void startLocationService() {
        Intent service = new Intent(getContext(), WHLocationService.class);
        getActivity().startService(service);
    }

    private void updateMap() {
        mMap.clear();

        // Get position of other users
        // Update markers depending on user movements
        if (mUserList != null) {
            for (User user : mUserList) {
                double lat = user.getLatitude();
                double lon = user.getLongitude();
                LatLng userCoords = new LatLng(lat, lon);
                this.placeMarkerAt(userCoords, user.getUsername(), BitmapDescriptorFactory.HUE_AZURE);
            }
        }

        // Update position
        LatLng myLatLng = new LatLng(mLastKnownLocation.getLatitude(), mLastKnownLocation.getLongitude());
        this.placeMarkerAt(myLatLng, getString(R.string.geoloc_myPosition), 0);
        CameraPosition position = new CameraPosition.Builder().target(myLatLng).zoom(ZOOM_LEVEL).build();
        if (!mZoomed) {
            mMap.animateCamera(CameraUpdateFactory.newCameraPosition(position));
            mZoomed = true;
        }

        // Get map bounds
        LatLngBounds mapBounds = mMap.getProjection().getVisibleRegion().latLngBounds;
        Log.d(TAG, mapBounds.toString());
    }

    private void placeMarkerAt(LatLng latLng, String title, float hue) {
        MarkerOptions options = new MarkerOptions();
        options.position(latLng);
        options.title(title);
        if (hue != 0) {
            options.icon(BitmapDescriptorFactory.defaultMarker(hue));
        } else {
            options.icon(BitmapDescriptorFactory.defaultMarker());
        }
        mMap.addMarker(options);
    }
}
