//
//  MelodyManager.h
//  MelodySmart
//
//  Copyright (c) 2014 BlueCreation. All rights reserved.
//

#import "MelodySmart.h"

@class MelodyManager;

/*!
 *  @protocol MelodyManagerDelegate
 *
 *  @discussion The delegate of a MelodySmart object must adopt the <code>MelodySmartDelegate</code> protocol. The requirement of methods are
 *  dependent on the implementation.
 *
 */
@protocol MelodyManagerDelegate <NSObject>


/*!
 *  @method melodyManagerDiscoveryDidRefresh:
 *
 *  @discussion     Invoked whenever the Melody Smart found a Melody device.central manager's state has been updated.
 *
 */
- (void) melodyManagerDiscoveryDidRefresh:(MelodyManager*)manager;

/*!
 *  @method melodyManagerDiscoveryStatePoweredOff:
 *
 *  @discussion     Invoked if the bluetooth is powered off. This indicates that melody
 *  will not be able to find any devices.
 *
 */
@optional
- (void) melodyManagerDiscoveryStatePoweredOff:(MelodyManager*)manager;

/*!
 *  @method melodyManagerDidClearDevices:
 *
 *  @discussion     Invoked when the internal found devices is cleared. This can be invoked when starting to scan for exampl
 *
 */
@optional
- (void) melodyManagerDidClearDevices:(MelodyManager*)manager;

/*!
 *  @method melodyManagerConnectedListChanged:
 *
 *  @discussion     Invoked when the internal connected device list has changed.
 *
 */
@optional
- (void) melodyManagerConnectedListChanged;
@end

/*!
 *  @class MelodyManager:
 *
 *  @discussion Manages searching and connecting to Melody Devices. This is only for iOS acting as Central
 *
 */
@interface MelodyManager : NSObject

@property (readonly) NSString *version;

/*!
 *  @property delegate
 *
 *  @discussion The delegate object that will receive Melody Manager events.
 *
 */
@property (nonatomic, weak) id<MelodyManagerDelegate> delegate;

/*!
 *  @method initForService
 *
 *  @param  serviceUUid     Change the last 8 bytes of the Primary Service UUID.
 *
 *  @param  dataUUID        Change the last 8 bytes of the Data Characteristic UUID.
 *
 *  @param  pioReportUUID   Change the last 8 bytes of the PIO Report Characteristic UUID.
 *
 *  @param  pioSettingUUID  Change the last 8 bytes of the PIO Setting Characteristic UUID.
 *
 *  @discussion Initialises MelodySmart with modified UUIDs, To comply with the Melody peripheral, only the last 8 bytes are allowed to change. This will make sure that the application can find the correct peripheral. Setting any value to nil will keep the default value.
 *
 */
- (void) setForService:(NSString*)serviceUUID andDataCharacterisitc:(NSString*)DataUUID andPioReportCharacteristic:(NSString*)PioReportUUID andPioSettingCharacteristic:(NSString*)pioSettingUUID;

/*!
 *  @method scanForMelody
 *
 *  @discussion Start scanning for Melody peripheral with the correct Primary UUID
 *
 */
- (void) scanForMelody;

/*!
 *  @method stopScanning
 *
 *  @discussion Stop the previously started scan.
 *
 */
- (void) stopScanning;

/*!
 *  @method numberOfFoundDevices
 *
 *  @return The number of found Melody devices.
 *
 *  @discussion This can be read while scanning to know how many devices were found
 *
 */
+ (NSInteger) numberOfFoundDevices;

/*!
 *  @method numberOfConnectedDevices
 *
 *  @return the number of connected Melody devices.
 *
 *  @discussion This can be checked to find out how many melody peripherals are connected
 *
 */
+ (NSInteger) numberOfConnectedDevices;

/*!
 *  @method foundDeviceAtIndex
 *
 *  @param  index   The melody device in the found devices list.
 *
 *  @return The MelodySmart instance for the required device if available. nil otherwise.
 *
 *  @discussion Retrieves the melody device at index in the internal list of found devices. The returned device is not guranteed to be available.
 *
 */
+ (MelodySmart*) foundDeviceAtIndex:(NSInteger)index;

/*!
 *  @method connectedDeviceAtIndex
 *
 *  @param  index The melody device in the connected devices list.
 *
 *  @return The MelodySmart instance for the required device if available. nil otherwise.
 *
 *  @discussion Retrieves the melody device at index in the internal list of connected devices. The returned device is not guranteed to be available.
 *
 */
+ (MelodySmart*) connectedDeviceAtIndex:(NSInteger)index;


@end
