//    __             ___  _      __                        
//   / /  ___ ____  / _ \(_)__  / /__  __ _  ___ _______ __
//  / /__/ _ `/ _ \/ // / / _ \/ / _ \/  ' \/ _ `/ __/ // /
// /____/\_,_/_//_/____/_/ .__/_/\___/_/_/_/\_,_/\__/\_, / 
//                      /_/                         /___/  
// Lan Diplomacy Development File
// Sep 13, 2021

// The Battle class handles the actions which target a specific region and has 
// the capability to determine a winner. It also contains a list of Move orders
// which are targeting the region. Once the battle has been adjudicated, a bool
// is marked to indicate that the situation is resolved.
class Battle {
  
  Region target;
  ArrayList<Move> contenders;
  boolean resolved;

  // Constructor for Battle
  // Inputs: Region target -- the region where the battle is taking place
  // Effect: Creates battle instance
  Battle(Region target) {
    this.target = target;
    contenders = new ArrayList<Move>();
    resolved = false;
  }
  
  // Constructor for Battle (with move)
  // Inputs: Region target -- the region where the battle is taking place
  //         Move o -- a movement targeting the target
  // Effect: Creates battle instance
  Battle(Region target, Move o) {
    this(target);
    addContender(o);
  }
  
  // Adds a contender to the battle
  // Inputs: Move o -- a movement targeting the target
  // Effect: Adds move to the list of contenders
  void addContender(Move o) {
    contenders.add(o);
  }
  
  // removes a contender from the battle
  // Inputs: Move o -- a movement targeting the target, which is already in the
  //                   list of contenders
  // Effect: Removes the move from the list of contenders
  void removeContender(Move o) {
    contenders.remove(o);
  }
  
  // Determines the winner of a battle by simulation
  // Inputs: boolean force -- Not sure???
  // Output: if the battle has already been resolved or force and tie, return 
  //         false, otherwise, return true
  // Effect: If the battle resolves, all losers of the battle will have their
  //         move orders marked as fail, and the winner's move will be executed
  boolean simulateBattle(boolean force) {
    if(resolved) return false;
    int max = 0;
    Order winner = null;
    if(!target.isEmpty()) {
      winner = target.getOccupier().currOrder;
      max = target.getOccupier().currOrder.strength;
    }
    for(int i = 0; i < contenders.size(); i++) {
      if(contenders.get(i).failed) continue;
      if(contenders.get(i).strength == max) winner = null;
      else if(contenders.get(i).strength > max) {
        winner = contenders.get(i);
        max = contenders.get(i).strength;
      }
    }
    if(winner == null && !force) return false;
    if(target.getOccupier() != null) {
      if(winner != null && winner.unit.owner == target.getOccupier().owner) {
        winner = null;
      }
    }
    for(Order cont : contenders) {
      if(cont == winner) cont.execute();
      else cont.fail();
    }
    resolved = true;
    return true;
  }
}
