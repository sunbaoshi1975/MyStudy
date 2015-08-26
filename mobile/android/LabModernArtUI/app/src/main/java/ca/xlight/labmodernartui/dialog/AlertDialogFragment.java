package ca.xlight.labmodernartui.dialog;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.os.Bundle;

import ca.xlight.labmodernartui.R;
import ca.xlight.labmodernartui.interfaces.MainInterface;

/**
 * Created by sunboss on 8/25/2015.
 */
// Class that creates the AlertDialog
public class AlertDialogFragment extends DialogFragment {

    public static AlertDialogFragment newInstance() {
        return new AlertDialogFragment();
    }

    // Build AlertDialog using AlertDialog.Builder
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        return new AlertDialog.Builder(getActivity())
                .setMessage(R.string.msg_dialog_visit_moma)

                        // User cannot dismiss dialog by hitting back button
                .setCancelable(false)

                        // Set up No Button
                .setNegativeButton(R.string.btn_not_now,
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog,
                                                int id) {
                                // Dismiss me
                                dismiss();
                            }
                        })

                        // Set up Yes Button
                .setPositiveButton(R.string.btn_visit_url,
                        new DialogInterface.OnClickListener() {
                            public void onClick(
                                    final DialogInterface dialog, int id) {

                                // Open browser with an URL
                                ((MainInterface)getActivity()).startImplicitActivation();

                                // Dismiss me
                                dismiss();
                            }
                        }).create();
    }
}