class_name CardPile
extends Resource

signal card_pile_size_changed(cards_amount)
signal card_added(card)

@export var cards: Array[Card] = []

func size() -> int:
	return cards.size()

func empty() -> bool:
	return cards.is_empty()

func draw_card() -> Card:
	var card = cards.pop_front()
	card_pile_size_changed.emit(cards.size())
	return card

func add_card(card: Card) -> void:
	cards.append(card)
	Tweakables.debug_print("sending card_added signal", Tweakables.DEBUG_LEVELS.DEBUG)
	card_added.emit(card)
	card_pile_size_changed.emit(cards.size())

func shuffle() -> void:
	cards.shuffle()

func clear() -> void:
	cards.clear()
	card_pile_size_changed.emit(cards.size())

func _to_string() -> String:
	var _card_strings: PackedStringArray = []
	for i in range(cards.size()):
		_card_strings.append("%s: %s" % [i+1, cards[i].id])
	return "\n".join(_card_strings)
	
