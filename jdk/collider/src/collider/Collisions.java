package collider;


import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Based on the work in the context of the "SipHash" project by 
 * Jean-Philippe Aumasson and Daniel J. Bernstein.
 *
 * See https://www.131002.net/siphash/ for details.
 *
 * @author <a href="mailto:Martin.Bosslet@googlemail.com">Martin Bosslet</a>
 */
public class Collisions {
    private static final int INV_MAGIC_1 = 0x56ed309b;
    private static final int INV_MAGIC_2 = 0xdee13bb1;
    private static final char[] DIFF = bytesOf(0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x80);

    private static char[] bytesOf(Integer... bytes) {
        char[] ret = new char[bytes.length / 2];
        for (int i = 0; i < ret.length; i++) {
            ret[i] = (char) ( (bytes[2 * i] & 0x00ff) | ((bytes[2 * i + 1] & 0x00ff) << 8) );
        }
        return ret;
    }
    
    public static List<String> find(int blocks) {
        int numCollisions = 1 << blocks;
        List<String> ret = new ArrayList<>(numCollisions);
        
        try {
            Inputs inputs = findInputs(blocks);

            char[] in0 = inputs.in0;
            char[] in1 = inputs.in1;
        
            for (int i = 0; i < numCollisions; i++) {
                char[] collision = new char[4 * blocks];
                int off = 0;
                
                for (int j = 0; j < blocks; j++) {
                    char[] src = (i & (1 << j)) == 0 ? in0 : in1;
                    char[] tmp = slice(src, j * 4, 4);
                    for (int k = 0; k < 4; k ++) {
                        collision[off++] = tmp[k];
                    }
                }
                
                ret.add(new String(collision));
            }
            return ret;
        } catch (IOException ex) {
            throw new RuntimeException(ex);
        }
    }
    
    private static Inputs findInputs(int blocks) throws IOException {
        char[] in0 = new char[4 * blocks];
        char[] in1 = new char[4 * blocks];
        
        fillRandomly(in0);
        
        for (int i = 0; i < in0.length; i++) {
            in1[i] = (char)(in0[i] ^ DIFF[i % 4]);
        }
    
        in0 = invert(in0, blocks);
        in1 = invert(in1, blocks);
        
        return new Inputs(in0, in1);
    }
    
    private static char[] invert(char[] src, int blocks) throws IOException {
        char[] inverted = new char[src.length];
        int off = 0;
        
        for (int i = 0; i < blocks; i++) {
            for (int j = 0; j < 2; j++) {
                char[] tmp = invert32(binToInt(slice(src, (2 * i + j) * 2, 2)));
                for (int k = 0; k < 2; k++) {
                    inverted[off++] = tmp[k];
                }
            }
        }
        
        return inverted;
    }
    
    private static char[] invert32(int n) {
        n *= INV_MAGIC_1;
        n = (n >>> 15) | (n << 17);
        n *= INV_MAGIC_2;
        return intToBin(n);
    }
    
    private static void fillRandomly(char[] b) {
        Random prng = new Random();
        int off = 0;
        while(off != b.length) {
            int rnd = prng.nextInt();
            char[] tmp = intToBin(rnd);
            b[off++] = tmp[0];
            b[off++] = tmp[1];
        }
    }
    
    private static char[] slice(char[] src, int begin, int len) {
        char[] ret = new char[len];
        for (int i = 0; i < len; i++) {
            ret[i] = src[begin + i];
        }
        return ret;
    }
    
    private static int binToInt(char[] b) {
        return (b[0] & 0xffff) | b[1] << 16;
    }
    
    private static char[] intToBin(int n) {
        char[] b = new char[2];
        b[0] = (char) n;
        b[1] = (char) (n >>> 16);
        return b;
    }
    
    private static class Inputs {
        private final char[] in0;
        private final char[] in1;

        public Inputs(char[] in0, char[] in1) {
            this.in0 = in0;
            this.in1 = in1;
        }
    }
}
