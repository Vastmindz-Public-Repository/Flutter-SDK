# RPPG Common Flutter Plugin Documentation

## Introduction
The RPPG Common Flutter Plugin facilitates real-time face analysis using a camera. This plugin includes features such as camera configuration, video streaming, and analysis execution. The plugin maintains different states to represent the various stages of its lifecycle.

## States
1. **Initial State (`initial`):**
    - Represents the state of the `RppgCommon` right after initialization.

2. **Prepared State (`prepared`):**
    - Represents the state when the video session is configured.
    - Web socket is not configured yet.

3. **Video Started State (`videoStarted`):**
    - Represents the state when input and output devices of the video session are initialized.
    - Connected to the session, and input video should be rendered in `RPPGCameraView`.

4. **Analysis Running State (`analysisRunning`):**
    - Represents the state when both the video session and web socket are configured and running.
    - Images captured and passed to the face detector, BGR signals calculated and submitted to the backend.
    - Vitals should be received through the web socket (analysis is running).

## Methods

### `Future<String> getState()`
- Returns: `Future<String>`
- Description: Retrieves the current/internal state of the `RppgCommon` object. Valid state transitions are: `initial -> prepared <-> videoStarted <-> analysisRunning`.

### `Future<bool> askPermissions()`
- Returns: `Future<bool>`
- Description: Requests camera permissions.

### `configure(int fps, bool isFrontCamera)`
- Parameters:
    - `fps`: Frames per second for video analysis.
    - `isFrontCamera`: A boolean indicating whether the front camera is being used.
- Description: Configures the RppgCommon camera before preview. Should be invoked only when the `state` is either `initial` or `prepared`. Changes `state` to `prepared` on success.

### `startVideo()`
- Description: Starts video capturing. Should be invoked only when the `state` is `prepared`. Changes `state` to `videoStarted` on success.

### `Stream<AnalysisData> startAnalysis(String baseUrl, String authToken, String fps, String age, String sex, String height, String weight)`

- Parameters:
    - `baseUrl` (String): Base URL for the analysis service.
    - `authToken` (String): Authentication token required for accessing the analysis service.
    - `fps` (String): Frames per second (FPS) for the analysis. - (Optional)
    - `age` (String): Age of the subject for analysis. - (for e.g "27")
    - `sex` (String): Gender of the subject for analysis. - (male/female for e.g "male")
    - `height` (String): Height of the subject for analysis. - (in cm, for e.g "172")
    - `weight` (String): Weight of the subject for analysis. - (in kg, for e.g "81")

   Note: All values should be in String.

- Returns:
    - `Stream<AnalysisData>`: A stream emitting `AnalysisData` objects representing the analysis results.
      
    The emitted `AnalysisData` objects contain the following attributes:

    - `accessToken` (String): The access token.
    - `progressPercentage` (int): Progress percentage of the analysis.
    - `signals` (List<int>): List of signals.
    - `bloodPressure` (BloodPressure): Blood pressure data.
        - `systolic` (int): Systolic blood pressure value.
        - `diastolic` (int): Diastolic blood pressure value.
    - `avgRespirationRate` (int): Average respiration rate.
    - `statusCode` (String): Status code.
    - `statusMessage` (String): Status message of the analysis.
    - `snr` (double): Signal-to-noise ratio.
    - `rateWarning` (RateWarning): Rate warning data.
        - `notificationMessage` (String): Warning notification message.
        - `delayValue` (int): Delay value associated with the warning.
    - `rmssd` (double): Root mean square of successive differences.
    - `avgO2SaturationLevel` (int): Average oxygen saturation level.
    - `isMovingWarning` (bool): Indicator for movement warning when face will be out.
    - `avgBpm` (int): Average beats per minute.
    - `bloodPressureStatus` (String): Status of blood pressure.
    - `ibi` (double): Inter-beat interval.
    - `stressStatus` (String): Stress status.
    - `afibRiskStatus` (String?): Atrial fibrillation risk status.
    - `sdnns` (double): Standard deviation of NN intervals.

- Description:
  Starts the analysis process for the RppgCommon instance. This method should be invoked only when the `state` is `videoStarted`. Invoking it in any other state will have no effect. Upon successful invocation, the state will be changed to `analysisRunning`.


### `stopAnalysis()`
- Description: Stops analysis. Should be invoked only when the `state` is `analysisRunning`. Changes `state` to `videoStarted` on success.

### `meshColor()`
- Description: Adds mesh over the face.

### `cleanMesh()`
- Description: Removes the mesh from the face.

## Usage Example
```dart
RppgCommon rppgCommon = RppgCommon();

// Example: Get the current state
String currentState = await rppgCommon.getState();
print("Current State: $currentState");

// Example: Ask for camera permissions
bool permissionGranted = await rppgCommon.askPermissions();

// Example: Configure and start camera
rppgCommon.configure(fps: 30, isFrontCamera: true);
rppgCommon.startVideo();

// Example: Start analysis with user data
String baseUrl = "...";
String authToken = "...";
String fps = "...";
String age = "...";
String sex = "...";
String height = "...";
String weight = "...";
Stream<AnalysisData> analysisStream = rppgCommon.startAnalysis(baseUrl, authToken, fps, age, sex, height, weight);

// Example: Stop analysis
rppgCommon.stopAnalysis();

// Example: Add mesh to the face
rppgCommon.meshColor();

// Example: Remove mesh from the face
rppgCommon.cleanMesh();
```

This documentation provides an overview of the RPPG Common Flutter Plugin, including its states and methods. Users can follow the provided examples to integrate the plugin into their Flutter applications for real-time photoplethysmogram analysis using a camera.