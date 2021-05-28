class Battle {
  
  Region target;
  ArrayList<Move> contenders;
  boolean resolved;
  
  Battle(Region target) {
    this.target = target;
    contenders = new ArrayList<Move>();
    resolved = false;
  }
  
  Battle(Region target, Move o) {
    this(target);
    addContender(o);
  }
  
  void addContender(Move o) {
    contenders.add(o);
  }
  
  void removeContender(Move o) {
    contenders.remove(o);
  }
  
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
