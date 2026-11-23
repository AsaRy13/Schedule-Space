# Core
## Requirements
1. Accept tasks
2. Display tasks
3. Optimize task scheduling based on:
* Length (Ranked)
* Complexity
4. Users provide feedback about their performance of each task for continued schedule optimization.

## Architecture
1. Hexagonal
2. Layers
* Domain
* Infrastructure
* Presentation
3. Features
* Tasks
* Optimizer
* Stats

## Initial scheduler behavior
* Add a task with a title, estimated minutes, and complexity from 1 (simplest) to 5 (most complex).
* Schedule pending tasks by shortest estimated duration, then lowest complexity; preserve creation order for exact ties.
* Record actual minutes as task feedback. Future estimates are calibrated using the running average of actual-to-estimated duration ratios for tasks with the same complexity.
* The public API is in `project.ex` (`ScheduleSpace.new/0`, `add_task/2`, `list_tasks/1`, `schedule/1`, `record_feedback/3`, and `stats/1`).

# Calender
## Requirements
