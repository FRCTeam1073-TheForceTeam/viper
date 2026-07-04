/// Field metadata - stores everything as strings, typed getters parse on demand
class FieldDescriptor {
	final String name;  // Single source of truth: used for storage, CSV, and access
	final String? uiLabelKey;
	final String? descriptionLabelKey;
	final String? _value;
	final String? imagePath;
	final double? width;
	final double? height;
	final String? autoCountersTableHeading;  // Section heading in auto counters table
	final String? teleCountersTableHeading;  // Section heading in tele counters table
	final String? autoCountersTableDescription;  // Description/label for auto counters
	final String? teleCountersTableDescription;  // Description/label for tele counters
	final String? autoValuesTableHeading;  // Section heading in auto values table
	final String? teleValuesTableHeading;  // Section heading in tele values table

	const FieldDescriptor({
		required this.name,
		this.uiLabelKey,
		this.descriptionLabelKey,
		String? value,
		this.imagePath,
		this.width,
		this.height,
		this.autoCountersTableHeading,
		this.teleCountersTableHeading,
		this.autoCountersTableDescription,
		this.teleCountersTableDescription,
		this.autoValuesTableHeading,
		this.teleValuesTableHeading,
	}) : _value = value;

	/// Create a copy with a new value
	FieldDescriptor withValue(String? newValue) {
		return FieldDescriptor(
			name: name,
			uiLabelKey: uiLabelKey,
			descriptionLabelKey: descriptionLabelKey,
			value: newValue,
			imagePath: imagePath,
			width: width,
			height: height,
			autoCountersTableHeading: autoCountersTableHeading,
			teleCountersTableHeading: teleCountersTableHeading,
			autoCountersTableDescription: autoCountersTableDescription,
			teleCountersTableDescription: teleCountersTableDescription,
			autoValuesTableHeading: autoValuesTableHeading,
			teleValuesTableHeading: teleValuesTableHeading,
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
