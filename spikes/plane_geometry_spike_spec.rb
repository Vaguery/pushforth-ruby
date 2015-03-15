require 'rspec'


class Point
  attr_reader :x,:y

  def initialize(x,y)
    @x,@y = x.to_f,y.to_f
  end

  def lies_on?(line)
    x1,y1 = @x,@y
    x2,y2 = line.x1,line.y1
    x3,y3 = line.x2,line.y2
    
    return x1 * (y2-y3) + x2 * (y3-y1) + x3 * (y1-y2) == 0.0
  end
end


class Line
  attr_reader :basis1,:basis2
  attr_reader :x1,:y1,:x2,:y2

  def initialize(pt1,pt2)
    @basis1,@basis2 = pt1,pt2
    @x1,@y1 = pt1.x,pt1.y
    @x2,@y2 = pt2.x,pt2.y
  end

  def slope
    vertical? ? nil : (@y1-@y2)/(@x1-@x2)
  end

  def intercept
    vertical? ? nil : (@x1*@y2-@x2*@y1)/(@x1-@x2)
  end

  def vertical?
    @x1 == @x2
  end

  def intersects?(line)
    x1,y1 = self.x1,self.y1
    x2,y2 = self.x2,self.y2
    x3,y3 = line.x1,line.y1
    x4,y4 = line.x2,line.y2

    return (x1-x2) * (y3-y4) - (y1-y2) * (x3-x4) != 0.0
  end

  def intersection(line)
    x1,y1 = self.x1,self.y1
    x2,y2 = self.x2,self.y2
    x3,y3 = line.x1,line.y1
    x4,y4 = line.x2,line.y2

    d = (x1-x2) * (y3-y4) - (y1-y2) * (x3-x4)
    return nil if d == 0.0
    n1 = (x1*y2 - y1*x2) * (x3-x4) - (x1-x2) * (x3*y4 - y3*x4)
    n2 = (x1*y2 - y1*x2) * (y3-y4) - (y1-y2) * (x3*y4 - y3*x4)
    return Point.new(n1/d,n2/d)
  end
end


describe "Line" do
  describe "Line.through" do
    it "should take two points as args" do
      p1 = Point.new(0.0,0.0)
      p2 = Point.new(2.0,3.0)
      l1 = Line.new(p1,p2)
      expect(l1.slope).to eq 1.5
      expect(l1.intercept).to eq 0
    end

    it "should be comfortable with vertical lines" do
      p1 = Point.new(2.0,1.0)
      p2 = Point.new(2.0,3.0)
      l1 = Line.new(p1,p2)
      expect(l1.vertical?).to be true 
    end
  end

  describe "Line intersection with (line)" do
    it "should return a Point" do
      p1 = Point.new(0.0,0.0)
      p2 = Point.new(2.0,3.0)
      l1 = Line.new(p1,p2)
      p3 = Point.new(1.0,9.0)
      p4 = Point.new(9.0,1.0)
      l2 = Line.new(p3,p4)
      i = l1.intersection(l2)
      expect(i.x).to eq 4.0
      expect(i.y).to eq 6.0
    end

    it "should return nil if they don't intersect" do
      p1 = Point.new(0.0,0.0)
      p2 = Point.new(2.0,3.0)
      l1 = Line.new(p1,p2)
      p3 = Point.new(1.0,0.0)
      p4 = Point.new(3.0,3.0)
      l2 = Line.new(p3,p4)
      expect(l1.intersection(l2)).to be nil

      p1 = Point.new(3.0,0.0)
      p2 = Point.new(3.0,3.0)
      l1 = Line.new(p1,p2)
      p3 = Point.new(6.0,0.0)
      p4 = Point.new(6.0,7.0)
      l2 = Line.new(p3,p4)
      expect(l1.intersection(l2)).to be nil
    end
  end

  describe "intersects?" do
    it "should return a boolean to check" do
      p1 = Point.new(0.0,0.0)
      p2 = Point.new(2.0,3.0)
      l1 = Line.new(p1,p2)
      p3 = Point.new(1.0,0.0)
      p4 = Point.new(3.0,3.0)
      l2 = Line.new(p3,p4)
      expect(l1.intersects?(l2)).to be false
    end
  end
end

describe "Point" do
  describe "initialization" do
    it "should cast the numbers to Floats" do
      expect(Point.new(1,2).x).to be 1.0
      expect(Point.new(1,2).y).not_to be 2
    end
  end

  describe "lies_on?(Line)" do
    it "should return a boolean to check" do
      p1 = Point.new(0.0,0.0)
      p2 = Point.new(2.0,3.0)
      p3 = Point.new(19.0,3.0)
      l1 = Line.new(p1,p2)
      expect(p1.lies_on?(l1)).to be true
      expect(p3.lies_on?(l1)).to be false
    end
  end
end

## exercising them
setup = [ [1,1],[1,2],[1,3],[2,1],[2,2],[2,3],[3,3],[3,2],[3,1]]
points = setup.collect {|p| Point.new(*p)}

l1 = Line.new(points[6],points[8])
l2 = Line.new(points[3],points[1])
l3 = Line.new(points[0],points[6])
l4 = Line.new(points[6],points[2])

lines = [l1,l2,l3,l4]

hits = points.collect do |pt|
  lines.collect do |line|
    pt.lies_on?(line)
  end
end

points_are_covered = hits.collect do |line_row| 
  line_row.inject(false) do |any,this| 
    any || this
  end
end

line_intersections = lines.collect do |l1| 
  lines.collect do |l2| 
    l1.intersects?(l2) ? 1 : 0
  end
end

puts "\n positive example (9 points, 4 lines)"
puts "which points lie on any line at all: #{points_are_covered}"
puts "which lines intersect one another: #{line_intersections}"

## negative example:

lines = [l1,l2,l3]

hits = points.collect do |pt|
  lines.collect do |line|
    pt.lies_on?(line)
  end
end

points_are_covered = hits.collect do |line_row| 
  line_row.inject(false) do |any,this| 
    any || this
  end
end

line_intersections = lines.collect do |l1| 
  lines.collect do |l2| 
    l1.intersects?(l2) ? 1 : 0
  end
end

puts "\n negative example (9 points, 3 lines)"
puts "which points lie on any line at all: #{points_are_covered}"
puts "which lines intersect one another: #{line_intersections}"

