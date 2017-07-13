package esgi.project.wehud.dialog;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.text.InputType;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageButton;

import com.squareup.picasso.Picasso;

import esgi.project.wehud.R;
import esgi.project.wehud.utils.APIUtils;

/**
 * This subclass of {@link DialogFragment} displays
 * a list of {@link android.widget.ImageButton} for the
 * user to choose.
 *
 * @author Olivier Gonçalves
 */
public final class ImagePickerDialogFragment extends DialogFragment {

    private static final int PASSWORD_INVISIBLE = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD;
    private static final int PASSWORD_VISIBLE = InputType.TYPE_CLASS_TEXT;

    private static OnImagePickListener mListener;

    public static ImagePickerDialogFragment newInstance() {
        return new ImagePickerDialogFragment();
    }

    public void setOnImagePickListener(OnImagePickListener listener) {
        mListener = listener;
    }

    @SuppressLint("InflateParams")
    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        final Context context = getActivity();
        final View bodyView = LayoutInflater.from(context).inflate(R.layout.dialog_change_profile_image, null);
        final int[] imageId = {-1};

        ImageButton profile01 = (ImageButton) bodyView.findViewById(R.id.profile_01);
        ImageButton profile02 = (ImageButton) bodyView.findViewById(R.id.profile_02);
        ImageButton profile03 = (ImageButton) bodyView.findViewById(R.id.profile_03);
        ImageButton profile04 = (ImageButton) bodyView.findViewById(R.id.profile_04);

        ImageButton[] profiles = {profile01, profile02, profile03, profile04};
        for (int i = 0; i < profiles.length; ++i) {
            Picasso.with(context).load(APIUtils.IMAGES[i]).resize(256, 256).into(profiles[i]);
            profiles[i].setTag(i);
            profiles[i].setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    imageId[0] = (int) view.getTag();
                    String url = APIUtils.IMAGES[imageId[0]];
                    mListener.onImagePick(url);
                    dismiss();
                }
            });
        }

        final AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle(R.string.dialog_changeProfileImageTitle);
        builder.setView(bodyView);
        builder.setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                dismiss();
            }
        });
        return builder.create();
    }

    public interface OnImagePickListener {
        void onImagePick(String imageUrl);
    }
}
