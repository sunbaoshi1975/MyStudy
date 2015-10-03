package ca.xlight.labdailyselfie;

import android.graphics.Bitmap;

/**
 * Created by sunboss on 10/1/2015.
 */
public class PictureRecord {

    private String mFileName;
    private String mDescription;
    private Bitmap mThumbnail;

    public PictureRecord(Bitmap thumbNail, String fileName, String description) {

        this.mThumbnail = thumbNail;
        this.mFileName = fileName;
        this.mDescription = description;
    }

    public PictureRecord() {
    }

    public Bitmap getThumbnail() {
        return mThumbnail;
    }

    public void setThumbnail(Bitmap thumbnail) {
        this.mThumbnail = thumbnail;
    }

    public String getFileName() {
        return mFileName;
    }

    public void setFileName(String fileName) {
        this.mFileName = fileName;
    }

    public String getDescription() {
        return mDescription;
    }

    public void setDescription(String description) {
        this.mDescription = description;
    }

    @Override
    public String toString(){
        return "Picture: " + mFileName + " Desc: " + mDescription;

    }
}
