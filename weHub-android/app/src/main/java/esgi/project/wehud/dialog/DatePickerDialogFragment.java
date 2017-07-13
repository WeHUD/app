package esgi.project.wehud.dialog;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.DatePicker;

import java.util.Calendar;

import esgi.project.wehud.R;

/**
 * This subclass of {@link DialogFragment} displays
 * a {@link DatePicker} widget to allow the user
 * to select a date.
 *
 * @author Olivier Gonçalves
 */
public final class DatePickerDialogFragment extends DialogFragment {

    private static OnDatePickListener mListener;

    public static DatePickerDialogFragment newInstance() {
        return new DatePickerDialogFragment();
    }

    public void setOnDatePickListener(OnDatePickListener listener) {
        mListener = listener;
    }

    @SuppressLint("InflateParams")
    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Context context = getActivity();

        Calendar cal = Calendar.getInstance();
        final int year = cal.get(Calendar.YEAR);
        final int month = cal.get(Calendar.MONTH);
        final int day = cal.get(Calendar.DAY_OF_MONTH);

        View headerView = LayoutInflater.from(context).inflate(R.layout.dialog_date_picker_header, null);
        View bodyView = LayoutInflater.from(context).inflate(R.layout.dialog_date_picker, null);

        final DatePicker picker = (DatePicker) bodyView.findViewById(R.id.picker);
        picker.init(year, month, day, null);

        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setCustomTitle(headerView);
        builder.setView(bodyView);
        builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                int year = picker.getYear();
                int month = picker.getMonth();
                int day = picker.getDayOfMonth();
                if (mListener != null) {
                    mListener.onDatePick(year, month, day);
                    dismiss();
                }
            }
        });
        builder.setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                dismiss();
            }
        });

        return builder.create();
    }

    public interface OnDatePickListener {
        void onDatePick(int i, int i1, int i2);
    }

}
