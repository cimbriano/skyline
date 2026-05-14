# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Skyline transforms MIDI music files into 3D-printable OpenSCAD models. Each unique note (C, C#, D, … B) becomes a building whose height = note count, width = average note duration, and depth = total duration rank. Octaves become layers within each building; individual note occurrences become windows.

## Running the Pipeline

```bash
ruby run.rb [options] <midi_file>
```

Options (default is `--all`):
- `--midi` / `-m` — parse MIDI → `out/notes_*.csv`
- `--stats` / `-s` — compute statistics → `out/stats_*.json`
- `--scad` / `-d` — generate OpenSCAD → `out/scad_*.scad`
- `--all` — run all three stages

```bash
ruby run.rb 0_input_midi/song.mid          # full pipeline, one file
ruby run.rb 0_input_midi/*.mid             # batch all MIDI files
ruby run.rb --scad 0_input_midi/song.mid   # re-render only (stats already exist)
```

## Dependencies

- Ruby 3.0.0 (`.ruby-version`); gem: `byebug` — install with `bundle install`
- Python 3.11.8 via pyenv virtualenv named `skyline` (`.python-version`);
  packages: `pandas`, `numpy` — install with `pip3 install -r requirements.txt`
  (the virtualenv is created with `pyenv virtualenv 3.11.8 skyline`)
- OpenSCAD (external, for viewing/rendering `.scad` output) — note that
  OpenSCAD does not auto-render on open; press F5 for preview or F6 to
  render the 3D model

The Ruby pipeline invokes `python3` as a subprocess for the stats stage.

## Pipeline Architecture

Four numbered directories map to four stages:

```
0_input_midi/   MIDI source files
1_midi/         Ruby: MIDI binary → Note objects → notes_*.csv
2_stats/        Python: notes CSV → hierarchical JSON (stats_*.json)
3_object_model/ Ruby: stats JSON → in-memory object graph → scad_*.scad
4_openscad/     OpenSCAD module library included by generated .scad files
out/            All generated outputs land here (gitignored)
baselines/      Frozen 2015 outputs from the original pipeline, for diffing
```

**Stage 1 — MIDI parsing** (`1_midi/`): `midifile.rb` reads raw MIDI events; `NoteQueue` (`nqueue.rb`) pairs NOTE_ON/NOTE_OFF events (handles overlapping and unmatched events without raising); `Note` builds per-event rows written as CSV.

**Stage 2 — Statistics** (`2_stats/stats.py`): pandas aggregates the CSV into a three-level hierarchy — song summary → per-letter (note name) summary → per-octave summary — and writes `stats_*.json`.

**Stage 3 — Object model** (`3_object_model/`): `Area` reads stats JSON and builds a tree of `Building` → `Layer` → `Window` objects. `Area#scale` computes the required total width of all buildings and picks a target print size (vertical 70×140, square 100×100, horizontal 140×70) based on aspect ratio. `Model#to_scad` / `Model#write_out_code` recursively emit OpenSCAD source with `include` statements for the library modules in `4_openscad/`.

**Stage 4 — OpenSCAD modules** (`4_openscad/`): Pure `.scad` files defining `area()`, `layer()`, `window()`, `layer_divider()`, `base()`. The generated `.scad` file references these with relative paths, so both must be present when opening in OpenSCAD.

## Key Design Decisions

- Window density is driven by `notes_per_sec`: `num_windows = (density * MAX_WINDOWS).to_i`, capped at 1.0 so very fast passages don't produce degenerate geometry.
- The generated model is wrapped in `rotate([90,0,65])` + `translate(...)` for a default isometric-style perspective when opened in OpenSCAD.
- `keys.py` defines the 12 major/minor keys but is not currently wired into the stats pipeline.
