package com.megadodo.devicebigbrother;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity {

    public String mDeviceID = "";
    public static final String PREFS_NAME = "DeviceID";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // This part checks to see if permissions are given
        Toast toast = null;
        if ( ContextCompat.checkSelfPermission( this, android.Manifest.permission.ACCESS_COARSE_LOCATION ) != PackageManager.PERMISSION_GRANTED ) {
            toast = Toast.makeText(getApplicationContext(), "Please remember to enable Location", Toast.LENGTH_LONG);
            toast.show();
        }
        if ( Build.VERSION.SDK_INT >= 23 &&
                ContextCompat.checkSelfPermission( this, android.Manifest.permission.ACCESS_FINE_LOCATION ) != PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission( this, android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return  ;
        }

        final EditText inputBox = (EditText) findViewById(R.id.editText);

        Button submitButton = (Button) findViewById(R.id.button);

        // Restore preferences
        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
        mDeviceID = settings.getString("deviceID", "");
        inputBox.setText(mDeviceID);

        submitButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDeviceID = inputBox.getText().toString().trim();
                Log.v("MainActivity", "Setting Shared Preferences for " + mDeviceID);

                SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
                SharedPreferences.Editor editor = settings.edit();
                editor.putString("deviceID", mDeviceID);

                // Commit the edits!
                editor.commit();
            }
        });

        if (!mDeviceID.contentEquals("")) {
            Intent intent = new Intent(this, BigBrotherService.class);
            PendingIntent pingService = PendingIntent.getService(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
            AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
            alarmManager.cancel(pingService);
            alarmManager.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), 1000, pingService);
        }

    }
}
