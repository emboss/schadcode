module Collisions
  
  INV_MAGIC_1 = 0xa81e14edd9de2c7f
  INV_MAGIC_2 = 0xa98409e882ce4d7d
  MASK64 = 0xffffffffffffffff
  DIFF = "\x00\x00\x00\x00\x10\x00\x00\x00" \
         "\x00\x00\x00\x00\x01\x00\x00\x00" \
         "\x00\x00\x00\x00\x00\x00\x00\x80" \
         "\x00\x00\x00\x00\x00\x00\x00\x00"

  module_function

  def find(blocks)
    num_collisions = 1 << blocks
    in0 = Random.new.bytes(32 * blocks)
    in1 = "".tap do |s|
      in0.each_byte.each_with_index do |b, i|
        s << (in0[i].ord ^ DIFF[i % 32].ord)
      end
    end

    in0 = invert(in0, blocks)
    in1 = invert(in1, blocks) 
    
    num_collisions.times do |i|
      collision = ""
      blocks.times do |j|
        src = i & (1 << j) == 0 ? in0 : in1
        collision << src.slice(j * 32, 32)
      end
      puts "Murmur3_x64_128 (#{i}) = #{collision.hash}"
    end
  end

  private; module_function
        
  def invert(s, blocks)
    "".tap do |r|
      blocks.times do |i|
        4.times do |j|
          f = (j % 2) == 0 ? :invert64a : :invert64b
          r << send(f, s.slice((4 * i + j) * 8, 8).unpack("Q<")[0])
        end
      end
    end
  end

  def invert64a(n)
    x = (n * INV_MAGIC_1) & MASK64
    x = (x >> 31) | ((x << 33) & MASK64)
    [((x * INV_MAGIC_2) & MASK64)].pack("Q<")
  end

  def invert64b(n)
    x = (n * INV_MAGIC_2) & MASK64
    x = (x >> 33) | ((x << 31) & MASK64)
    [((x * INV_MAGIC_1) & MASK64)].pack("Q<")
  end

end

Collisions.find(4)

