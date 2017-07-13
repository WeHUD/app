package esgi.project.wehud.activity;

import android.app.ProgressDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import esgi.project.wehud.R;
import esgi.project.wehud.dialog.DatePickerDialogFragment;
import esgi.project.wehud.model.User;
import esgi.project.wehud.utils.APIUtils;
import esgi.project.wehud.utils.AppUtils;
import esgi.project.wehud.utils.GSONUtils;
import esgi.project.wehud.utils.JSONUtils;
import esgi.project.wehud.webservices.WBRegister;

/**
 * This class is used for registering a new user into the application.
 *
 * @author Olivier Gonçalves
 */
public class RegisterActivity extends AppCompatActivity
        implements View.OnClickListener, WBRegister.IRegister, DatePickerDialogFragment.OnDatePickListener {

    private ProgressDialog mProgress;
    private TextView mDateOfBirthField;
    private EditText mEmailField;
    private EditText mUsernameField;
    private EditText mPasswordField;
    private EditText mConfirmPasswordField;
    private EditText[] mFields;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        setTitle(getString(R.string.title_register));

        mDateOfBirthField = (TextView) findViewById(R.id.register_dateOfBirth);
        mEmailField = (EditText) findViewById(R.id.register_email);
        mUsernameField = (EditText) findViewById(R.id.register_username);
        mPasswordField = (EditText) findViewById(R.id.register_password);
        mConfirmPasswordField = (EditText) findViewById(R.id.register_confirmPassword);
        Button createAccountButton = (Button) findViewById(R.id.register_btnCreateAccount);

        mDateOfBirthField.setOnClickListener(this);
        createAccountButton.setOnClickListener(this);

        mFields = new EditText[]{mEmailField, mUsernameField, mPasswordField, mConfirmPasswordField};

    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.register_btnCreateAccount:
                this.clearErrorsOnFields();
                this.attemptRegister();
                break;
            case R.id.register_dateOfBirth:
                this.generateDatePickerDialog();
                break;
            default:
                break;
        }
    }

    @Override
    public void onRegisterSuccess() {
        mProgress.dismiss();
        AppUtils.toast(this, getString(R.string.message_registerSuccess));
        finish();
    }

    @Override
    public void onRegisterFail(int status) {
        mProgress.dismiss();
        switch (status) {
            case APIUtils.NO_HTTP:
                AppUtils.toast(this, getString(R.string.error_noResponse));
                break;
            case APIUtils.HTTP_SERVER_ERROR:
                AppUtils.toast(this, getString(R.string.error_server));
                break;
            default:
                break;
        }
    }

    @Override
    public void onDatePick(int year, int month, int day) {
        final Calendar c = Calendar.getInstance();
        c.set(year, month, day);
        Date newDate = c.getTime();
        DateFormat formatter = DateFormat.getDateInstance(DateFormat.SHORT);
        mDateOfBirthField.setText(formatter.format(newDate));
    }

    private void clearErrorsOnFields() {
        for (EditText field : mFields) {
            field.setError(null);
        }
    }

    private void clearFields() {
        for (EditText field : mFields) {
            field.getText().clear();
        }
    }

    private View getFirstEmptyField() {
        View empty = null;
        for (EditText field : mFields) {
            if (TextUtils.isEmpty(field.getText().toString())) {
                field.setError(getString(R.string.error_field_required));
                empty = field;
                break;
            }
        }

        if (!mPasswordField.getText().toString().equals(mConfirmPasswordField.getText().toString())) {
            mPasswordField.setError(getString(R.string.error_passwords_no_match));
            mConfirmPasswordField.setError(getString(R.string.error_passwords_no_match));
            empty = mPasswordField;
        }

        return empty;
    }

    private void generateDatePickerDialog() {
        DatePickerDialogFragment datePickerDialog = DatePickerDialogFragment.newInstance();
        datePickerDialog.setOnDatePickListener(this);
        datePickerDialog.show(getSupportFragmentManager(), getClass().getName());
    }

    private void attemptRegister() {
        View focusView = this.getFirstEmptyField();
        if (focusView != null) {
            return;
        }

        mProgress = new ProgressDialog(this);
        mProgress.setTitle(getString(R.string.title_connection));
        mProgress.setMessage(getString(R.string.message_connect));
        mProgress.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        mProgress.setCancelable(false);
        mProgress.show();

        String avatar = APIUtils.IMAGES[0];
        String username = mUsernameField.getText().toString();
        String reply = '@' + username;
        String email = mEmailField.getText().toString();
        String dob = mDateOfBirthField.getText().toString();
        Date dateOfBirth = AppUtils.getISODate(dob);
        String password = mPasswordField.getText().toString();

        this.clearFields();

        User newUser = new User();
        newUser.setAvatar(avatar);
        newUser.setUsername(username);
        newUser.setReply(reply);
        newUser.setEmail(email);
        newUser.setDateOfBirth(dateOfBirth);
        newUser.setDob(dob);
        newUser.setPassword(password);

        String body = GSONUtils.getInstance().toJson(newUser, User.class);

        WBRegister task = new WBRegister();
        task.setIRegister(this);
        task.execute(body);
    }
}
