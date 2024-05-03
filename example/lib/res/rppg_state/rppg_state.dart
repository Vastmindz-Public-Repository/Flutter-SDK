enum RppgState {
  initial,
  prepared,
  videoStarted,
  analysisRunning,
  fail,
}

RppgState stringToRppgState(String value) {
  switch (value.toLowerCase()) {
    case "initial":
      return RppgState.initial;
    case "prepared":
      return RppgState.prepared;
    case "videostarted":
      return RppgState.videoStarted;
    case "analysisrunning":
      return RppgState.analysisRunning;
    case "fail":
      return RppgState.fail;
    default:
      throw ArgumentError("Invalid RppgState string: $value");
  }
}