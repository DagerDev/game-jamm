extends Control



# =========================================================
# UI
# =========================================================
@onready var npc_text = %ShopKeeper
@onready var yes_button = %Yes
@onready var no_button = %No

var selected_upgrade := ""

@onready var PlayerLabel = %PlayerStats
@onready var BankLabel = %BankStats
@onready var HealthBar = %HealthBank
@onready var shop_controller = %Tweenss
@onready var bankhealthText = %Bankhealth
@onready var history_log: RichTextLabel = %HistoryLog

@onready var actions = [%Hack,%Bomb,%Sabotage,%Loan]

@export var hack_icon: Texture2D
@export var bomb_icon: Texture2D
@export var sabotage_icon: Texture2D
@export var loan_icon: Texture2D
@export var pay_icon: Texture2D

var action_icons = []

var actionNames = ["Hack",
"Bomb",
"Sabotage",
"Loan"]


@onready var shopbut = [
	%HackingBuy,
	%BombingBuy,
	%SabotageBuy,
	%ClickingBuy,
	%PassiveBuy
]

const shopTitles = [
	"Upgrade Hacking",
	"Upgrade Bombing",
	"Upgrade Sabotage",
	"Upgrade Clicking",
	"Upgrade Passive Income"
]


# =========================================================
# PLAYER
# =========================================================
var money := 67
var debt := 0

var hacking := 1
var bombing := 1
var sabotage_power := 1
var click_power := 1
var passive_income := 0

# =========================================================
# BANK
# =========================================================
var bank_hp := 1000
var bank_max_hp := 1000

var security := 1
var cybersecurity := 1
var building_strength := 1

# =========================================================
# GAME
# =========================================================
var turn := 0
var game_over := false
var negative_turns := 0

var action_cd := 0.0
const ACTION_CD_TIME := 0.5

# =========================================================
# TIMERS
# =========================================================
var passive_timer := 0.0

# =========================================================
# LOAN
# =========================================================
var loan_active := false
var loan_turn_due := -1
var loan_amount := 0

# =========================================================
# EVENTS
# =========================================================
var event_cooldown := 0

# =========================================================
# UPGRADES
# =========================================================
var upgrades := {
	"Hacking": {
		"level": 1,
		"price": 40,
		"growth": 1.35
	},

	"Bombing": {
		"level": 1,
		"price": 60,
		"growth": 1.45
	},

	"Sabotage": {
		"level": 1,
		"price": 70,
		"growth": 1.50
	},

	"Click": {
		"level": 1,
		"price": 25,
		"growth": 1.30
	},

	"Passive": {
		"level": 1,
		"price": 100,
		"growth": 1.50
	}
}

var upgrade_info := {
	"Hacking": {
		"name": "Hire Hackers",
		"description": "+1 Hacking"
	},
	"Bombing": {
		"name": "Buy Explosives",
		"description": "+1 Bombing"
	},
	"Sabotage": {
		"name": "Recruit Insider",
		"description": "+1 Sabotage"
	},
	"Click": {
		"name": "Better Tools",
		"description": "+1 Click Power"
	},
	"Passive": {
		"name": "Money Laundering",
		"description": "+1 Passive Income/sec"
	}
}

# =========================================================
# PROCESS
# =========================================================
func _process(delta):

	if action_cd > 0:
		action_cd -= delta

	passive_timer += delta

	if passive_timer >= 1.0:

		passive_timer = 0

		if passive_income > 0:

			money += passive_income

			update_ui()

# =========================================================
# MESSAGE SYSTEM
# =========================================================
func push_message(text:String):
	shop_controller.push_message(text)

	# Skip manual clicks / income spam
	if "CLICK" in text or "MANUAL INCOME" in text or "Click Upgrade" in text:
		return
	
	var turn_text = "Start" if turn == 0 else "T%d" % turn
	var color = "#FFFFFF"
	var prefix = ""
	
	# Color + prefix by type
	if "HACKING" in text:
		color = "#FF6B6B"
		prefix = "🖥️ "
	elif "BOMBING" in text:
		color = "#FF6B6B"
		prefix = "💣 "
	elif "SABOTAGE" in text:
		color = "#FF6B6B"
		prefix = "☠️ "
	elif "UPGRADE" in text:
		color = "#4ECDC4"
		prefix = "⬆ "
	elif "SHOP" in text or "Not enough" in text:
		color = "#FFE66D"
		prefix = "⚠ "
	elif "LOAN" in text:
		color = "#A8E6CF"
		prefix = "💵 "
	elif "PAY" in text:
		color = "#A8E6CF"
		prefix = "💸 "
	elif "NEW GAME" in text or "MISSION" in text:
		color = "#95E1D3"
		prefix = "★ "
	elif "TIP" in text:
		color = "#C7B3FF"
		prefix = "💡 "
	
	# Clean newlines and add spacing
	var clean_text = text.replace("\n", " ").strip_edges()
	var formatted = "[font_size=14][color=%s][%s] %s%s[/color][/font_size]\n\n" % [color, turn_text, prefix, clean_text]
	history_log.append_text(formatted)
# =========================================================
# UI
# =========================================================
func update_ui():

	var debt_color = "red" if debt > 0 else "gray"
	var hp_ratio = float(bank_hp) / bank_max_hp
	var hp_color = "lime" if hp_ratio > 0.5 else "yellow" if hp_ratio > 0.2 else "red"
	
	PlayerLabel.bbcode_enabled = true
	PlayerLabel.text = \
		"[b][font_size=20]💰 PLAYER[/font_size][/b]\n" + \
		"Money: [color=lime]$" + str(money) + "[/color]\n" + \
		"Debt: [color=" + debt_color + "]$" + str(debt) + "[/color]\n" + \
		"Passive: [color=cyan]$" + str(passive_income) + "/s[/color]\n" + \
		"\nHacking: " + str(hacking) + "\n" + \
		"Bombing: " + str(bombing) + "\n" + \
		"Sabotage: " + str(sabotage_power) + "\n" + \
		"Click: " + str(click_power) + "\n" + \
		"\nTurn: [wave amp=20][color=yellow]" + str(turn) + "[/color][/wave]"

	BankLabel.bbcode_enabled = true
	BankLabel.text = \
		"[b][font_size=20]🏦 BANK[/font_size][/b]\n" + \
		"HP: [color=" + hp_color + "]" + str(bank_hp) + "[/color]/" + str(bank_max_hp) + "\n" + \
		"Security: " + str(security) + "\n" + \
		"Cyber: " + str(cybersecurity) + "\n" + \
		"Strength: " + str(building_strength)
		
	bankhealthText.bbcode_enabled = true
	bankhealthText.text = "[b]BankHealth:[/b] [color=" + hp_color +"]" + str(bank_hp) + "[/color]/" + str(bank_max_hp)
		
	HealthBar.max_value = bank_max_hp
	HealthBar.value = bank_hp

# =========================================================
# HELPERS
# =========================================================
func can_action() -> bool:

	if game_over:
		return false

	if action_cd > 0:
		return false

	action_cd = ACTION_CD_TIME

	return true


func next_turn():

	turn += 1

	process_loan()
	process_negative_money()
	process_bank_upgrade()
	process_random_event()
	check_win()

	update_ui()


func check_win():

	if bank_hp > 0:
		return

	game_over = true
	get_tree().change_scene_to_file.call_deferred("res://scenes/story.tscn")
	push_message(
		"VICTORY\n\nYou Destroyed The Bank!\n\nCreated By King"
	)


func process_negative_money():

	if money < 0:

		negative_turns += 1

		push_message(
			"BANKRUPTCY WARNING\n\nNegative balance for %s / 5 turns."
			% negative_turns
		)

		if negative_turns >= 5:

			game_over = true

			push_message(
				"GAME OVER\n\nYou went bankrupt."
			)

	else:

		negative_turns = 0

# =========================================================
# LOAN SYSTEM
# =========================================================
func process_loan():

	if !loan_active:
		return

	# reminder
	if turn == loan_turn_due - 3:

		push_message(
			"PAYMENT REMINDER\n\nThe lender expects repayment in 3 turns."
		)

	# final warning
	if turn == loan_turn_due - 1:

		push_message(
			"FINAL WARNING\n\nDebt collection will occur next turn."
		)

	# collect debt
	if turn < loan_turn_due:
		return

	var repayment = debt

	money -= repayment

	push_message(
		"DEBT COLLECTOR\n\nThe lender collected your unpaid loan.\n\n-$%s"
		% repayment
	)

	debt = 0
	loan_amount = 0
	loan_active = false
	update_loan_button()


# =========================================================
# BANK UPGRADES
# =========================================================
func process_bank_upgrade():

	if turn == 0:
		return

	if turn % 4 != 0:
		return

	var roll = randi() % 3

	match roll:

		0:

			security += randi_range(1, 2)

			push_message(
				"BANK SECURITY UPGRADE\n\nNew guards and procedures have been implemented.\n\nSecurity +1"
			)

		1:

			cybersecurity += randi_range(1, 2)

			push_message(
				"CYBERSECURITY PATCH\n\nThe bank deployed new security software.\n\nCybersecurity +1"
			)

		2:

			building_strength += randi_range(1, 2)

			push_message(
				"STRUCTURAL REINFORCEMENT\n\nThe bank improved physical defenses.\n\nStrength +1"
			)


# =========================================================
# RANDOM EVENTS
# =========================================================
func process_random_event():

	if turn < event_cooldown:
		return

	# 35% chance
	if randi_range(1, 100) > 35:
		return

	event_cooldown = turn + 3

	var roll = randi() % 8

	match roll:

		0:

			var reward = randi_range(50, 150)

			money += reward

			push_message(
				"ANONYMOUS DONOR\n\nAn unknown individual transferred money into your account.\n\n+$%s"
				% reward
			)

		1:

			var fine = randi_range(30, 100)

			money -= fine

			push_message(
				"POLICE INVESTIGATION\n\nAuthorities investigated suspicious activity.\n\n-$%s"
				% fine
			)

		2:

			hacking += 1

			push_message(
				"SOFTWARE LEAK\n\nConfidential bank software was leaked.\n\nHacking +1"
			)

		3:

			bombing += 1

			push_message(
				"BLACK MARKET CONTACT\n\nNew equipment has become available.\n\nBombing +1"
			)

		4:

			click_power += 1

			push_message(
				"SIDE BUSINESS\n\nA small side operation generated experience.\n\nClick +1"
			)

		5:

			security = max(1, security - 1)

			push_message(
				"POWER OUTAGE\n\nSeveral security systems temporarily failed.\n\nSecurity -1"
			)

		6:

			cybersecurity = max(1, cybersecurity - 1)

			push_message(
				"NETWORK FAILURE\n\nThe bank suffered a system outage.\n\nCybersecurity -1"
			)

		7:

			var cash = randi_range(25, 75)

			money += cash

			push_message(
				"FOUND CASH\n\nA hidden stash of money was discovered.\n\n+$%s"
				% cash
			)

# =========================================================
# ACTIONS
# =========================================================

func OnHack():

	if !can_action():
		return

	var chance = clamp(
		35 + (hacking * 5) - (cybersecurity * 4),
		10,
		95
	)

	if randi_range(1, 100) <= chance:

		var reward = randi_range(
			25 + hacking * 10,
			60 + hacking * 15
		)

		# critical hack
		if randi_range(1, 100) <= 10:

			reward *= 3

			push_message(
				"CRITICAL HACK\n\nA major vulnerability was exploited.\n\n+$%s"
				% reward
			)

		else:

			push_message(
				"HACK SUCCESS\n\nFunds were successfully transferred.\n\n+$%s"
				% reward
			)

		money += reward

	else:

		var loss = randi_range(
			15,
			35 + cybersecurity * 2
		)

		money -= loss

		push_message(
			"HACK FAILED\n\nThe attack was detected.\n\n-$%s"
			% loss
		)

	next_turn()


# =========================================================

func OnBomb():

	if !can_action():
		return

	var caught = clamp(
		35 + security * 3,
		10,
		95
	)

	if randi_range(1, 100) <= caught:

		var fine = randi_range(
			20,
			40 + security * 2
		)

		money -= fine

		push_message(
			"CAUGHT\n\nAuthorities intercepted the operation.\n\n-$%s"
			% fine
		)

	else:

		var damage = max(
			5,
			(bombing * 20) -
			(building_strength * 3)
		)

		if randi_range(1, 100) <= 15:

			damage *= 2

			push_message(
				"MEGA EXPLOSION\n\nThe blast exceeded expectations.\n\n-%s HP"
				% damage
			)

		else:

			push_message(
				"EXPLOSION\n\nThe bank suffered structural damage.\n\n-%s HP"
				% damage
			)

		bank_hp -= damage

		if bank_hp < 0:
			bank_hp = 0

	next_turn()


# =========================================================

func OnSabotage():

	if !can_action():
		return

	var cost = 20 + sabotage_power * 5

	money -= cost

	var stat = randi() % 3

	match stat:

		0:

			var amount = max(1, sabotage_power)

			security = max(
				1,
				security - amount
			)

			push_message(
				"SABOTAGE SUCCESS\n\nSecurity procedures were disrupted.\n\nSecurity -%s"
				% amount
			)

		1:

			var amount = max(1, sabotage_power)

			cybersecurity = max(
				1,
				cybersecurity - amount
			)

			push_message(
				"SABOTAGE SUCCESS\n\nCritical systems were compromised.\n\nCybersecurity -%s"
				% amount
			)

		2:

			var amount = max(1, sabotage_power)

			building_strength = max(
				1,
				building_strength - amount
			)

			push_message(
				"SABOTAGE SUCCESS\n\nPhysical infrastructure was weakened.\n\nStrength -%s"
				% amount
			)

	next_turn()


# =========================================================
# LOAN BUTTON
# =========================================================

func OnLoan():

	if !can_action():
		return

	# repay current loan
	if loan_active:

		if money < debt:

			push_message(
				"LOAN REPAYMENT\n\nYou need $%s to repay the loan."
				% debt
			)

			return

		money -= debt

		push_message(
			"LOAN REPAID\n\nThe debt has been cleared.\n\n-$%s"
			% debt
		)

		debt = 0
		loan_amount = 0
		loan_turn_due = -1
		loan_active = false
		update_loan_button()

		next_turn()
		return

	# take new loan

	var amount = 250

	money += amount

	loan_amount = amount
	debt = int(amount * 1.5)

	loan_active = true
	
	loan_turn_due = turn + randi_range(10, 15)
	update_loan_button()
	
	push_message(
		"LOAN APPROVED\n\nFunds have been deposited.\n\n+$%s\nRepay: $%s"
		% [amount, debt]
	)

	next_turn()


# =========================================================
# CLICK
# =========================================================

func OnBank():

	if game_over:
		return

	var earned = max(
		1,
		click_power + int(hacking * 0.3)
	)

	earned = max(
		1,
		earned - int(turn / 25.0)
	)

	money += earned

	push_message(
		"MANUAL INCOME\n\n+$%s"
		% earned
	)

	update_ui()

# =========================================================
# SHOP
# =========================================================

func update_shop_buttons():

	var ids = [
		"Hacking",
		"Bombing",
		"Sabotage",
		"Click",
		"Passive"
	]

	for i in range(shopbut.size()):

		var id = ids[i]

		var item = upgrades[id]
		var info = upgrade_info[id]

		shopbut[i].text = ""

		var label = shopbut[i].get_node("RichLabel")

		label.bbcode_enabled = true

		label.text = \
			"[center]" + \
			"[b]" + info["name"] + "[/b]\n" + \
			"Lv." + str(item["level"]) + "\n" + \
			info["description"] + "\n" + \
			"[color=yellow]$" + str(item["price"]) + "[/color]" + \
			"[/center]"

func create_shop_button(id:String):

	var btn = ShopButton.new()

	btn.setup(id, upgrades[id].price)

	btn.selected.connect(_on_shop_item_selected)

	%VBoxContainer.add_child(btn)
	
func _on_shop_item_selected(id:String):

	selected_upgrade = id

	var item = upgrades[id]

	npc_text.text = "Do you wish to buy %s upgrade for $%s?" % [
		id,
		item["price"]
	]

	yes_button.show()
	no_button.show()

func _on_yes_button_pressed():

	if selected_upgrade == "":
		return

	buy_upgrade(selected_upgrade)

	selected_upgrade = ""

	yes_button.hide()
	no_button.hide()

	npc_text.text = "Anything else?"
	
func _on_no_button_pressed():

	selected_upgrade = ""

	yes_button.hide()
	no_button.hide()

	npc_text.text = "Come back anytime."
	
# =========================================================
# BUY UPGRADE
# =========================================================

func buy_upgrade(id:String):

	var item = upgrades[id]

	if money < item["price"]:

		push_message(
			"SHOP\n\nNot enough money.\n\nNeed $%s"
			% item["price"]
		)

		return

	money -= item["price"]

	item["level"] += 1

	match id:

		"Hacking":

			hacking += 1

			push_message(
				"HACKING UPGRADE\n\nLevel %s"
				% item["level"]
			)

		"Bombing":

			bombing += 1

			push_message(
				"BOMBING UPGRADE\n\nLevel %s"
				% item["level"]
			)

		"Sabotage":

			sabotage_power += 1

			push_message(
				"SABOTAGE UPGRADE\n\nLevel %s"
				% item["level"]
			)

		"Click":

			click_power += 1

			push_message(
				"CLICK UPGRADE\n\nLevel %s"
				% item["level"]
			)

		"Passive":

			passive_income += 1

			push_message(
				"PASSIVE INCOME UPGRADE\n\nIncome +1/sec"
			)

	# scale prices

	var growth = item["growth"]

	if item["level"] >= 10:
		growth += 0.05

	if item["level"] >= 20:
		growth += 0.10

	if item["level"] >= 30:
		growth += 0.15

	item["price"] = max(
		1,
		ceili(item["price"] * growth)
	)

	upgrades[id] = item

	update_ui()


# =========================================================
# RESET GAME
# =========================================================

func reset_game():

	money = 67
	debt = 0

	hacking = 1
	bombing = 1
	sabotage_power = 1
	click_power = 1
	passive_income = 0

	bank_hp = 1000
	bank_max_hp = 1000

	security = 1
	cybersecurity = 1
	building_strength = 1

	turn = 0

	game_over = false
	negative_turns = 0

	loan_active = false
	loan_amount = 0
	loan_turn_due = -1

	event_cooldown = 0

	upgrades = {
		"Hacking": {
			"level": 1,
			"price": 40,
			"growth": 1.35
		},

		"Bombing": {
			"level": 1,
			"price": 60,
			"growth": 1.45
		},

		"Sabotage": {
			"level": 1,
			"price": 70,
			"growth": 1.50
		},

		"Click": {
			"level": 1,
			"price": 25,
			"growth": 1.30
		},

		"Passive": {
			"level": 1,
			"price": 100,
			"growth": 1.50
		}
	}

	update_ui()

	push_message(
		"NEW GAME\n\nDestroy the bank."
	 )

const LOAN_INDEX := 3

func update_loan_button():

	if loan_active:
		actions[LOAN_INDEX].update_text("Pay")
		actions[LOAN_INDEX].update_icon(pay_icon)
	else:
		actions[LOAN_INDEX].update_text("Loan")
		actions[LOAN_INDEX].update_icon(loan_icon)

# =========================================================
# READY
# =========================================================

func _ready():
	update_shop_buttons()
	
	for child in %VBoxContainer.get_children():

		if child is ShopButton:
			child.selected.connect(_on_shop_item_selected)

	action_icons = [
	hack_icon,
	bomb_icon,
	sabotage_icon,
	loan_icon
	]
	
	
	for i in range(actions.size()):
		actions[i].update_text(actionNames[i])
		actions[i].update_icon(action_icons[i])
	update_loan_button()

	update_ui()


	push_message(
		"MISSION\n\nDestroy the bank before going bankrupt."
	)

	push_message(
		"TIP\n\nHacking is the fastest early-game income source."
	)

	push_message(
		"TIP\n\nLoans can be repaid early by pressing the loan button again."
	)
