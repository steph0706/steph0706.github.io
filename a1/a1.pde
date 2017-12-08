import java.util.Collections;

TreeNode root;
Rectangle canvas;
color ON = color(65, 105, 225);
color OFF = color(255, 255, 255);
float currWid, currHgt;

void setup() {
  size(1024, 768);
  //size(500, 300);
  background(color(255, 255, 255));
  surface.setResizable(true);
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
  int numLeaves = Integer.valueOf(lines[0]);
  HashMap<Integer, TreeNode> nodes = new HashMap<Integer, TreeNode>();
  
  for (int i = 1; i <= numLeaves; i++) {
    String[] currLine = lines[i].split(" ");
    int id = Integer.valueOf(currLine[0]);
    float wgt = Float.valueOf(currLine[1]);
    nodes.put(id, new TreeNode(id, wgt));
  }
  
  int numEdges = Integer.valueOf(lines[numLeaves + 1]);
  for (int i = numLeaves + 2; i < numLeaves + 2 + numEdges; i++) {
    String[] currLine = lines[i].split(" ");
    int parentId = Integer.valueOf(currLine[0]);
    int childId = Integer.valueOf(currLine[1]);
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
  }
  //Collections.sort(node.children);
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
    max = max(max, wgt);
    min = min(min, wgt);
    sum += wgt;
  }
  
  return max((w * w * max) / (sum * sum), (sum * sum) / (w * w * min));
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