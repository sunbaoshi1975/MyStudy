package ca.xlight.labmodernartui.activity;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.SeekBar;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import ca.xlight.labmodernartui.R;
import ca.xlight.labmodernartui.dialog.AlertDialogFragment;
import ca.xlight.labmodernartui.interfaces.MainInterface;

public class MainActivity extends AppCompatActivity implements MainInterface {

    // Identifier for each type of Dialog
    private static final int ALERTTAG = 0;

    static private final String URL = "http://www.MoMA.org/visit/films";
    // For use with app chooser
    static private final String CHOOSER_TEXT = "Load " + URL + " with:";

    private final List<View> mShapes = new ArrayList<View>();
    //private static final String TAG = "Lab-ModernArtUI";
    private static final String TAG = MainActivity.class.getName();
    private int m_nOldProgress = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Get SeekBar and reset it to 0 position
        SeekBar mSeekBar = (SeekBar)findViewById(R.id.seekBarColor);
        mSeekBar.setProgress(m_nOldProgress);

        // Add all color shapes into the list
        mShapes.add((View)findViewById(R.id.shape_left_1));
        mShapes.add((View)findViewById(R.id.shape_left_2));
        mShapes.add((View)findViewById(R.id.shape_right_1));
        mShapes.add((View)findViewById(R.id.shape_right_2));
        mShapes.add((View)findViewById(R.id.shape_right_3));

        // Initialize the colors for all shapes
        // 1. Random set color for each item
        // 2. Random pick up one item and set whose color to COLOR_WHITE
        int nShapeCnt = mShapes.size();
        int nLuckyNum = (int)(Math.random() * nShapeCnt);
        int nColor_R, nColor_G, nColor_B;
        final int[] mOriginalColors = new int[nShapeCnt];
        for( int nLoop = 0; nLoop < nShapeCnt; nLoop++ ) {
            if( nLoop == nLuckyNum ) {
                mOriginalColors[nLoop] = Color.WHITE;
            } else {
                nColor_R = (int)(Math.random() * 256);
                nColor_G = (int)(Math.random() * 256);
                nColor_B = (int)(Math.random() * 256);
                mOriginalColors[nLoop] = Color.rgb(nColor_R, nColor_G, nColor_B);
            }

            //mShapes.get(nLoop).setBackgroundColor(mOriginalColors[nLoop]);
            setRectColor(mShapes.get(nLoop), mOriginalColors[nLoop]);
        }

        mSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                Log.i(TAG, "Entered onProgressChanged(), progress = " + progress);

                // Change shapes‘ color
                /// 1. leave shapes with color WRITE or BLACK
                /// 2. otherwise, shift rgb w.r.t. the progress
                int nShapeCnt = mShapes.size();
                int nColor_R, nColor_G, nColor_B;
                int nNewColor;
                for( int nLoop = 0; nLoop < nShapeCnt; nLoop++ ) {
                    if( mOriginalColors[nLoop] == Color.WHITE || mOriginalColors[nLoop] == Color.BLACK )
                        continue;
                    else
                        nColor_R = Color.rgb( (Color.red(mOriginalColors[nLoop]) + progress) % 256,
                            (Color.green(mOriginalColors[nLoop]) + progress) % 256,
                            (Color.blue(mOriginalColors[nLoop]) + progress) % 256);

                    //mShapes.get(nLoop).setBackgroundColor(nColor_R);
                    setRectColor(mShapes.get(nLoop), nColor_R);
                }
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                Log.i(TAG, "Entered onStopTrackingTouch(), from " +
                        m_nOldProgress + ", to " + seekBar.getProgress());
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                Log.i(TAG, "Entered onStartTrackingTouch(), current progress = " +
                        seekBar.getProgress() + ", previous old progress = " + m_nOldProgress);

                // Record old progress
                m_nOldProgress = seekBar.getProgress();
            }
        });
    }

    private void setRectColor(View rect, int color) {
        GradientDrawable bg = new GradientDrawable();
        int border = (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, 3, getResources().getDisplayMetrics());
        bg.setStroke(border, Color.BLACK);
        bg.setColor(color);
        rect.setBackground(bg);
    }

    private int getRandomColorWithSeed(int seed) {
        Random r = new Random(seed);
        return Color.parseColor("#" + Integer.toHexString(r.nextInt(0x00FFFFFF + 1)));
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {

            // Show my alert dialog
            showDialogFragment(ALERTTAG);

            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    // Show desired Dialog
    void showDialogFragment(int dialogID) {

        switch (dialogID) {

            // Show AlertDialog
            case ALERTTAG:

                // Create a new AlertDialogFragment
                DialogFragment mDialog;

                mDialog = AlertDialogFragment.newInstance();

                // Show AlertDialogFragment
                mDialog.show(getFragmentManager(), "@string/action_information");

                break;
        }
    }

    // Start a Browser Activity to view a web page or its URL
    public void startImplicitActivation() {

        Log.i(TAG, "Entered startImplicitActivation()");

        // TODO - Create a base intent for viewing a URL
        // (HINT:  second parameter uses Uri.parse())
        Intent baseIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(URL));

        // TODO - Create a chooser intent, for choosing which Activity
        // will carry out the baseIntent
        // (HINT: Use the Intent class' createChooser() method)
        Intent chooserIntent = Intent.createChooser(baseIntent, CHOOSER_TEXT);

        Log.i(TAG,"Chooser Intent Action:" + chooserIntent.getAction());

        // TODO - Start the chooser Activity, using the chooser intent
        if (baseIntent.resolveActivity(getPackageManager()) != null) {
            startActivity(chooserIntent);
        }
    }
}
