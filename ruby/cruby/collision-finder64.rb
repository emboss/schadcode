module Collisions
  
  INV_MAGIC = 0x5f7a0ea7e59b19bd
  R = 16
  MASK64 = 0xffffffffffffffff
  DIFF = "\x00\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00\x00\x80"
 
  module_function

  def find(blocks)
    num_collisions = 1 << blocks
    in0 = Random.new.bytes(16 * blocks)
    in1 = "".tap do |s|
      in0.each_byte.each_with_index do |b, i|
        s << (in0[i].ord ^ DIFF[i % 16].ord)
      end
    end

    #p in0.unpack("H*")[0]
    #p in1.unpack("H*")[0]

    in0 = invert(in0, blocks)
    in1 = invert(in1, blocks) 

    #p in0.unpack("H*")[0]
    #p in1.unpack("H*")[0]

    num_collisions.times do |i|
      collision = ""
      blocks.times do |j|
        #puts "i: #{i} j: #{j} i & 1 << j: #{i & (1 << j)}"
        src = i & (1 << j) == 0 ? in0 : in1
        collision << src.slice(j * 16, 16)
      end
      puts "Murmur2 (#{collision.unpack("H*")[0]}) = #{collision.hash}"
    end
  end

  def invert(s, blocks)
    "".tap do |r|
      blocks.times do |i|
        2.times { |j| r << invert64(s.slice((2 * i + j) * 8, 8).unpack("Q<")[0]) }
      end
    end
  end

  def invert64(n)
    x = (n * INV_MAGIC) & MASK64
    t = x >> R
    u = (x ^ t) >> R
    v = (x ^ u) >> R
    x = x ^ v
    x = (x * INV_MAGIC) & MASK64
    [x].pack("Q<")
  end
end

Collisions.find(4)

