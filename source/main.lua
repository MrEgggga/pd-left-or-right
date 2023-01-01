import "CoreLibs/graphics"
local gfx = playdate.graphics
local snd = playdate.sound

math.randomseed(playdate.getSecondsSinceEpoch())
local seq = {}
local cover = -170 -- 0 = 0% covered; 5000 = 100% covered; inc by one each frame
local offset = 0
local last = false
local tutorial = false

local uncover = 0

local title = true
local gameover = false
local animComplete = false
local animJustComplete = true
local score = 0

local imgLeft = gfx.image.new("images/left.png")
local imgRight = gfx.image.new("images/right.png")

local sndLeft = snd.sampleplayer.new("sounds/left.wav")
sndLeft:setVolume(1, 0)
local sndRight = snd.sampleplayer.new("sounds/right.wav")
sndRight:setVolume(0, 1)
local sndBuzzer = snd.sampleplayer.new("sounds/buzzer.wav")

local fnt = gfx.font.new("fonts/mont2.pft")

playdate.display.setRefreshRate(50)

local function reset()
  for i = 1, 10 do
    seq[i] = math.random() < 0.5
  end
  cover = -170
  offset = 0
  last = false
  gameover = false
  animComplete = false
  animJustComplete = true
  score = 0
  uncover = 0
  tutorial = false
end
reset()

gfx.fillRect(0, 0, 400, 240)
gfx.setImageDrawMode(gfx.kDrawModeNXOR)
fnt:drawTextAligned("left or right", 200, 105, kTextAlignment.center)
gfx.setImageDrawMode(gfx.kDrawModeCopy)

function playdate.update()
  if title then
    if false then
      gfx.clear(gfx.kColorBlack)
      title = false
      tutorial = true
    end
    return
  end

  update()
  draw()
end

function update()
  if animComplete then
    animJustComplete = false
  end

  if not gameover then
    local left, right = playdate.buttonJustPressed(playdate.kButtonLeft) or playdate.buttonJustPressed(playdate.kButtonB), playdate.buttonJustPressed(playdate.kButtonRight) or playdate.buttonJustPressed(playdate.kButtonA)
    if left or right then
      print(seq[1], left, right)
      if seq[1] ~= right then
        sndBuzzer:play(1)
        gameover = true
        return
      end
      (seq[1] and sndRight or sndLeft):play(1)
      score += 1
      last = seq[1]
      offset = 4
      shiftseq()
    end
    if offset > 0 then
      offset -= 1
    end

    cover += 1
    if cover > 4500 then
      cover = 4500
    end

    if uncover <= 5000 then
      uncover += 250
    end
  elseif not animComplete then
    cover += 140
    uncover += 250
    if cover > 5000 then
      animComplete = true
    end
  else
    print(playdate.getButtonState())
    local current, pressed, released = playdate.getButtonState()
    if pressed > 0 then
      gfx.clear(gfx.kColorBlack)
      reset()
    end
  end
end

function draw()
  if animJustComplete then
    -- gfx.clear()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, math.min((cover * 240 / 5000), 24), 400, math.min(24, (uncover * 240 / 5000)) - math.min((cover * 240 / 5000), 24)) -- anim
    gfx.fillRect(0, 0, 100, 32) -- text
    if uncover <= 5000 then gfx.fillRect(0, (uncover * 240 / 5000) - 14, 400, 14) end -- uncover
    if not gameover then gfx.fillRect(186, (cover * 240 / 5000), 30, (uncover * 240 / 5000) - (cover * 240 / 5000)) end -- arrows
    gfx.setColor(gfx.kColorBlack)

    if score == 0 and tutorial then
      gfx.drawRect(187, -1, 26, 26)
    end

    -- arrows
    for i = 1, 10 do
      (seq[i] and imgRight or imgLeft):draw(188, (i-1) * 24 + offset * 6)
    end

    -- last arrow
    if offset > 0 then
      local a = offset * 50
      (last and imgRight or imgLeft):draw(last and 400-a or a, 0);
    end

    -- cover
    gfx.fillRect(0, (cover * 240 / 5000) - 9, 400, 9);
    gfx.fillRect(0, 0, 100, math.min(cover * 240 / 5000, 32))

    -- -- uncover
    -- if uncover < 5000 then
    --   gfx.fillRect(0, uncover * 240 / 5000, 400, 240)
    -- end
    if uncover < 14 * 50 then
      gfx.fillRect(0, uncover * 240 / 5000, 100, 32)
    end

    -- text
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    fnt:drawText(score, 0, 0)
    if animComplete then
      fnt:drawTextAligned("game over", 200, 105, kTextAlignment.center)
    end
  end

  -- -- debug: fps
  -- playdate.drawFPS(300, 200)

  gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

function shiftseq()
  for i = 1, 9 do
    seq[i] = seq[i+1]
  end
  seq[10] = math.random() < 0.5
end