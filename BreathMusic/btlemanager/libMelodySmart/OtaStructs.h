//
//  OtaStructs.h
//  MelodySmart
//
//  Created by Stanislav Nikolov on 20/01/2015.
//  Copyright (c) 2015 BlueCreation. All rights reserved.
//

#ifndef MelodySmart_OtaStructs_h
#define MelodySmart_OtaStructs_h

/**
 @brief The bootmode the device is in.
 */
typedef enum {
    /** Bootloader bootmode - the device is ready to start OTAU */
    BOOT_MODE_BOOTLOADER,
    /** Application boot mode - the device is running the Reign firmware */
    BOOT_MODE_APPLICATION,
    /** Unknown boot mode - the uninitialized state of the boot mode */
    BOOT_MODE_UNKNOWN
} BootMode ;

/**
 @brief The state of the OTAU process.
 */
typedef enum {
    /** Idle state */
    OTAU_IDLE,
    /** OTAU process is underway */
    OTAU_IN_PROGRESS,
    /** OTAU process completed successfully */
    OTAU_COMPLETE,
    /** OTAU process failed */
    OTAU_FAILED
} OtauState;

#endif
