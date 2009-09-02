require 'simple_bloom_filter'

# Warning these specs are extremely slow!
describe 'US Zip Code Pattern' do
  before :all do 
    @all_zips = ('00000'..'99999').to_a
  end
  
  shared_examples_for 'progressive saturation' do
    (1..9).map{|i| i / 10.0}.each do |saturation|
      it "should give false postives within 1% for #{(saturation*100).to_i}% of randomized zip codes" do
        added =  @zips[0...(@zips.size * saturation).round]
        bf = SimpleBloomFilter.new(added.size, 0.01, 8)
        added.each{|zip| bf.add(zip) }
        added.each do |zip|
          bf.should include(zip)
        end

        not_added = @zips - added
        false_positive = 0 
        not_added.each do |zip|
          false_positive +=1 if bf.include?(zip)
        end

        false_positive_rate = false_positive / not_added.size.to_f
        puts "\n#{(saturation*100).to_i}% added, false Positive expected 1.1% got #{false_positive_rate*100}%" 
        false_positive_rate.should <= 0.011  # with 0.01 tolerance 
      end    
    end
  end
  
  context 'sorted zips' do
    before :all do
      @zips = @all_zips
    end
    it_should_behave_like 'progressive saturation'
  end
  
  context 'randomized zips' do
    before :all do
      @zips = @all_zips.sort_by{rand}
    end
    
    it_should_behave_like 'progressive saturation'
  end
  
  
end