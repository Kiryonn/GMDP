class_name PassTree extends Tree

const COPY_IMAGE = preload("res://sprites/32x32/copy_32x32.png")
const DELETE_IMAGE = preload("res://sprites/32x32/delete_32x32.png")
const SHOW_IMAGE = preload("res://sprites/32x32/show_32x32.png")
const __ := "res://data/pwd_database.res"

var items: Array[TreeItem] = []
var data: PackedStringArray
var visible_pwd := {}

func _ready() -> void:
	data = load_data()
	create_header()
	for i in range(0, len(data), 2):
		items.append(create_line_item(data[i], data[i+1]))

func create_header() -> void:
	set_column_title(0, "Applcation")
	set_column_title(1, "Password")
	set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_title_alignment(2, HORIZONTAL_ALIGNMENT_RIGHT)
	set_column_title_alignment(3, HORIZONTAL_ALIGNMENT_RIGHT)
	set_column_expand(2, false)
	set_column_expand(3, false)
	set_column_expand(4, false)
	create_line_item("", "") # prevent invisible items

func create_line_item(app_name: String, pwd: String) -> TreeItem:
	var item := create_item()
	item.set_text(0, app_name)
	item.set_text(1, '*'.repeat(len(pwd)))
	item.add_button(2, SHOW_IMAGE)
	item.add_button(3, COPY_IMAGE)
	item.add_button(4, DELETE_IMAGE)
	return item

func sort_item_by_app_name(a: TreeItem, b: TreeItem) -> bool:
	return a.get_text(0) < b.get_text(0)

func add_line(app_name: String, pwd: String) -> void:
	if len(app_name) == 0 || len(pwd) == 0: return
	var item := create_line_item(app_name, pwd)
	var index = items.bsearch_custom(item, sort_item_by_app_name)
	items.insert(index, item)
	data.insert(index*2, pwd)
	data.insert(index*2, app_name)
	set_selected(item, 0)
	scroll_to_item(item)
	save_data()

func remove_line(index: int) -> void:
	var item = items[index]
	items.remove_at(index)
	data.remove_at(index*2)
	data.remove_at(index*2)
	item.free()
	save_data()
	print(data)

func _exit_tree() -> void:
	save_data()

func load_data() -> PackedStringArray:
	data = PackedStringArray()
	if ResourceLoader.exists(__):
		var database = ResourceLoader.load(__)
		data = database.items
	else:
		save_data()
	return data

func save_data() -> void:
	DirAccess.make_dir_recursive_absolute(__.get_base_dir())
	var database := Database.new()
	database.items = data
	ResourceSaver.save(database, __)

func copy_pwd_to_clipboard(index: int) -> void:
	DisplayServer.clipboard_set(data[index * 2 + 1])

func toggle_pwd_visibility(index: int) -> void:
	if index in visible_pwd:
		items[index].set_text(1, '*'.repeat(len(data[index*2+1])))
		visible_pwd.erase(index)
	else:
		items[index].set_text(1, data[index*2+1])
		visible_pwd[index] = true

func _on_button_clicked(item: TreeItem, column: int, _id: int, mouse_button_index: int) -> void:
	if mouse_button_index != 1: return
	var index: int = items.find(item)
	if column == 2:
		toggle_pwd_visibility(index)
	elif column == 3:
		copy_pwd_to_clipboard(index)
	elif column == 4:
		remove_line(index)
