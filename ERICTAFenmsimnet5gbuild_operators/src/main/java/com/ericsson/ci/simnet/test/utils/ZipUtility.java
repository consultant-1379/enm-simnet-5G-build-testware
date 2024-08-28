/**
 * -----------------------------------------------------------------------
 *     Copyright (C) 2015 LM Ericsson Limited.  All rights reserved.
 * -----------------------------------------------------------------------
 */
package com.ericsson.ci.simnet.test.utils;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.LinkedList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A utility class which allows zip and unzip the given files and folders recursively
 *
 * @author xkatmri
 *
 */
public class ZipUtility {

    /** Size of the buffer to read/write data */
    private static final int BUFFER_SIZE = 1024;

    private static final Logger log = LoggerFactory.getLogger(ZipUtility.class);

    /**
     * A non instantiable utility class only
     */
    private ZipUtility() {
    }

    public static boolean zip(final String zipFile, final String source) throws IOException {

        if (source == null) {
            return false;
        }

        try (ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(zipFile))) {
            final Path sourceFolderPath = new File(source).toPath();

            log.info("Source location - " + source);
            log.info("Zipping files into - " + zipFile);

            // creates the root directory based on source folder
            final String sourceDir = sourceFolderPath.getFileName().toString() + File.separator;
            zos.putNextEntry(new ZipEntry(sourceDir));
            log.info("  DirName: " + sourceFolderPath.getFileName().toString() + "RelativeDirName: " + sourceDir);

            for (final Path unzippedFile : listFiles(sourceFolderPath)) {

                if (unzippedFile.toFile().isDirectory()) {
                    // "\" or "/" is required to mark that the given path is a folder
                    final String dirName = sourceFolderPath.getParent().relativize(unzippedFile).toString() + File.separator;
                    final ZipEntry entry = new ZipEntry(dirName);
                    zos.putNextEntry(entry);
                    log.info("  DirName: " + unzippedFile.getFileName().toString() + ", RelativeDirName: " + dirName + ", DirEntry: "
                            + unzippedFile.toString());
                    continue;
                }

                log.info("  --FileName: " + unzippedFile.getFileName().toString() + ", RelativeFileName: "
                        + sourceFolderPath.relativize(unzippedFile).toString() + ", FileEntry: " + unzippedFile.toString());

                final ZipEntry entry = new ZipEntry(sourceFolderPath.getParent().relativize(unzippedFile).toString());
                zos.putNextEntry(entry);

                try (FileInputStream fis = new FileInputStream(unzippedFile.toFile())) {
                    final byte[] buffer = new byte[1024];
                    int len = 0;
                    while ((len = fis.read(buffer)) > 0) {
                        zos.write(buffer, 0, len);
                    }
                }
            }
        }

        log.info("Zipping files completed!!");
        return true;
    }

    private static List<Path> listFiles(final Path path) throws IOException {
        final Deque<Path> stack = new ArrayDeque<Path>();
        final List<Path> files = new LinkedList<>();

        stack.push(path);

        while (!stack.isEmpty()) {
            try (final DirectoryStream<Path> stream = Files.newDirectoryStream(stack.pop())) {
                for (final Path entry : stream) {
                    if (Files.isDirectory(entry)) {
                        files.add(entry);
                        stack.push(entry);
                    } else {
                        files.add(entry);
                    }
                }
            }
        }
        return files;
    }

    public static boolean unzip(final String theZipFile, final String destination) throws IOException {

        final File destDir = new File(destination);
        if (!destDir.exists()) {
            destDir.mkdirs();
        }
        final Path destDirPath = destDir.toPath();

        final File zipFile = new File(theZipFile);

        log.info("Source location - " + zipFile.getAbsolutePath());
        log.info("Unzipping files into:" + destDirPath);

        try (final ZipInputStream zis = new ZipInputStream(new FileInputStream(zipFile))) {
            ZipEntry entry = null;

            // iterates over entries in the zip file
            while ((entry = zis.getNextEntry()) != null) {
                final String dir = entry.getName();
                final String filePath = destDirPath.resolve(entry.getName()).toString();

                if (!(dir.endsWith("\\") || dir.endsWith("/"))) {
                    log.info("  --File::" + "EntryName:" + entry.getName() + ", EntryPath:" + filePath);

                    // if the entry is a file, extracts it
                    extractFile(zis, filePath);
                } else {
                    log.info("  --Dir::" + "EntryName:" + entry.getName() + ", EntryPath:" + filePath);
                    // if the entry is a directory, make the directory
                    final File directory = new File(filePath);
                    directory.mkdir();
                }
                zis.closeEntry();
            }

        }
        log.info("Unzipping files completed!!");
        return true;
    }

    private static void extractFile(final ZipInputStream zis, final String filePath) throws IOException {
        try (final BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(filePath))) {
            final byte[] buffer = new byte[BUFFER_SIZE];
            int read = 0;
            while ((read = zis.read(buffer)) != -1) {
                bos.write(buffer, 0, read);
            }
        }
    }

    public static void main(final String[] args) {
        zipping();
        unzipping();
    }

    private static void zipping() {
        try {
            ZipUtility.zip("C:\\ME\\repos\\enm-simnet-5G-build-testware\\ERICTAFenmsimnet5gbuild_CXP9036539\\src\\main\\resources\\zips\\enm-simnet-5G.zip",
                    "C:\\ME\\repos\\enm-simnet-5G-build-testware\\ERICTAFenmsimnet5gbuild_CXP9036539\\src\\main\\resources\\script");
        } catch (final IOException e) {
            log.info("Problem occured: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void unzipping() {
        try {
            ZipUtility.unzip("C:\\ME\\repos\\enm-simnet-5G-build-testware\\ERICTAFenmsimnet5gbuild_CXP9036539\\src\\main\\resources\\zips\\enm-simnet-5G.zip",
                    "src/main/resources/testing/dest");
        } catch (final IOException e) {
            log.info("Problem occured: " + e.getMessage());
            e.printStackTrace();
        }
    }

}