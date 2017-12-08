TreeNode root;
Rectangle canvas;
color ON = color(65, 105, 225);
color OFF = color(255, 255, 255);
float currWid, currHgt;

void setup() {
  size(1024, 768);
  //size(500, 300);
  background(color(255, 255, 255));
  //surface.setResizable(true);
  currWid = width;
  currHgt = height;
  treeFromFile();
  //selectInput("Select a file to process: ", "treeFromFile");
}

void draw() {
  if (root != null && canvas != null) {
    onResize();
    mouseOff();
    mouseOver();
    canvas.draw();
    drawLabelBox();
  }
}

void treeFromFile() {
    root = parseData();
    canvas = makeCanvas(root);
  
}

// parse data into tree
TreeNode parseData() {
  String[] lines = loadStrings("hierarchy2.shf");
  int numLeaves = (int)(lines[0]);
  HashMap<Integer, TreeNode> nodes = new HashMap<Integer, TreeNode>();
  
  for (int i = 1; i <= numLeaves; i++) {
    String[] currLine = lines[i].split(" ");
    int id = (int)(currLine[0]);
    float wgt = (float)(currLine[1]);
    nodes.put(id, new TreeNode(id, wgt));
  }
  
  int numEdges = (int)(lines[numLeaves + 1]);
  for (int i = numLeaves + 2; i < numLeaves + 2 + numEdges; i++) {
    String[] currLine = lines[i].split(" ");
    int parentId = (int)(currLine[0]);
    int childId = (int)(currLine[1]);
    TreeNode parent, child;
    
    if (!nodes.containsKey(parentId)) {
      parent = new TreeNode(parentId, 0);
      nodes.put(parentId, parent);
    } else {
      parent = nodes.get(parentId);
    }
    if (!nodes.containsKey(childId)) {
      child = new TreeNode(childId, 0);
      nodes.put(childId, child);
    } else {
      child = nodes.get(childId);
    }
    
    child.parent = parent;
    parent.children.add(child);
  }
  
  TreeNode root = null;
  for (TreeNode node : nodes.values()) {
    if (node.parent == null) {
      root = node;
      break;
    }
  }
  
  return root;
}

// gets total weight of a tree
// side effect: nonleaf nodes have their weights set to that of their children
float sumNodeWeight(TreeNode node) {
  if (node.children.size() <= 0) {
    return node.value;
  }
  float sum = 0;
  for (TreeNode c : node.children) {
    sum += sumNodeWeight(c);
  }
  node.value = sum;
  return sum;
}

// convert all weights in tree to scalar
void normalize(TreeNode node, float normfact) {
  node.ratio = node.value / normfact;
  for (TreeNode c : node.children) {
    normalize(c, normfact);
  }
  node.children.sort(function(a, b) {
     return a.val - b.val; 
   )};
}



Rectangle makeCanvas(TreeNode node) {
  if (node != null) {
    normalize(node, sumNodeWeight(node));
    Rectangle newCanvas = new Rectangle(node, null, 0, 0, 1, 1, ON, OFF);
    squarify(node, newCanvas);
    return newCanvas;
  } else {
    return canvas;
  }
}

// assumes weights.size() > 0
float aspectRatio(ArrayList<TreeNode> nodes, float w) {
  float area = width * height;
  float max = nodes.get(0).ratio * area;
  float min = nodes.get(0).ratio * area;
  float sum = 0;
  
  for (TreeNode node : nodes) {
    float wgt = node.ratio * area;
    max = Math.max(max, wgt);
    min = Math.min(min, wgt);
    sum += wgt;
  }
  
  return Math.max((w * w * max) / (sum * sum), (sum * sum) / (w * w * min));
}

void squarify(TreeNode node, Rectangle r) {
  if (node.children.size() <= 0) {
    return;
  }
  
  float w = r.shortest();
  ArrayList<TreeNode> row = new ArrayList<TreeNode>();
  row.add(node.children.get(0));
  ArrayList<Rectangle> rects = new ArrayList<Rectangle>();
  
  for (int i = 1; i < node.children.size(); i++) {
    float currAR = aspectRatio(row, w);
    row.add(node.children.get(i));
    float newAR = aspectRatio(row, w);
    
    if (currAR <= newAR) {
      row.remove(row.size() - 1);
      rects.addAll(r.layoutRow(row));
      row.clear();
      row.add(node.children.get(i));
      w = r.shortest();
    }
 }
  
  if (row.size() > 0) {
    rects.addAll(r.layoutRow(row));
  }
  
  for (int i = 0; i < node.children.size(); i++) {
    squarify(node.children.get(i), rects.get(i));
  }
}

void onRects(Rectangle r) {
  if (r.isOver()) {
    r.onOver();
    for (Rectangle c : r.children) {
      onRects(c);
    }
  }
}

void mouseOver() {
  onRects(canvas);
}

void offRects(Rectangle r, Rectangle over) {
  if (r != over) {
    r.onOff();
  }
  for (Rectangle c : r.children) {
    offRects(c, over);
  }
}

void mouseOff() {
  offRects(canvas, canvas.whichOver());
}

void mouseClicked() {
  Rectangle over = canvas.whichOver();
  if (mouseButton == LEFT) {
    canvas = makeCanvas(over.node);
  }  else if (mouseButton == RIGHT) {
    canvas = makeCanvas(canvas.node.parent);
  }
}

Boolean resized() {
  return currWid != width || currHgt != height;
}

void onResize() {
  if (resized()) {
    currWid = width;
    currHgt = height;
    
    canvas = makeCanvas(canvas.node);
  }
}

void drawLabelBox() {
  Rectangle over = canvas.whichOver();
  if (over == null) return;
  String idstr = "id: " + String.valueOf(over.node.id);
  String wgtstr = "weight: " + String.valueOf(over.node.value);
  float padding = 2 * FRAME;
  float boxW = max(textWidth(idstr), textWidth(wgtstr)) + 2 * padding;
  float boxH = 2 * (textAscent() + textDescent() + padding);
  float boxX = mouseX;
  float boxY = mouseY - boxH - padding;
  
  if (boxX + boxW > width) {
    boxX = mouseX - boxW - padding;
    boxY = mouseY + boxH > height ? boxY : mouseY;
  } else if (boxY < 0) {
    boxX = mouseX + 2 * padding;
    boxY = mouseY;
  }
  
  fill(color(255, 255, 255));
  rect(boxX, boxY, boxW, boxH);
  fill(color(0, 0, 0));
  text(idstr, boxX + FRAME, boxY + (textAscent() + textDescent()) + padding);
  text(wgtstr, boxX + FRAME, boxY + 2 * (textAscent() + textDescent()) + padding);
}

//----------------------------------------------------------------------------------------
class TreeNode {
  int id;
  float value;
  float ratio;
  TreeNode parent;
  ArrayList<TreeNode> children;
  
  TreeNode(int id, float value) {
    this.id = id;
    this.value = value;
    this.ratio = value;
    this.parent = null;
    this.children = new ArrayList<TreeNode>();
  }
  
}

//------------------------------------------------------------------------------------------
static final float FRAME = 4;
static final float EPSILON = 0.001;

class Rectangle {
  private float sw, sh, sx, sy;
  TreeNode node;
  float x, y, w, h;
  Rectangle parent;
  ArrayList<Rectangle> children;
  color on, off;
  private color c;
  
  Rectangle(TreeNode node, Rectangle parent, float x, float y, float w, float h, color on, color off) {
    this.node = node;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.parent = parent;
    this.sx = 0;
    this.sy = 0;
    this.sw = 1;
    this.sh = 1;
    this.on = on;
    this.off = off;
    this.c = off;
    children = new ArrayList<Rectangle>();
  }
 
  float getWidth() {
    return (this.parent == null ? width : this.parent.getWidth()) * this.w;
  }
  
  float getHeight() {
    return (this.parent == null ? height : this.parent.getHeight()) * this.h;
  }
  
  float getX() {
    return this.parent == null ? width * this.x : parent.getX() + parent.getWidth() * this.x;
  }
  
  float getY() {
    return this.parent == null ? height * this.y : parent.getY() + parent.getHeight() * this.y;
  }
  
  float shortest() {
    float sAbsWid = this.sw * getWidth();
    float sAbsHgt = this.sh * getHeight();
    return Math.min(sAbsWid, sAbsHgt);
  }
  
  private ArrayList<Rectangle> addVRow(ArrayList<TreeNode> nodes) {
    float sum = 0;
    for (TreeNode node : nodes) {
      sum += node.ratio;
    }
    
    ArrayList<Rectangle> rects = new ArrayList<Rectangle>();
    float currW = 0, currY = this.sy;
    
    for (TreeNode node : nodes) {
      float currH = (node.ratio / sum) * this.sh;
      currW = (node.ratio * width * height) / (currH * getHeight()) / getWidth();
      Rectangle currRect = new Rectangle(node, this, this.sx, currY, currW, currH, this.on, this.off);
      currRect.parent = this;
      children.add(currRect);
      rects.add(currRect);
      currY += currH;
    }
    
    this.sw -= currW;
    this.sx += currW;
    
    return rects;
  }
  
  private ArrayList<Rectangle> addHRow(ArrayList<TreeNode> nodes) {
    float sum = 0;
    for (TreeNode node : nodes) {
      sum += node.ratio;
    }
    
    ArrayList<Rectangle> rects = new ArrayList<Rectangle>();
    float currH = 0, currX = this.sx;
    
    for (TreeNode node : nodes) {
      float currW = (node.ratio / sum) * this.sw;
      currH = (node.ratio * width * height) / (currW * getWidth()) / getHeight();
      Rectangle currRect = new Rectangle(node, this, currX, this.sy, currW, currH, this.on, this.off);
      currRect.parent = this;
      children.add(currRect);
      rects.add(currRect);
      currX += currW;
    }
    
    this.sh -= currH;
    this.sy += currH;
    
    return rects;
  }
  
  ArrayList<Rectangle> layoutRow(ArrayList<TreeNode> nodes) {
    float sAbsWid = this.sw * getWidth();
    float sAbsHgt = this.sh * getHeight();
    return sAbsWid <= sAbsHgt ? addHRow(nodes) : addVRow(nodes);
  }
  
  private float getLOff() {
    if (parent == null) return 0;
    float absX = getX();
    float absW = getWidth();
    return absX == 0 || absX == parent.getX() ?
           FRAME + parent.getLOff() :
           FRAME / 2;  
  }
  
  private float getROff() {
    if (parent == null) return 0;
    float absX = getX();
    float absW = getWidth();
    return (Math.abs(absX + absW - width) < EPSILON ||
            Math.abs(absX + absW - parent.getX() - parent.getWidth()) < EPSILON ?
            FRAME + parent.getROff() :
            FRAME / 2);
  }
  
  private float getUOff() {
    if (parent == null) return 0;
    float absY = getY();
    float absH = getHeight();
    return absY == 0 || absY == parent.getY() ?
           FRAME + parent.getUOff() :
           FRAME / 2;
  }
  
  private float getDOff() {
    if (parent == null) return 0;
    float absY = getY();
    float absH = getHeight();
    return (Math.abs(absY + absH - height) < EPSILON ||
            Math.abs(absY + absH - parent.getY() - parent.getHeight()) < EPSILON ?
            FRAME + parent.getDOff() :
            FRAME / 2);
  }
  
  private int getTreeHeight() {
    if (this.children.size() <= 0) return 0;
    int longest = 1 + this.children.get(0).getTreeHeight();
    for (Rectangle c : this.children) {
      longest = max(longest, 1 + c.getTreeHeight());
    }
    return longest;
  }
  
  private color getColor() {
    Rectangle root = this;
    int hgt = 2;
    while (root.parent != null) {
      root = root.parent;
      hgt++;
    }
    int treeHgt = root.getTreeHeight() + 2;
    float scale = (treeHgt - hgt) / (float)treeHgt;
    
    float r = (red(this.on) - red(this.off)) * scale;
    float g = (green(this.on) - green(this.off)) * scale;
    float b = (blue(this.on) - blue(this.off)) * scale;
    
    return color(red(this.on) - r, green(this.on) - g, blue(this.on) - b);
  }
  
  void draw() {
    float absX = getX();
    float absY = getY();
    float absW = getWidth();
    float absH = getHeight();
    
    // rect
    float xOff = getLOff();
    float yOff = getUOff();
    float wOff = xOff + getROff();
    float hOff = yOff + getDOff();
    fill(this.c);
    rect(absX + xOff, absY + yOff, absW - wOff, absH - hOff);
    
    // label
    if (this.children.size() <= 0) {
      fill(color(0, 0, 0));
      String id = String.valueOf(this.node.id);
      text(id, absX + (absW - textWidth(id)) / 2, absY + absH / 2);
    }
    
    fill(color(255, 255, 255));
    for (Rectangle c : this.children) {
      c.draw();
    }
  }
  
  Rectangle whichOver() {
    return whichOver(0);
  }
  
  private Rectangle whichOver(int lvl) {
    for (Rectangle c : this.children) {
      if (c.isOver(lvl + 1)) {
        return c.whichOver(lvl + 1);
      }
    }
    return isOver(lvl) ? this : null;
  }
  
  Boolean isOver() {
    return isOver(0);
  }
  
  private Boolean isOver(int lvl) {
    float absX = getX();
    float absY = getY();
    float absW = getWidth();
    float absH = getHeight();
    float xOff = getLOff();
    float yOff = getUOff();
    float wOff = xOff + getROff();
    float hOff = yOff + getDOff();
    return mouseX >= absX + xOff && mouseX <= absX + absW - wOff &&
           mouseY >= absY + yOff && mouseY <= absY + absH - hOff;
  }
  
  void onOver() {
    this.c = getColor();
  }
  
  void onOff() {
    this.c = this.off;
  }
}