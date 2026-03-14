package com.techsparrow.analogclock;

import android.content.Intent;
import android.service.dreams.DreamService;

/**
 * Android Daydream (Screen saver) service. When the user selects this app as screen saver
 * in Settings → Display → Screen saver, and the device is charging/docked, the system
 * starts this service. We launch the Flutter MainActivity in screen saver mode so the
 * clock is shown full screen with the screen kept on.
 */
public class ClockDreamService extends DreamService {

    @Override
    public void onDreamingStarted() {
        super.onDreamingStarted();
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        intent.putExtra("screensaver", true);
        startActivity(intent);
    }
}
