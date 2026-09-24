class_name StringDumper
## 翻訳対象の英語テキストをゲームデータから抽出する (開発用)。
## DevAutoPilot の --auto=dump_strings から呼ばれ、res://tools/i18n/data_strings.json に書き出す。

const OUT_PATH := "res://tools/i18n/data_strings.json"
## 翻訳対象とみなすプロパティ名
const TEXT_PROPERTY := "(_name|_description|bbcode|bb_code|_use_text)$"
const SKIP_PROPERTY := "(_path|_id|_ids|stat_name|profile_name|mod_name)$"


static func dump() -> void:
	var include := RegEx.create_from_string(TEXT_PROPERTY)
	var skip := RegEx.create_from_string(SKIP_PROPERTY)
	var strings := {}	# text -> "Class.property" (初出の出どころ)
	for schema_row: Array in Global.SCHEMA:
		var table: Dictionary = Global.get(schema_row[2])
		for data in table.values():
			_collect(data, include, skip, strings, 0)
	var file := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(strings, "\t", true))
	print("StringDumper: %d strings -> %s" % [strings.size(), OUT_PATH])


static func _collect(value: Variant, include: RegEx, skip: RegEx, strings: Dictionary, depth: int) -> void:
	if depth > 6:
		return
	if value is Array:
		for v in value:
			_collect(v, include, skip, strings, depth + 1)
	elif value is Dictionary:
		for v in value.values():
			_collect(v, include, skip, strings, depth + 1)
	elif value is Object:
		for prop in value.get_property_list():
			if not (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
				continue
			var v = value.get(prop.name)
			if v is String:
				if v != "" and include.search(prop.name) and not skip.search(prop.name):
					if not strings.has(v):
						strings[v] = "%s.%s" % [value.get_script().get_global_name(), prop.name]
			elif v is Array or v is Dictionary or v is Object:
				_collect(v, include, skip, strings, depth + 1)
