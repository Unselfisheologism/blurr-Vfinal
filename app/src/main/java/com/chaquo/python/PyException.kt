package com.chaquo.python

/**
 * Minimal stub for Chaquopy's PyException.
 *
 * The real Chaquopy runtime is not bundled in this project. This stub exists so the
 * Android module can compile when Chaquopy isn't present.
 */
open class PyException(message: String? = null, cause: Throwable? = null) : RuntimeException(message, cause)
