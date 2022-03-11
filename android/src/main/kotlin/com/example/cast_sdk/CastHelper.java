package com.example.cast_sdk;

import android.app.Activity;

import com.connectsdk.discovery.DiscoveryManager;
import com.connectsdk.service.DIALService;

import static com.connectsdk.ConstantKt.checkVideoCapacityAction;
import static com.connectsdk.ConstantKt.loadVideoAction;
import static com.connectsdk.ConstantKt.methodChannelName;
import static com.connectsdk.ConstantKt.onLogListener;
import static com.connectsdk.ConstantKt.pauseAction;
import static com.connectsdk.ConstantKt.playAction;
import static com.connectsdk.ConstantKt.startConnectAction;
import static com.connectsdk.ConstantKt.startDiscoverAction;
import static com.connectsdk.ConstantKt.stopAction;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.text.InputType;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.EditText;

import androidx.annotation.NonNull;

import com.connectsdk.core.MediaInfo;
import com.connectsdk.device.ConnectableDevice;
import com.connectsdk.device.ConnectableDeviceListener;
import com.connectsdk.device.DevicePicker;
import com.connectsdk.discovery.DiscoveryManager;
import com.connectsdk.service.DIALService;
import com.connectsdk.service.DeviceService;
import com.connectsdk.service.capability.MediaControl;
import com.connectsdk.service.capability.MediaPlayer;
import com.connectsdk.service.capability.listeners.ResponseListener;
import com.connectsdk.service.command.ServiceCommandError;
import com.connectsdk.service.sessions.LaunchSession;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CastHelper implements MethodChannel.MethodCallHandler {

    private MethodChannel channel;
    private Activity activity;
    private String URL_VIDEO_MP4 =
            "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/genesis/video-genesis-l07-ch6-ch7.mp4";
    private String URL_IMAGE_ICON = "http://connectsdk.com/ConnectSDK_Logo.jpg";


    private ConnectableDevice mTV;
    private AlertDialog dialog;
    private AlertDialog pairingAlertDialog;
    private AlertDialog pairingCodeDialog;
    private DevicePicker dp;

    private DiscoveryManager mDiscoveryManager;

    private MediaPlayer mediaPlayer;


    LaunchSession launchSession;
    MediaControl mMediaControl;
    Timer refreshTimer;
    Boolean isPlaying = false;
    long totalTimeDuration = 0;
    int REFRESH_INTERVAL_MS = (int) TimeUnit.SECONDS.toMillis(1);

    void setUpMethodChannel(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), methodChannelName);
        channel.setMethodCallHandler(this);
    }

    void setUpActivity(Activity activity) {
        this.activity = activity;
    }

    void removeMethodChannel() {
        channel.setMethodCallHandler(null);

        if (dialog != null) {
            dialog.dismiss();
        }

        if (mTV != null) {
            mTV.disconnect();
        }
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

        switch (call.method) {
            case startDiscoverAction: {
                DIALService.registerApp("Levak");
                DiscoveryManager.init(activity);
                startDiscovery();
                result.success(true);
                break;
            }

            case startConnectAction: {
                hConnectToggle();
                break;
            }

            case checkVideoCapacityAction: {
                if (mTV != null) {
                    result.success(mTV.hasCapability(MediaPlayer.Play_Video));
                } else {
                    result.success(false);
                }
                break;
            }

            case loadVideoAction: {
                playVideo();
                break;
            }
            case playAction: {
                onPlay();
            }


            case pauseAction: {
                onPause();
                break;
            }
            case stopAction: {
                onStop();
                break;
            }
//            closeAction -> {
//                onClose();
//            }
//
//            fastForwardAction -> {
//                onFastForward();
//            }
//
//            seekAction -> {
//                onSeekBarMoved(call.arguments);
//            }
            default: {

            }
        }
    }

    private void startDiscovery() {
        printLog("Start Discovery");
        setupPicker();

        mDiscoveryManager = DiscoveryManager.getInstance();
        mDiscoveryManager.registerDefaultDeviceTypes();
        mDiscoveryManager.setPairingLevel(DiscoveryManager.PairingLevel.ON);

        DiscoveryManager.getInstance().start();

    }

    private void setupPicker() {
        printLog("setupPicker");
        dp = new DevicePicker(activity);
        dialog = dp.getPickerDialog("Device List", new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {

                mTV = (ConnectableDevice) arg0.getItemAtPosition(arg2);
                mTV.addListener(deviceListener);
                mTV.setPairingType(null);
                mTV.connect();

                dp.pickDevice(mTV);
            }
        });

        pairingAlertDialog = new AlertDialog.Builder(activity , AlertDialog.THEME_DEVICE_DEFAULT_LIGHT)
                .setTitle("Pairing with TV")
                .setMessage("Please confirm the connection on your TV")
                .setPositiveButton("Okay", null)
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dp.cancelPicker();

                        hConnectToggle();
                    }
                })
                .create();

        final EditText input = new EditText(activity);
        input.setInputType(InputType.TYPE_CLASS_TEXT);

        final InputMethodManager imm = (InputMethodManager) activity.getSystemService(Context.INPUT_METHOD_SERVICE);

        pairingCodeDialog = new AlertDialog.Builder(activity, AlertDialog.THEME_DEVICE_DEFAULT_LIGHT)
                .setTitle("Enter Pairing Code on TV")
                .setView(input)
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface arg0, int arg1) {
                        if (mTV != null) {
                            String value = input.getText().toString().trim();
                            mTV.sendPairingKey(value);
                            imm.hideSoftInputFromWindow(input.getWindowToken(), 0);
                        }
                    }
                })
                .setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int whichButton) {
                        dp.cancelPicker();

                        hConnectToggle();
                        imm.hideSoftInputFromWindow(input.getWindowToken(), 0);
                    }
                })
                .create();
    }

    private ConnectableDeviceListener deviceListener = new ConnectableDeviceListener() {

        @Override
        public void onPairingRequired(ConnectableDevice device, DeviceService service, DeviceService.PairingType pairingType) {
            printLog("deviceListener onPairingRequired " + mTV.getIpAddress());
            switch (pairingType) {
                case FIRST_SCREEN:
                    Log.d("2ndScreenAPP", "First Screen");
                    pairingAlertDialog.show();
                    break;

                case PIN_CODE:
                case MIXED:
                    Log.d("2ndScreenAPP", "Pin Code");
                    pairingCodeDialog.show();
                    break;

                case NONE:
                default:
                    break;
            }
        }

        @Override
        public void onConnectionFailed(ConnectableDevice device, ServiceCommandError error) {
            printLog("deviceListener onConnectionFailed ");

            connectFailed(mTV);
        }

        @Override
        public void onDeviceReady(ConnectableDevice device) {
            printLog("deviceListener onDeviceReady ");

            if (pairingAlertDialog.isShowing()) {
                pairingAlertDialog.dismiss();
            }
            if (pairingCodeDialog.isShowing()) {
                pairingCodeDialog.dismiss();
            }
            registerSuccess(mTV);
        }

        @Override
        public void onDeviceDisconnected(ConnectableDevice device) {
            printLog("deviceListener onDeviceDisconnected  ");

            connectEnded(mTV);
        }

        @Override
        public void onCapabilityUpdated(ConnectableDevice device, List<String> added, List<String> removed) {

        }
    };

    public void hConnectToggle() {
        printLog("hConnectToggle call  ");

        if (!activity.isFinishing()) {
            if (mTV != null) {
                if (mTV.isConnected())
                    mTV.disconnect();

                mTV.removeListener(deviceListener);
                mTV = null;

            } else {
                dialog.show();
            }
        }
    }

    void registerSuccess(ConnectableDevice device) {
        printLog("successful register");

    }

    void connectFailed(ConnectableDevice device) {
        if (device != null)
            printLog("Failed to connect to " + device.getIpAddress());

        if (mTV != null) {
            mTV.removeListener(deviceListener);
            mTV.disconnect();
            mTV = null;
        }
    }

    void connectEnded(ConnectableDevice device) {
        if (pairingAlertDialog.isShowing()) {
            pairingAlertDialog.dismiss();
        }
        if (pairingCodeDialog.isShowing()) {
            pairingCodeDialog.dismiss();
        }
    }

    private void playVideo() {
        printLog("playVideo call");

//        Toast.makeText(getActivity(), "video click", Toast.LENGTH_SHORT).show();
//        boolean shouldLoop = loopingButton.isChecked();

//        SubtitleInfo.Builder subtitleBuilder = null;
//        if (subtitlesButton.isChecked()) {
//            subtitleBuilder = new SubtitleInfo.Builder(
//                    getTv().hasCapability(MediaPlayer.Subtitle_WebVTT) ? URL_SUBTITLES_WEBVTT :
//                            URL_SUBTITLE_SRT);
//            subtitleBuilder.setLabel("English").setLanguage("en");
//        }

        MediaInfo mediaInfo = new MediaInfo.Builder(URL_VIDEO_MP4, "video/mp4")
                .setTitle("Connect SDK")
                .setDescription("One SDK Eight Media Platforms")
                .setIcon(URL_IMAGE_ICON)
//                .setSubtitleInfo(subtitleBuilder == null ? null : subtitleBuilder.build())
                .build();

        printLog("playVideo call mtv " + mTV + " cap " + mTV.getCapability(MediaPlayer.class));
        mTV.getCapability(MediaPlayer.class).playMedia(mediaInfo, false, new MediaPlayer.LaunchListener() {

            @Override
            public void onError(ServiceCommandError error) {
                printLog("Error playing video " + error);
                stopMediaSession();
            }

            public void onSuccess(MediaPlayer.MediaLaunchObject object) {
                printLog("playing video onSuccess ");

                launchSession = object.launchSession;
                mMediaControl = object.mediaControl;
                stopUpdating();
                enableMedia();
                isPlaying = true;
            }
        });
    }

    public void enableMedia() {
        printLog("enableMedia");

        if (mTV.hasCapability(MediaControl.PlayState_Subscribe) && !isPlaying) {
            mMediaControl.subscribePlayState(playStateListener);
        } else {
            if (mMediaControl != null) {
                mMediaControl.getDuration(durationListener);
            }
            startUpdating();
        }
    }


    private void stopMediaSession() {
        printLog("stopMediaSession");

        // don't call launchSession.close() here, currently it can close
        // a different web app in WebOS
        if (launchSession != null) {
            launchSession = null;
            stopUpdating();
            disableMedia();
        }
    }

    private void startUpdating() {
        printLog("startUpdating");

        if (refreshTimer != null) {
            refreshTimer.cancel();
            refreshTimer = null;
        }
        refreshTimer = new Timer();
        refreshTimer.schedule(new TimerTask() {

            @Override
            public void run() {
                Log.d("LG", "Updating information");
                if (mMediaControl != null && mTV != null && mTV.hasCapability(MediaControl.Position)) {
                    mMediaControl.getPosition(positionListener);
                }

                if (mMediaControl != null
                        && mTV != null
                        && mTV.hasCapability(MediaControl.Duration)
                        && !mTV.hasCapability(MediaControl.PlayState_Subscribe)
                        && totalTimeDuration <= 0) {
                    mMediaControl.getDuration(durationListener);
                }
            }
        }, 0, REFRESH_INTERVAL_MS);
    }

    public MediaControl.PlayStateListener playStateListener = new MediaControl.PlayStateListener() {

        @Override
        public void onError(ServiceCommandError error) {
            printLog("playStateListener error " + error);
        }

        @Override
        public void onSuccess(MediaControl.PlayStateStatus playState) {
            printLog("playStateListener success " + playState);

            switch (playState) {
                case Playing:
                    startUpdating();

                    if (mMediaControl != null && mTV.hasCapability(MediaControl.Duration)) {
                        mMediaControl.getDuration(durationListener);
                    }
                    break;
                case Finished:

                default:
                    stopUpdating();
                    break;
            }
        }
    };


    private MediaControl.PositionListener positionListener = new MediaControl.PositionListener() {

        @Override
        public void onError(ServiceCommandError error) {
            printLog("positionListener error " + error);

        }

        @Override
        public void onSuccess(Long position) {
            printLog("positionListener position " + position);

        }
    };

    private MediaControl.DurationListener durationListener = new MediaControl.DurationListener() {

        @Override
        public void onError(ServiceCommandError error) {
            printLog("durationListener error " + error);

        }

        @Override
        public void onSuccess(Long duration) {
            printLog("durationListener success " + duration);

            totalTimeDuration = duration;
        }
    };


    private void stopUpdating() {
        printLog("stopUpdating");

        if (refreshTimer == null)
            return;

        refreshTimer.cancel();
        refreshTimer = null;
    }

    public void disableMedia() {
        printLog("disableMedia");

        stopMedia();
    }

    public void stopMedia() {
        totalTimeDuration = -1;
    }


    private void onPlay() {
        printLog("onPlay");
        if (mMediaControl != null) mMediaControl.play(null);
    }

    private void onPause() {
        printLog("onPause");
        if (mMediaControl != null) mMediaControl.pause(null);
    }

    private void onFastForward() {
        printLog("onFastForward");
        if (mMediaControl != null) mMediaControl.fastForward(null);
    }

    private void onClose() {
        if (mTV != null) {
            if (launchSession != null) launchSession.close(null);
            launchSession = null;
            stopMedia();
            stopUpdating();
            isPlaying = false;
        }
        printLog("onClose");

    }

    private void onStop() {
        printLog("onStop");

        if (mMediaControl != null) {
            mMediaControl.stop(new ResponseListener<Object>() {

                @Override
                public void onSuccess(Object response) {
                    printLog("onStop onSuccess");

                    stopMedia();
                    stopUpdating();
                    isPlaying = false;
                }

                @Override
                public void onError(ServiceCommandError error) {
                    printLog("onStop error " + error);

                }
            });
        }
    }

//    private void onSeekBarMoved(args: Any) {
//        printLog("onSeekBarMoved $args")
//
//        if ((args is Double) && mMediaControl != null && mTV?.hasCapability(MediaControl.Seek) == true) {
//            printLog("onSeekBarMoved start $args")
//            mMediaControl?.seek(args.toLong(), object : ResponseListener<Any?> {
//                override fun onSuccess(response: Any?) {
//                    printLog("Success on Seeking")
//                    startUpdating()
//                }
//
//                override fun onError(error: ServiceCommandError) {
//                    printLog("Unable to seek $error")
//                    startUpdating()
//                }
//            })
//        }
//    }

    private void printLog(String s) {
        Log.d("Tag", "===> $s ");
        channel.invokeMethod(onLogListener, s);
    }
}
