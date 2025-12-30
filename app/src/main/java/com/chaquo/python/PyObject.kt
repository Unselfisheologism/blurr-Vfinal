package com.chaquo.python

/**
 * Minimal stub for Chaquopy's PyObject.
 */
open class PyObject {

    open fun callAttr(name: String, vararg args: Any?): PyObject {
        throw UnsupportedOperationException("Chaquopy is not available in this build.")
    }

    open fun put(name: String, value: Any?) {
        throw UnsupportedOperationException("Chaquopy is not available in this build.")
    }

    override fun toString(): String {
        return "<PyObject stub>"
    }
}
