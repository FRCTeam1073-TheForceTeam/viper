// Connectivity provider - simplified to always assume online for now
// TODO: Fix the actual connectivity detection with proper API usage
final connectivityProvider = StreamProvider((ref) async* {
  // Always assume online - will be improved later
  yield true;
});
