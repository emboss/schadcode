package collider;

import java.util.HashMap;
import java.util.List;
import java.util.concurrent.Callable;

/**
 * Based on the work in the context of the "SipHash" project by 
 * Jean-Philippe Aumasson and Daniel J. Bernstein.
 *
 * See https://www.131002.net/siphash/ for details.
 *
 * @author <a href="mailto:Martin.Bosslet@googlemail.com">Martin Bosslet</a>
 */
public class Collider {

    public static void main(String[] args) {
        try {
            final int blocks = Integer.parseInt(args[0]);
            final HashMap<String, Integer> map = new HashMap<>();
            
            Result<List<String>> creationResult = new TimedRunner<>(new Callable<List<String>>() {
                @Override public List<String> call() throws Exception {
                    return Collisions.find(blocks);
                }
            }).execute();
            
            System.out.println("Creating payload: " + (creationResult.executionTime / 1000.0d) + "s");
            final List<String> collisions = creationResult.result;
                    
            Result<Void> collisionResult = new TimedRunner<>(new Callable<Void>() {
                @Override public Void call() throws Exception {
                    int counter = 0;
                    for (String s : collisions) {
                        map.put(s, counter++);
                    }
                    return null;
                }
            }).execute();
            
            System.out.println("Collisions: 2^" + blocks + "(=" + Math.pow(2, blocks) +
                               "): " + (collisionResult.executionTime / 1000.0d) + "s");
            
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }
    
    private static class TimedRunner<V> {
        private final Callable<V> callable;

        public TimedRunner(Callable<V> callable) {
            this.callable = callable;
        }
        
        public Result<V> execute() {
            try {
                long start = System.currentTimeMillis();
                V value = callable.call();
                long end = System.currentTimeMillis();
                return new Result<V>(value, end - start);
            } catch (Exception ex) {
                throw new RuntimeException(ex);
            }
        }
    }
    
    private static class Result<V> {
        private final V result;
        private final long executionTime;

        public Result(V result, long executionTime) {
            this.result = result;
            this.executionTime = executionTime;
        }
    }
}
