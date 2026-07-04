import '../models/map_data_model.dart';

/// Global reference to the active ScoutingData instance
late MapDataModel _globalScoutingData;

MapDataModel getGlobalScoutingData() => _globalScoutingData;
void setGlobalScoutingData(MapDataModel data) => _globalScoutingData = data;
