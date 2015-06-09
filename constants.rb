#ATTACKER_WIN = 1
#DEFENDER_WIN = 2
#ATTACKER_HOLD = 3
#DEFENDER_HOLD = 4
#ATTACKER_FLEE = 5
#DEFENDER_FLEE = 6
#TIE           = 7
#BOTH_DEAD     = 8

ENUM_MAP = {
  1 => "attacker_win",
  2 => "defender_win",
  3 => "attacker_hold",
  4 => "defender_hold",
  5 => "attacker_flee",
  6 => "defender_flee",
  7 => "tie",
  8 => "both_dead",
}

def map_enum_to_string(enum)
  ENUM_MAP.fetch(enum)
end
