import 'package:viper_scout/providers/global_scouting_data.dart';

/// Field metadata - stores everything as strings, typed getters parse on demand
class FieldDescriptor {
	static final Map<String, FieldDescriptor> _cache = {};

	final String name;  // Single source of truth: used for storage, CSV, and access
	final String? uiLabelKey;
	final String? descriptionLabelKey;
	final String? _value;
	final String? imagePath;
	final double? width;
	final double? height;
	final String? teleValuesTableDescription;
	final String? autoValuesTableDescription;

	FieldDescriptor._internal({
		required this.name,
		this.uiLabelKey,
		this.descriptionLabelKey,
		String? value,
		this.imagePath,
		this.width,
		this.height,
		this.teleValuesTableDescription,
		this.autoValuesTableDescription,
		bool autoRegister = true,
	}) : _value = value {
		// Register with global scouting data if available (skip for static descriptors)
		if (autoRegister) {
			try {
				getGlobalScoutingData().registerDescriptor(this);
			} catch (e) {
				// Silently ignore if global data not yet initialized
			}
		}
	}

	/// Create a static descriptor that doesn't auto-register
	static FieldDescriptor createStatic({
		required String name,
		String? uiLabelKey,
		String? descriptionLabelKey,
		String? imagePath,
		double? width,
		double? height,
		String? teleValuesTableDescription,
		String? autoValuesTableDescription,
	}) {
		return FieldDescriptor._internal(
			name: name,
			uiLabelKey: uiLabelKey,
			descriptionLabelKey: descriptionLabelKey,
			imagePath: imagePath,
			width: width,
			height: height,
			teleValuesTableDescription: teleValuesTableDescription,
			autoValuesTableDescription: autoValuesTableDescription,
			autoRegister: false,
		);
	}

	/// Factory constructor: returns cached instance if it exists, creates new one otherwise
	factory FieldDescriptor({
		required String name,
		String? uiLabelKey,
		String? descriptionLabelKey,
		String? value,
		String? imagePath,
		double? width,
		double? height,
		String? teleValuesTableDescription,
		String? autoValuesTableDescription,
	}) {
		// Return cached instance if it exists with no value override
		if (value == null && _cache.containsKey(name)) {
			return _cache[name]!;
		}

		// Create new instance and cache it (only cache instances without values)
		final descriptor = FieldDescriptor._internal(
			name: name,
			uiLabelKey: uiLabelKey,
			descriptionLabelKey: descriptionLabelKey,
			value: value,
			imagePath: imagePath,
			width: width,
			height: height,
			teleValuesTableDescription: teleValuesTableDescription,
			autoValuesTableDescription: autoValuesTableDescription,
		);

		if (value == null) {
			_cache[name] = descriptor;
		}

		return descriptor;
	}

	/// Create a copy with a new value (not cached since it has a specific value)
	FieldDescriptor withValue(String? newValue) {
		return FieldDescriptor._internal(
			name: name,
			uiLabelKey: uiLabelKey,
			descriptionLabelKey: descriptionLabelKey,
			value: newValue,
			imagePath: imagePath,
			width: width,
			height: height,
			teleValuesTableDescription: teleValuesTableDescription,
			autoValuesTableDescription: autoValuesTableDescription,
		);
	}

	/// Parse as bool with default
	bool asBool() {
		if (_value == null) return false;
		return _value == '1' || _value!.toLowerCase() == 'true';
	}

	/// Parse as int with default
	int asInt() {
		if (_value == null) return 0;
		return int.tryParse(_value ?? '') ?? 0;
	}

	/// Get as string with default
	String asString() {
		return (_value == null || _value!.isEmpty) ? '' : _value!;
	}

	/// Get the UI label key, defaulting to the field name if not specified
	String get uiLabel => uiLabelKey ?? name;
}
