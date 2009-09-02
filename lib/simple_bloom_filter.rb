# A simple Bloom Filter using pure Ruby.

# References & Inspirations: 
#  http://en.wikipedia.org/wiki/Bloom_filter
#  http://github.com/igrigorik/bloomfilter/tree/master
#  http://blog.rapleaf.com/dev/?p=6

require 'zlib'

class SimpleBloomFilter
  attr_reader :n, :p, :m, :k, :b, :bit_fields
  
  
  # n: number of total elements
  # p: false positive probability
  # b: number of bits per bit-field
  # m: number of bits (estimate)
  # k: optimal number of hash (estimate)
  def initialize( n, p=0.01, b=8 )
    @n, @p, @b = n, p, b
    @m = ( -(@n * Math.log(@p) / (Math.log(2)**2)) ).ceil
    @k = (0.7 * (@m/@n)).round
    @bit_fields = "\0" * (@m/@b + 1)
  end
  
  
  def add( string )
    each_hashed_index(string) { |index| set_field(index) }
  end
  
  
  def include?( string )
    each_hashed_index(string) { |index| return false unless get_field(index) }
    true
  end
  
  
  
  private
    
    def each_hashed_index( string )
      @k.times do |i|
        index = Zlib.crc32("#{string}-#{i}", i) % @m
        yield index
      end
    end
    
    
    def set_field( bit_position )
      @bit_fields[bit_position / @b] |= (1 << (bit_position % @b))
    end
    
    
    def get_field( bit_position )
      @bit_fields[bit_position / @b] & (1 << (bit_position % @b)) > 0
    end
end
