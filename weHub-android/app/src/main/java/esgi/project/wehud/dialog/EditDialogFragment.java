package esgi.project.wehud.dialog;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.text.Editable;
import android.text.InputType;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.TextView;

import esgi.project.wehud.R;

/**
 * This subclass of {@link DialogFragment} displays
 * one or several fields the user can interact with.
 *
 * @author Olivier Gonçalves
 */
public final class EditDialogFragment extends DialogFragment {

    private static final String KEY_VIEW_ID = "id";
    private static final String KEY_HINT = "hint";
    private static final String KEY_TITLE = "title";
    private static final String KEY_TEXT = "text";
    private static final String KEY_PASSWORD = "password";

    private static final int PASSWORD_INVISIBLE = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD;
    private static final int PASSWORD_VISIBLE = InputType.TYPE_CLASS_TEXT;

    private static OnEditListener mListener;

    public static EditDialogFragment newInstance() {
        return new EditDialogFragment();
    }

    public void setOnEditListener(OnEditListener listener) {
        mListener = listener;
    }

    @SuppressLint("InflateParams")
    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        final Context context = getActivity();
        final Bundle bundle = getArguments();
        final int viewId = bundle.getInt(KEY_VIEW_ID);
        final String[] text = {bundle.getString(KEY_TEXT)};
        final String title = bundle.getString(KEY_TITLE);
        final String hint = bundle.getString(KEY_HINT);
        final boolean isPassword = bundle.getBoolean(KEY_PASSWORD);

        final View headerView = LayoutInflater.from(context).inflate(R.layout.dialog_edit_header, null);
        final View bodyView = LayoutInflater.from(context).inflate(R.layout.dialog_edit, null);

        final TextView headerTitle = (TextView) headerView.findViewById(R.id.dialog_headerTitle);
        if (TextUtils.isEmpty(title)) {
            headerTitle.setText(hint);
        } else {
            headerTitle.setText(title);
        }

        final EditText bodyField = (EditText) bodyView.findViewById(R.id.dialog_editField);
        bodyField.setHint(hint);
        bodyField.setText(text[0]);
        bodyField.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                text[0] = bodyField.getText().toString();
            }
        });

        final EditText newPassword = (EditText) bodyView.findViewById(R.id.dialog_newPassword);
        final EditText confirmNewPassword = (EditText) bodyView.findViewById(R.id.dialog_confirmNewPassword);
        final CheckBox showPasswordBox = (CheckBox) bodyView.findViewById(R.id.dialog_boxShowPassword);
        if (isPassword) {
            bodyField.setInputType(PASSWORD_INVISIBLE);
            showPasswordBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
                    if (checked) {
                        bodyField.setInputType(PASSWORD_VISIBLE);
                    } else {
                        bodyField.setInputType(PASSWORD_INVISIBLE);
                    }
                }
            });
        } else {
            newPassword.setVisibility(View.GONE);
            confirmNewPassword.setVisibility(View.GONE);
            showPasswordBox.setVisibility(View.GONE);
        }

        final AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setCustomTitle(headerView);
        builder.setView(bodyView);
        builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                if (mListener != null && !TextUtils.isEmpty(bodyField.getText().toString())) {
                    if (isPassword) {
                        if (!newPassword.getText().toString().equals(confirmNewPassword.getText().toString())) {
                            newPassword.setError(getString(R.string.error_passwords_no_match));
                            confirmNewPassword.setError(getString(R.string.error_passwords_no_match));
                            return;
                        }
                        text[0] = newPassword.getText().toString();
                    }
                    mListener.onEdit(viewId, text[0]);
                }
                dismiss();
            }
        });
        builder.setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                dismiss();
            }
        });
        return builder.create();
    }

    public interface OnEditListener {
        void onEdit(int textId, String text);
    }
}
