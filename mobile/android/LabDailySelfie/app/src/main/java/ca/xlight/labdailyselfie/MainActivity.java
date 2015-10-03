package ca.xlight.labdailyselfie;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.app.AlarmManager;
import android.app.AlertDialog;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.app.ListActivity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.SystemClock;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.Toast;

public class MainActivity extends ListActivity {
    private static final String TAG = "Lab-DailySelfie";
    private static final String SETTINGS_SIZE = "size";
    private static final long TWO_MINS = 2 * 60 * 1000;     // two minutes
    static final int REQUEST_TAKE_PHOTO = 1;

    private PictureViewAdapter mAdapter;
    private String mCurrentPhotoPath;
    private String mCurrentPhotoTimeStamp;
    private SharedPreferences mSharedPref;

    private Intent mNotificationReceiverIntent;
    private PendingIntent mNotificationReceiverPendingIntent;
    private AlarmManager mAlarmManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Create Alarm
        mAlarmManager = (AlarmManager)getSystemService(ALARM_SERVICE);
        mNotificationReceiverIntent = new Intent(MainActivity.this, AlarmNotificationReceiver.class);
        mNotificationReceiverPendingIntent = PendingIntent.getBroadcast(
                MainActivity.this, 0, mNotificationReceiverIntent, 0);
        mAlarmManager.setRepeating(AlarmManager.ELAPSED_REALTIME,
                SystemClock.elapsedRealtime() + TWO_MINS, TWO_MINS,
                mNotificationReceiverPendingIntent);

        // Initialize ListView
        mSharedPref = getPreferences(Context.MODE_PRIVATE);
        ListView picturesListView = getListView();
        picturesListView.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                try {
                    PictureRecord curr = (PictureRecord) mAdapter.getItem(position);
                    if (null !=curr)
                        ShowBigPicture(curr.getFileName());
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        // Long push to have more operations on current record: Open, Delete, Cancel
        picturesListView.setOnItemLongClickListener(new OnItemLongClickListener() {
            @Override
            public boolean onItemLongClick(AdapterView<?> parent, View view, final int position, long id) {
                final CharSequence[] options = {"Open", "Delete", "Cancel"};
                AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
                builder.setTitle("Choose Operation");
                builder.setItems(options, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int item) {
                        if (options[item].equals("Open")) {
                            PictureRecord curr = (PictureRecord) mAdapter.getItem(position);
                            if (null !=curr)
                                ShowBigPicture(curr.getFileName());
                        }
                        else if (options[item].equals("Delete")) {
                            // update SharedPreferences
                            mAdapter.delete(position);
                            UpdateSharedPreferences();
                        }
                        else if (options[item].equals("Cancel")) {
                            dialog.dismiss();
                        }
                    }
                });
                builder.show();

                return false;
            }
        });

        mAdapter = new PictureViewAdapter(getApplicationContext());
        LoadRecords();
        setListAdapter(mAdapter);
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
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
        if (id == R.id.action_take_pic) {
            dispatchTakePictureIntent();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_TAKE_PHOTO && resultCode == RESULT_OK) {
            // add new picture record
            //Bundle extras = data.getExtras();
            //Bitmap bitmap = (Bitmap) extras.get("data");
            Bitmap bitmap = (mCurrentPhotoPath.equals("") ? null : setPic(160, 120, mCurrentPhotoPath));

            if (mCurrentPhotoPath != null) {
                Log.i(TAG, "Add record: " + mCurrentPhotoPath);
                AddOneRecord(bitmap, mCurrentPhotoPath, mCurrentPhotoTimeStamp);
                AppendSharedPreference(mCurrentPhotoPath, mCurrentPhotoTimeStamp);
                //galleryAddPic();
                mCurrentPhotoPath = null;
            }
        }
    }

    private void AddOneRecord(Bitmap bitmap, String fileName, String description) {
        PictureRecord curr = new PictureRecord(bitmap, fileName, description);
        mAdapter.add(curr);
    }

    private void LoadRecords() {
        if (null == mSharedPref)
            return;

        int size = mSharedPref.getInt(SETTINGS_SIZE, 0);
        for (int pos = 0; pos < size; pos++) {
            String fileName = mSharedPref.getString(pos + "_FileName", "");
            String description = mSharedPref.getString(pos + "_Desc", "");
            Bitmap bitmap = (fileName.equals("") ? null : setPic(80, 60, fileName));
            AddOneRecord(bitmap, fileName, description);
        }
    }

    private void UpdateSharedPreferences() {
        if (null == mSharedPref)
            return;

        SharedPreferences.Editor editor = mSharedPref.edit();
        editor.clear();
        int size = mAdapter.getCount();
        editor.putInt(SETTINGS_SIZE, size);
        for (int pos = 0; pos < size; pos++) {
            PictureRecord curr = (PictureRecord) mAdapter.getItem(pos);
            editor.putString(pos + "_FileName", curr.getFileName());
            editor.putString(pos + "_Desc", curr.getDescription());
        }
        editor.commit();
    }

    private void AppendSharedPreference(String fileName, String description) {
        if (null == mSharedPref)
            return;

        SharedPreferences.Editor editor = mSharedPref.edit();
        editor.putInt("size", mAdapter.getCount());
        editor.putString((mAdapter.getCount() - 1) + "_FileName", fileName);
        editor.putString((mAdapter.getCount() - 1) + "_Desc", description);
        editor.commit();
    }

    private void ShowBigPicture(String fileName) {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        intent.setDataAndType(Uri.parse("file://" + fileName), "image/*");
        startActivity(intent);
    }

    private File createImageFile() throws IOException {
        // Create an image file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "JPEG_" + timeStamp + "_";
        File storageDir;
        //if (Environment.getExternalStorageState() != Environment.MEDIA_MOUNTED) {
        //    storageDir = getCacheDir();
        //} else {
        //    storageDir = Environment.getExternalStoragePublicDirectory(
        //            Environment.DIRECTORY_PICTURES);
        //}
        storageDir = getExternalCacheDir();
        //Toast.makeText(MainActivity.this, "External file: " + storageDir, Toast.LENGTH_LONG).show();

        File image = File.createTempFile(
                imageFileName,  /* prefix */
                ".jpg",         /* suffix */
                storageDir      /* directory */
        );

        // Save a file: path for use with ACTION_VIEW intents
        //mCurrentPhotoPath = "file:" + image.getAbsolutePath();
        mCurrentPhotoPath = image.getAbsolutePath();
        mCurrentPhotoTimeStamp = timeStamp;
        return image;
    }

    private void dispatchTakePictureIntent() {
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        // Ensure that there's a camera activity to handle the intent
        if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
            // Create the File where the photo should go
            File photoFile = null;
            try {
                photoFile = createImageFile();
            } catch (IOException ex) {
                // Error occurred while creating the File
                mCurrentPhotoPath = null;
                photoFile = null;

                Toast.makeText(MainActivity.this, "Failed to create external file!", Toast.LENGTH_LONG).show();
            }
            // Continue only if the File was successfully created
            if (photoFile != null) {
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT,
                        Uri.fromFile(photoFile));
                startActivityForResult(takePictureIntent, REQUEST_TAKE_PHOTO);
            }
        }
    }

    private void galleryAddPic() {
        Intent mediaScanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
        File f = new File(mCurrentPhotoPath);
        Uri contentUri = Uri.fromFile(f);
        mediaScanIntent.setData(contentUri);
        this.sendBroadcast(mediaScanIntent);
    }

    private Bitmap setPic(int targetW, int targetH, String photoPath) {
        // Get the dimensions of the View
        //int targetW = imgView.getWidth();
        //int targetH = imgView.getHeight();

        // Get the dimensions of the bitmap
        BitmapFactory.Options bmOptions = new BitmapFactory.Options();
        bmOptions.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(photoPath, bmOptions);
        int photoW = bmOptions.outWidth;
        int photoH = bmOptions.outHeight;

        // Determine how much to scale down the image
        int scaleFactor = Math.min(photoW/targetW, photoH/targetH);

        // Decode the image file into a Bitmap sized to fill the View
        bmOptions.inJustDecodeBounds = false;
        bmOptions.inSampleSize = scaleFactor;
        bmOptions.inPurgeable = true;

        Bitmap bitmap = BitmapFactory.decodeFile(photoPath, bmOptions);
        //imgView.setImageBitmap(bitmap);

        return bitmap;
    }
}
