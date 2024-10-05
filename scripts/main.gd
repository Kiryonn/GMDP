extends Control

@export_group("Main Components")
@export var app_le: LineEdit
@export var pwd_le: LineEdit
@export var pass_tree: PassTree


const lowercase_chars: Array[String] = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
const uppercase_chars: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
const number_chars: Array[String] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']


func _ready() -> void:
	%Restrictions.visible = %AdvancedSettings.button_pressed

func _on_add_line_button_pressed() -> void:
	pass_tree.add_line(app_le.text, pwd_le.text)
	app_le.clear()
	pwd_le.clear()

func _on_generate_password_pressed() -> void:
	var pwd = generate_password()
	pwd_le.text = pwd

func _on_show_pass_button_down() -> void: pwd_le.secret = false
func _on_show_pass_button_up() -> void: pwd_le.secret = true
func _on_advanced_settings_toggled(toggled_on: bool) -> void: %Restrictions.visible = toggled_on

@warning_ignore("narrowing_conversion")
func generate_password() -> String:
	randomize()
	var nb_chars: int = randi_range(%MinLength.value, %MaxLength.value)
	var pass_chars: Array[String] = []
	var char_pool: Array[String] = []
	
	# fill required numbers
	if %UseNumbers.button_pressed:
		char_pool.append_array(number_chars)
		for i in range(%MinNumbers.value):
			pass_chars.append(number_chars.pick_random())
	
	# fill required upper characters
	if %UseUppercase.button_pressed:
		char_pool.append_array(uppercase_chars)
		for i in range(%MinUppercase.value):
			pass_chars.append(uppercase_chars.pick_random())
	
	# fill required lower characters
	if %UseLowercase.button_pressed:
		char_pool.append_array(lowercase_chars)
		for i in range(%MinLowercase.value):
			pass_chars.append(lowercase_chars.pick_random())
	
	# fill required special characters
	if %UseSpecialCharacters.button_pressed:
		var special_characters: Array[String] = []
		special_characters.assign(%SpecialCharacters.text.split())
		if special_characters == [""]:
			special_characters.assign(%SpecialCharacters.placeholder_text.split())
		char_pool.append_array(special_characters)
		for i in range(%MinSpecialCharacters.value):
			pass_chars.append(special_characters.pick_random())
	
	# fill the rest
	for i in range(nb_chars - len(pass_chars)):
		pass_chars.append(char_pool.pick_random())
	
	# shuffle
	pass_chars.shuffle()
	
	# build and return
	return ''.join(pass_chars)

func update_min(__):
	pass
