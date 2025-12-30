package com.chaquo.python

import com.chaquo.python.android.AndroidPlatform

/**
 * Minimal stub for Chaquopy's Python runtime.
 *
 * This project includes Python tooling code, but does not bundle Chaquopy in the
 * default build. These stubs keep compilation working; attempting to execute Python
 * will throw at runtime.
 */
class Python private constructor() {

    fun getModule(name: String): PyObject {
        throw UnsupportedOperationException("Chaquopy is not available in this build.")
    }

    companion object {
        @JvmStatic
        fun isStarted(): Boolean = false

        @JvmStatic
        fun start(@Suppress("UNUSED_PARAMETER") platform: AndroidPlatform) {
            throw UnsupportedOperationException("Chaquopy is not available in this build.")
        }

        @JvmStatic
        fun getInstance(): Python {
            throw UnsupportedOperationException("Chaquopy is not available in this build.")
        }
    }
}
