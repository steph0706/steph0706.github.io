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
    return min(sAbsWid, sAbsHgt);
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