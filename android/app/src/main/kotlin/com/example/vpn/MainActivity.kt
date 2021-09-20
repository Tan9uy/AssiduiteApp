package com.example.vpn

import android.content.Intent
import com.topfreelancerdeveloper.flutter_openvpn.FlutterOpenvpnPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == 1) {
            if (resultCode == RESULT_OK){
                FlutterOpenvpnPlugin.setPermission(true);
            } else {
                FlutterOpenvpnPlugin.setPermission(false);
            }
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
