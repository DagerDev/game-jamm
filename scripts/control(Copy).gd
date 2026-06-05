extends Control

# =========================
# UI
# =========================
@onready var PlayerLabel = %PlayerStats
@onready var BankLabel = %BankStats
@onready var InfoLabel = %Info
@onready var HealthBar = %HealthBank

# ==========================
# SHOP BUTTON
# ==≠=======================
@onready var shopbut = [
	%Hacking,
	%Bombing,
	%Sabotage,
	%Clicking
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

# =========================
# PLAYER
# =========================
var money := 10000000
var debt := 0

var hacking := 1
var bombing := 1
var sabotage_power := 1
var click_power := 1

# =========================
# BANK
# =========================
var bank_hp := 1000
var bank_max_hp := 1000

var security := 1
var cybersecurity := 1
var building_strength := 1

# =========================
# GAME
# =========================
var turn := 0

var negative_turns := 0

# global cooldown
var action_cd := 0.0
const ACTION_CD_TIME := 1.0

# loan
var loan_active := false
var loan_turn_due := -1
var loan_amount := 0

# =========================
# UPGRADES
# Easy to add more
# =========================
var upgrades := {
	"Hacking": {
		"level": 1,
		"price": 50,
		"growth": 1.5
	},
	"Bombing": {
		"level": 1,
		"price": 50,
		"growth": 1.5
	},
	"Sabotage": {
		"level": 1,
		"price": 50,
		"growth": 1.5
	},
	"Click": {
		"level": 1,
		"price": 30,
		"growth": 1.4
	}
}

func _process(delta):
	if action_cd > 0:
		action_cd -= delta

# =========================
# UI
# =========================
func update_ui():
	PlayerLabel.text = \
	"PLAYER\n" + \
	"Money: $" + str(money) + "\n" + \
	"Debt: $" + str(debt) + "\n" + \
	"Hacking: " + str(hacking) + "\n" + \
	"Bombing: " + str(bombing) + "\n" + \
	"Sabotage: " + str(sabotage_power) + "\n" + \
	"Click: " + str(click_power) + "\n" + \
	"Turn: " + str(turn)

	BankLabel.text = \
	"BANK\n" + \
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
		
# =========================
# HELPERS
# =========================
func can_action() -> bool:
	if action_cd > 0:
		InfoLabel.text = "Cooldown: %.1f sec left" % action_cd
		return false

	action_cd = ACTION_CD_TIME
	return true

func next_turn():
	turn += 1

	process_loan()
	process_negative_money()
	process_bank_upgrade()

	check_win()

	update_ui()

func check_win():
	if bank_hp <= 0:
		InfoLabel.text = "YOU BROKE THE BANK!"

func process_negative_money():
	if money < 0:
		negative_turns += 1

		if negative_turns >= 5:
			InfoLabel.text = "GAME OVER\nLost with $" + str(abs(money))
			get_tree().paused = true
	else:
		negative_turns = 0

func process_loan():
	if loan_active and turn >= loan_turn_due:
		var repayment = int(loan_amount * 1.5)

		money -= repayment
		debt = 0
		loan_amount = 0
		loan_active = false

		InfoLabel.text = \
		"Loan collected!\nPaid $" + str(repayment)

func process_bank_upgrade():
	if turn == 0:
		return

	if turn % 3 != 0:
		return

	var roll = randi() % 3

	match roll:
		0:
			security += randi_range(1,3)

			if cybersecurity > 1 and randi() % 2 == 0:
				cybersecurity -= 1

			InfoLabel.text = "Bank upgraded Security"

		1:
			cybersecurity += randi_range(1,3)

			if security > 1 and randi() % 2 == 0:
				security -= 1

			InfoLabel.text = "Bank upgraded Cybersecurity"

		2:
			building_strength += randi_range(1,3)

			if cybersecurity > 1 and randi() % 2 == 0:
				cybersecurity -= 1

			InfoLabel.text = "Bank upgraded Building Strength"

# =========================
# ACTIONS
# =========================
func OnHack():
	if !can_action():
		return

	var chance = clamp(25 + hacking * 5 - cybersecurity * 3, 5, 90)

	if randi_range(1,100) <= chance:
		var reward = randi_range(40,80) * hacking
		money += reward

		InfoLabel.text = \
		"Hack Success\n+$" + str(reward)
	else:
		var loss = randi_range(20,40)
		money -= loss

		InfoLabel.text = \
		"Hack Failed\n-$" + str(loss)

	next_turn()

func OnBomb():
	if !can_action():
		return

	var caught = clamp(50 + security * 2, 10, 95)

	if randi_range(1,100) <= caught:
		var loss = randi_range(20,50)

		money -= loss

		InfoLabel.text = \
		"CAUGHT!\n-$" + str(loss)
	else:
		var damage = max(5, bombing * 15 - building_strength * 2)

		bank_hp -= damage

		InfoLabel.text = \
		"BOOM!\n-" + str(damage) + " HP"

	next_turn()

func OnSabotage():
	if !can_action():
		return

	var cost = 30

	money -= cost

	var stat = randi() % 3

	match stat:
		0:
			security = max(1, security - sabotage_power)

			InfoLabel.text = \
			"Security Reduced"

		1:
			cybersecurity = max(1, cybersecurity - sabotage_power)

			InfoLabel.text = \
			"Cybersecurity Reduced"

		2:
			building_strength = max(1, building_strength - sabotage_power)

			InfoLabel.text = \
			"Building Strength Reduced"

	next_turn()

func OnLoan():
	if !can_action():
		return

	if loan_active:
		InfoLabel.text = "Existing loan unpaid!"
		return

	loan_amount = 250

	money += loan_amount
	debt = int(loan_amount * 1.5)

	loan_active = true
	loan_turn_due = turn + randi_range(10,15)

	InfoLabel.text = \
	"Loan Approved\n+$" + str(loan_amount)

	next_turn()

func OnBank():
	var earned = click_power

	money += earned

	InfoLabel.text = \
	"+$" + str(earned)
	
	update_ui()

# =========================
# SHOP
# =========================
func UpgradeHacking():
	buy_upgrade("Hacking")

func UpgradeBombing():
	buy_upgrade("Bombing")

func UpgradeSabotage():
	buy_upgrade("Sabotage")

func UpgradeClick():
	buy_upgrade("Click")

func buy_upgrade(id:String):
	var item = upgrades[id]

	if money < item.price:
		InfoLabel.text = "Not enough money!"
		return

	money -= item.price

	item.level += 1

	match id:
		"Hacking":
			hacking += 1

		"Bombing":
			bombing += 1

		"Sabotage":
			sabotage_power += 1

		"Click":
			click_power += 1

	item.price = int(item.price * item.growth)

	upgrades[id] = item

	InfoLabel.text = \
	id + " Upgraded!\nNext Price: $" + str(item.price)
	
	update_ui()

func _ready():
	randomize()
	update_ui()
	for i in shopbut.size():
		shopbut[i].OnBuy.connect(shopfunc[i])
		shopbut[i].getTitle(shopTitles[i])
