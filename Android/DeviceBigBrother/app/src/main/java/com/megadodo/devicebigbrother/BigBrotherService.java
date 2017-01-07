package com.megadodo.devicebigbrother;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Location;
import android.location.LocationManager;
import android.os.AsyncTask;
import android.os.IBinder;
import android.util.Base64;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Date;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;


public class BigBrotherService extends Service {

    public static final String PREFS_NAME = "DeviceID";
    public String mDeviceID = "";

    protected String hostname = "myhostname";
    protected int port = 80;
    protected String URI = "/DeviceBigBrother/track.php";

    private class SendToBackendHTTP extends AsyncTask {

        @Override
        protected Object doInBackground(Object[] params) {
            String url = (String) params[0];
            String header = (String) params[1];
            String headerValue = (String) params[2];
            String payload = (String) params[3];
            HttpURLConnection urlConnection = null;

            try {
                URL request = new URL(url);
                urlConnection = (HttpURLConnection) request.openConnection();
                urlConnection.setRequestProperty(header, headerValue);

                Log.i("BigBrotherService", url);
                Log.i("BigBrotherService", header + ":" + headerValue);
                Log.i("BigBrotherService", payload);

                InputStream in = new BufferedInputStream(urlConnection.getInputStream());
                // readStream(in);
            } catch (MalformedURLException e) {
                Log.e("BigBrotherService", "MalformedURL:" + e.toString());
            } catch (IOException e) {
                Log.e("BigBrotherService", "IOException:" + e.toString());
            } catch (Exception e) {
                Log.e("BigBrotherService", "Error:" + e.toString());
            } finally {
                urlConnection.disconnect();
            }

            return null;
        }
    };

    public BigBrotherService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        throw new UnsupportedOperationException("Not yet implemented");
    }

    public static String genHash(String aMessage) {
        String secret = "MySecret";
        byte[] hash = null;

        try {
            Mac sha256_HMAC = Mac.getInstance("HmacSHA256");
            SecretKeySpec secret_key = new SecretKeySpec(secret.getBytes(), "HmacSHA256");
            sha256_HMAC.init(secret_key);

            hash = Base64.encode(sha256_HMAC.doFinal(aMessage.getBytes()), Base64.DEFAULT);
            Log.v("BigBrotherService", "Hash is " + hash);
        }
        catch (Exception e){
            Log.e("BigBrotherService", "Hash gen is error " + e.getMessage());
        }

        return new String(hash);
    }


    public Runnable ping = new Runnable() {

        @Override
        public void run() {

            if (!mDeviceID.contentEquals("")) {
                Log.v("BigBrotherService", "Big Brother Started for DeviceID " + mDeviceID);

                LocationManager manager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
                Location loc = null;
                double lat = 0;
                double lon = 0;
                String model = "";
                String hash = "";
                Date d = new Date();
                String url = "";
                String header = "";
                String headerValue = "";

                try {
                    loc = manager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);

                    lat = loc.getLatitude();
                    lon = loc.getLongitude();
                    model = URLEncoder.encode(android.os.Build.MODEL);
                    long ts = d.getTime() / 1000;
                    hash = genHash(Long.toString(ts));

                    Log.v("BigBrotherService", "deviceID:" + mDeviceID + " lat:" + lat + " lon:" + lon +
                            " model:" + model + " ts:" + ts + " hash:" + hash);

                    url = "http://" + hostname + ":" + port + URI + "?deviceID=" + mDeviceID +
                            "&lat=" + lat + "&lon=" + lon + "&model=" + model + "&ts=" + ts;
                    header = "Authorization";
                    headerValue = hash;

                } catch (SecurityException e) {
                    Log.e("BigBrotherService", "Unable to getLastKnownLocation:" + e.getMessage());
                } catch (Exception e) {
                    Log.e("BigBrotherService", "Error:" + e.toString());
                }
                new SendToBackendHTTP().execute(url, header, headerValue, "");
            }
        }

    };

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        //TODO do something useful
        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
        mDeviceID = settings.getString("deviceID", "");

        this.ping.run();
        this.stopSelf();

        return Service.START_NOT_STICKY;
    }
}
