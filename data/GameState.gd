extends Node

var playerSelectedRoom
# Record escape times
var escape_count: int = 0
# List fragments' id that alrdy collected
var unlocked_fragments: Array[int] = []   # [0,1,2,3...]
# flags the collected fragments
var fragments_collected := {
	"north": false, "east": false, "south": false, "west": false
}
# fragments database
var memory_db: Array = []
const SAVE_PATH := "user://save.json"
const FRAG_DB_PATH := "res://data/memory_fragments.json"

signal progress_changed(escape_count: int)
signal fragment_unlocked(id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_db()
	_load_save()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Load database
func _load_db() -> void:
	memory_db.clear()
	if FileAccess.file_exists(FRAG_DB_PATH):
		var f := FileAccess.open(FRAG_DB_PATH, FileAccess.READ)
		var parsed_v: Variant = JSON.parse_string(f.get_as_text())
		if typeof(parsed_v) == TYPE_ARRAY:
			memory_db = parsed_v as Array
		else:
			push_warning("memory_fragments.json malformed.")
	else:
		push_warning("memory_fragments.json missing.")

# Load Save file
func _load_save() -> void:
	# return if saved file no exists
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	# Read saved files
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data_v: Variant = JSON.parse_string(f.get_as_text())
	if typeof(data_v) != TYPE_DICTIONARY:
		push_warning("save.json malformed; starting fresh")
		return
	
	var data: Dictionary = data_v
	escape_count = int(data.get("escape_count", 0))
	var uf_v: Variant = data.get("unlocked_fragments", [])
	unlocked_fragments.clear()
	if typeof(uf_v) == TYPE_ARRAY:
		for x in (uf_v as Array):
			if typeof(x) == TYPE_INT:
				unlocked_fragments.append(x)
	
	# fragments_collected (typed Dictionary)
	var saved_col_v: Variant = data.get("fragments_collected", {})
	if typeof(saved_col_v) == TYPE_DICTIONARY:
		var saved_col: Dictionary = saved_col_v
		for k in fragments_collected.keys():
			if saved_col.has(k):
				fragments_collected[k] = bool(saved_col[k])

# Save everything (escape count, unlocked frags, frags collected)
func save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data := {
		"escape_count": escape_count,
		"unlocked_fragments": unlocked_fragments,
		"fragments_collected": fragments_collected
	}
	f.store_string(JSON.stringify(data))

# Clear progression and reset all counters
func reset_save() -> void:
	escape_count = 0
	unlocked_fragments.clear()
	for k in fragments_collected.keys():
		fragments_collected[k] = false
	save()
	emit_signal("progress_changed", escape_count)

## --- Helpers ---
# Normalize naming clarification
func normalize_maze_key(k: String) -> String:
	k = k.to_lower()
	if k in ["n","north"]: return "north"
	if k in ["e","east"]:  return "east"
	if k in ["s","south"]: return "south"
	if k in ["w","west"]:  return "west"
	return k

# get fragment id for maze
func get_fragment_id_for_maze(maze_key: String) -> int:
	var key := normalize_maze_key(maze_key)
	for frag in memory_db:
		if frag.get("maze","") == key:
			return int(frag.get("id",-1))
	return -1

# get fragment with id
func get_fragment(id: int) -> Dictionary:
	if id >= 0 and id < memory_db.size():
		return memory_db[id]
	return {}

# get unlocked fragment
func get_unlocked_fragments() -> Array:
	var out: Array = []
	for id in unlocked_fragments:
		if id >= 0 and id < memory_db.size():
			out.append(memory_db[id])
	return out

# check the status of fragments (collected/not)
func has_collected_fragment(maze_key: String) -> bool:
	var key := normalize_maze_key(maze_key)
	return bool(fragments_collected.get(key, false))

# mark fragment as collected
func mark_fragment_collected(maze_key: String) -> void:
	var key := normalize_maze_key(maze_key)
	if not has_collected_fragment(key):
		fragments_collected[key] = true
		save()

# maze escape triggered function (collected frags)
func on_escape_completed(maze_key: String) -> void:
	# Only run if the player actually collected the fragment in this maze
	var key := normalize_maze_key(maze_key)
	var frag_id := get_fragment_id_for_maze(key)

	escape_count += 1
	emit_signal("progress_changed", escape_count)

	if frag_id >= 0 and not unlocked_fragments.has(frag_id) and has_collected_fragment(key):
		unlocked_fragments.append(frag_id)
		emit_signal("fragment_unlocked", frag_id)

	save()
