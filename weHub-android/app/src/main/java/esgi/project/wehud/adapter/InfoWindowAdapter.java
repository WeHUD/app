package esgi.project.wehud.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Marker;

import esgi.project.wehud.R;

/**
 * An adapter for the info window on the Google Map in
 * {@link esgi.project.wehud.fragment.GeolocationFragment}.
 *
 * @author Olivier Gonçalves
 */
public final class InfoWindowAdapter implements GoogleMap.InfoWindowAdapter {

    private Context mContext;

    public InfoWindowAdapter(Context context) {
        mContext = context;
    }

    @Override
    public View getInfoWindow(Marker marker) {
        return null;
    }

    @SuppressLint("InflateParams")
    @Override
    public View getInfoContents(final Marker marker) {

        View view = LayoutInflater.from(mContext).inflate(R.layout.info_window, null);
        String markerTitle = marker.getTitle();

        TextView infoWindowUsername = (TextView) view.findViewById(R.id.infoWindow_username);
        infoWindowUsername.setText(markerTitle);

        return view;
    }
}
