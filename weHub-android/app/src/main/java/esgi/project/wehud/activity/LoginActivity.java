package esgi.project.wehud.activity;

import android.app.ProgressDialog;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import java.util.HashMap;
import java.util.Map;

import esgi.project.wehud.R;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.SharedPreferencesUtils;
import esgi.project.wehud.webservices.WBLogin;

/**
 * This page is the starting point of the application. A user can log in by entering their credentials,
 * but they can also choose to create a new account.
 *
 * @author Olivier Gonçalves
 */
public class LoginActivity extends AppCompatActivity implements View.OnClickListener, WBLogin.ILogin {

    // This app uses OAuth2 for authentication, so we need to provide a grant type.
    private static final String KEY_GRANT_TYPE = "grant_type";
    private static final String KEY_USERNAME = "username";
    private static final String KEY_PASSWORD = "password";

    private ProgressDialog mProgress; // A dialog used when calling the login webservice.
    private EditText mUsernameField;
    private EditText mPasswordField;
    private EditText[] mFields; // This array is used to check all fields on several methods.

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        // Instantiating the Toolbar here, since we chose not to use an
        // application theme that has one.
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        setTitle(getString(R.string.title_login));

        // Setting up UI components and their listeners when needed.
        mUsernameField = (EditText) findViewById(R.id.login_username);
        mPasswordField = (EditText) findViewById(R.id.login_password);
        Button signInButton = (Button) findViewById(R.id.login_btnSignIn);
        Button signUpButton = (Button) findViewById(R.id.login_btnSignUp);

        signInButton.setOnClickListener(this);
        signUpButton.setOnClickListener(this);

        // Filling the array here for further checks.
        mFields = new EditText[]{mUsernameField, mPasswordField};
    }

    /**
     * A method provided by the {@link android.view.View.OnClickListener} interface.
     * It is called when a user presses a {@link Button}.
     *
     * @param view represents the button pressed
     */
    @Override
    public void onClick(View view) {

        // Since we go here multiple times for different processes,
        // clearing previous errors is necessary.
        this.clearErrorsOnFields();
        switch (view.getId()) {
            case R.id.login_btnSignIn:
                this.attemptLogin();
                break;
            case R.id.login_btnSignUp:
                this.clearFields();
                Intent signUpIntent = new Intent(this, RegisterActivity.class);
                startActivity(signUpIntent);
                break;
            default:
                break;
        }
    }

    /**
     * This method is called when the login webservice terminated successfully
     * (i.e. when the user has correctly entered their credentials).
     *
     * @param token the OAuth2 Access Token provided by the server
     */
    @Override
    public void onLoginSuccess(String token) {
        mProgress.dismiss();
        AppUtils.toast(this, getString(R.string.message_loginSuccess));

        // Using SharedPreferences to store the token in the device
        // makes it accessible accross the entire application.
        SharedPreferencesUtils.putSharedPreference(this, APIUtils.SP_KEY_TOKEN, token);

        // When login works, the user should be lead to the main screen of the application.
        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
    }

    /**
     * This method is called when the login webservice terminated with an error.
     * Depending on the nature of the error, a different message should be displayed.
     *
     * @param status the status code of the webservice response
     */
    @Override
    public void onLoginFail(int status) {
        mProgress.dismiss();
        switch (status) {
            case APIUtils.NO_HTTP:
                AppUtils.toast(this, getString(R.string.error_noResponse));
                break;
            case APIUtils.HTTP_FORBIDDEN:
                AppUtils.toast(this, getString(R.string.error_invalidCredentials));
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
    }

    /**
     * Clears all fields on screen of errors that might have popped up
     * when the user attempted to log in.
     */
    private void clearErrorsOnFields() {
        for (EditText field : mFields) {
            field.setError(null);
        }
    }

    /**
     * Clears all fields of their text.
     */
    private void clearFields() {
        for (EditText field : mFields) {
            field.getText().clear();
        }
    }

    /**
     * Checks all fields on screen to see if one of them is empty.
     * All fields are required, so if there is one that is empty, this method
     * sets an error on this field.
     *
     * @return the first empty {@link View}, or null if all fields are filled.
     */
    private View getFirstEmptyField() {
        View empty = null;
        for (EditText field : mFields) {
            if (TextUtils.isEmpty(field.getText().toString())) {
                field.setError(getString(R.string.error_field_required));
                empty = field;
                break;
            }
        }

        return empty;
    }

    /**
     * Makes a call to {@link WBLogin} in order to authenticate the user.
     */
    private void attemptLogin() {
        // We have to make sure all fields are filled first.
        View focusView = this.getFirstEmptyField();
        if (focusView != null) {
            return;
        }

        // Show a dialog for the user to know the login
        // process is active.
        mProgress = new ProgressDialog(this);
        mProgress.setTitle(getString(R.string.title_connection));
        mProgress.setMessage(getString(R.string.message_connect));
        mProgress.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        mProgress.setCancelable(false);
        mProgress.show();

        // Get all required values before clearing the fields
        // that contained them.
        String username = mUsernameField.getText().toString();
        String password = mPasswordField.getText().toString();
        this.clearFields();

        /*
          In OAuth2, authentication is done with URL-encoded
          parameters. Using the {@link AppUtils} class,
          we encode a {@link Map} object into a URL-encoded
          string.
         */
        Map<String, Object> map = new HashMap<>();
        map.put(KEY_GRANT_TYPE, "password");
        map.put(KEY_USERNAME, username);
        map.put(KEY_PASSWORD, password);
        String body = AppUtils.getURLFormEncodedFromMap(map);

        // The login process actually starts here.
        if (!TextUtils.isEmpty(body)) {
            WBLogin task = new WBLogin();
            task.setILogin(this);
            task.execute(body);
        }
    }
}
