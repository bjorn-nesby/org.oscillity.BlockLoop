

function pos_le(pos1,pos2)
  if (pos1.sequence < pos2.sequence) then 
    return true 
  elseif (pos1.sequence == pos2.sequence) then
    return  (pos1.line <= pos2.line) 
  else 
    return false 
  end
end

function pos_lt(pos1,pos2)
  if (pos1.sequence < pos2.sequence) then 
    return true 
  elseif (pos1.sequence == pos2.sequence) then
    return  (pos1.line < pos2.line) 
  else 
    return false 
  end
end

function toggle_and_play()
  local rns = renoise.song()
  if (rns.transport.loop_block_enabled) then
    rns.transport.loop_block_enabled = false
  else
    rns.transport.loop_block_enabled = true
    rns.transport.playing = true
  end
end

function select_next_and_catch_up()
  local rns = renoise.song()
  local playpos = rns.transport.playback_pos
  local patt_idx = rns.sequencer:pattern(playpos.sequence)
  local patt = rns.patterns[patt_idx]
  local block_coeff = rns.transport.loop_block_range_coeff
  local block_size = patt.number_of_lines / block_coeff
  local block_start = rns.transport.loop_block_start_pos
  local block_end = {
    sequence = block_start.sequence, 
    line = block_start.line + block_size
  }
  local within = pos_le(block_start,playpos) and pos_lt(playpos,block_end)

  rns.transport:loop_block_move_forwards()
    
  -- only catch up when playback is within block
  -- (if there is room, move playback cursor)
  if within then
    playpos.line = playpos.line + block_size
    if (playpos.line < patt.number_of_lines) then
      rns.transport.playback_pos = playpos
    end
  end 
  
end

renoise.tool():add_keybinding {
  name = "Global:Transport:Toggle Block Playing (2.x style)",
  invoke = function()
    toggle_and_play()
  end
}

renoise.tool():add_keybinding {
  name = "Global:Transport:Select Next Loopblock (catch up)",
  invoke = function()
    select_next_and_catch_up()
  end
}
