extends Control

# =========================================================
# UI
# =========================================================
@onready var PlayerLabel = %PlayerStats
@onready var BankLabel = %BankStats
#@onready var InfoLabel = %StatusLabel
@onready var HealthBar = %HealthBank
@onready var shop_controller = %Tweenss

@onready var shopbut = [
	%HackingBuy,
	%BombingBuy,
	%SabotageBuy,
	%ClickingBuy
]

const shopTitles = [
	"Upgrade Hacking",
	"Upgrade Bombing",
	"Upgrade Sabotage",
	"Upgrade Clicking"
]

var shopfunc = [
	UpgradeHacking,
	UpgradeBombing,
	UpgradeSabotage,
	UpgradeClick
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

# =========================================================
# BANK
# =========================================================
var bank_level := 1

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
# MESSAGE QUEUE
# prevents text instantly replacing itself
# =========================================================
var message_queue:Array[String] = []

var current_message_time := 0.0
const MESSAGE_DURATION := 2.0

# =========================================================
# TIMERS
# =========================================================
var passive_timer := 0.0
var event_timer := 0.0

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
	}
}

# =========================================================
# PROCESS
# =========================================================
func _process(delta):

	if action_cd > 0:
		action_cd -= delta

	#if message_timer > 0:
		#message_timer -= delta
		#if message_timer <= 0:
			#InfoLabel.text = ""

	passive_timer += delta

	if passive_timer >= 5.0:
		passive_timer = 0

		var passive_income = max(1, click_power / 2.0)

		money += passive_income

		push_message(
			"Passive Income\n+$%s" % passive_income
		)

		update_ui()

# =========================================================
# MESSAGE SYSTEM
# =========================================================
var message_timer := 0.0

func push_message(text:String): 
	shop_controller.push_message(text)

# =========================================================
# UI
# =========================================================
func update_ui():

	PlayerLabel.text = \
	"PLAYER\n" + \
	"Money: $" + str(money) + "\n" + \
	"Debt: $" + str(debt) + "\n" + \
	"\nHacking: " + str(hacking) + "\n" + \
	"Bombing: " + str(bombing) + "\n" + \
	"Sabotage: " + str(sabotage_power) + "\n" + \
	"Click: " + str(click_power) + "\n" + \
	"\nTurn: " + str(turn)

	BankLabel.text = \
	"BANK Lv." + str(bank_level) + "\n" + \
	"HP: " + str(bank_hp) + "/" + str(bank_max_hp) + "\n" + \
	"Security: " + str(security) + "\n" + \
	"Cyber: " + str(cybersecurity) + "\n" + \
	"Strength: " + str(building_strength)

	HealthBar.max_value = bank_max_hp
	HealthBar.value = bank_hp

	var upgradesPrice = [
		upgrades["Hacking"].price,
		upgrades["Bombing"].price,
		upgrades["Sabotage"].price,
		upgrades["Click"].price
	]

	for i in shopbut.size():
		shopbut[i].getPrice(upgradesPrice[i])

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
	check_bank_phase()
	check_win()

	update_ui()

func check_win():

	if bank_hp > 0:
		return

	bank_level += 1

	var reward = bank_level * 500

	money += reward

	push_message(
		"BANK DESTROYED!\nReward: $" + str(reward)
	)

	spawn_new_bank()

func spawn_new_bank():

	bank_max_hp = 1000 + (bank_level * 400)
	bank_hp = bank_max_hp

	security = 1 + bank_level
	cybersecurity = 1 + bank_level
	building_strength = 1 + bank_level

	update_ui()

func process_negative_money():

	if money < 0:

		negative_turns += 1

		push_message(
			"Negative Balance!\n(%s/5)" %
			negative_turns
		)

		if negative_turns >= 5:

			game_over = true

			push_message(
				"GAME OVER\nBankrupt"
			)

	else:

		negative_turns = 0

func process_loan():

	if !loan_active:
		return

	if turn < loan_turn_due:
		return

	var repayment = debt

	money -= repayment

	push_message(
		"Loan Collected!\n-$%s" %
		repayment
	)

	debt = 0
	loan_amount = 0
	loan_active = false

func check_bank_phase():

	var hp_percent = float(bank_hp) / float(bank_max_hp)

	if hp_percent <= 0.25:

		security += 1
		cybersecurity += 1

func process_bank_upgrade():

	if turn == 0:
		return

	if turn % 4 != 0:
		return

	var roll = randi() % 3

	match roll:

		0:
			security += randi_range(1,2)

			push_message(
				"Bank Upgraded Security"
			)

		1:
			cybersecurity += randi_range(1,2)

			push_message(
				"Bank Upgraded Cybersecurity"
			)

		2:
			building_strength += randi_range(1,2)

			push_message(
				"Bank Upgraded Strength"
			)

func process_random_event():

	if turn < event_cooldown:
		return

	if randi_range(1,100) > 20:
		return

	event_cooldown = turn + 4

	var roll = randi() % 5

	match roll:

		0:
			var reward = randi_range(30,100)

			money += reward

			push_message(
				"Anonymous Donation\n+$%s"
				% reward
			)

		1:
			var fine = randi_range(20,80)

			money -= fine

			push_message(
				"Police Investigation\n-$%s"
				% fine
			)

		2:
			hacking += 1

			push_message(
				"Found Exploit\nHack +1"
			)

		3:
			bombing += 1

			push_message(
				"Black Market Deal\nBomb +1"
			)

		4:
			click_power += 1

			push_message(
				"Side Job\nClick +1"
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

	if randi_range(1,100) <= chance:

		var reward = randi_range(
			25 + hacking * 10,
			60 + hacking * 15
		)

		# critical hack
		if randi_range(1,100) <= 10:

			reward *= 3

			push_message(
				"CRITICAL HACK!\n+$%s" %
				reward
			)

		else:

			push_message(
				"Hack Success\n+$%s" %
				reward
			)

		money += reward

	else:

		var loss = randi_range(
			15,
			35 + cybersecurity * 2
		)

		money -= loss

		push_message(
			"Hack Failed\n-$%s" %
			loss
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

	if randi_range(1,100) <= caught:

		var fine = randi_range(
			20,
			40 + security * 2
		)

		money -= fine

		push_message(
			"CAUGHT!\n-$%s" %
			fine
		)

	else:

		var damage = max(
			5,
			(bombing * 20) -
			(building_strength * 3)
		)

		# critical explosion
		if randi_range(1,100) <= 15:

			damage *= 2

			push_message(
				"MEGA EXPLOSION!\n-%s HP" %
				damage
			)

		else:

			push_message(
				"BOOM!\n-%s HP" %
				damage
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

			var amount = max(
				1,
				sabotage_power
			)

			security = max(
				1,
				security - amount
			)

			push_message(
				"Security Reduced\n-%s"
				% amount
			)

		1:

			var amount = max(
				1,
				sabotage_power
			)

			cybersecurity = max(
				1,
				cybersecurity - amount
			)

			push_message(
				"Cybersecurity Reduced\n-%s"
				% amount
			)

		2:

			var amount = max(
				1,
				sabotage_power
			)

			building_strength = max(
				1,
				building_strength - amount
			)

			push_message(
				"Building Strength Reduced\n-%s"
				% amount
			)

	next_turn()

# =========================================================
# LOAN
# Press again while loan exists to repay it
# =========================================================

func OnLoan():

	if !can_action():
		return

	# repay existing loan
	if loan_active:

		if money < debt:

			push_message(
				"Need $%s To Repay"
				% debt
			)

			return

		money -= debt

		push_message(
			"Loan Repaid\n-$%s"
			% debt
		)

		debt = 0
		loan_amount = 0
		loan_active = false
		loan_turn_due = -1

		next_turn()
		return

	# take loan

	var amount = 250 + bank_level * 50

	money += amount

	loan_amount = amount

	debt = int(amount * 1.50)

	loan_active = true

	loan_turn_due = turn + randi_range(
		10,
		15
	)

	push_message(
		"Loan Approved\n+$%s\nRepay $%s"
		% [amount, debt]
	)

	next_turn()

# =========================================================
# CLICK
# Strong early game
# Weak late game
# =========================================================

func OnBank():

	if game_over:
		return

	var earned = max(
		1,
		click_power +
		int(hacking * 0.3)
	)

	# diminishing returns
	earned = max(
		1,
		earned - int(turn / 25.0)
	)

	money += earned

	push_message(
		"+$%s"
		% earned
	)

	update_ui()


# =========================================================
# SHOP
# =========================================================

func UpgradeHacking():
	buy_upgrade("Hacking")

func UpgradeBombing():
	buy_upgrade("Bombing")

func UpgradeSabotage():
	buy_upgrade("Sabotage")

func UpgradeClick():
	buy_upgrade("Click")

# =========================================================
# BALANCED SHOP
# =========================================================

func buy_upgrade(id:String):

	var item = upgrades[id]

	if money < item.price:

		push_message(
			"Not Enough Money!\nNeed $" +
			str(item.price)
		)

		return

	money -= item.price

	item.level += 1

	match id:

		"Hacking":

			hacking += 1

			push_message(
				"Hacking Lv." +
				str(item.level)
			)

		"Bombing":

			bombing += 1

			push_message(
				"Bombing Lv." +
				str(item.level)
			)

		"Sabotage":

			sabotage_power += 1

			push_message(
				"Sabotage Lv." +
				str(item.level)
			)

		"Click":

			click_power += 1

			push_message(
				"Click Lv." +
				str(item.level)
			)

	# -------------------------
	# Dynamic scaling
	# -------------------------

	var growth = item.growth

	# make high levels expensive
	if item.level >= 10:
		growth += 0.05

	if item.level >= 20:
		growth += 0.10

	if item.level >= 30:
		growth += 0.15

	item.price = max(
		1,
		ceili(item.price * growth)
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

	bank_level = 1

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
		}
	}

	update_ui()

	push_message(
		"New Game Started"
	)

# =========================================================
# SAVE
# =========================================================

func SaveGame():

	var data = {

		"money": money,
		"debt": debt,

		"hacking": hacking,
		"bombing": bombing,
		"sabotage_power": sabotage_power,
		"click_power": click_power,

		"bank_level": bank_level,

		"bank_hp": bank_hp,
		"bank_max_hp": bank_max_hp,

		"security": security,
		"cybersecurity": cybersecurity,
		"building_strength": building_strength,

		"turn": turn,

		"loan_active": loan_active,
		"loan_amount": loan_amount,
		"loan_turn_due": loan_turn_due,

		"upgrades": upgrades
	}

	var file = FileAccess.open(
		"user://save.json",
		FileAccess.WRITE
	)

	file.store_string(
		JSON.stringify(data)
	)

	push_message(
		"Game Saved"
	)

# =========================================================
# LOAD
# =========================================================

func LoadGame():

	if !FileAccess.file_exists(
		"user://save.json"
	):
		return

	var file = FileAccess.open(
		"user://save.json",
		FileAccess.READ
	)

	var data = JSON.parse_string(
		file.get_as_text()
	)

	if data == null:
		return

	money = data.money
	debt = data.debt

	hacking = data.hacking
	bombing = data.bombing
	sabotage_power = data.sabotage_power
	click_power = data.click_power

	bank_level = data.bank_level

	bank_hp = data.bank_hp
	bank_max_hp = data.bank_max_hp

	security = data.security
	cybersecurity = data.cybersecurity
	building_strength = data.building_strength

	turn = data.turn

	loan_active = data.loan_active
	loan_amount = data.loan_amount
	loan_turn_due = data.loan_turn_due

	upgrades = data.upgrades

	update_ui()

	push_message(
		"Save Loaded"
	)

# =========================================================
# READY
# =========================================================

func _ready():

	randomize()

	update_ui()

	for i in shopbut.size():

		shopbut[i].OnBuy.connect(
			shopfunc[i]
		)

		shopbut[i].getTitle(
			shopTitles[i]
		)

	push_message(
		"Destroy The Bank"
	)

	push_message(
		"Upgrade Hacking For Fast Money"
	)

	push_message(
		"Loan Can Be Repaid Early"
	)
