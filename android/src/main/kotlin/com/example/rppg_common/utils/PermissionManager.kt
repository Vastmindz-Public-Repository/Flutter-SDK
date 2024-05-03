package com.example.rppg_common.utils

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat


class PermissionManager {

    companion object {
        private const val VIDEO_PERMISSION = "video_permisson"
    }

    fun checkVideoPermission(activity: Activity, callback: (isGranted:Boolean) -> Unit) {
        val permissions = arrayOf(Manifest.permission.CAMERA)

        if (hasPermissionsGranted(activity, permissions)) {
            callback.invoke(true)
        } else {
            callback.invoke(false)
            activity.requestPermissions(permissions, 1)
        }
    }

    private fun hasPermissionsGranted(activity: Activity, permissions: Array<String>) =
        permissions.none {
            ContextCompat.checkSelfPermission(activity.baseContext, it) !=
                    PackageManager.PERMISSION_GRANTED
        }
}