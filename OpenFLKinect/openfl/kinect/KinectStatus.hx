package openfl.kinect;

/**
 * ...
 * @author Chris Porter
 */
enum KinectStatus
{

		None;

        /// <summary>
        /// Don't have a sensor yet, some sensor is initializing, you may not get it
        /// </summary>
        SensorInitializing;

        /// <summary>
        /// This KinectSensorChooser has a connected and started sensor.
        /// </summary>
        SensorStarted;

        /// <summary>
        /// There are no sensors available on the system.  If one shows up
        /// we will try to use it automatically.
        /// </summary>
        NoAvailableSensors;

        /// <summary>
        /// Available sensor is in use by another application
        /// </summary>
        SensorConflict;

        /// <summary>
        /// The available sensor is not powered.  If it receives power we
        /// will try to use it automatically.
        /// </summary>
        SensorNotPowered;

        /// <summary>
        /// There is not enough bandwidth on the USB controller available
        /// for this sensor.
        /// </summary>
        SensorInsufficientBandwidth;

        /// <summary>
        /// Available sensor is not genuine.
        /// </summary>
        SensorNotGenuine;

        /// <summary>
        /// Available sensor is not supported
        /// </summary>
        SensorNotSupported;

        /// <summary>
        /// Available sensor has an error
        /// </summary>
        SensorError;
	
}
