module Collisions
  
  INV_MAGIC = 0xe59b19bd
  R = 24
  MASK32 = 0xffffffff
  DIFF = "\x00\x00\x00\x80\x00\x00\x00\x80"

  module_function

  def find(blocks)
    num_collisions = 1 << blocks
    in0 = Random.new.bytes(8 * blocks)
    in1 = "".tap do |s|
      in0.each_byte.each_with_index do |b, i|
        s << (in0[i].ord ^ DIFF[i % 8].ord)
      end
    end

    in0 = invert(in0, blocks)
    in1 = invert(in1, blocks) 

    num_collisions.times do |i|
      collision = ""
      blocks.times do |j|
        src = i & (1 << j) == 0 ? in0 : in1
        collision << src.slice(j * 8, 8)
      end
      puts "Murmur2 (#{collision.unpack("H*")[0]}) = #{collision.hash}"
    end
  end

  private; module_function
        
  def invert(s, blocks)
    "".tap do |r|
      blocks.times do |i|
        2.times { |j| r << invert32(s.slice((2 * i + j) * 4, 4).unpack("L<")[0]) }
      end
    end
  end

  def invert32(v)
    y = v
    y = (y * INV_MAGIC) & MASK32
    y ^= y >> R
    y = (y * INV_MAGIC) & MASK32
    [y].pack("L<")
  end

end

Collisions.find(4)

