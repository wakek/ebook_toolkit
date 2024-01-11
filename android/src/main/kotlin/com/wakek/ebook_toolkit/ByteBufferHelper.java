package com.wakek.ebook_toolkit;

import java.nio.ByteBuffer;

class ByteBufferHelper {
    static {
        try {

            System.loadLibrary("bbhelper");

        } catch (UnsatisfiedLinkError e) {
            System.err.println("Native code library failed to load.\n" + e);
            System.exit(1);
        }
    }

    public static native ByteBuffer newDirectBuffer(long ptr, long size);
    public static native long malloc(long size);
    public static native void free(long ptr);
}
