extends Area2D

var is_empty:bool:
	get:
		return (not has_overlapping_areas() and not has_overlapping_bodies())
