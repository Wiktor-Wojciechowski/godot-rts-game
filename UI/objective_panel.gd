extends Panel

@onready var name_label = $NameLabel
@onready var description_label = $DescriptionLabel

# Sets the objective's properties
func set_objective(objective) -> void:
	$NameLabel.text = objective.objective_name
	$DescriptionLabel.text = objective.description
	$CompletionLabel.text = "Completed: " + str(objective.completed)
	$ProgressBar.value = objective.progress
	print("progress: ", objective.progress)
	#progress_bar.value = float(progress) if progress.is_valid_float() else 0
	#check_mark.visible = progress == "complete"
