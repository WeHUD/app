package esgi.project.wehud.services;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.FirebaseInstanceIdService;

import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;

/**
 * This class is one of two required to be able to use Firebase within the application.
 *
 * @author Olivier Gonçalves
 */
public class WHFirebaseIDService extends FirebaseInstanceIdService {

    private static final String TAG = "FCMService";

    @Override
    public void onTokenRefresh() {
        // Get updated InstanceID token.
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        Log.d(TAG, "Refreshed token: " + refreshedToken);

        // Send messages to this application instance and
        // manage this app's subscriptions on the server side
        this.sendRegistrationToServer(refreshedToken);
    }

    private void sendRegistrationToServer(String token) {
        SharedPreferencesUtils.putSharedPreference(this, APIUtils.SP_KEY_FIREBASE_TOKEN, token);
    }
}
