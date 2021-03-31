extends Entity

onready var Port_Hind_Leg = get_node("Port_Hind/Leg")
onready var Port_Hind_Ray = get_node("Port_Hind/RayCast")
onready var Port_Hind_Dot = get_node("Port_Hind/Dot")

onready var Port_MidHind_Leg = get_node("Port_MidHind/Leg")
onready var Port_MidHind_Ray = get_node("Port_MidHind/RayCast")
onready var Port_MidHind_Dot = get_node("Port_MidHind/Dot")

onready var Port_MidFront_Leg = get_node("Port_MidFront/Leg")
onready var Port_MidFront_Ray = get_node("Port_MidFront/RayCast")
onready var Port_MidFront_Dot = get_node("Port_MidFront/Dot")

onready var Port_Front_Leg = get_node("Port_Front/Leg")
onready var Port_Front_Ray = get_node("Port_Front/RayCast")
onready var Port_Front_Dot = get_node("Port_Front/Dot")

onready var Starboard_Hind_Leg = get_node("Starboard_Hind/Leg")
onready var Starboard_Hind_Ray = get_node("Starboard_Hind/RayCast")
onready var Starboard_Hind_Dot = get_node("Starboard_Hind/Dot")

onready var Starboard_MidHind_Leg = get_node("Starboard_MidHind/Leg")
onready var Starboard_MidHind_Ray = get_node("Starboard_MidHind/RayCast")
onready var Starboard_MidHind_Dot = get_node("Starboard_MidHind/Dot")

onready var Starboard_MidFront_Leg = get_node("Starboard_MidFront/Leg")
onready var Starboard_MidFront_Ray = get_node("Starboard_MidFront/RayCast")
onready var Starboard_MidFront_Dot = get_node("Starboard_MidFront/Dot")

onready var Starboard_Front_Leg = get_node("Starboard_Front/Leg")
onready var Starboard_Front_Ray = get_node("Starboard_Front/RayCast")
onready var Starboard_Front_Dot = get_node("Starboard_Front/Dot")

func _ready():
	legs = [
		[Port_Hind_Leg, Port_Hind_Ray, Port_Hind_Dot, Port_Hind_Ray.transform.origin],
		[Starboard_Hind_Leg, Starboard_Hind_Ray, Starboard_Hind_Dot, Starboard_Hind_Ray.transform.origin],
		[Port_MidFront_Leg, Port_MidFront_Ray, Port_MidFront_Dot, Port_MidFront_Ray.transform.origin],
		[Starboard_MidFront_Leg, Starboard_MidFront_Ray, Starboard_MidFront_Dot, Starboard_MidFront_Ray.transform.origin],
		[Port_MidHind_Leg, Port_MidHind_Ray, Port_MidHind_Dot, Port_MidHind_Ray.transform.origin],
		[Starboard_MidHind_Leg, Starboard_MidHind_Ray, Starboard_MidHind_Dot, Starboard_MidHind_Ray.transform.origin],
		[Port_Front_Leg, Port_Front_Ray, Port_Front_Dot, Port_Front_Ray.transform.origin],
		[Starboard_Front_Leg, Starboard_Front_Ray, Starboard_Front_Dot, Starboard_Front_Ray.transform.origin]
	]
