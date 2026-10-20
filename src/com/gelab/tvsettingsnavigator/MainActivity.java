package com.gelab.tvsettingsnavigator;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.os.Bundle;
import android.provider.Settings;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

/**
 * 仅发送四个标准设置 Intent，不写入任何设置，不执行 shell，不申请权限。
 * 不自动回退、不循环尝试：每个入口都必须由用户点击。
 */
public class MainActivity extends Activity {

    private TextView statusView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        statusView = findViewById(R.id.status);

        bind(R.id.btn_development, Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS, R.string.entry_development);
        bind(R.id.btn_device_info, Settings.ACTION_DEVICE_INFO_SETTINGS, R.string.entry_device_info);
        bind(R.id.btn_settings, Settings.ACTION_SETTINGS, R.string.entry_settings);
        bind(R.id.btn_wireless, Settings.ACTION_WIRELESS_SETTINGS, R.string.entry_wireless);

        findViewById(R.id.btn_development).requestFocus();
    }

    private void bind(int buttonId, final String action, final int entryLabelRes) {
        Button button = findViewById(buttonId);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                open(action, entryLabelRes);
            }
        });
    }

    private void open(String action, int entryLabelRes) {
        String entryLabel = getString(entryLabelRes);
        try {
            Intent intent = new Intent(action);
            startActivity(intent);
            // 只表示请求已发出，不代表页面一定存在，也不代表开发者/ADB 已被开启。
            statusView.setText(getString(R.string.status_sent, entryLabel));
        } catch (ActivityNotFoundException e) {
            statusView.setText(getString(R.string.status_not_found, entryLabel));
        } catch (Exception e) {
            statusView.setText(R.string.status_error);
        }
    }
}
