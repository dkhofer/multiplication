require "./large_integer"

module Multiplication
  class Test
    def self.test_multiply(x1, x2, expected_product)
      integer1 = Multiplication::LargeInteger.new(x1)
      integer2 = Multiplication::LargeInteger.new(x2)
      expect(integer1.fft_multiply(integer2)).to eq expected_product
    end

    def self.random_integer(length = 1000)
      (1..length).to_a.map { (0..9).to_a.sample }.map { |x| x.to_s }.join.to_i
    end

    def self.run_test
      x1 = random_integer(1_000_000)
      x2 = random_integer(1_000_000)
      start1 = Time.now
      result = x1 * x2
      end1 = Time.now

      puts "Time for crystal multiplication: #{end1 - start1}"

      start2 = Time.now
      test_multiply(x1, x2, result)
      end2 = Time.now

      puts "Time for FFT multiplication: #{end2 - start2}"
    end
  end
end

Multiplication::Test.run_test