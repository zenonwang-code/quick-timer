start = null
is-blink = false
is-light = true
is-run = false
is-show = true
is-warned = false
handler = null
latency = 0
stop-by = null
delay = 60000
audio-remind = null
audio-end = null
carmina-audio = null
composer-handler = null
composer-index = 0

composer-portraits = [
  {name: 'Johann Sebastian Bach', url: 'https://upload.wikimedia.org/wikipedia/commons/9/9d/Johann_Sebastian_Bach.jpg'}
  {name: 'Ludwig van Beethoven', url: 'https://upload.wikimedia.org/wikipedia/commons/6/6f/Beethoven.jpg'}
  {name: 'Wolfgang Amadeus Mozart', url: 'https://upload.wikimedia.org/wikipedia/commons/1/1e/Wolfgang-amadeus-mozart_1.jpg'}
  {name: 'Frédéric Chopin', url: 'https://upload.wikimedia.org/wikipedia/commons/9/9f/Chopin%2C_by_Wodzinska.JPG'}
  {name: 'Pyotr Ilyich Tchaikovsky', url: 'https://upload.wikimedia.org/wikipedia/commons/6/60/Piotr_Tchaikovsky_by_Ku%C4%87i%C5%9B_%281879%29.jpg'}
  {name: 'Claude Debussy', url: 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Claude_Debussy_atelier_Nadar.jpg'}
  {name: 'Giuseppe Verdi', url: 'https://upload.wikimedia.org/wikipedia/commons/3/3e/Giuseppe_Verdi.jpg'}
  {name: 'Antonio Vivaldi', url: 'https://upload.wikimedia.org/wikipedia/commons/1/1b/Antonio_Vivaldi.jpg'}
  {name: 'Johannes Brahms', url: 'https://upload.wikimedia.org/wikipedia/commons/7/7a/JohannesBrahms.jpg'}
  {name: 'Franz Schubert', url: 'https://upload.wikimedia.org/wikipedia/commons/7/75/Franz_Schubert_by_Wilhelm_August_Riezler.jpg'}
]

new-audio = (file, loop=false) ->
  node = new Audio!
    ..src = file
    ..loop = loop
    ..load!
  document.body.appendChild node
  return node

sound-toggle = (des, state) ->
  if state => des.play!
  else des
    ..currentTime = 0
    ..pause!

update-timer-visibility = ->
  tm = $ \#timer
  if is-run => tm.addClass \timer-hidden
  else tm.removeClass \timer-hidden

show = ->
  is-show := !is-show
  $ \.fbtn .css \opacity, if is-show => \1.0 else \0.1

adjust = (it,v) ->
  if is-blink => return
  delay := delay + it * 1000
  if it==0 => delay := v * 1000
  if delay <= 0 => delay := 0
  $ \#timer .text delay
  resize!

update-composer = ->
  data = composer-portraits[composer-index]
  img = $ \#composer-photo
  caption = $ \#composer-name
  img.attr \src, data.url
  img.attr \alt, "#{data.name} portrait"
  caption.text data.name
  composer-index := (composer-index + 1) % composer-portraits.length

start-media = ->
  update-composer!
  if composer-handler => clearInterval composer-handler
  composer-handler := setInterval (-> update-composer!), 8000
  if carmina-audio => sound-toggle carmina-audio, true

stop-media = ->
  if composer-handler =>
    clearInterval composer-handler
    composer-handler := null
  if carmina-audio => sound-toggle carmina-audio, false


toggle = ->
  is-run := !is-run
  update-timer-visibility!
  $ \#toggle .text if is-run => "STOP" else "RUN"
  if !is-run and handler =>
    stop-by := new Date!
    clearInterval handler
    handler := null
    sound-toggle audio-end, false
    sound-toggle audio-remind, false
    stop-media!
  if stop-by =>
    latency := latency + (new Date!)getTime! - stop-by.getTime!
  if is-run =>
    start-media!
    run!

reset = ->
  if delay == 0 => delay := 1000
  sound-toggle audio-remind, false
  sound-toggle audio-end, false
  stop-media!
  stop-by := 0
  is-warned := false
  is-blink := false
  latency := 0
  start := null #new Date!
  is-run := true
  toggle!
  if handler => clearInterval handler
  handler := null
  $ \#timer .text delay
  $ \#timer .css \color, \#fff
  resize!


blink = ->
  is-blink := true
  is-light := !is-light
  $ \#timer .css \color, if is-light => \#fff else \#f00

count = ->
  tm = $ \#timer
  diff = start.getTime! - (new Date!)getTime! + delay + latency
  if diff > 60000 => is-warned := false
  if diff < 60000 and !is-warned =>
    is-warned := true
    sound-toggle audio-remind, true
  if diff < 55000 => sound-toggle audio-remind, false
  if diff < 0 and !is-blink =>
    sound-toggle audio-end, true
    is-blink := true
    diff = 0
    clearInterval handler
    handler := setInterval ( -> blink!), 500
  tm.text "#{diff}"
  resize!

run =  ->
  if start == null =>
    start := new Date!
    latency := 0
    is-blink := false
  if handler => clearInterval handler
  if is-blink => handler := setInterval (-> blink!), 500
  else handler := setInterval (-> count!), 100

resize = ->
  tm = $ \#timer
  w = tm.width!
  h = $ window .height!
  len = tm.text!length
  len>?=3
  tm.css \font-size, "#{1.5 * w/len}px"
  tm.css \line-height, "#{h}px"


window.onload = ->
  $ \#timer .text delay
  resize!
  #audio-remind := new-audio \audio/cop-car.mp3
  #audio-end := new-audio \audio/fire-alarm.mp3
  audio-remind := new-audio \audio/smb_warning.mp3
  audio-end := new-audio \audio/smb_mariodie.mp3
  carmina-audio := new-audio 'https://upload.wikimedia.org/wikipedia/commons/4/4a/Carl_Orff_-_O_Fortuna%2C_Carmina_Burana.ogg', true
window.onresize = -> resize!
