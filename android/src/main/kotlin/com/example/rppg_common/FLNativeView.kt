/*package com.example.rppg_common

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.platform.PlatformView


internal class FLNativeView(context: Context, id: Int,creationParams: Map<String?, Any?>?) : PlatformView {
    private val view : View

    override fun getView(): View {
        return view
    }

    override fun dispose() {}

    init {
        var frameLayout = FrameLayout(context)
        var lps = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT)
        frameLayout.layoutParams = lps
        Analysis.getInstance().rppgCameraView.layoutParams = lps
        frameLayout.addView(Analysis.getInstance().rppgCameraView)
        view = frameLayout
    }
} */

package com.example.rppg_common

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.plugin.platform.PlatformView

internal class FLNativeView(
    context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?
) : PlatformView {

    private val frameLayout: FrameLayout
    private val rppgCameraView: View = Analysis.getInstance().rppgCameraView

    override fun getView(): View {
        return frameLayout
    }

    override fun dispose() {
        (rppgCameraView.parent as? ViewGroup)?.removeView(rppgCameraView)
    }

    init {
        frameLayout = FrameLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )

            (rppgCameraView.parent as? ViewGroup)?.removeView(rppgCameraView)

            rppgCameraView.layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )

            addView(rppgCameraView)
        }
    }
}
