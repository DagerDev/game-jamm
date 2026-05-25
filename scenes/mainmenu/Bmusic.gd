extends AudioStreamPlayer

func _ready():
	stream = load("res://assets/Audio/music/game_theme.ogg")
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	play()
