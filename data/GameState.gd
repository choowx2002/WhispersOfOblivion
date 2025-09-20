extends Node

var playerSelectedRoom
var escape_count: int = 0	# Record escape times
var unlocked_fragments: Array[int] = []   # List fragments' id that alrdy collected [0,1,2,3...]
var fragments_collected := {	# Records the fragment progressions
	"north": false, "east": false, "south": false, "west": false
}
var fragments_picked_up := {	# Records if fragments have been picked up in current maze attempt
	"north": false, "east": false, "south": false, "west": false
}
var memory_db: Array = []

var hits: int = 0
var respawns: int = 0
var start_time: float = 0.0
var end_time: float = 0.0
const SAVE_PATH := "res://data/save.json"
const FRAG_DB_PATH := "res://data/memory_fragments.json"

# Signals
signal progress_changed(escape_count: int)
signal fragment_unlocked(id: int)
signal fragment_collected(maze_key: String)
signal truth_ending_triggered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_db()
	_load_save()
	print("DEBUG: Initial fragments state: ", fragments_collected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Function to Hard Reset Game Status
func reset_game_state() -> void:
	fragments_collected = {
		"north": false,
		"east": false,
		"south": false,
		"west": false
	}
	fragments_picked_up = {
		"north": false,
		"east": false,
		"south": false,
		"west": false
	}
	escape_count = 0
	unlocked_fragments.clear()
	save()
	print("DEBUG: Reset game state - fragments:", fragments_collected)

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

# check all fragments collected (true when all collected)
func has_all_fragments() -> bool:
	for k in fragments_collected.keys():
		if not fragments_collected[k]:
			return false
	return true


# mark fragment as collected
func mark_fragment_collected(maze_key: String) -> void:
	var key := normalize_maze_key(maze_key)
	if not has_collected_fragment(key):
		fragments_collected[key] = true
		save()

# maze escape triggered function (collected frags)
func on_escape_completed(maze_key: String) -> void:
	var key := normalize_maze_key(maze_key)
	var frag_id := get_fragment_id_for_maze(key)
	# Only run if the player actually collected the fragment in this maze
	if frag_id >= 0 and not unlocked_fragments.has(frag_id) and has_collected_fragment(key):
		escape_count += 1
		emit_signal("progress_changed", escape_count)
		
		unlocked_fragments.append(frag_id)
		emit_signal("fragment_unlocked", frag_id)
		save()

	# Check if this was the final maze (ending condition)
	if key == "South":  # adjust if your last maze key is named differently
		if has_all_fragments():
			emit_signal("truth_ending_triggered")

# Mark fragment as picked up in current maze attempt
func mark_fragment_picked_up(maze_key: String) -> void:
	var key := normalize_maze_key(maze_key)
	fragments_picked_up[key] = true
	print("DEBUG: Fragment picked up in maze: ", key)

# Check if fragment is picked up in current maze attempt
func has_picked_up_fragment(maze_key: String) -> bool:
	var key := normalize_maze_key(maze_key)
	return bool(fragments_picked_up.get(key, false))

# Reset picked up state when entering a new maze
func reset_picked_up_state() -> void:
	fragments_picked_up = {
		"north": false,
		"east": false,
		"south": false,
		"west": false
	}
