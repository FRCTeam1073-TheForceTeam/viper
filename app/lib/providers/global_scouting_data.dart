import 'package:flutter/foundation.dart';
import '../models/map_data_model.dart';

/// Global reference to the active ScoutingData instance
MapDataModel? _globalScoutingData;

MapDataModel? getGlobalScoutingData() => _globalScoutingData;
void setGlobalScoutingData(MapDataModel data) => _globalScoutingData = data;

/// Reset global scouting data for testing
@visibleForTesting
void resetGlobalScoutingDataForTesting() {
	_globalScoutingData = null;
}
