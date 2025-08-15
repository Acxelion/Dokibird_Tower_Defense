extends RichTextLabel

@export var text_file_path: String

func _ready():
	var txt_file = FileAccess.open(text_file_path, FileAccess.READ)
	
	self.add_text(txt_file.get_as_text())
	
	txt_file.close()
