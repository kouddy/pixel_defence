extends Node
## SFX (autoload singleton)
## Procedurally synthesized retro sound effects — no external audio files needed.
## Sounds are generated once at _ready() as AudioStreamWAV (16-bit PCM), cached,
## and played through pooled AudioStreamPlayer nodes so overlapping shots/hits
## never cut each other off.
##
## Design: short, crunchy, 8-bit-style. Noise bursts for hits/explosions, quick
## pitch-swept square tones for shoots/placement. Every combat event has a voice.

const SAMPLE_RATE := 22050

# Cached streams, keyed by name.
var _streams: Dictionary = {}
# Player pool for polyphony.
var _players: Array[AudioStreamPlayer] = []
var _pool_idx: int = 0
const POOL_SIZE := 8

var _master_vol: float = 0.6
var _muted: bool = false


func _ready() -> void:
	_build_all()
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)


# ============================ PUBLIC API ============================

func shoot() -> void:        _play("shoot")
func hit() -> void:          _play("hit")
func enemy_die() -> void:    _play("enemy_die")
func boss_die() -> void:     _play("boss_die")
func place() -> void:        _play("place")
func leak() -> void:         _play("leak")
func wave_start() -> void:   _play("wave_start")
func victory() -> void:      _play("victory")
func defeat() -> void:       _play("defeat")
func build_deny() -> void:   _play("build_deny")


func set_muted(v: bool) -> void:
	_muted = v


func is_muted() -> bool:
	return _muted


func _play(name: String) -> void:
	if _muted or not _streams.has(name):
		return
	var p := _players[_pool_idx]
	_pool_idx = (_pool_idx + 1) % POOL_SIZE
	p.stream = _streams[name]
	p.volume_db = linear_to_db(_master_vol)
	p.play()


# ============================ SYNTHESIS ============================

func _build_all() -> void:
	_streams["shoot"]      = _tone_sweep(660.0, 220.0, 0.08, 0.5, 0.10, true)
	_streams["hit"]        = _noise_burst(0.06, 0.7, 0.25, 1200.0)
	_streams["enemy_die"]  = _tone_sweep(420.0, 70.0, 0.18, 0.55, 0.15, false)
	_streams["boss_die"]   = _tone_sweep(180.0, 40.0, 0.6, 0.8, 0.20, false)
	# Layer the boss death with a noise explosion for weight.
	_streams["boss_die"]   = _mix(_streams["boss_die"], _noise_burst(0.5, 0.9, 0.30, 800.0))
	_streams["place"]      = _tone_sweep(300.0, 720.0, 0.12, 0.5, 0.12, true)
	_streams["leak"]       = _tone_sweep(300.0, 90.0, 0.25, 0.7, 0.18, false)
	_streams["build_deny"] = _tone_sweep(200.0, 120.0, 0.10, 0.5, 0.10, false)
	_streams["wave_start"] = _arp([330.0, 440.0, 550.0], 0.08, 0.45)
	_streams["victory"]    = _arp([523.0, 659.0, 784.0, 1047.0], 0.12, 0.5)
	_streams["defeat"]     = _arp([440.0, 349.0, 294.0, 220.0], 0.16, 0.5)


## A pitch-swept tone (square or sine) with exponential decay envelope.
func _tone_sweep(f0: float, f1: float, dur: float, vol: float,
		decay: float, square: bool) -> AudioStreamWAV:
	var n := int(dur * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase := 0.0
	for i in n:
		var t := float(i) / SAMPLE_RATE
		var freq := lerpf(f0, f1, float(i) / n)
		phase += freq / SAMPLE_RATE * TAU
		phase = fmod(phase, TAU)
		var s: float
		if square:
			s = 1.0 if sin(phase) >= 0.0 else -1.0
		else:
			s = sin(phase)
		# Exponential decay envelope — punchy, not clicky.
		var env := vol * exp(-t / decay)
		var sample := int(clamp(s * env, -1.0, 1.0) * 32767.0)
		_encode_s16(data, i * 2, sample)
	return _make_stream(data)


## A filtered noise burst (white noise, simple one-pole low-pass) — for hits.
func _noise_burst(dur: float, vol: float, decay: float, cutoff: float) -> AudioStreamWAV:
	var n := int(dur * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	# One-pole low-pass coefficient from cutoff freq.
	var dt := 1.0 / SAMPLE_RATE
	var rc := 1.0 / (cutoff * TAU)
	var alpha := dt / (rc + dt)
	var prev := 0.0
	for i in n:
		var t := float(i) / SAMPLE_RATE
		var white := randf_range(-1.0, 1.0)
		prev = prev + alpha * (white - prev)
		var env := vol * exp(-t / decay)
		var sample := int(clamp(prev * env, -1.0, 1.0) * 32767.0)
		_encode_s16(data, i * 2, sample)
	return _make_stream(data)


## A short arpeggio of tones played in sequence (one stream).
func _arp(freqs: Array, step: float, vol: float) -> AudioStreamWAV:
	var total := int(step * freqs.size() * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(total * 2)
	var phase := 0.0
	var step_samples := int(step * SAMPLE_RATE)
	for i in total:
		var note_idx := mini(i / step_samples, freqs.size() - 1)
		var freq: float = freqs[note_idx]
		var local := i - note_idx * step_samples
		phase += freq / SAMPLE_RATE * TAU
		phase = fmod(phase, TAU)
		var s := 1.0 if sin(phase) >= 0.0 else -1.0
		# Decay within each note so the arp sounds plucked, not buzzy.
		var env := vol * exp(-float(local) / SAMPLE_RATE / 0.08)
		var sample := int(clamp(s * env, -1.0, 1.0) * 32767.0)
		_encode_s16(data, i * 2, sample)
	return _make_stream(data)


## Mix two equal-length streams into one (sum + soft clip).
func _mix(a: AudioStreamWAV, b: AudioStreamWAV) -> AudioStreamWAV:
	var da: PackedByteArray = a.data
	var db: PackedByteArray = b.data
	var len := mini(da.size(), db.size())
	var out := PackedByteArray()
	out.resize(len)
	for i in range(0, len, 2):
		var sa := _decode_s16(da, i)
		var sb := _decode_s16(db, i)
		var s := clampi((sa + sb) / 2, -32768, 32767)
		_encode_s16(out, i, s)
	return _make_stream(out)


# ============================ HELPERS ============================

func _encode_s16(buf: PackedByteArray, off: int, v: int) -> void:
	# Little-endian signed 16-bit.
	buf[off] = v & 0xFF
	buf[off + 1] = (v >> 8) & 0xFF


func _decode_s16(buf: PackedByteArray, off: int) -> int:
	var lo: int = buf[off]
	var hi: int = buf[off + 1]
	var v: int = (hi << 8) | lo
	if v >= 32768:
		v -= 65536
	return v


func _make_stream(data: PackedByteArray) -> AudioStreamWAV:
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = SAMPLE_RATE
	s.stereo = false
	s.data = data
	return s
