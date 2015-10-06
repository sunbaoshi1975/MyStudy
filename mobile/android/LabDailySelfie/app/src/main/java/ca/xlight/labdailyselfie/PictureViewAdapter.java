package ca.xlight.labdailyselfie;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.io.File;
import java.util.ArrayList;

/**
 * Created by sunboss on 10/1/2015.
 */
public class PictureViewAdapter extends BaseAdapter {
    private static final String TAG = "Lab-DailySelfie";
    private ArrayList<PictureRecord> list = new ArrayList<PictureRecord>();
    private static LayoutInflater inflater = null;
    private Context mContext;

    public PictureViewAdapter(Context context) {
        mContext = context;
        inflater = LayoutInflater.from(mContext);
    }

    public int getCount() {
        return list.size();
    }

    public Object getItem(int position) {
        return list.get(position);
    }

    public long getItemId(int position) {
        return position;
    }

    public View getView(int position, View convertView, ViewGroup parent) {

        View newView = convertView;
        ViewHolder holder;

        PictureRecord curr = list.get(position);

        if (null == convertView) {
            holder = new ViewHolder();
            newView = inflater
                    .inflate(R.layout.activity_main, parent, false);
            holder.thumbnail = (ImageView) newView.findViewById(R.id.thumbNail);
            holder.description = (TextView) newView.findViewById(R.id.txtDesc);
            //holder.fileName = (TextView) newView.findViewById(R.id.place_name);
            newView.setTag(holder);

        } else {
            holder = (ViewHolder) newView.getTag();
        }

        holder.thumbnail.setImageBitmap(curr.getThumbnail());
        holder.description.setText(curr.getDescription());
        //holder.fileName.setText(curr.getFileName());

        return newView;
    }

    static class ViewHolder {

        ImageView thumbnail;
        TextView fileName;
        TextView description;
    }

    public void add(PictureRecord listItem) {
        list.add(listItem);
        notifyDataSetChanged();
    }

    public void delete(int position) {
        // delete file
        PictureRecord curr = list.get(position);
        String filePath = curr.getFileName();
        File storageDir = new File(filePath);
        Log.d(TAG, "will delete file: " + filePath);
        if (storageDir.exists()) {
            storageDir.delete();
        }

        // romeve item from list
        list.remove(position);
        notifyDataSetChanged();
    }

    public ArrayList<PictureRecord> getList() {
        return list;
    }

    public void removeAllViews() {
        deleteAllFilesRecursive(new File(MainActivity.picsDir));
        list.clear();
        this.notifyDataSetChanged();
    }

    private void deleteAllFilesRecursive(File fileOrDirectory) {
        if(fileOrDirectory.isDirectory()) {
            for(File child : fileOrDirectory.listFiles()) {
                deleteAllFilesRecursive(child);
            }
        }
        else {
            Log.d(TAG, "will delete file: " + fileOrDirectory.getPath());
            fileOrDirectory.delete();
        }
    }
}
