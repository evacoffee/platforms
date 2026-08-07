extends Node2D
@onready var scorelabel: Label = $HUD/scorepanel/scorelabel
@onready var fade: ColorRect = $HUD/fade

var level: int = 1
var score: int = 0
var current_level_root: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set up level
	fade.modulate.a = 1.0
	current_level_root = get_node("levelroot")
	await _load_level(level, true, false)

#------------------
#LEVEL MANAGEMENT
#------------------

func _load_level(level_number: int, first_load: bool, reset_score: bool) -> void:
	#Fade out
	if not first_load:
		await _fade(1.0)
	
	if reset_score:
		score = 0
		scorelabel.text = "SCORE: 0"
	
	if current_level_root:
		current_level_root.queue_free()
		
	#change level
	var level_path = "res://scenes/levels/level%s.tscn" % level_number
	current_level_root = load(level_path). instantiate()
	add_child(current_level_root)
	current_level_root.name = "levelroot"
	_setup_level(current_level_root)
	
	# Fade in
	await _fade(0.0)
	
func _setup_level(level_root: Node) -> void:
	#Connect exit
	var exit = level_root.get_node_or_null("exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
			
	#Connect apples
	var apples = level_root.get_node_or_null("apples")
	if apples:
		for apple in apples.get_children():
			apple.collected.connect(increase_score)
	
	#Connect enemies
	var enemies = level_root.get_node_or_null("enemies")
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_died.connect(_on_player_died)


#-------------
#SIGNAL HANDLES
#-------------
func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "player1":
		level += 1
		body.can_move = false
		await _load_level(level, false, false)
	
func _on_player_died(body):
	body.die()
	await _load_level(level, false, true)
	
	#------------------
	#SCORES
	#------------------
	
func increase_score() -> void:
		score += 1
		scorelabel.text = "SCORE: %s" % score
		
	#------------------
	#FADE
	#------------------
	
func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.5)
	await tween.finished
