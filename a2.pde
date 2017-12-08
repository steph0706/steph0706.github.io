System sys;
final color OFF = color(176, 224, 230);
final color ON = color(65, 105, 225);
final float MIN_ENERGY = 0.0001;
Boolean interacted = false;

void setup() {
  size(1100, 600);


  //surface.setResizable(true);
  parseData();
  //selectInput("Choose a file", "parseData");
}

void draw() {
  background(color(255, 255, 255));
  if (sys != null) {
    mouseOver();
    if (sys.totalEnergy > MIN_ENERGY || interacted) {
      sys.updateForces();
      sys.commitNodes();
      interacted = false;
    }
    sys.draw();
  }
}

// need to add -1 len edges for nodes not conencted by springs
void parseData() {
  //if (file == null) {
  //  println("No file was selected.");
  //} else {
    System s = new System(ON, OFF);
    String file = "data2.csv";
    HashMap<int, Node> nodesHash = new HashMap<int, Node>();

    String[] lines = loadStrings(file);
    int numNodes = (int)(lines[0]);

    for (int i = 1; i <= numNodes; i++) {
      String[] currLine = lines[i].split(",");
      int id = (int)(currLine[0]);
      int mass = (int)(currLine[1]);
      nodesHash.put(id, s.makeNode(id, mass));
    }

    int numEdges = (int)(lines[numNodes + 1]);
    for (int i = numNodes+2; i < numNodes + 2 + numEdges; i++) {
       String[] currLine = lines[i].split(",");
       Node n1 = nodesHash.get((int)(currLine[0]));
       Node n2 = nodesHash.get((int)(currLine[1]));
       s.makeEdge(n1, n2, (int)(currLine[2]));
    }

    sys = s;

}

void mouseOver() {
  for (Node n : sys.nodes) {
    if (n.isOver()) {
      n.onOver();
    } else {
      n.onOff();
    }
  }
}

void mousePressed() {
  interacted = true;
  ArrayList<Node> nodesCopy = new ArrayList<Node>(sys.nodes);
  for (Node n : nodesCopy) {
    if (n.isOver()) n.onPress();
  }
  sys.onPress();
}

void mouseReleased() {
  interacted = true;
  for (Node n : sys.nodes) {
    n.onRelease();
  }
  sys.onRelease();
}

void mouseDragged() {
  interacted = true;
  for (Node n : sys.nodes) {
    if (n.dragged) n.onDrag();
  }
}

void mouseClicked() {
  interacted = true;
  ArrayList<Node> nodesCopy = new ArrayList<Node>(sys.nodes);
  for (Node n : nodesCopy) {
    if (n.isOver()) n.onClick();
  }
}

//-------------------------------------------------------------------------------------------------------------------
class Edge {
  final float len;
  Node n1, n2;
  
  Edge(Node n1, Node n2, float len) {
    this.n1 = n1;
    this.n2 = n2;
    this.len = len;
  }
  
  void useTheForce() {
    this.n1.stageChange(this.n1.calcSpringForce(this.n2, this.len));
    this.n2.stageChange(this.n2.calcSpringForce(this.n1, this.len));
  }
  
  void draw() {
    line(this.n1.pos.x, this.n1.pos.y,
         this.n2.pos.x, this.n2.pos.y);
  }
}

//-------------------------------------------------------------------------------------------------------------------
class Node {
  final int id;
  final float r, mass;
  System parent;
  PVector v0, pos;
  Queue q;
  Boolean dragged;
  color on, off;
  private color c;
  
  Node(int id, float mass, System parent, float x, float y, color on, color off) {
    this.mass = mass;
    this.r = Physics.radius(this.mass);
    this.parent = parent;
    this.id = id;
    this.v0 = new PVector(0, 0);
    this.pos = new PVector(x, y);
    this.q = new Queue();
    this.dragged = false;
    this.on = on;
    this.off = off;
    this.c = off;
  }
  
  PVector calcParticleForce(Node other) {
    PVector fc = Physics.coulombs(this.pos, other.pos);
    PVector fd = Physics.damping(this.v0);
    return PVector.add(fc, fd);
  }
  
  PVector calcSpringForce(Node other, float len) {
    return Physics.hookes(this.pos, other.pos, len);
  }
  
  void stageChange(PVector chg) {
    q.add(chg);
  }
  
  void makeChanges() {
    if (dragged) {
      q.clear();
      return;
    }
    PVector total = new PVector(0, 0);
    while (!q.isEmpty()) total.add(q.remove());
    PVector a = Physics.acceleration(total, this.mass);
    PVector v1 = Physics.velocity(this.v0, a, this.parent.TIME);
    PVector s = Physics.displacement(this.v0, a, this.parent.TIME);
    this.v0 = v1;
    this.pos.add(s);
  }
  
  void onClick() {
    if (mouseButton == RIGHT) {
      parent.removeNode(this);
    }
  }
  
  void onPress() {
    this.dragged = true;
  }
  
  void onRelease() {
    for (Node n : this.parent.nodes) {
      if (n != this && this.dragged && mouseButton == RIGHT && n.isOver()) {
        parent.makeEdge(n, this, PVector.sub(n.pos, this.pos).mag());
        break;
      }
    }
    this.dragged = false;
  }
  
  Boolean isOver() {
    return pow(mouseX-this.pos.x, 2) + pow(mouseY-this.pos.y, 2) <= pow(this.r, 2);
  }
  
  void onDrag() {
    // move using displacement
    if (mouseButton == LEFT) {
      PVector s1 = new PVector(mouseX - this.pos.x, mouseY - this.pos.y);
      s1.div(2);
      this.v0 = PVector.div(s1, this.parent.TIME);
      this.pos.add(s1);
    }
  }
  
  void onOver() {
    this.c = this.on;
    
  }
  
  void onOff() {
    this.c = this.off;
  }

  void draw() {
    // new line
    if (this.dragged && mouseButton == RIGHT) line(mouseX, mouseY, this.pos.x, this.pos.y);
    
    // node
    ellipseMode(CENTER);
    fill(this.c);
    ellipse(this.pos.x, this.pos.y, this.r * 2, this.r * 2);
  }
}

//-------------------------------------------------------------------------------------------------------------------
static abstract class Physics {
  static final float HOOKES = 0.0012;
  static final float COULOMBS = 800;
  static final float DAMP = 0.005;
  
  static PVector hookes(PVector pos1, PVector pos2, float relaxed) {
    PVector spring = PVector.sub(pos2, pos1);
    float stretched = spring.mag();
    if (stretched < 0) return new PVector(0, 0);
    float factor = -(relaxed / stretched);
    if (factor < -1) factor = -1;
    return PVector.mult(spring, HOOKES * sqrt(1 + factor));
  }
  
  static PVector coulombs(PVector pos1, PVector pos2) {
    PVector spring = PVector.sub(pos1, pos2);
    float distance = spring.mag();
    if (distance < 0) return new PVector(0, 0);
    spring.normalize(); // now unit vector
    return PVector.mult(spring, COULOMBS / pow(distance, 2));
  }

  static PVector damping(PVector v0) {
    return PVector.mult(v0, -DAMP);
  }
  
  static PVector acceleration(PVector f, float mass) {
    return PVector.div(f, mass);
  }
  
  static PVector velocity(PVector v0, PVector a, float t) {
    return PVector.add(v0, PVector.mult(a, t));
  }
  
  static PVector displacement(PVector v0, PVector a, float t) {
    return PVector.add(PVector.mult(v0, t), PVector.mult(a, 0.5 * pow(t, 2)));
  }
  
  static float kineticEnergy(float mass, PVector v0) {
    return pow(v0.mag(), 2) * 0.5 * mass;
  }
  
  static float radius(float mass) {
    return sqrt(mass) + 5;
  }
}

//-------------------------------------------------------------------------------------------------------------------
class Queue {
  Node head;
  Node tail;
  
  
  Queue() {
    Node head = null;
    Node tail = head;
  }
  
  PVector remove() {
    PVector v = head.data;
    head = head.next;
    return v;
  }
  
  void add(PVector v) {
    Node add = new Node(v);
    if (head != null) {
      tail.next = add;
      tail = tail.next;
    } else {
      head = add;
      tail = head;
    }
  }
  
  boolean isEmpty() {
    return head == null;
  }
  
  void clear() {
    head = null;
  }
  private class Node {
    PVector data;
    Node next;
    
    Node(PVector data) {
        this.data = data;
        next = null;
    }
  }
}

//-------------------------------------------------------------------------------------------------------------------
final float GROWTH = 1;

class System {
  final float TIME = 1;
  float totalEnergy;
  ArrayList<Edge> edges;
  ArrayList<Node> nodes;
  color on, off;
  private int nextID;
  private float newMass;
  private Boolean dragged;
  
  System(color on, color off) {
    this.edges = new ArrayList<Edge>();
    this.nodes = new ArrayList<Node>();
    this.on = on;
    this.off = off;
    this.newMass = 1;
    this.nextID = 1;
    this.dragged = false;
    this.totalEnergy = 1; // to allow over threshold on initial run
  }
  
  Node makeNode(int id, float mass, float x, float y) {
    Node n = new Node(id, mass, this, x, y, this.on, this.off);
    this.nodes.add(n);
    this.nextID++;
    return n;
  }

  
  Node makeNode(int id, float mass) {
    return makeNode(id, mass, random(0, width), random(0, height));
  }
  
  void removeNode(Node n) {
    this.nodes.remove(n);
    ArrayList<Edge> edgeCopy = new ArrayList<Edge>(this.edges);
    for (Edge e : edgeCopy) {
      if (e.n1 == n || e.n2 == n) this.edges.remove(e);
    }
  }
  
  Edge makeEdge(Node n1, Node n2, float len) {
    Edge e = new Edge(n1, n2, len);
    this.edges.add(e);
    return e;
  }

  void updateForces() {
    for (int i = 0; i < this.nodes.size()-1; i++) {
      Node n1 = this.nodes.get(i);
      for (int j = i+1; j < this.nodes.size(); j++) {
        Node n2 = this.nodes.get(j);
        n1.stageChange(n1.calcParticleForce(n2));
        n2.stageChange(n2.calcParticleForce(n1));
      }
    }
    for (Edge e : this.edges) e.useTheForce();
  }
  
  void commitNodes() {
    this.totalEnergy = 0;
    for (Node n : this.nodes) {
      n.makeChanges();
      this.totalEnergy += Physics.kineticEnergy(n.mass, n.v0);
    }
  }
  
  void onPress() {
    if (mouseButton == LEFT) {
      for (Node n : this.nodes) {
        if (n.isOver()) return;
      }
      this.dragged = true;
    }
  }
  
  void onRelease() {
    if (this.dragged) makeNode(this.nextID, this.newMass, mouseX, mouseY);
    this.newMass = 1;
    this.dragged = false;
  }
  
  void drawLabel(Node n) {
    float padding = 3;
    String mass = "Mass: " + (String.valueOf)(n.mass);
    String id = "ID: " + String.valueOf(n.id);
    float textW = max(textWidth(mass), textWidth(id)) + 2 * padding;
    float boxH = 2 * (textAscent() + textDescent() + 2 * padding);
    float boxX = mouseX;
    float boxY = mouseY - boxH - padding;
    fill(255);
    rect(boxX, boxY,  textW, boxH);
    fill(0);
    text(id, boxX + padding, boxY + (textAscent() + textDescent() + padding));
    text(mass, boxX + padding, boxY + 2 * (textAscent() + textDescent() + padding));
  }
  
  void draw() {
    for (Edge e : this.edges) e.draw();
    for (Node n : this.nodes) n.draw();
    
    // new mass
    if (this.dragged) {
      float newRadius = Physics.radius(this.newMass);
      ellipseMode(CENTER);
      fill(OFF);
      ellipse(mouseX, mouseY, newRadius * 2, newRadius * 2);
      this.newMass += GROWTH;
    }
    
    // tooltip
    for (Node n : this.nodes) if (n.isOver()) drawLabel(n);

    // energy output
    fill(0);
    String energyText = "Total Energy: " + this.totalEnergy.toFixed(4);
    text(energyText, 10, 20);
  }
}