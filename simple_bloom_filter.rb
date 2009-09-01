# A simple Bloom Filter using pure Ruby.

# References & Inspirations: 
#  http://en.wikipedia.org/wiki/Bloom_filter
#  http://github.com/igrigorik/bloomfilter/tree/master
#  http://blog.rapleaf.com/dev/?p=6

require 'Zlib'

class SimpleBloomFilter
  attr_reader :n, :p, :m, :k, :b, :bit_fields
  
  # n: number of total elements
  # p: false positive probability
  # b: number of bits per bit-field
  # m: number of bits (estimate)
  # k: optimal number of hash (estimate)
  def initialize( n, p=0.01, b=8 )
    @n, @p, @b = n, p, b
    @m = ( - ( @n * Math.log(@p) / (Math.log(2)**2) ) ).ceil
    @k = (0.7 * (@m/@n)).round
    @bit_fields = "\0" * (@m/@b + 1)
  end
  
  def add( string )
    k.times do |i|
      index = crc32(string, i) % m
      set_field(index)
    end
  end
  
  
  def include?( string )
    k.times do |i|
      index = crc32(string, i) % m
      return false unless get_field(index)
    end
    true
  end
  
  private
  
    def set_field( position )
      @bit_fields[position / @b] |= (1 << (position % @b))
    end
    
    def get_field( position )
      @bit_fields[position / @b] & (1 << (position % @b)) > 0
    end
    
    def crc32(string, index=0)
      Zlib.crc32(string, index)
    end
end
