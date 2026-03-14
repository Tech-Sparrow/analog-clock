package com.techsparrow.analogclock;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    @Override
    public String getInitialRoute() {
        if (getIntent() != null && getIntent().getBooleanExtra("screensaver", false)) {
            return "/screensaver";
        }
        return null;
    }
}
